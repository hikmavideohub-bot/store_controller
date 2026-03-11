import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

/// Wiederverwendbares Widget für Store-Logo Upload
///
/// - Zeigt aktuelles Logo oder Platzhalter
/// - Tap => Upload
/// - Delete => sofort löschen (kein "erst nach Speichern")
/// - Zeigt Status: Uploading / Processing / Deleting
class StoreLogoPicker extends StatefulWidget {
  final String? logoUrl;
  final String storeName;
  final String storeId;

  /// Optional: falls du lokal sofort UI updaten willst
  final Function(String newLogoUrl) onLogoChanged;

  /// Löscht Logo sofort (Firestore/Backend) + Storage cleanup (best effort)
  final Future<void> Function()? onLogoDeleted;

  /// Wird nach Upload aufgerufen, um Polling/Resized-Persist abzuwarten
  final Future<void> Function(String baseName)? onLogoUploaded;

  /// z.B. um Settings "disabled" zu machen während Upload/Delete läuft
  final ValueChanged<bool>? onUploadStateChanged;

  final double size;

  const StoreLogoPicker({
    super.key,
    required this.logoUrl,
    required this.storeName,
    required this.storeId,
    required this.onLogoChanged,
    this.onLogoDeleted,
    this.onLogoUploaded,
    this.onUploadStateChanged,
    this.size = 80,
  });

  @override
  State<StoreLogoPicker> createState() => _StoreLogoPickerState();
}

class _StoreLogoPickerState extends State<StoreLogoPicker> {
  bool _busy = false;
  double _progress = 0.0;

  /// none | uploading | processing | deleting
  String _phase = 'none';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final s = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _busy ? null : _pickAndUploadLogo,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _busy
                      ? _buildProgressOverlay(colors, s)
                      : _buildLogoContent(colors),
                ),
              ),
            ),

            // Delete Button (unten links) - nur wenn Logo vorhanden
            if (_hasValidLogo && widget.onLogoDeleted != null)
              Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTap: _busy ? null : () => _confirmDelete(context, s),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 14,
                      color: colors.onError,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          s.logoHint,
          style: TextStyle(
            fontSize: 11,
            color: theme.hintColor,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool get _hasValidLogo {
    final url = widget.logoUrl?.trim() ?? '';
    return url.isNotEmpty && url.startsWith('http');
  }

  Widget _buildLogoContent(ColorScheme colors) {
    if (_hasValidLogo) {
      return CachedNetworkImage(
        key: ValueKey(widget.logoUrl),
        imageUrl: widget.logoUrl!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
        placeholder: (context, url) => _buildPlaceholder(colors),
        errorWidget: (context, url, error) => _buildPlaceholder(colors),
      );
    }
    return _buildPlaceholder(colors);
  }

  Widget _buildPlaceholder(ColorScheme colors) {
    return Container(
      color: colors.primaryContainer.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          size: widget.size * 0.4,
          color: colors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildProgressOverlay(ColorScheme colors, AppLocalizations s) {
    final label = switch (_phase) {
      'uploading' => _progress > 0 ? '${(_progress * 100).toStringAsFixed(0)}%' : s.logoUploading,
      'deleting' => s.logoDeleting,
      _ => s.logoProcessing,
    };

    return Container(
      color: colors.inverseSurface.withValues(alpha: 0.78),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              child: CircularProgressIndicator(
                value: (_phase == 'uploading' && _progress > 0) ? _progress : null,
                color: colors.onInverseSurface,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.onInverseSurface,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations s) async {
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.deleteLogoTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(s.deleteLogoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _runDelete(s);
    }
  }

  Future<void> _runDelete(AppLocalizations s) async {
    if (widget.onLogoDeleted == null) return;

    setState(() {
      _busy = true;
      _progress = 0.0;
      _phase = 'deleting';
    });
    widget.onUploadStateChanged?.call(true);

    try {
      await widget.onLogoDeleted!.call();

      // UI sofort leeren (falls Parent nicht direkt rebuildet)
      widget.onLogoChanged('');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.logoDeletedToast)),
      );
    } catch (e) {
      debugPrint('Logo delete error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.uploadError)),
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = 0.0;
          _phase = 'none';
        });
      }
      widget.onUploadStateChanged?.call(false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    final s = AppLocalizations.of(context)!;

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file == null) return;

    // ✅ DEIN FIX: effectiveStoreId (nicht kaputt machen)
    final effectiveStoreId = widget.storeId.isNotEmpty
        ? widget.storeId
        : (FirebaseAuth.instance.currentUser?.uid ?? '');

    if (effectiveStoreId.isEmpty) {
      debugPrint('StoreLogoPicker: storeId/auth uid is empty, cannot upload');
      return;
    }

    final authUid = FirebaseAuth.instance.currentUser?.uid ?? 'NO_AUTH';
    debugPrint('Logo Upload: storeId=$effectiveStoreId, auth=$authUid');

    setState(() {
      _busy = true;
      _progress = 0.0;
      _phase = 'uploading';
    });
    widget.onUploadStateChanged?.call(true);

    try {
      final storage = FirebaseStorage.instanceFor(
        bucket: 'gs://aldeebtech-1ec64.firebasestorage.app',
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueName = 'logo_$timestamp';

      final imageRef = storage.ref(
        'stores/$effectiveStoreId/logo/original/$uniqueName.png',
      );

      final bytes = await file.readAsBytes();

      final task = imageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/png',
          cacheControl: 'public, max-age=3600',
        ),
      );

      task.snapshotEvents.listen((snapshot) {
        if (!mounted) return;
        final total = snapshot.totalBytes;
        if (total > 0) {
          setState(() {
            _progress = snapshot.bytesTransferred / total;
          });
        }
      });

      await task;
      debugPrint('Logo upload complete: $uniqueName.png');

      // Jetzt “Processing…” bis resized verfügbar + persisted ist
      if (mounted) {
        setState(() {
          _progress = 0.0; // indeterminate
          _phase = 'processing';
        });
      }

      if (widget.onLogoUploaded != null) {
        await widget.onLogoUploaded!.call(uniqueName);
      }

      if (!mounted) return;

      setState(() {
        _busy = false;
        _progress = 0.0;
        _phase = 'none';
      });
      widget.onUploadStateChanged?.call(false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.logoUpdatedToast)),
      );
    } catch (e) {
      debugPrint('Logo upload error: $e');
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = 0.0;
          _phase = 'none';
        });
        widget.onUploadStateChanged?.call(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.uploadError)),
        );
      }
      rethrow;
    }
  }
}