import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/messages_repository.dart';
import '../domain/conversation_model.dart';

enum ConversationFilter { all, unread, archived }

final conversationDetailsProvider =
    FutureProvider.autoDispose.family<ConversationModel, ChatKey>((ref, key) {
  ref.watch(authControllerProvider
      .select((s) => (s.status, s.user?.id, s.user?.role)));
  return ref.watch(messagesRepositoryProvider).details(key);
}, retry: (_, __) => null);

class ConversationsState {
  const ConversationsState(this.items, this.archived,
      {this.query = '', this.filter = ConversationFilter.all, this.error});
  final List<ConversationModel> items;
  final Set<String> archived;
  final String query;
  final ConversationFilter filter;
  final Object? error;
  int get unreadCount => items.fold(0, (sum, c) => sum + c.unreadCount);
  int count(ConversationFilter f) => items
      .where((c) => switch (f) {
            ConversationFilter.all => !archived.contains(c.id),
            ConversationFilter.unread =>
              !archived.contains(c.id) && c.unreadCount > 0,
            ConversationFilter.archived => archived.contains(c.id),
          })
      .length;
  List<ConversationModel> get visible => items.where((c) {
        final matches = switch (filter) {
          ConversationFilter.all => !archived.contains(c.id),
          ConversationFilter.unread =>
            !archived.contains(c.id) && c.unreadCount > 0,
          ConversationFilter.archived => archived.contains(c.id),
        };
        return matches &&
            '${c.contactName} ${c.lastMessagePreview} ${c.relatedTask?.title ?? ''}'
                .toLowerCase()
                .contains(query.toLowerCase().trim());
      }).toList();
}

final conversationsControllerProvider =
    AsyncNotifierProvider<ConversationsController, ConversationsState>(
        ConversationsController.new,
        retry: (_, __) => null);

class ConversationsController extends AsyncNotifier<ConversationsState> {
  bool _refreshing = false;
  @override
  Future<ConversationsState> build() async {
    ref.watch(authControllerProvider
        .select((s) => (s.status, s.user?.id, s.user?.role)));
    final repo = ref.watch(messagesRepositoryProvider);
    final id = repo.owner;
    final archive = await ref.watch(chatArchiveStoreProvider).load(id);
    return ConversationsState(await repo.conversations(), archive);
  }

  bool _same(int id) =>
      ref.mounted && ref.read(authControllerProvider).user?.id == id;
  Future<void> refresh() async {
    if (_refreshing) return;
    final old = state.asData?.value;
    if (old == null) {
      ref.invalidateSelf();
      return;
    }
    final repo = ref.read(messagesRepositoryProvider);
    final id = repo.owner;
    _refreshing = true;
    try {
      final items = await repo.conversations();
      if (!_same(id)) return;
      final current = state.asData?.value ?? old;
      state = AsyncData(ConversationsState(items, current.archived,
          query: current.query, filter: current.filter));
    } catch (e) {
      if (_same(id)) {
        final current = state.asData?.value ?? old;
        state = AsyncData(ConversationsState(current.items, current.archived,
            query: current.query, filter: current.filter, error: e));
      }
    } finally {
      _refreshing = false;
    }
  }

  void search(String query) {
    final s = state.asData?.value;
    if (s != null) {
      state = AsyncData(ConversationsState(s.items, s.archived,
          query: query, filter: s.filter, error: s.error));
    }
  }

  void filter(ConversationFilter filter) {
    final s = state.asData?.value;
    if (s != null) {
      state = AsyncData(ConversationsState(s.items, s.archived,
          query: s.query, filter: filter, error: s.error));
    }
  }

  Future<void> archive(String conversationId) async {
    final s = state.asData?.value;
    if (s == null) return;
    final owner = ref.read(messagesRepositoryProvider).owner;
    final archived = {...s.archived};
    if (!archived.remove(conversationId)) archived.add(conversationId);
    await ref.read(chatArchiveStoreProvider).save(owner, archived);
    if (!_same(owner)) return;
    final current = state.asData?.value ?? s;
    state = AsyncData(ConversationsState(current.items, archived,
        query: current.query, filter: current.filter));
  }
}
