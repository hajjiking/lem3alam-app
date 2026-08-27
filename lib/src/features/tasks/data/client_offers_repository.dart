import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../domain/task.dart';
import '../domain/task_offer.dart';
import '../domain/tasks_repository.dart';
import 'tasks_repository_impl.dart';

class ClientOffer {
  const ClientOffer(this.task, this.offer);
  final Task task;
  final TaskOffer offer;
}

final clientOffersRepositoryProvider = Provider((ref) => ClientOffersRepository(
      tasks: ref.watch(tasksRepositoryProvider),
      api: ref.watch(apiClientProvider),
      auth: () => ref.read(authControllerProvider),
      expireSession: () =>
          ref.read(authControllerProvider.notifier).expireSession(),
    ));

final clientOffersProvider =
    FutureProvider.autoDispose<List<ClientOffer>>((ref) {
  final identity = ref.watch(authControllerProvider
      .select((state) => (state.status, state.user?.id, state.user?.role)));
  if (identity.$1 != AuthStatus.authenticated || identity.$3 != 'client') {
    throw const ApiException(statusCode: 403, message: 'err_forbidden');
  }
  return ref.watch(clientOffersRepositoryProvider).pending();
}, retry: (_, __) => null);

class ClientOffersRepository {
  ClientOffersRepository(
      {required this.tasks,
      required this.api,
      required this.auth,
      required this.expireSession});
  final TasksRepository tasks;
  final ApiClient api;
  final AuthState Function() auth;
  final Future<void> Function() expireSession;

  int _client() {
    final state = auth();
    if (state.status != AuthStatus.authenticated ||
        state.user?.isClient != true) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    return state.user!.id;
  }

  void _sameClient(int id) {
    if (_client() != id) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
  }

  Future<List<ClientOffer>> pending() async {
    final clientId = _client();
    final result = <int, ClientOffer>{};
    // /my-tasks embeds applications.tasker. Read every page so older tasks'
    // proposals are not missed and the waiting count is not a sample count.
    for (var page = 1;; page++) {
      _sameClient(clientId);
      final response = await tasks.list(page: page, perPage: 50);
      _sameClient(clientId);
      if (response.currentPage != page) {
        throw const ApiException(message: 'err_unknown');
      }
      for (final task in response.items) {
        if (task.clientId != clientId) {
          throw const ApiException(statusCode: 403, message: 'err_forbidden');
        }
        if (task.status != 'open') continue;
        for (final offer in task.offers) {
          if (offer.status == 'pending' && offer.taskId == task.id) {
            result[offer.id] = ClientOffer(task, offer);
          }
        }
      }
      if (!response.hasNextPage) break;
    }
    return result.values.toList(growable: false);
  }

  Future<void> decide(ClientOffer entry, {required bool accept}) async {
    final clientId = _client();
    if (entry.task.clientId != clientId ||
        entry.offer.taskId != entry.task.id) {
      throw const ApiException(statusCode: 403, message: 'err_forbidden');
    }
    // Revalidate a possibly stale dashboard card before changing an offer.
    final task = await tasks.getById(entry.task.id);
    _sameClient(clientId);
    if (task.clientId != clientId ||
        task.status != 'open' ||
        !task.offers.any((offer) =>
            offer.id == entry.offer.id &&
            offer.taskId == task.id &&
            offer.status == 'pending')) {
      throw const ApiException(
          statusCode: 409, message: 'offerNoLongerAvailable');
    }
    try {
      final response = await api.putJson<Map<String, dynamic>>(
          'applications/${entry.offer.id}/${accept ? 'accept' : 'reject'}');
      _sameClient(clientId);
      if (response['success'] != true) {
        throw const ApiException(message: 'err_unknown');
      }
    } on ApiException catch (error) {
      if (error.statusCode == 401 &&
          auth().user?.id == clientId &&
          auth().user?.isClient == true) {
        await expireSession();
      }
      rethrow;
    }
  }
}
