import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../../auth/domain/user.dart';
import '../domain/nearby_task_feed.dart';
import '../domain/task.dart';
import '../domain/tasks_repository.dart';
import 'tasks_api.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(
    api: TasksApi(ref.watch(apiClientProvider)),
    readAuthState: () => ref.read(authControllerProvider),
    expireSession: () =>
        ref.read(authControllerProvider.notifier).expireSession(),
  );
});

class TasksRepositoryImpl implements TasksRepository {
  TasksRepositoryImpl({
    required this.api,
    required this.readAuthState,
    required this.expireSession,
  });

  final TasksApi api;
  final AuthState Function() readAuthState;
  final Future<void> Function() expireSession;

  Future<T> _withAuthRecovery<T>(Future<T> Function() request) async {
    final requestUser = readAuthState().user;
    try {
      return await request();
    } on ApiException catch (e) {
      // #region debug-point B:task-request-error
      (() {
        try {
          final auth = readAuthState();
          final client = HttpClient();
          client
              .postUrl(Uri.parse('http://127.0.0.1:7778/event'))
              .then((req) {
                req.headers.contentType = ContentType.json;
                req.write(jsonEncode({
                  'sessionId': 'tasker-tasks-crash',
                  'runId': 'pre-fix',
                  'hypothesisId': 'B',
                  'location': 'tasks_repository_impl.dart:31',
                  'msg': '[DEBUG] task request failed',
                  'data': {
                    'statusCode': e.statusCode,
                    'message': e.message,
                    'authStatus': auth.status.name,
                    'role': auth.user?.role
                  },
                  'ts': DateTime.now().millisecondsSinceEpoch
                }));
                return req.close();
              })
              .then((res) => res.drain<void>())
              .whenComplete(client.close)
              .catchError((_) {});
        } catch (_) {}
      })();
      // #endregion
      final currentUser = readAuthState().user;
      if (e.statusCode == 401 &&
          currentUser?.id == requestUser?.id &&
          currentUser?.role == requestUser?.role) {
        await expireSession();
      }
      rethrow;
    }
  }

  void _ensureAuthenticated() {
    if (readAuthState().status != AuthStatus.authenticated) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  void _ensureClient() {
    final user = readAuthState().user;
    if (user == null || !user.isClient) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  void _ensureTasker() {
    final user = readAuthState().user;
    if (user == null || !user.isTasker) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  @override
  Future<void> apply(
      {required int taskId, required TaskApplicationPayload payload}) async {
    _ensureTasker();
    await _withAuthRecovery(() => api.apply(taskId, payload.toJson()));
  }

  @override
  Future<void> dismissNearbyTask(int taskId) async {
    _ensureTasker();
    await _withAuthRecovery(() => api.dismissNearby(taskId));
  }

  @override
  Future<List<CategoryOption>> categories({required int perPage}) async {
    final json =
        await _withAuthRecovery(() => api.categories(perPage: perPage));
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final page = Paginated.fromLaravel<CategoryOption>(
        data,
        itemFromJson: CategoryOption.fromJson,
      );
      return page.items;
    }
    return const [];
  }

  @override
  Future<Task> create(TaskPayload payload,
      {List<TaskImageAttachment>? images}) async {
    _ensureClient();
    final payloadJson = payload.toJson();
    final Object requestData;
    if (images != null && images.isNotEmpty) {
      requestData = FormData.fromMap({
        ...payloadJson,
        'is_remote': payload.isRemote ? 1 : 0,
        'images[]': images
            .map((i) => MultipartFile.fromBytes(i.bytes, filename: i.filename))
            .toList(growable: false),
      });
    } else {
      requestData = payloadJson;
    }

    final json = await _withAuthRecovery(() => api.create(requestData));
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return Task.fromJson(data);
  }

  @override
  Future<void> delete(int id) async {
    _ensureClient();
    await _withAuthRecovery(() => api.delete(id));
  }

  @override
  Future<Task> getById(int id) async {
    _ensureAuthenticated();
    final user = readAuthState().user!;
    final json = await _withAuthRecovery(() => api.show(id));
    _ensureSameAccount(user);
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    final task = Task.fromJson(data);
    _ensureClientOwnsTasks(user, [task]);
    return task;
  }

  void _ensureSameAccount(User requestedUser) {
    final current = readAuthState();
    if (current.status != AuthStatus.authenticated ||
        current.user?.id != requestedUser.id ||
        current.user?.role != requestedUser.role) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  void _ensureClientOwnsTasks(User user, List<Task> tasks) {
    // Reject a bad/old server response instead of displaying another client's
    // tasks or silently changing the server's pagination totals.
    if (user.isClient && tasks.any((task) => task.clientId != user.id)) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  @override
  Future<NearbyTaskFeed> nearby({
    required int page,
    required int perPage,
    required int radiusKm,
    bool savedOnly = false,
  }) async {
    _ensureTasker();
    // #region debug-point C:repo-nearby-entry
    (() {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 1400),
          receiveTimeout: const Duration(milliseconds: 1800),
          sendTimeout: const Duration(milliseconds: 1400),
        ));
        const fallbackUrl = 'http://192.168.3.48:7777/event';
        const sessionId = 'nearby-tasks-load-fail';
        final auth = readAuthState();
        dio
            .post<Object?>(
              fallbackUrl,
              data: jsonEncode({
                'sessionId': sessionId,
                'runId': 'pre-fix',
                'hypothesisId': 'C',
                'location': 'tasks_repository_impl.dart:140',
                'msg':
                    '[DEBUG] TasksRepositoryImpl.nearby entry args & request payload',
                'data': {
                  'page': page,
                  'perPage': perPage,
                  'radiusKm': radiusKm,
                  'savedOnly': savedOnly,
                  'latitudeInRequest': false,
                  'longitudeInRequest': false,
                  'requestParams': {
                    'page': page,
                    'per_page': perPage,
                    'radius': radiusKm,
                    if (savedOnly) 'saved_only': 1,
                  },
                  'userRole': auth.user?.role,
                  'authStatus': auth.status.name,
                },
              }),
              options: Options(headers: {'Content-Type': 'application/json'}),
            )
            .then<void>((Response<Object?> _) {})
            .catchError((Object _) {});
      } catch (_) {}
    })();
    // #endregion
    final json = await _withAuthRecovery(
      () => api.nearby(
        page: page,
        perPage: perPage,
        radiusKm: radiusKm,
        savedOnly: savedOnly,
      ),
    );
    // #region debug-point B+D:repo-nearby-response
    (() {
      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(milliseconds: 1400),
          receiveTimeout: const Duration(milliseconds: 1800),
          sendTimeout: const Duration(milliseconds: 1400),
        ));
        const fallbackUrl = 'http://192.168.3.48:7777/event';
        const sessionId = 'nearby-tasks-load-fail';
        final data = json['data'];
        final meta = json['meta'];
        dio
            .post<Object?>(
              fallbackUrl,
              data: jsonEncode({
                'sessionId': sessionId,
                'runId': 'pre-fix',
                'hypothesisId': 'D',
                'location': 'tasks_repository_impl.dart:175',
                'msg': '[DEBUG] API nearby raw response keys & shape',
                'data': {
                  'success': json['success'],
                  'topLevelKeys': json.keys.toList(),
                  'dataType': data.runtimeType.toString(),
                  'dataTopKeys': (data is Map<String, dynamic>)
                      ? data.keys.toList()
                      : null,
                  'dataListLen':
                      (data is Map<String, dynamic> && data['data'] is List)
                          ? (data['data'] as List).length
                          : null,
                  'dataPaginationKeys': (data is Map<String, dynamic>)
                      ? [
                          'current_page',
                          'last_page',
                          'per_page',
                          'total',
                        ].fold<Map<String, Object?>>({}, (acc, k) {
                          acc[k] = data[k];
                          return acc;
                        })
                      : null,
                  'metaType': meta.runtimeType.toString(),
                  'metaKeys': (meta is Map<String, dynamic>)
                      ? meta.keys.toList()
                      : null,
                  'hasSettings': (meta is Map<String, dynamic>)
                      ? meta['settings'] != null
                      : null,
                  'settingsKeys': (meta is Map<String, dynamic> &&
                          meta['settings'] is Map<String, dynamic>)
                      ? (meta['settings'] as Map<String, dynamic>).keys.toList()
                      : null,
                },
              }),
              options: Options(headers: {'Content-Type': 'application/json'}),
            )
            .then<void>((Response<Object?> _) {})
            .catchError((Object _) {});
      } catch (_) {}
    })();
    // #endregion
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};
    final settingsJson =
        (meta['settings'] as Map<String, dynamic>?) ?? const {};
    return NearbyTaskFeed(
      page: Paginated.fromLaravel<Task>(data, itemFromJson: Task.fromJson),
      settings: NearbyTaskSettings.fromJson(settingsJson),
    );
  }

  @override
  Future<Paginated<Task>> list(
      {required int page, required int perPage, int? categoryId}) async {
    final auth = readAuthState();
    final user = auth.user;
    // #region debug-point C:task-list-entry
    (() {
      try {
        final client = HttpClient();
        client
            .postUrl(Uri.parse('http://127.0.0.1:7778/event'))
            .then((req) {
              req.headers.contentType = ContentType.json;
              req.write(jsonEncode({
                'sessionId': 'tasker-tasks-crash',
                'runId': 'pre-fix',
                'hypothesisId': 'C',
                'location': 'tasks_repository_impl.dart:109',
                'msg': '[DEBUG] task list requested',
                'data': {
                  'page': page,
                  'perPage': perPage,
                  'categoryId': categoryId,
                  'authStatus': auth.status.name,
                  'role': user?.role
                },
                'ts': DateTime.now().millisecondsSinceEpoch
              }));
              return req.close();
            })
            .then((res) => res.drain<void>())
            .whenComplete(client.close)
            .catchError((_) {});
      } catch (_) {}
    })();
    // #endregion
    if (auth.status != AuthStatus.authenticated || user == null) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }

    final json = user.isClient
        ? await _withAuthRecovery(
            () => api.myTasks(
                page: page, perPage: perPage, categoryId: categoryId),
          )
        : user.isTasker
            ? await _withAuthRecovery(
                () => api.list(
                    page: page, perPage: perPage, categoryId: categoryId),
              )
            : throw const ApiException(
                statusCode: 403, message: 'err_forbidden');
    _ensureSameAccount(user);
    final data = json['data'];
    if (json['success'] != false &&
        data is Map<String, dynamic> &&
        data['data'] is List) {
      final result = Paginated.fromLaravel<Task>(
        data,
        itemFromJson: Task.fromJson,
      );
      _ensureClientOwnsTasks(user, result.items);
      return result;
    }
    throw const FormatException('Invalid task list response');
  }

  @override
  Future<void> saveNearbyTask(int taskId) async {
    _ensureTasker();
    await _withAuthRecovery(() => api.saveNearby(taskId));
  }

  @override
  Future<void> unsaveNearbyTask(int taskId) async {
    _ensureTasker();
    await _withAuthRecovery(() => api.unsaveNearby(taskId));
  }

  @override
  Future<Task> update({
    required int id,
    required TaskPayload payload,
    List<TaskImageAttachment>? images,
  }) async {
    _ensureClient();
    final payloadJson = payload.toJson();
    final Map<String, dynamic> json;
    if (images != null && images.isNotEmpty) {
      final formData = FormData.fromMap({
        ...payloadJson,
        '_method': 'PUT',
        'is_remote': payload.isRemote ? 1 : 0,
        'images[]': images
            .map((i) => MultipartFile.fromBytes(i.bytes, filename: i.filename))
            .toList(growable: false),
      });
      json = await _withAuthRecovery(() => api.updateViaPost(id, formData));
    } else {
      json = await _withAuthRecovery(() => api.update(id, payloadJson));
    }

    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return Task.fromJson(data);
  }
}
