import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/api_client.dart';
import '../../../core/networking/pagination.dart';
import '../domain/location_repository.dart';
import '../domain/nearby_provider.dart';
import 'location_api.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(api: LocationApi(ref.watch(apiClientProvider)));
});

class LocationRepositoryImpl implements LocationRepository {
  LocationRepositoryImpl({required this.api});

  final LocationApi api;

  @override
  Future<void> updateMyLocation({required double latitude, required double longitude}) async {
    await api.update(latitude: latitude, longitude: longitude);
  }

  @override
  Future<Paginated<NearbyProvider>> nearbyProviders({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    int page = 1,
    int perPage = 20,
  }) async {
    final json = await api.nearbyProviders(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      page: page,
      perPage: perPage,
    );

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return Paginated.fromLaravel(
        data,
        itemFromJson: NearbyProvider.fromJson,
      );
    }
    if (data is List) {
      final items = data
          .whereType<Map>()
          .map((e) => NearbyProvider.fromJson(e.cast<String, dynamic>()))
          .toList();
      return Paginated(
        items: items,
        currentPage: 1,
        lastPage: 1,
        perPage: items.length,
        total: items.length,
      );
    }
    return Paginated(items: const [], currentPage: 1, lastPage: 1, perPage: perPage, total: 0);
  }
}
