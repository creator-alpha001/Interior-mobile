/// Posting a finished job from the phone.
///
/// The web has had this since the showcase shipped; the app could only *read*
/// a portfolio, which is backwards — the photographs are taken on the phone
/// standing in the finished kitchen, and asking a vendor to mail them to
/// themselves and open a laptop is how a portfolio stays empty.
///
/// What is posted is public immediately. Ops can take something down, and the
/// copy here says that rather than promising a review that no longer happens.
library;

import 'package:interiobee_core_api/interiobee_core_api.dart';
import 'package:interiobee_core_upload/interiobee_core_upload.dart';
import 'package:interiobee_design/interiobee_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'async_view.dart';
import 'providers.dart';

/// The trades this vendor may post work in.
///
/// Approved ones only: a fabricator's painting job on their profile would
/// advertise work nobody has vetted them to do, and the API refuses it anyway.
final _postableTradesProvider = FutureProvider<List<Domain>>((ref) async {
  final dashboard = await ref.watch(dashboardProvider.future);
  return [for (final link in dashboard.domains) link.domain];
});

final _citiesProvider = FutureProvider<List<City>>(
  (ref) => ref.watch(vendorApiProvider).public.listCities().orThrow(),
);

class PostWorkScreen extends ConsumerStatefulWidget {
  const PostWorkScreen({super.key, required this.queue});

  /// The same queue the stage proof screen uses: uploads survive a lift with
  /// no signal, and leaving the screen does not lose the photographs.
  final UploadQueue queue;

  @override
  ConsumerState<PostWorkScreen> createState() => _PostWorkScreenState();
}

class _PostWorkScreenState extends ConsumerState<PostWorkScreen> {
  final _picker = ImagePicker();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _details = TextEditingController();
  final _highlights = <TextEditingController>[TextEditingController()];

  String? _domainId;
  String? _cityId;
  bool _posting = false;
  String? _error;
  int _posted = 0;

  @override
  void initState() {
    super.initState();
    widget.queue.addListener(_onQueue);
  }

  @override
  void dispose() {
    widget.queue.removeListener(_onQueue);
    _title.dispose();
    _summary.dispose();
    _details.dispose();
    for (final controller in _highlights) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onQueue() => setState(() {});

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final files = await _picker.pickMultiImage(limit: 10);
      for (final file in files) {
        await widget.queue.add(
          localPath: file.path,
          purpose: UploadPurpose.portfolioItem,
        );
      }
      return;
    }

    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 3000,
      imageQuality: 90,
    );
    if (shot == null) return;
    await widget.queue.add(
      localPath: shot.path,
      purpose: UploadPurpose.portfolioItem,
    );
  }

  /// The typed details as the HTML the rest of the platform stores.
  ///
  /// The phone has no rich text editor: a toolbar over a `TextField` is a week
  /// of work and a worse experience than the keyboard the vendor already has.
  /// So what they type is wrapped — a paragraph per blank line — with the four
  /// characters that would otherwise be markup escaped. The API sanitises it
  /// again on arrival regardless, as it does everything from the web editor.
  String _detailsHtml() {
    final text = _details.text.trim();
    if (text.isEmpty) return '';

    String escape(String value) => value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');

    return text
        .split(RegExp(r'\n\s*\n'))
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .map((block) => '<p>${escape(block).replaceAll('\n', '<br />')}</p>')
        .join();
  }

  Future<void> _post({required bool again}) async {
    final domainId = _domainId;
    final media = widget.queue.completedAssetIds;
    if (domainId == null || _title.text.trim().isEmpty || media.isEmpty) return;

    setState(() {
      _posting = true;
      _error = null;
    });

    try {
      await ref
          .read(vendorApiProvider)
          .vendor
          .addPortfolioItem(
            body: AddPortfolioItemBody(
              domainId: domainId,
              cityId: _cityId,
              title: _title.text.trim(),
              description: _summary.text.trim(),
              highlights: [
                for (final controller in _highlights)
                  if (controller.text.trim().isNotEmpty) controller.text.trim(),
              ],
              details: _detailsHtml(),
              media: media,
            ),
          )
          .orThrow();

      ref.invalidate(portfolioProvider);
      if (!mounted) return;

      /// The trade and the city stay chosen: somebody posting their work posts
      /// all of it, usually from the same job in the same city.
      _title.clear();
      _summary.clear();
      _details.clear();
      for (final controller in _highlights) {
        controller.clear();
      }

      setState(() {
        _posting = false;
        _posted += 1;
      });
      if (!again && mounted) Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _posting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trades = ref
        .watch(_postableTradesProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <Domain>[]);
    final cities = ref
        .watch(_citiesProvider)
        .maybeWhen(data: (list) => list, orElse: () => const <City>[]);

    _domainId ??= trades.isEmpty ? null : trades.first.id;
    final ready =
        _domainId != null &&
        _title.text.trim().isNotEmpty &&
        widget.queue.completedAssetIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('Post work'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Space.gutter),
          children: [
            const SizedBox(height: Space.sm),
            if (_posted > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: ActionRequired(
                  title: context.l10n.plural(
                    _posted,
                    '{n} job posted',
                    '{n} jobs posted',
                  ),
                  body: context.t(
                    'It is on your public profile now. Add another while the '
                    'photographs are to hand.',
                  ),
                ),
              ),
            if (trades.isEmpty)
              EmptyState(
                title: context.t('No trades yet'),
                body: context.t(
                  'You can post work once our team has approved you for a '
                  'trade.',
                ),
              )
            else ...[
              Text(context.t('Trade'), style: context.text.labelMedium),
              const SizedBox(height: Space.xxs),
              DropdownButtonFormField<String>(
                initialValue: _domainId,
                items: [
                  for (final trade in trades)
                    DropdownMenuItem(value: trade.id, child: Text(trade.name)),
                ],
                onChanged: _posting
                    ? null
                    : (value) => setState(() => _domainId = value),
              ),
              const SizedBox(height: Space.md),
              Text(context.t('City'), style: context.text.labelMedium),
              const SizedBox(height: Space.xxs),
              DropdownButtonFormField<String?>(
                initialValue: _cityId,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(context.t('Not specified')),
                  ),
                  for (final city in cities)
                    DropdownMenuItem<String?>(
                      value: city.id,
                      child: Text(city.name),
                    ),
                ],
                onChanged: _posting
                    ? null
                    : (value) => setState(() => _cityId = value),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _title,
                enabled: !_posting,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: context.t('Title')),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _summary,
                enabled: !_posting,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.t('One-line summary'),
                ),
              ),
              const SizedBox(height: Space.lg),
              Text(context.t('Highlights'), style: context.text.labelMedium),
              const SizedBox(height: Space.xxs),
              Text(
                context.t(
                  'The short lines a customer skims: materials, size, how long '
                  'it took.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.xs),
              for (var i = 0; i < _highlights.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _highlights[i],
                          enabled: !_posting,
                          decoration: const InputDecoration(isDense: true),
                          onChanged: (value) {
                            // A filled last line grows the list, so there is
                            // always an empty one and never a button first.
                            if (i == _highlights.length - 1 &&
                                value.trim().isNotEmpty &&
                                _highlights.length < 6) {
                              setState(
                                () => _highlights.add(TextEditingController()),
                              );
                            }
                          },
                        ),
                      ),
                      if (_highlights.length > 1)
                        IconButton(
                          onPressed: _posting
                              ? null
                              : () => setState(
                                  () => _highlights.removeAt(i).dispose(),
                                ),
                          icon: const Icon(Icons.close),
                          tooltip: context.t('Remove'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: Space.md),
              TextField(
                controller: _details,
                enabled: !_posting,
                minLines: 4,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.t('Details'),
                  helperText: context.t(
                    'What the job involved, and anything that made it hard.',
                  ),
                ),
              ),

              const SizedBox(height: Space.lg),
              Text(context.t('Photographs'), style: context.text.labelMedium),
              const SizedBox(height: Space.xxs),
              Text(
                context.t(
                  'Only photographs of work you did yourself. The first one is '
                  'the cover.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.xs),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _posting
                          ? null
                          : () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(context.t('Camera')),
                    ),
                  ),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _posting
                          ? null
                          : () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(context.t('Gallery')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              for (final upload in widget.queue.items) ...[
                InterioBeeCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          upload.assetId == null
                              ? context.t('Uploading…')
                              : context.t('Ready'),
                          style: context.text.bodySmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () => widget.queue.remove(upload.id),
                        icon: const Icon(Icons.close),
                        tooltip: context.t('Remove'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Space.xs),
              ],

              if (_error != null) ...[
                const SizedBox(height: Space.sm),
                Text(
                  _error!,
                  style: context.text.bodySmall?.copyWith(
                    color: context.palette.wrong,
                  ),
                ),
              ],

              const SizedBox(height: Space.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ready && !_posting
                      ? () => _post(again: false)
                      : null,
                  child: Text(context.t('Publish')),
                ),
              ),
              const SizedBox(height: Space.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: ready && !_posting
                      ? () => _post(again: true)
                      : null,
                  child: Text(context.t('Save and add more')),
                ),
              ),
              const SizedBox(height: Space.sm),
              Text(
                context.t(
                  'Posted work goes on your public profile straight away. Our '
                  'team can take something down, and will say why.',
                ),
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: Space.xxxl),
          ],
        ),
      ),
    );
  }
}
