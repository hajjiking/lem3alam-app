import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/location_repository_impl.dart';
import '../domain/app_location.dart';
import '../domain/nearby_provider.dart';
import '../services/device_location_service.dart';

class NearbyProvidersState {
  const NearbyProvidersState({
    required this.loading,
    required this.providers,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.myLocation,
    this.errorCode,
  });

  final bool loading;
  final AppLocation? myLocation;
  final List<NearbyProvider> providers;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? errorCode;

  bool get hasPrevPage => currentPage > 1;
  bool get hasNextPage => currentPage < lastPage;

  NearbyProvidersState copyWith({
    bool? loading,
    AppLocation? myLocation,
    List<NearbyProvider>? providers,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    String? errorCode,
  }) {
    return NearbyProvidersState(
      loading: loading ?? this.loading,
      myLocation: myLocation ?? this.myLocation,
      providers: providers ?? this.providers,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      errorCode: errorCode,
    );
  }
}

final nearbyProvidersControllerProvider =
    NotifierProvider<NearbyProvidersController, NearbyProvidersState>(NearbyProvidersController.new);

class NearbyProvidersController extends Notifier<NearbyProvidersState> {
  final _device = const DeviceLocationService();
  static const int _defaultPerPage = 12;

  @override
  NearbyProvidersState build() {
    Future.microtask(load);
    return const NearbyProvidersState(
      loading: true,
      providers: [],
      currentPage: 1,
      lastPage: 1,
      perPage: _defaultPerPage,
      total: 0,
    );
  }

  Future<void> load() async {
    final auth = ref.read(authControllerProvider);
    if (auth.user == null) {
      state = state.copyWith(
        loading: false,
        providers: const [],
        errorCode: 'unauthenticated',
        currentPage: 1,
        lastPage: 1,
        total: 0,
      );
      return;
    }

    state = state.copyWith(loading: true, errorCode: null);
    try {
      final pos = await _device.getCurrentPosition();
      final my = AppLocation(latitude: pos.latitude, longitude: pos.longitude);

      await ref.read(locationRepositoryProvider).updateMyLocation(
            latitude: my.latitude,
            longitude: my.longitude,
          );

      state = state.copyWith(myLocation: my);
      await loadPage(1);
    } on LocationException catch (e) {
      state = state.copyWith(
        loading: false,
        myLocation: null,
        providers: const [],
        errorCode: e.code,
        currentPage: 1,
        lastPage: 1,
        total: 0,
      );
    } catch (_) {
      state = state.copyWith(loading: false, providers: const [], errorCode: 'unknown');
    }
  }

  Future<void> loadPage(int page) async {
    final auth = ref.read(authControllerProvider);
    if (auth.user == null) {
      state = state.copyWith(loading: false, providers: const [], errorCode: 'unauthenticated');
      return;
    }
    final my = state.myLocation;
    if (my == null) {
      await load();
      return;
    }

    state = state.copyWith(loading: true, errorCode: null);
    try {
      final result = await ref.read(locationRepositoryProvider).nearbyProviders(
            latitude: my.latitude,
            longitude: my.longitude,
            page: page,
            perPage: state.perPage,
          );

      state = state.copyWith(
        loading: false,
        providers: result.items,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        perPage: result.perPage,
        total: result.total,
      );
    } catch (_) {
      state = state.copyWith(loading: false, errorCode: 'unknown');
    }
  }

  Future<void> goFirst() => loadPage(1);

  Future<void> goPrev() => state.hasPrevPage ? loadPage(state.currentPage - 1) : Future.value();

  Future<void> goNext() => state.hasNextPage ? loadPage(state.currentPage + 1) : Future.value();

  Future<void> goLast() => state.lastPage > 1 ? loadPage(state.lastPage) : Future.value();

  Future<void> openSettings() => _device.openSettings();

  Future<void> openLocationSettings() => _device.openLocationSettings();
}
