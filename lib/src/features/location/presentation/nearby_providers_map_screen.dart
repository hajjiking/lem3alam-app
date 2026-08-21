import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/ui/app_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/auth_state.dart';
import '../../../routing/app_router.dart';
import '../domain/nearby_provider.dart';
import 'nearby_providers_controller.dart';

class NearbyProvidersMapScreen extends ConsumerStatefulWidget {
  const NearbyProvidersMapScreen({super.key});

  @override
  ConsumerState<NearbyProvidersMapScreen> createState() => _NearbyProvidersMapScreenState();
}

class _NearbyProvidersMapScreenState extends ConsumerState<NearbyProvidersMapScreen> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nearbyProvidersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.nearbyArtisans),
        leading: Semantics(
          button: true,
          label: context.l10n.goToHome,
          child: IconButton(
            tooltip: context.l10n.home,
            onPressed: () => _goHome(context),
            icon: const Icon(Icons.home_outlined),
          ),
        ),
        actions: const [AppThemeModeButton()],
      ),
      body: SafeArea(
        child: state.loading
            ? const Center(child: CircularProgressIndicator())
            : _bodyForState(context, state),
      ),
    );
  }

  void _goHome(BuildContext context) {
    final auth = ref.read(authControllerProvider);
    if (auth.user?.isAdmin == true) {
      context.goNamed(AppRouteNames.adminHome);
      return;
    }
    if (auth.status == AuthStatus.authenticated) {
      context.goNamed(AppRouteNames.dashboard);
      return;
    }
    context.goNamed(AppRouteNames.tasks);
  }

  Widget _bodyForState(BuildContext context, NearbyProvidersState state) {
    final controller = ref.read(nearbyProvidersControllerProvider.notifier);

    if (state.errorCode != null) {
      final l10n = context.l10n;
      final (title, message, actionLabel, action) = switch (state.errorCode) {
        'service_disabled' => (
            l10n.locationDisabled,
            l10n.locationServicesRequired,
            l10n.openLocationSettings,
            controller.openLocationSettings,
          ),
        'permission_denied_forever' => (
            l10n.permissionRequired,
            l10n.locationPermissionPermanentlyDenied,
            l10n.openSettings,
            controller.openSettings,
          ),
        'permission_denied' => (
            l10n.permissionRequired,
            l10n.locationPermissionRequiredNearbyArtisans,
            l10n.retry,
            controller.load,
          ),
        'unauthenticated' => (
            l10n.loginRequired,
            l10n.errUnauthorized,
            l10n.reload,
            controller.load,
          ),
        _ => (
            l10n.errUnknown,
            l10n.couldNotLoadNearbyArtisans,
            l10n.retry,
            controller.load,
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

    final my = state.myLocation;
    if (my == null) {
      final l10n = context.l10n;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: AppSectionCard(
          title: l10n.noLocation,
          child: FilledButton(
            onPressed: () => controller.load(),
            child: Text(l10n.reload),
          ),
        ),
      );
    }

    final center = LatLng(my.latitude, my.longitude);
    final providers = state.providers;

    final map = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'lem3alam_mobile',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                    ),
                    child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onPrimary, size: 22),
                  ),
                ),
                for (final p in providers) _providerMarker(context, p),
              ],
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'zoom-in',
                onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                heroTag: 'zoom-out',
                onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: map),
              SizedBox(
                width: 420,
                child: _resultsPanel(context, state),
              ),
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: map),
            DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.18,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return _resultsPanel(
                  context,
                  state,
                  scrollController: scrollController,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _resultsPanel(
    BuildContext context,
    NearbyProvidersState state, {
    ScrollController? scrollController,
  }) {
    final controller = ref.read(nearbyProvidersControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final origin = state.myLocation == null ? null : LatLng(state.myLocation!.latitude, state.myLocation!.longitude);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.artisans,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Semantics(
                  button: true,
                  label: context.l10n.goToHome,
                  child: IconButton.filledTonal(
                    tooltip: context.l10n.home,
                    onPressed: () => _goHome(context),
                    icon: const Icon(Icons.home_outlined),
                  ),
                ),
              ],
            ),
          ),
          _paginationButtons(context, state),
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: state.providers.isEmpty && !state.loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppInlineBanner(
                  message: context.l10n.noArtisansFoundNearby,
                  tone: AppBannerTone.info,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => controller.loadPage(state.currentPage),
                  child: Text(context.l10n.refreshAction),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 380 ? (width >= 760 ? 3 : 2) : 1;
                return GridView.builder(
                  controller: scrollController,
                  shrinkWrap: scrollController == null,
                  physics: scrollController == null ? const AlwaysScrollableScrollPhysics() : const ClampingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemCount: state.providers.length,
                  itemBuilder: (context, index) {
                    final p = state.providers[index];
                    return _artisanCard(
                      context,
                      p,
                      origin: origin,
                      background: scheme.surfaceContainerLowest,
                      borderColor: scheme.outlineVariant.withValues(alpha: 0.6),
                    );
                  },
                );
              },
            ),
    );

    return Material(
      elevation: 6,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      color: scheme.surface,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          header,
          if (state.loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _paginationButtons(BuildContext context, NearbyProvidersState state) {
    final controller = ref.read(nearbyProvidersControllerProvider.notifier);

    Widget iconButton({
      required String semanticsLabel,
      required IconData icon,
      required VoidCallback? onPressed,
    }) {
      return Semantics(
        button: true,
        label: semanticsLabel,
        child: IconButton(
          tooltip: semanticsLabel,
          onPressed: onPressed,
          icon: Icon(icon),
        ),
      );
    }

    final canGoBack = state.hasPrevPage && !state.loading;
    final canGoForward = state.hasNextPage && !state.loading;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconButton(
          semanticsLabel: context.l10n.goToFirstPage,
          icon: Icons.first_page,
          onPressed: canGoBack ? () => controller.goFirst() : null,
        ),
        iconButton(
          semanticsLabel: context.l10n.goToPreviousPage,
          icon: Icons.chevron_left,
          onPressed: canGoBack ? () => controller.goPrev() : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${state.currentPage} / ${state.lastPage}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        iconButton(
          semanticsLabel: context.l10n.goToNextPage,
          icon: Icons.chevron_right,
          onPressed: canGoForward ? () => controller.goNext() : null,
        ),
        iconButton(
          semanticsLabel: context.l10n.goToLastPage,
          icon: Icons.last_page,
          onPressed: canGoForward ? () => controller.goLast() : null,
        ),
      ],
    );
  }

  Widget _artisanCard(
    BuildContext context,
    NearbyProvider p, {
    required LatLng? origin,
    required Color background,
    required Color borderColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final title = p.name.isEmpty ? context.l10n.tasker : p.name;
    final subtitle = '${p.distanceKm.toStringAsFixed(2)} km';

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showProvider(context, p, origin: origin),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.handyman_outlined, color: scheme.onSecondaryContainer),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: '${context.l10n.directions} $title',
                      child: FilledButton.icon(
                        onPressed: () => _openDirections(context, destination: p.toLatLng(), origin: origin),
                        icon: const Icon(Icons.directions),
                        label: Text(context.l10n.go),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: '${context.l10n.center} $title',
                    child: IconButton.filledTonal(
                      onPressed: () => _mapController.move(p.toLatLng(), 15),
                      icon: const Icon(Icons.center_focus_strong),
                      tooltip: context.l10n.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Marker _providerMarker(BuildContext context, NearbyProvider p) {
    return Marker(
      point: p.toLatLng(),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () {
          final my = ref.read(nearbyProvidersControllerProvider).myLocation;
          final origin = my == null ? null : LatLng(my.latitude, my.longitude);
          _showProvider(context, p, origin: origin);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.surface,
              width: 3,
            ),
          ),
          child: Icon(Icons.handyman_outlined, color: Theme.of(context).colorScheme.onSecondary, size: 22),
        ),
      ),
    );
  }

  Future<void> _showProvider(BuildContext context, NearbyProvider p, {LatLng? origin}) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              p.name.isEmpty ? context.l10n.tasker : p.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(context.l10n.distanceAway(p.distanceKm.toStringAsFixed(2))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _openDirections(context, destination: p.toLatLng(), origin: origin),
                    icon: const Icon(Icons.directions),
                    label: Text(context.l10n.directions),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _mapController.move(p.toLatLng(), 15);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: Text(context.l10n.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(
    BuildContext context, {
    required LatLng destination,
    required LatLng? origin,
  }) async {
    final lat = destination.latitude;
    final lng = destination.longitude;

    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    final uri = isIos
        ? Uri.parse('https://maps.apple.com/?daddr=$lat,$lng&dirflg=d')
        : Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng${origin == null ? '' : '&origin=${origin.latitude},${origin.longitude}'}&travelmode=driving',
          );

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotOpenNavigationApp)),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotOpenNavigationApp)),
      );
    }
  }
}
