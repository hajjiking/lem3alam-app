import '../../../core/networking/api_client.dart';

class LocationApi {
  LocationApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> update({required double latitude, required double longitude}) {
    return _client.postJson('location/update', data: {
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  Future<Map<String, dynamic>> nearbyProviders({
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    int page = 1,
    int perPage = 20,
  }) {
    return _client.getJson('providers/nearby', queryParameters: {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'radius': radiusKm,
      'page': page,
      'per_page': perPage,
    });
  }
}
