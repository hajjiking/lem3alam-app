import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/dispute_draft.dart';

abstract interface class DisputesRepository {
  Future<void> submit(DisputeDraft draft);
  Future<DisputesPage> list({int page = 1});
  Future<void> act(int id, String action, String message, int version);
}

final disputesRepositoryProvider =
    Provider<DisputesRepository>((ref) => ApiDisputesRepository(
          api: ref.watch(apiClientProvider),
          auth: () => ref.read(authControllerProvider),
          expireSession: () =>
              ref.read(authControllerProvider.notifier).expireSession(),
        ));

final disputesPageProvider =
    FutureProvider.autoDispose.family<DisputesPage, int>((ref, page) {
  ref.watch(authControllerProvider
      .select((s) => (s.status, s.user?.id, s.user?.role)));
  return ref.watch(disputesRepositoryProvider).list(page: page);
}, retry: (_, __) => null);

class DisputeRecord {
  DisputeRecord.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as num).toInt(),
        taskId = (json['task_id'] as num).toInt(),
        subject = json['subject'] as String,
        description = json['description'] as String,
        status = json['status'] as String,
        additionalInfo = json['additional_info'] as String? ?? '',
        workflowState =
            json['workflow_state'] as String? ?? 'awaiting_response',
        version = (json['workflow_version'] as num?)?.toInt() ?? 0,
        allowedActions =
            (json['allowed_actions'] as List? ?? []).cast<String>(),
        history = (json['workflow_history'] as List? ?? [])
            .cast<Map<String, dynamic>>(),
        resolution = json['resolution'] as String? ?? '';
  final String workflowState, resolution;
  final int version;
  final List<String> allowedActions;
  final List<Map<String, dynamic>> history;
  final int id, taskId;
  final String subject, description, status, additionalInfo;
}

class DisputesPage {
  const DisputesPage(
      {required this.items, required this.page, required this.lastPage});
  final List<DisputeRecord> items;
  final int page, lastPage;
}

class ApiDisputesRepository implements DisputesRepository {
  ApiDisputesRepository(
      {required this.api, required this.auth, required this.expireSession});
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expireSession;

  int _userId() {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        !(state.user?.isClient == true ||
            state.user?.isTasker == true ||
            state.user?.isAdmin == true)) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  Future<Map<String, dynamic>> _request(
      Future<Map<String, dynamic>> Function() send) async {
    final id = _userId();
    try {
      final response = await send();
      if (_userId() != id) {
        throw const ApiException(message: 'err_unauthorized');
      }
      if (response['success'] != true ||
          response['data'] is! Map<String, dynamic>) {
        throw const ApiException(message: 'err_unknown');
      }
      return response['data'] as Map<String, dynamic>;
    } on ApiException catch (error) {
      if (error.statusCode == 401 && auth().user?.id == id) {
        await expireSession();
      }
      rethrow;
    }
  }

  @override
  Future<void> submit(DisputeDraft draft) async {
    if (!draft.isValid ||
        draft.evidenceFiles.length > DisputeLimits.maxFiles ||
        draft.evidenceFiles.any((file) =>
            file.bytes.length > DisputeLimits.maxBytes ||
            !['jpg', 'jpeg', 'png', 'pdf']
                .contains(file.fileName.split('.').last.toLowerCase()))) {
      throw const ApiException(message: 'err_unknown');
    }
    final payload = FormData.fromMap({
      'task_id': draft.taskId,
      'respondent_id': draft.againstUserId,
      'type': switch (draft.disputeType!) {
        DisputeType.paymentIssue => 'payment',
        DisputeType.qualityOfWork => 'quality',
        DisputeType.noShow => 'no_show',
        DisputeType.communicationIssue => 'communication',
        DisputeType.other => 'other',
      },
      'subject': draft.subject.trim(),
      'description': draft.description.trim(),
      'additional_info': draft.additionalInfo.trim(),
    });
    for (final file in draft.evidenceFiles) {
      payload.files.add(MapEntry('evidence[]',
          MultipartFile.fromBytes(file.bytes, filename: file.fileName)));
    }
    // Await a persisted record, not merely an HTTP response, before clearing the draft.
    final result = await _request(
        () => api.postJson<Map<String, dynamic>>('disputes', data: payload));
    if ((int.tryParse('${result['id']}') ?? 0) <= 0 ||
        int.tryParse('${result['task_id']}') != draft.taskId ||
        int.tryParse('${result['respondent_id']}') != draft.againstUserId) {
      throw const ApiException(message: 'err_unknown');
    }
  }

  @override
  Future<void> act(int id, String action, String message, int version) async {
    await _request(() => api.postJson<Map<String, dynamic>>(
        'disputes/$id/actions',
        data: {'action': action, 'message': message, 'version': version}));
  }

  @override
  Future<DisputesPage> list({int page = 1}) async {
    final result = await _request(() => api.getJson<Map<String, dynamic>>(
        'disputes',
        queryParameters: {'page': page, 'per_page': 15}));
    try {
      return DisputesPage(
          items: (result['data'] as List)
              .map((item) =>
                  DisputeRecord.fromJson(item as Map<String, dynamic>))
              .toList(growable: false),
          page: (result['current_page'] as num).toInt(),
          lastPage: (result['last_page'] as num).toInt());
    } catch (_) {
      throw const ApiException(message: 'err_unknown');
    }
  }
}
