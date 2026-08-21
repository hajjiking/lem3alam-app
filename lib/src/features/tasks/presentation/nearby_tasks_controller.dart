import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_exception.dart';
import '../../../core/networking/pagination.dart';
import '../../location/data/location_repository_impl.dart';
import '../../location/services/device_location_service.dart';
import '../data/nearby_tasks_local_prefs.dart';
import '../data/tasks_repository_impl.dart';
import '../domain/nearby_task_feed.dart';
import '../domain/task.dart';

// #region debug-point helpers:nearby-tasks-load-fail
void _dbgEvent({
  required String hypothesisId,
  required String location,
  required String msg,
  required Map<String, dynamic> data,
  String runId = 'pre-fix',
}) {
  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 1400),
      receiveTimeout: const Duration(milliseconds: 1800),
      sendTimeout: const Duration(milliseconds: 1400),
    ));
    const fallbackUrl = 'http://192.168.3.48:7777/event';
    const sessionId = 'nearby-tasks-load-fail';
    unawaited(
      dio
          .post<Object?>(
        fallbackUrl,
        data: jsonEncode({
          'sessionId': sessionId,
          'runId': runId,
          'hypothesisId': hypothesisId,
          'location': location,
          'msg': '[DEBUG] $msg',
          'data': data,
        }),
        options: Options(headers: {'Content-Type': 'application/json'}),
      )
          .then<void>((Response<Object?> _) {})
          .catchError((Object _) {}),
    );
  } catch (_) {}
}
// #endregion

final nearbyTasksLocalPrefsProvider = Provider<NearbyTasksLocalPrefs>((ref) {
  return NearbyTasksLocalPrefs();
});

final nearbyTasksControllerProvider =
    NotifierProvider<NearbyTasksController, NearbyTasksState>(NearbyTasksController.new);

class NearbyTasksState {
  const NearbyTasksState({
    required this.loading,
    required this.hasConsent,
    required this.radiusKm,
    required this.savedOnly,
    required this.page,
    required this.settings,
    this.errorCode,
    this.locationAccuracyMeters,
    this.lastRefreshedAt,
    this.newHighPriorityCount = 0,
  });

  final bool loading;
  final bool hasConsent;
  final int radiusKm;
  final bool savedOnly;
  final Paginated<Task> page;
  final NearbyTaskSettings settings;
  final String? errorCode;
  final double? locationAccuracyMeters;
  final DateTime? lastRefreshedAt;
  final int newHighPriorityCount;

  bool get hasLowAccuracyWarning => (locationAccuracyMeters ?? 0) > 500;

  NearbyTasksState copyWith({
    bool? loading,
    bool? hasConsent,
    int? radiusKm,
    bool? savedOnly,
    Paginated<Task>? page,
    NearbyTaskSettings? settings,
    String? errorCode,
    double? locationAccuracyMeters,
    DateTime? lastRefreshedAt,
    int? newHighPriorityCount,
  }) {
    return NearbyTasksState(
      loading: loading ?? this.loading,
      hasConsent: hasConsent ?? this.hasConsent,
      radiusKm: radiusKm ?? this.radiusKm,
      savedOnly: savedOnly ?? this.savedOnly,
      page: page ?? this.page,
      settings: settings ?? this.settings,
      errorCode: errorCode,
      locationAccuracyMeters: locationAccuracyMeters ?? this.locationAccuracyMeters,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      newHighPriorityCount: newHighPriorityCount ?? this.newHighPriorityCount,
    );
  }
}

class NearbyTasksController extends Notifier<NearbyTasksState> {
  final _device = const DeviceLocationService();
  Set<int> _knownHighPriorityTaskIds = <int>{};

  @override
  NearbyTasksState build() {
    Future.microtask(initialize);
    return NearbyTasksState(
      loading: true,
      hasConsent: false,
      radiusKm: 50,
      savedOnly: false,
      page: Paginated(items: const [], currentPage: 1, lastPage: 1, perPage: 15, total: 0),
      settings: const NearbyTaskSettings(
        defaultRadiusKm: 50,
        minRadiusKm: 5,
        maxRadiusKm: 100,
        refreshIntervalMinutes: 15,
        notificationMinUrgency: 'high',
        notificationsEnabled: true,
      ),
    );
  }

  Future<void> initialize() async {
    final prefs = ref.read(nearbyTasksLocalPrefsProvider);
    final consent = await prefs.hasConsent();
    final savedRadius = await prefs.radiusKm();
    state = state.copyWith(
      hasConsent: consent,
      radiusKm: savedRadius ?? state.settings.defaultRadiusKm,
      loading: consent,
      errorCode: null,
    );
    if (consent) {
      await refresh();
    } else {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> grantConsent() async {
    await ref.read(nearbyTasksLocalPrefsProvider).setConsent(true);
    state = state.copyWith(hasConsent: true, loading: true, errorCode: null);
    await refresh();
  }

  Future<void> updateRadius(int radiusKm, {bool refreshFeed = false}) async {
    await ref.read(nearbyTasksLocalPrefsProvider).setRadiusKm(radiusKm);
    state = state.copyWith(radiusKm: radiusKm);
    if (refreshFeed) {
      await loadPage(1);
    }
  }

  Future<void> toggleSavedOnly(bool value) async {
    state = state.copyWith(savedOnly: value);
    await loadPage(1);
  }

  Future<void> refresh() => loadPage(1);

  Future<void> loadPage(int page) async {
    // #region debug-point A:loadPage-entry
    _dbgEvent(
      hypothesisId: 'A',
      location: 'nearby_tasks_controller.dart:173',
      msg: 'loadPage called with params',
      data: {
        'page': page,
        'consent': state.hasConsent,
        'radiusKm': state.radiusKm,
        'savedOnly': state.savedOnly,
        'perPage': state.page.perPage,
      },
    );
    // #endregion
    if (!state.hasConsent) {
      state = state.copyWith(loading: false);
      return;
    }

    state = state.copyWith(loading: true, errorCode: null, newHighPriorityCount: 0);
    try {
      final pos = await _device.getCurrentPosition();
      // #region debug-point C:device-location
      _dbgEvent(
        hypothesisId: 'C',
        location: 'nearby_tasks_controller.dart:188',
        msg: 'Device location read from GPS/location services',
        data: {
          'lat': pos.latitude,
          'lng': pos.longitude,
          'accuracy': pos.accuracy,
          'positionType': pos.runtimeType.toString(),
        },
      );
      // #endregion
      await ref.read(locationRepositoryProvider).updateMyLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );

      final feed = await ref.read(tasksRepositoryProvider).nearby(
            page: page,
            perPage: state.page.perPage,
            radiusKm: state.radiusKm,
            savedOnly: state.savedOnly,
          );

      final clampedRadius = state.radiusKm.clamp(feed.settings.minRadiusKm, feed.settings.maxRadiusKm);
      final highPriorityIds = feed.page.items
          .where((task) => _isPriorityAtLeast(task.urgency, feed.settings.notificationMinUrgency))
          .map((task) => task.id)
          .toSet();
      final newHighPriorityCount = feed.settings.notificationsEnabled
          ? highPriorityIds.difference(_knownHighPriorityTaskIds).length
          : 0;
      _knownHighPriorityTaskIds = highPriorityIds;

      // #region debug-point D+E:state-update-after-parse
      _dbgEvent(
        hypothesisId: 'D',
        location: 'nearby_tasks_controller.dart:215',
        msg: 'Controller final state update after nearby feed parse',
        data: {
          'pageItemsLength': feed.page.items.length,
          'pageCurrentPage': feed.page.currentPage,
          'pageLastPage': feed.page.lastPage,
          'pageTotal': feed.page.total,
          'pagePerPage': feed.page.perPage,
          'settings': {
            'defaultRadiusKm': feed.settings.defaultRadiusKm,
            'minRadiusKm': feed.settings.minRadiusKm,
            'maxRadiusKm': feed.settings.maxRadiusKm,
            'refreshIntervalMinutes': feed.settings.refreshIntervalMinutes,
            'notificationMinUrgency': feed.settings.notificationMinUrgency,
            'notificationsEnabled': feed.settings.notificationsEnabled,
          },
          'clampedRadiusKm': clampedRadius,
          'newHighPriorityCount': newHighPriorityCount,
          'errorCode': null,
        },
      );
      // #endregion

      state = state.copyWith(
        loading: false,
        radiusKm: clampedRadius,
        page: feed.page,
        settings: feed.settings,
        locationAccuracyMeters: pos.accuracy,
        lastRefreshedAt: DateTime.now(),
        newHighPriorityCount: newHighPriorityCount,
      );
    } on LocationException catch (e) {
      // #region debug-point C:location-error
      _dbgEvent(
        hypothesisId: 'C',
        location: 'nearby_tasks_controller.dart:241',
        msg: 'LocationException raised in nearby page load',
        data: {'code': e.code, 'message': e.toString()},
      );
      // #endregion
      state = state.copyWith(loading: false, errorCode: e.code);
    } on ApiException catch (e) {
      // #region debug-point B:api-exception
      _dbgEvent(
        hypothesisId: 'B',
        location: 'nearby_tasks_controller.dart:251',
        msg: 'ApiException raised loading nearby feed',
        data: {
          'statusCode': e.statusCode,
          'message': e.message,
          'validationErrors': e.validationErrors?.map((k, v) => MapEntry(k, v.length)),
        },
      );
      // #endregion
      state = state.copyWith(
        loading: false,
        errorCode: e.statusCode == 403 ? 'forbidden' : 'unknown',
      );
    } on Object catch (err) {
      // #region debug-point B+D:generic-catch
      _dbgEvent(
        hypothesisId: 'D',
        location: 'nearby_tasks_controller.dart:265',
        msg: 'Generic catch clause fired loading nearby tasks',
        data: {
          'runtimeType': err.runtimeType.toString(),
          'toString': err.toString(),
        },
      );
      // #endregion
      state = state.copyWith(loading: false, errorCode: 'unknown');
    }
  }

  Future<void> toggleSave(Task task) async {
    if (task.isSaved) {
      await ref.read(tasksRepositoryProvider).unsaveNearbyTask(task.id);
    } else {
      await ref.read(tasksRepositoryProvider).saveNearbyTask(task.id);
    }
    await loadPage(state.page.currentPage);
  }

  Future<void> dismiss(Task task) async {
    await ref.read(tasksRepositoryProvider).dismissNearbyTask(task.id);
    await loadPage(state.page.currentPage);
  }

  Future<void> accept(Task task) async {
    await ref.read(tasksRepositoryProvider).apply(
          taskId: task.id,
          payload: TaskApplicationPayload(
            proposal: 'I am nearby, available, and ready to start this task promptly.',
            proposedBudget: task.budgetMin > 0 ? task.budgetMin : task.budgetMax,
            estimatedDuration: 'Flexible',
          ),
        );
    await loadPage(1);
  }

  Future<void> openSettings() => _device.openSettings();

  Future<void> openLocationSettings() => _device.openLocationSettings();

  bool _isPriorityAtLeast(String urgency, String minimum) {
    const rank = {
      'low': 1,
      'medium': 2,
      'high': 3,
    };
    return (rank[urgency] ?? 0) >= (rank[minimum] ?? 0);
  }
}
