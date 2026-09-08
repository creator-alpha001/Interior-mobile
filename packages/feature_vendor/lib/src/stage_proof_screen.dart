/// Submitting proof that a stage is done.
///
/// The vendor's core action, and the one MOBILE.md is most careful about.
///
/// **The button says "Submit for approval", not "Mark complete".** §6.2:
/// *"evidence is not completion, and the screen must not imply it is."* A stage
/// is done when somebody at Aangan has checked the photographs — that is a
/// platform rule, enforced server-side, and the customer's progress bar moves
/// on the approval rather than on this submission. Wording it as completion
/// would teach the vendor something false about how they get paid.
///
/// The colour carries the same distinction. A stage the vendor has submitted is
/// **ochre** — waiting on somebody else. It turns **sage** the moment ops
/// approve it. DESIGN.md §1.4 calls that the most important transition in the
/// product, because it is "a stage is done when somebody checked" made visible.
library;

import 'package:aangan_core_api/aangan_core_api.dart';
import 'package:aangan_core_upload/aangan_core_upload.dart';
import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'providers.dart';

class StageProofScreen extends ConsumerStatefulWidget {
  const StageProofScreen({
    super.key,
    required this.project,
    required this.milestone,
    required this.queue,
  });

  final VendorProjectView project;
  final ProjectMilestone milestone;
  final UploadQueue queue;

  @override
  ConsumerState<StageProofScreen> createState() => _StageProofScreenState();
}

class _StageProofScreenState extends ConsumerState<StageProofScreen> {
  final _note = TextEditingController();
  final _picker = ImagePicker();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_onQueue);
  }

  @override
  void dispose() {
    widget.queue.removeListener(_onQueue);
    _note.dispose();
    super.dispose();
  }

  void _onQueue() => setState(() {});

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final files = await _picker.pickMultiImage(limit: 8);
      for (final file in files) {
        await widget.queue.add(
          localPath: file.path,
          purpose: UploadPurpose.milestoneProof,
        );
      }
      return;
    }

    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      // The plugin's own downscale, before ours. Cheaper than compressing an
      // 8MB frame that was never needed at that size.
      maxWidth: 3000,
      imageQuality: 90,
    );
    if (shot == null) return;

    await widget.queue.add(
      localPath: shot.path,
      purpose: UploadPurpose.milestoneProof,
    );
  }

  Future<void> _submit() async {
    final assetIds = widget.queue.completedAssetIds;
    if (assetIds.isEmpty) return;

    setState(() => _submitting = true);

    try {
      await ref
          .read(vendorApiProvider)
          .vendor
          .submitMilestoneProof(
            id: widget.project.project.id,
            stageId: widget.milestone.id,
            body: SubmitMilestoneProofBody(
              note: _note.text.trim(),
              proof: assetIds,
            ),
          )
          .orThrow();

      if (!mounted) return;
      refreshAfterWriteFrom(ref);
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploads = widget.queue.items;
    final ready = widget.queue.completedAssetIds;
    final pending = uploads.where((u) => u.state != UploadState.done).toList();
    final failed = uploads.where((u) => u.state == UploadState.failed).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.milestone.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.md),
            Text(widget.project.domain.name, style: context.text.labelMedium),
            const SizedBox(height: Space.xxs),
            Text(widget.milestone.title, style: context.text.headlineLarge),
            if (widget.milestone.description != null) ...[
              const SizedBox(height: Space.xs),
              Text(
                widget.milestone.description!,
                style: context.text.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],

            /// Rework, if ops sent it back. This is the highest-value thing on
            /// the screen when it is present, so it goes above the camera.
            if (widget.milestone.verification ==
                    MilestoneVerification.rejected &&
                widget.milestone.verifierNote != null) ...[
              const SizedBox(height: Space.lg),
              ActionRequired(
                title: context.t('Sent back for rework'),
                body: widget.milestone.verifierNote!,
              ),
            ],

            SectionHead(
              context.t('Photographs'),
              eyebrow: context.t('The evidence'),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => _pick(ImageSource.camera),
                    icon: const Icon(
                      Icons.photo_camera_outlined,
                      size: TapTarget.glyph,
                    ),
                    label: Text(context.t('Camera')),
                  ),
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _submitting
                        ? null
                        : () => _pick(ImageSource.gallery),
                    icon: const Icon(
                      Icons.photo_library_outlined,
                      size: TapTarget.glyph,
                    ),
                    label: Text(context.t('Gallery')),
                  ),
                ),
              ],
            ),

            if (uploads.isEmpty) ...[
              const SizedBox(height: Space.md),
              Text(
                context.t(
                  'At least one photograph is required. Ops check the work '
                  'against these before the stage counts.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: Space.sm),
            for (final upload in uploads) ...[
              _UploadRow(
                upload: upload,
                onRetry: () => widget.queue.retry(upload.id),
                onRemove: () => widget.queue.remove(upload.id),
              ),
              const SizedBox(height: Space.xs),
            ],

            if (failed.isNotEmpty) ...[
              const SizedBox(height: Space.xs),
              Text(
                // The queue survives the app closing, so this is recoverable
                // rather than lost — worth saying, because the vendor's
                // instinct after a failure is to start again from the camera.
                '${failed.length} did not send. They are saved on this device '
                'and will retry — you will not have to take them again.',
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.wrong,
                ),
              ),
            ],

            SectionHead(
              context.t('What you did'),
              eyebrow: context.t('For the coordinator'),
            ),
            TextField(
              controller: _note,
              enabled: !_submitting,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.t('Note'),
                hintText: context.t(
                  context.t('Carcass fitted, shutters hung, hardware pending…'),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: Space.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    ready.isNotEmpty &&
                        pending.isEmpty &&
                        _note.text.trim().isNotEmpty &&
                        !_submitting
                    ? _submit
                    : null,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    // Never "Mark complete". Evidence is not completion.
                    : Text(context.t('Submit for approval')),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              pending.isNotEmpty
                  ? 'Waiting for ${pending.length} photograph(s) to finish sending.'
                  : context.t(
                      'Ops check the photographs against the stage. The customer’s '
                      'progress moves when they approve, not when you submit.',
                    ),
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.upload,
    required this.onRetry,
    required this.onRemove,
  });

  final QueuedUpload upload;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final (Widget badge, String detail) = switch (upload.state) {
      UploadState.done => (
        StatusPill(context.t('Sent'), tone: StatusTone.verified),
        _saving(context, upload),
      ),
      UploadState.uploading => (
        StatusPill(context.t('Sending'), tone: StatusTone.waiting),
        context.t('Uploading…'),
      ),
      UploadState.pending => (
        StatusPill(context.t('Queued'), tone: StatusTone.waiting),
        context.t('Waiting to send'),
      ),
      UploadState.failed => (
        StatusPill(context.t('Failed'), tone: StatusTone.wrong),
        upload.error ?? context.t('Could not send'),
      ),
    };

    return AanganCard(
      child: Row(
        children: [
          Icon(
            Icons.image_outlined,
            size: TapTarget.glyph,
            color: context.colors.onSurfaceVariant,
          ),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upload.localPath.split(RegExp(r'[/\\]')).last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium,
                ),
                Text(
                  detail,
                  style: context.text.bodySmall?.copyWith(
                    color: upload.state == UploadState.failed
                        ? palette.wrong
                        : context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          badge,
          if (upload.state == UploadState.failed)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: TapTarget.glyph),
              tooltip: context.t('Try again'),
            )
          else if (upload.state != UploadState.uploading)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: TapTarget.glyph),
              tooltip: context.t('Remove'),
            ),
        ],
      ),
    );
  }

  /// Vendors watch their data. Showing the saving is worth the line.
  static String _saving(BuildContext context, QueuedUpload upload) {
    final before = upload.originalBytes;
    final after = upload.compressedBytes;
    if (before == null || after == null || before <= after) {
      return context.t('Sent');
    }

    // Megabytes are the same two letters everywhere, so the unit is not copy.
    String mb(int bytes) => '${(bytes / 1048576).toStringAsFixed(1)}MB';
    return context.t('Sent · {before} → {after}', {
      'before': mb(before),
      'after': mb(after),
    });
  }
}
