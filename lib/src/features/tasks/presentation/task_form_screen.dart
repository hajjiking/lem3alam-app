import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/networking/api_exception.dart';
import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/language_picker.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/app_widgets.dart';
import '../../../routing/app_router.dart';
import '../../location/presentation/map_picker_screen.dart';
import '../domain/task.dart';
import 'tasks_controller.dart';
import '../data/tasks_repository_impl.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({
    super.key,
    this.editTaskId,
    this.prefillTitle,
    this.prefillDescription,
  });

  final int? editTaskId;
  final String? prefillTitle;
  final String? prefillDescription;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _city = TextEditingController();
  final _budgetMin = TextEditingController(text: '0');
  final _budgetMax = TextEditingController(text: '0');
  final _address = TextEditingController();

  int? _categoryId;
  String _budgetType = 'fixed';
  String _urgency = 'medium';
  String? _paymentMethod;
  bool _isRemote = false;
  double? _latitude;
  double? _longitude;
  String? _locationLabel;
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};
  final List<TaskImageAttachment> _images = [];
  bool _addingPhoto = false;

  @override
  void initState() {
    super.initState();
    final id = widget.editTaskId;
    if (id != null) {
      _prefill(id);
    } else {
      final t = (widget.prefillTitle ?? '').trim();
      if (t.isNotEmpty) _title.text = t;
      final d = (widget.prefillDescription ?? '').trim();
      if (d.isNotEmpty) _description.text = d;
    }
  }

  Future<void> _prefill(int id) async {
    setState(() => _loading = true);
    try {
      final task = await ref.read(tasksRepositoryProvider).getById(id);
      _title.text = task.title;
      _description.text = task.description;
      _city.text = task.city;
      _budgetMin.text = task.budgetMin.toStringAsFixed(0);
      _budgetMax.text = task.budgetMax.toStringAsFixed(0);
      _categoryId = task.categoryId;
      _budgetType = task.budgetType.isEmpty ? 'fixed' : task.budgetType;
      _urgency = task.urgency.isEmpty ? 'medium' : task.urgency;
      _isRemote = task.isRemote;
      _latitude = task.latitude;
      _longitude = task.longitude;
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _city.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    _address.dispose();
    _images.clear();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final l10n = context.l10n;
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cameraCaptureNotAvailableOnWeb)),
      );
      return;
    }

    if (_images.length >= 5) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxTaskPhotos)),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_addingPhoto) return;
    setState(() => _addingPhoto = true);
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        if (!mounted) return;
        final permanentlyDenied = permission.isPermanentlyDenied;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.cameraPermission),
            content: Text(
              permanentlyDenied
                  ? l10n.cameraPermissionPermanentlyDenied
                  : l10n.cameraPermissionRequired,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close)),
              if (permanentlyDenied)
                FilledButton(
                  onPressed: () async {
                    await openAppSettings();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(l10n.openSettings),
                ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      final xfile = await navigator.push<XFile?>(
        MaterialPageRoute(builder: (_) => const _CameraCaptureScreen()),
      );
      if (xfile == null) return;

      final bytes = await xfile.readAsBytes();
      final compressed = await _compressJpeg(bytes);
      final attachment = TaskImageAttachment(
        bytes: compressed,
        filename: 'task_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      if (!mounted) return;
      setState(() => _images.add(attachment));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cameraError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _addingPhoto = false);
    }
  }

  Future<List<int>> _compressJpeg(Uint8List input) async {
    var quality = 85;
    var output = input;
    while (output.lengthInBytes > 1900 * 1024 && quality >= 55) {
      final compressed = await FlutterImageCompress.compressWithList(
        output,
        quality: quality,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );
      output = Uint8List.fromList(compressed);
      quality -= 10;
    }
    return output;
  }

  void _removePhoto(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _pickOnMap() async {
    final initial = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : null;
    final result = await context.pushNamed<MapPickerResult>(
      AppRouteNames.mapPicker,
      extra: initial,
    );
    if (!mounted || result == null) return;

    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _locationLabel = result.label;
      final city = (result.city ?? '').trim();
      if (_city.text.trim().isEmpty && city.isNotEmpty) {
        _city.text = city;
      }
      final label = (result.label ?? '').trim();
      if (_address.text.trim().isEmpty && label.isNotEmpty) {
        _address.text = label;
      }
    });
  }

  void _clearPickedLocation() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _locationLabel = null;
    });
  }

  Future<void> _previewPhoto(TaskImageAttachment img) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.memory(
                  Uint8List.fromList(img.bytes),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors = const {};
      _loading = true;
    });

    try {
      final payload = TaskPayload(
        title: _title.text.trim(),
        description: _description.text.trim(),
        categoryId: _categoryId ?? 0,
        city: _city.text.trim(),
        budgetMin: double.tryParse(_budgetMin.text) ?? 0,
        budgetMax: double.tryParse(_budgetMax.text) ?? 0,
        budgetType: _budgetType,
        urgency: _urgency,
        paymentMethod: _paymentMethod,
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        location: _isRemote
            ? null
            : (((_locationLabel?.trim().isEmpty) ?? true)
                ? null
                : _locationLabel!.trim()),
        latitude: _isRemote ? null : _latitude,
        longitude: _isRemote ? null : _longitude,
        isRemote: _isRemote,
      );

      final mutation = ref.read(taskMutationControllerProvider);
      final task = widget.editTaskId == null
          ? await mutation.create(payload,
              images: _images.isEmpty ? null : List.of(_images))
          : await mutation.update(
              id: widget.editTaskId!,
              payload: payload,
              images: _images.isEmpty ? null : List.of(_images),
            );

      ref.invalidate(tasksListControllerProvider);
      _images.clear();
      if (mounted) {
        context.goNamed(
          AppRouteNames.taskDetail,
          pathParameters: {'id': task.id.toString()},
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _fieldErrors = e.validationErrors ?? const {};
        _error = localizeApiException(context, e);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _err(String key) => _fieldErrors[key]?.first;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryOptionsProvider);
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: _TaskFormHeader(
            title: widget.editTaskId == null ? l10n.createTask : l10n.editTask),
        actions: [
          IconButton(
            onPressed: () => showLanguagePicker(context),
            icon: const Icon(Icons.language),
            tooltip: l10n.languageAction,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading && widget.editTaskId != null
            ? const _TaskFormSkeleton()
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppStyle.sheetRadius)),
                ),
                child: AppResponsiveCenter(
                  maxWidth: 640,
                  padding: EdgeInsets.zero,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      _TaskFormIntro(message: l10n.tipText),
                      const SizedBox(height: 16),
                      if (_error != null)
                        AppInlineBanner(
                            message: _error!, tone: AppBannerTone.error),
                      if (_error != null) const SizedBox(height: 12),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSectionCard(
                              title: l10n.title,
                              subtitle: l10n.description,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _title,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.title,
                                      prefixIcon:
                                          const Icon(Icons.title_outlined),
                                      errorText: _err('title'),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? l10n.requiredField
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _description,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      labelText: l10n.description,
                                      prefixIcon:
                                          const Icon(Icons.subject_outlined),
                                      errorText: _err('description'),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? l10n.requiredField
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppSectionCard(
                              title: l10n.photos,
                              trailing: FilledButton.tonalIcon(
                                onPressed:
                                    _loading || _addingPhoto ? null : _addPhoto,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: Text(_images.isEmpty
                                    ? l10n.add
                                    : '${_images.length}/5'),
                              ),
                              child: _images.isEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.addPhotosHelper,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            _PhotoAddSlot(
                                              icon: Icons.image_outlined,
                                              onTap: _loading || _addingPhoto
                                                  ? null
                                                  : _addPhoto,
                                            ),
                                            for (var index = 0;
                                                index < 4;
                                                index++)
                                              _PhotoAddSlot(
                                                  onTap:
                                                      _loading || _addingPhoto
                                                          ? null
                                                          : _addPhoto),
                                          ],
                                        ),
                                      ],
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: _images.length,
                                      itemBuilder: (context, index) {
                                        final img = _images[index];
                                        return Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Material(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                clipBehavior: Clip.antiAlias,
                                                child: InkWell(
                                                  onTap: () =>
                                                      _previewPhoto(img),
                                                  child: Ink.image(
                                                    image: MemoryImage(
                                                        Uint8List.fromList(
                                                            img.bytes)),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: IconButton.filledTonal(
                                                style: IconButton.styleFrom(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                ),
                                                onPressed: _loading
                                                    ? null
                                                    : () => _removePhoto(index),
                                                icon: const Icon(Icons.close,
                                                    size: 16),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 12),
                            AppSectionCard(
                              title: l10n.location,
                              child: Column(
                                children: [
                                  categoriesAsync.when(
                                    loading: () => const AppSkeletonBox(
                                        height: 56, width: double.infinity),
                                    error: (e, _) => AppInlineBanner(
                                      message: e.toString(),
                                      tone: AppBannerTone.error,
                                    ),
                                    data: (cats) =>
                                        DropdownButtonFormField<int>(
                                      value: _categoryId,
                                      isExpanded: true,
                                      menuMaxHeight: 360,
                                      itemHeight: null,
                                      items: [
                                        for (final c in cats)
                                          DropdownMenuItem(
                                            value: c.id,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              child: Text(
                                                c.localizedName(languageCode),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                      ],
                                      selectedItemBuilder: (context) => [
                                        for (final c in cats)
                                          Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Text(
                                              c.localizedName(languageCode),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                      onChanged: _loading
                                          ? null
                                          : (v) =>
                                              setState(() => _categoryId = v),
                                      decoration: InputDecoration(
                                        labelText: l10n.category,
                                        prefixIcon:
                                            const Icon(Icons.category_outlined),
                                        errorText: _err('category_id'),
                                      ),
                                      validator: (v) => (v == null || v == 0)
                                          ? l10n.requiredField
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AppCityPickerField(
                                    controller: _city,
                                    labelText: l10n.city,
                                    textInputAction: TextInputAction.next,
                                    errorText: _err('city'),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? l10n.requiredField
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _address,
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      labelText: l10n.addressOptional,
                                      prefixIcon:
                                          const Icon(Icons.place_outlined),
                                      errorText: _err('address'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.tonalIcon(
                                          onPressed:
                                              _loading ? null : _pickOnMap,
                                          icon: const Icon(Icons.map_outlined),
                                          label: Text(
                                            (_latitude != null &&
                                                    _longitude != null)
                                                ? l10n.locationSelected
                                                : l10n.pickOnMap,
                                          ),
                                        ),
                                      ),
                                      if (_latitude != null &&
                                          _longitude != null) ...[
                                        const SizedBox(width: 10),
                                        IconButton(
                                          onPressed: _loading
                                              ? null
                                              : _clearPickedLocation,
                                          tooltip: l10n.clear,
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if ((_locationLabel ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        _locationLabel!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppSectionCard(
                              title: l10n.proposedBudget,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _budgetMin,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            labelText: l10n.budgetMin,
                                            prefixIcon: const Icon(
                                                Icons.money_outlined),
                                            errorText: _err('budget_min'),
                                          ),
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? l10n.requiredField
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _budgetMax,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            labelText: l10n.budgetMax,
                                            prefixIcon: const Icon(
                                                Icons.money_outlined),
                                            errorText: _err('budget_max'),
                                          ),
                                          validator: (v) =>
                                              (v == null || v.trim().isEmpty)
                                                  ? l10n.requiredField
                                                  : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: _budgetType,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'fixed',
                                          child: Text(l10n.fixed)),
                                      DropdownMenuItem(
                                          value: 'hourly',
                                          child: Text(l10n.hourly)),
                                      DropdownMenuItem(
                                          value: 'negotiable',
                                          child: Text(l10n.negotiable)),
                                    ],
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(
                                            () => _budgetType = v ?? 'fixed'),
                                    decoration: InputDecoration(
                                      labelText: l10n.budgetType,
                                      prefixIcon:
                                          const Icon(Icons.tune_outlined),
                                      errorText: _err('budget_type'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: _urgency,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'low',
                                          child: Text(l10n.urgencyLow)),
                                      DropdownMenuItem(
                                          value: 'medium',
                                          child: Text(l10n.urgencyMedium)),
                                      DropdownMenuItem(
                                          value: 'high',
                                          child: Text(l10n.urgencyHigh)),
                                      DropdownMenuItem(
                                          value: 'urgent',
                                          child: Text(l10n.urgencyUrgent)),
                                    ],
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(
                                            () => _urgency = v ?? 'medium'),
                                    decoration: InputDecoration(
                                      labelText: l10n.urgency,
                                      prefixIcon:
                                          const Icon(Icons.flag_outlined),
                                      errorText: _err('urgency'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    value: _paymentMethod,
                                    items: [
                                      DropdownMenuItem(
                                          value: 'cash',
                                          child: Text(l10n.cash)),
                                      DropdownMenuItem(
                                          value: 'card',
                                          child: Text(l10n.card)),
                                      DropdownMenuItem(
                                          value: 'online',
                                          child: Text(l10n.online)),
                                    ],
                                    onChanged: _loading
                                        ? null
                                        : (v) =>
                                            setState(() => _paymentMethod = v),
                                    decoration: InputDecoration(
                                      labelText: l10n.paymentMethodOptional,
                                      prefixIcon: const Icon(
                                          Icons.credit_card_outlined),
                                      errorText: _err('payment_method'),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SwitchListTile.adaptive(
                                    value: _isRemote,
                                    onChanged: _loading
                                        ? null
                                        : (v) => setState(() => _isRemote = v),
                                    title: Text(l10n.remote),
                                    secondary: const Icon(
                                        Icons.wifi_tethering_outlined),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          _submit();
                                        }
                                      },
                                icon: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 3),
                                      )
                                    : const Icon(Icons.send_rounded),
                                label: Text(widget.editTaskId == null
                                    ? l10n.createTask
                                    : l10n.save),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _TaskFormIntro extends StatelessWidget {
  const _TaskFormIntro({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.lightbulb_outline_rounded,
                color: context.appColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFormHeader extends StatelessWidget {
  const _TaskFormHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
}

class _PhotoAddSlot extends StatelessWidget {
  const _PhotoAddSlot({this.icon, this.onTap});

  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPreview = icon != null;
    return Material(
      color: isPreview
          ? context.appColors.primary.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isPreview
                ? null
                : Border.all(
                    color: context.appColors.primary.withValues(alpha: 0.45),
                    style: BorderStyle.solid,
                  ),
          ),
          child: Icon(
            icon ?? Icons.add_rounded,
            color: context.appColors.primary
                .withValues(alpha: isPreview ? 1 : 0.55),
            size: isPreview ? 34 : 30,
          ),
        ),
      ),
    );
  }
}

class _TaskFormSkeleton extends StatelessWidget {
  const _TaskFormSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppResponsiveCenter(
      maxWidth: 760,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeletonBox(height: 18, width: 120),
                  SizedBox(height: 10),
                  AppSkeletonBox(height: 56, width: double.infinity),
                  SizedBox(height: 12),
                  AppSkeletonBox(height: 56, width: double.infinity),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeletonBox(height: 18, width: 120),
                  SizedBox(height: 10),
                  AppSkeletonBox(height: 56, width: double.infinity),
                  SizedBox(height: 12),
                  AppSkeletonBox(height: 56, width: double.infinity),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppSkeletonBox(height: 18, width: 120),
                  SizedBox(height: 10),
                  AppSkeletonBox(height: 56, width: double.infinity),
                  SizedBox(height: 12),
                  AppSkeletonBox(height: 56, width: double.infinity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraCaptureScreen extends StatefulWidget {
  const _CameraCaptureScreen();

  @override
  State<_CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<_CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _initializing = true;
  bool _busy = false;
  XFile? _captured;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        setState(() {
          _error = context.l10n.noCameraFound;
          _initializing = false;
        });
        return;
      }

      _cameras = cams;
      final backIndex =
          cams.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      _cameraIndex = backIndex == -1 ? 0 : backIndex;
      await _startController(_cameras[_cameraIndex]);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _initializing = false;
      });
    }
  }

  Future<void> _startController(CameraDescription camera) async {
    _initializing = true;
    setState(() {});
    await _controller?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() => _initializing = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _initializing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    _captured = null;
    _error = null;
    setState(() => _cameraIndex = next);
    await _startController(_cameras[_cameraIndex]);
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() => _captured = file);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(l10n.camera),
        actions: [
          IconButton(
            onPressed: _initializing || _busy || _captured != null
                ? null
                : _switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: l10n.switchCamera,
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              : _captured != null
                  ? _PreviewBody(
                      file: _captured!,
                      onRetake: () => setState(() => _captured = null),
                      onUse: () => Navigator.pop(context, _captured),
                    )
                  : controller == null
                      ? const SizedBox.shrink()
                      : Stack(
                          children: [
                            Positioned.fill(child: CameraPreview(controller)),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 24,
                              child: Center(
                                child: InkResponse(
                                  onTap: _busy ? null : _takePicture,
                                  radius: 40,
                                  child: Container(
                                    height: 72,
                                    width: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      color: _busy
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
    );
  }
}

class _PreviewBody extends StatelessWidget {
  const _PreviewBody({
    required this.file,
    required this.onRetake,
    required this.onUse,
  });

  final XFile file;
  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<Uint8List>(
            future: file.readAsBytes(),
            builder: (context, snap) {
              final data = snap.data;
              if (data == null) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }
              return Center(
                child: InteractiveViewer(
                  child: Image.memory(data, fit: BoxFit.contain),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: onRetake,
                    child: Text(l10n.retake),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onUse,
                    child: Text(l10n.usePhoto),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
