import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/messages_repository.dart';
import '../domain/conversation_model.dart';
import 'conversations_controller.dart';

class ChatThreadState {
  const ChatThreadState(this.messages,
      {this.page = 1,
      this.hasMore = false,
      this.sending = false,
      this.loadingMore = false,
      this.error});
  final List<ChatMessageModel>
      messages; // Newest first; reverse ListView keeps the composer anchored.
  final int page;
  final bool hasMore, sending, loadingMore;
  final Object? error;
  ChatThreadState copy(
          {List<ChatMessageModel>? messages,
          int? page,
          bool? hasMore,
          bool? sending,
          bool? loadingMore,
          Object? error}) =>
      ChatThreadState(messages ?? this.messages,
          page: page ?? this.page,
          hasMore: hasMore ?? this.hasMore,
          sending: sending ?? this.sending,
          loadingMore: loadingMore ?? this.loadingMore,
          error: error);
}

final chatThreadControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ChatThreadController, ChatThreadState, ChatKey>(
        ChatThreadController.new,
        retry: (_, __) => null);

class ChatThreadController extends AsyncNotifier<ChatThreadState> {
  ChatThreadController(this.key);
  final ChatKey key;
  bool _refreshing = false;
  int _readThrough = 0;
  bool _reading = false;
  @override
  Future<ChatThreadState> build() async {
    ref.watch(authControllerProvider
        .select((s) => (s.status, s.user?.id, s.user?.role)));
    _readThrough = 0;
    final page = await ref.watch(messagesRepositoryProvider).thread(key);
    return ChatThreadState(page.items, hasMore: page.hasNextPage);
  }

  bool _same(int id) =>
      ref.mounted && ref.read(authControllerProvider).user?.id == id;
  List<ChatMessageModel> _merge(
          List<ChatMessageModel> current, List<ChatMessageModel> incoming) =>
      {
        ...{for (final m in current) m.id: m},
        ...{for (final m in incoming) m.id: m}
      }.values.toList()
        ..sort((a, b) => b.id.compareTo(a.id));
  Future<void> refresh({bool older = false}) async {
    final s = state.asData?.value;
    if (s == null || _refreshing || (older && !s.hasMore)) return;
    final repo = ref.read(messagesRepositoryProvider);
    final id = repo.owner;
    _refreshing = true;
    if (older) state = AsyncData(s.copy(loadingMore: true));
    try {
      var result = await repo.thread(key,
          beforeId: older && s.messages.isNotEmpty ? s.messages.last.id : null);
      final incoming = [...result.items];
      // Bridge bursts larger than one page rather than skipping messages
      // between the last visible message and the newest polling response.
      if (!older && s.messages.isNotEmpty) {
        while (result.hasNextPage &&
            result.items.isNotEmpty &&
            result.items.last.id > s.messages.first.id) {
          if (!_same(id)) return;
          result = await repo.thread(key, beforeId: result.items.last.id);
          incoming.addAll(result.items);
        }
      }
      if (!_same(id)) return;
      final current = state.asData!.value;
      state = AsyncData(current.copy(
          messages: _merge(current.messages, incoming),
          page: older ? current.page + 1 : current.page,
          hasMore: older || s.messages.isEmpty
              ? result.hasNextPage
              : current.hasMore,
          loadingMore: false));
    } catch (e) {
      if (_same(id) && state.hasValue) {
        state =
            AsyncData(state.asData!.value.copy(loadingMore: false, error: e));
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<bool> send(String text) async {
    final s = state.asData?.value;
    if (s == null || s.sending) return false;
    final repo = ref.read(messagesRepositoryProvider);
    final id = repo.owner;
    state = AsyncData(s.copy(sending: true));
    try {
      final message = await repo.send(key, text);
      if (!_same(id)) return false;
      state = AsyncData(state.asData!.value.copy(
          messages: _merge(state.asData!.value.messages, [message]),
          sending: false));
      ref.read(conversationsControllerProvider.notifier).refresh();
      return true;
    } catch (e) {
      if (_same(id) && state.hasValue) {
        // The composer owns its send error and retained draft. A failed send
        // must not be presented as a failed history refresh.
        state = AsyncData(state.asData!.value.copy(sending: false));
      }
      return false;
    }
  }

  Future<void> acknowledge() async {
    final s = state.asData?.value;
    if (s == null ||
        s.messages.isEmpty ||
        _reading ||
        s.messages.first.id <= _readThrough) {
      return;
    }
    final repo = ref.read(messagesRepositoryProvider);
    final id = repo.owner;
    final through = s.messages.first.id;
    _reading = true;
    try {
      await repo.read(key, through);
      if (!_same(id)) return;
      _readThrough = through;
      ref.read(conversationsControllerProvider.notifier).refresh();
    } catch (_) {
      /* Retry on the next visible poll; do not invent read state. */
    } finally {
      _reading = false;
    }
  }
}
