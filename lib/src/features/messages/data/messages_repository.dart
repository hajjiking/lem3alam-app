import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/conversation_model.dart';

final messagesRepositoryProvider = Provider((ref) => MessagesRepository(
    ref.watch(apiClientProvider),
    () => ref.read(authControllerProvider),
    () => ref.read(authControllerProvider.notifier).expireSession()));

class MessagesRepository {
  MessagesRepository(this.api, this.auth, this.expire);
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expire;
  int get owner {
    final s = auth();
    if (s.status != AuthStatus.authenticated ||
        !(s.user?.isClient == true || s.user?.isTasker == true)) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return s.user!.id;
  }

  Future<Map<String, dynamic>> _request(
      int id, Future<Map<String, dynamic>> Function() send) async {
    try {
      final result = await send();
      if (owner != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      if (result['success'] != true ||
          result['data'] is! Map<String, dynamic>) {
        throw const ApiException(message: 'err_unknown');
      }
      return result['data'] as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 401 && auth().user?.id == id) await expire();
      rethrow;
    }
  }

  Future<List<ConversationModel>> conversations() async {
    final id = owner;
    final items = <String, ConversationModel>{};
    for (var page = 1;; page++) {
      if (owner != id) {
        throw const ApiException(statusCode: 403, message: 'err_forbidden');
      }
      final data = await _request(
          id,
          () => api.getJson<Map<String, dynamic>>('conversations',
              queryParameters: {'page': page, 'per_page': 50}));
      final result =
          Paginated.fromLaravel(data, itemFromJson: ConversationModel.fromJson);
      if (data['data'] is! List || result.currentPage != page) {
        throw const ApiException(message: 'err_unknown');
      }
      for (final item in result.items) {
        items[item.id] = item;
      }
      if (!result.hasNextPage) break;
    }
    return items.values.toList();
  }

  Future<Paginated<ChatMessageModel>> thread(ChatKey key,
      {int page = 1, int? beforeId}) async {
    final id = owner;
    final data = await _request(
        id,
        () => api.getJson<Map<String, dynamic>>(
                'conversations/${key.contactId}',
                queryParameters: {
                  'task_id': key.taskId ?? 0,
                  'page': page,
                  if (beforeId != null) 'before_id': beforeId,
                  'per_page': 30
                }));
    final result = Paginated.fromLaravel(data,
        itemFromJson: (json) => _message(json, id, key));
    if (data['data'] is! List || result.currentPage != page) {
      throw const ApiException(message: 'err_unknown');
    }
    if (beforeId != null && result.items.any((m) => m.id >= beforeId)) {
      throw const ApiException(message: 'err_unknown');
    }
    return result;
  }

  Future<ConversationModel> details(ChatKey key) async {
    final id = owner;
    final data = await _request(
        id,
        () => api.getJson<Map<String, dynamic>>(
            'conversations/${key.contactId}/details',
            queryParameters: {'task_id': key.taskId ?? 0}));
    final result = ConversationModel.fromJson(data);
    if (result.key != key) throw const ApiException(message: 'err_unknown');
    return result;
  }

  ChatMessageModel _message(Map<String, dynamic> json, int id, ChatKey key) {
    final m = ChatMessageModel.fromJson(json, id);
    if (m.taskId != key.taskId ||
        !((m.senderId == id && m.receiverId == key.contactId) ||
            (m.receiverId == id && m.senderId == key.contactId))) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return m;
  }

  Future<ChatMessageModel> send(ChatKey key, String text) async {
    final id = owner;
    if (text.trim().isEmpty || text.trim().runes.length > 5000) {
      throw const ApiException(statusCode: 422, message: 'err_unknown');
    }
    final data = await _request(
        id,
        () => api.postJson<Map<String, dynamic>>('messages', data: {
              'receiver_id': key.contactId,
              'task_id': key.taskId,
              'content': text.trim(),
            }));
    return _message(data, id, key);
  }

  Future<void> read(ChatKey key, int throughId) async {
    final id = owner;
    await _request(
        id,
        () => api.putJson<Map<String, dynamic>>(
                'conversations/${key.contactId}/read',
                data: {
                  'task_id': key.taskId ?? 0,
                  'through_id': throughId,
                }));
  }
}

// This is a device-local view preference, not server moderation or deletion.
final chatArchiveStoreProvider = Provider((ref) => ChatArchiveStore());

class ChatArchiveStore {
  Future<Set<String>> load(int userId) async =>
      (await SharedPreferences.getInstance())
          .getStringList('chat_archives_$userId')
          ?.toSet() ??
      {};
  Future<void> save(int userId, Set<String> ids) async {
    final ok = await (await SharedPreferences.getInstance())
        .setStringList('chat_archives_$userId', ids.toList());
    if (!ok) throw StateError('Unable to save archive preference');
  }
}
