import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../services/device_location_service.dart';

class MapPickerResult {
  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    this.label,
    this.city,
  });

  final double latitude;
  final double longitude;
  final String? label;
  final String? city;

  LatLng toLatLng() => LatLng(latitude, longitude);
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    this.initialLocation,
  });

  final LatLng? initialLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final _device = const DeviceLocationService();
  final _mapController = MapController();

  bool _loading = true;
  String? _errorCode;

  LatLng? _selected;
  String? _label;
  String? _city;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _errorCode = null;
    });

    try {
      final initial = widget.initialLocation;
      if (initial != null) {
        _selected = initial;
        await _reverseGeocode(initial);
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final pos = await _device.getCurrentPosition();
      final center = LatLng(pos.latitude, pos.longitude);
      _selected = center;
      await _reverseGeocode(center);
      if (!mounted) return;
      setState(() => _loading = false);
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorCode = e.code;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorCode = 'unknown';
      });
    }
  }

  Future<void> _reverseGeocode(LatLng p) async {
    try {
      final placemarks = await placemarkFromCoordinates(p.latitude, p.longitude);
      final pm = placemarks.isNotEmpty ? placemarks.first : null;
      final pieces = <String>[];
      final name = (pm?.name ?? '').trim();
      final street = (pm?.street ?? '').trim();
      final locality = (pm?.locality ?? '').trim();
      final admin = (pm?.administrativeArea ?? '').trim();
      final country = (pm?.country ?? '').trim();

      if (name.isNotEmpty && name != street) pieces.add(name);
      if (street.isNotEmpty) pieces.add(street);
      if (locality.isNotEmpty) pieces.add(locality);
      if (admin.isNotEmpty && admin != locality) pieces.add(admin);
      if (country.isNotEmpty) pieces.add(country);

      _label = pieces.isEmpty ? null : pieces.join(', ');
      _city = locality.isNotEmpty ? locality : (admin.isNotEmpty ? admin : null);
    } catch (_) {
      _label = null;
      _city = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.pickLocation),
        actions: const [AppThemeModeButton()],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorCode != null
                ? _errorView(context, _errorCode!)
                : selected == null
                    ? _errorView(context, 'unknown')
                    : Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: selected,
                              initialZoom: 15,
                              onTap: (tapPosition, point) async {
                                setState(() {
                                  _selected = point;
                                  _label = null;
                                  _city = null;
                                });
                                await _reverseGeocode(point);
                                if (!mounted) return;
                                setState(() {});
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'lem3alam_mobile',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: selected,
                                    width: 46,
                                    height: 46,
                                    child: Icon(
                                      Icons.location_on,
                                      size: 46,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _label ?? '${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                          MapPickerResult(
                                            latitude: selected.latitude,
                                            longitude: selected.longitude,
                                            label: _label,
                                            city: _city,
                                          ),
                                        );
                                      },
                                      child: Text(context.l10n.confirmLocation),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _errorView(BuildContext context, String code) {
    final l10n = context.l10n;
    final (title, message, actionLabel, action) = switch (code) {
      'service_disabled' => (
          l10n.locationDisabled,
          l10n.locationServicesRequired,
          l10n.openLocationSettings,
          _device.openLocationSettings,
        ),
      'permission_denied_forever' => (
          l10n.permissionRequired,
          l10n.locationPermissionPermanentlyDenied,
          l10n.openSettings,
          _device.openSettings,
        ),
      'permission_denied' => (
          l10n.permissionRequired,
          l10n.locationPermissionRequiredToPick,
          l10n.retry,
          _bootstrap,
        ),
      _ => (
          l10n.errUnknown,
          l10n.couldNotLoadMap,
          l10n.retry,
          _bootstrap,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppSectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => action(), child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
