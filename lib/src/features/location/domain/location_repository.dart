import '../../../core/networking/pagination.dart';
import 'nearby_provider.dart';

abstract class LocationRepository {
  Future<void> updateMyLocation({required double latitude, required double longitude});

  Future<Paginated<NearbyProvider>> nearbyProviders({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    int page = 1,
    int perPage = 20,
  });
}
