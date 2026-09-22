import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/api_error_localizer.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/networking/api_exception.dart';
import '../application/client_kyc_controller.dart';
import '../data/client_kyc_repository.dart';
import '../domain/client_kyc.dart';

class ClientKycSection extends ConsumerStatefulWidget {
  const ClientKycSection({super.key});

  @override
  ConsumerState<ClientKycSection> createState() => _ClientKycSectionState();
}

class _ClientKycSectionState extends ConsumerState<ClientKycSection> {
  bool _picking = false;

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(clientKycControllerProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.kycTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            value.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Column(
                children: [
                  Text(context.l10n.kycLoadError),
                  TextButton(
                    onPressed: () => ref
                        .read(clientKycControllerProvider.notifier)
                        .refresh(),
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
              data: _buildOverview,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(KycOverview overview) {
    final l = context.l10n;
    final latest = overview.latest;
    final pending = latest?.status == 'pending';
    final rejected = latest?.status == 'rejected';
    final color = overview.isVerified
        ? Colors.green
        : pending
            ? Colors.orange
            : Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            overview.isVerified
                ? Icons.verified_user_rounded
                : pending
                    ? Icons.hourglass_top_rounded
                    : Icons.badge_outlined,
            color: color,
          ),
          title: Text(
            overview.isVerified
                ? l.kycVerified
                : pending
                    ? l.kycPending
                    : rejected
                        ? l.kycRejected
                        : l.kycNotSubmitted,
          ),
          subtitle: latest == null
              ? Text(l.kycExplanation)
              : Text(_typeLabel(latest.type)),
        ),
        if (rejected && latest?.rejectionReason != null)
          Text(
            l.kycRejectionReason(latest!.rejectionReason!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (!overview.isVerified && !pending) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _picking ? null : _submit,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(rejected ? l.kycSubmitAgain : l.kycSubmit),
          ),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    final type = await showDialog<KycDocumentType>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(context.l10n.kycChooseType),
        children: [
          for (final type in KycDocumentType.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, type),
              child: Text(_typeLabel(type)),
            ),
        ],
      ),
    );
    if (type == null || !mounted) return;
    setState(() => _picking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
        withReadStream: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final selected = result.files.single;
      if (selected.size <= 0 ||
          selected.size > ClientKycRepository.maxDocumentBytes) {
        throw const ApiException(message: 'err_invalid_kyc_document');
      }
      final bytes = BytesBuilder(copy: false);
      await for (final chunk
          in selected.readStream ?? selected.xFile.openRead()) {
        if (bytes.length + chunk.length >
            ClientKycRepository.maxDocumentBytes) {
          throw const ApiException(message: 'err_invalid_kyc_document');
        }
        bytes.add(chunk);
      }
      await ref.read(clientKycControllerProvider.notifier).submit(
            KycSubmission(
              type: type,
              fileName: selected.name,
              bytes: bytes.takeBytes(),
            ),
          );
      if (mounted) _message(context.l10n.kycSubmitted);
    } on ApiException catch (error) {
      if (!mounted) return;
      _message(error.message == 'err_invalid_kyc_document'
          ? context.l10n.kycInvalidFile
          : localizeApiException(context, error));
    } catch (_) {
      if (mounted) _message(context.l10n.kycInvalidFile);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  String _typeLabel(KycDocumentType type) => switch (type) {
        KycDocumentType.idCard => context.l10n.kycIdCard,
        KycDocumentType.passport => context.l10n.kycPassport,
        KycDocumentType.driverLicense => context.l10n.kycDriverLicense,
        KycDocumentType.selfie => context.l10n.kycSelfie,
        KycDocumentType.addressProof => context.l10n.kycAddressProof,
      };

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
