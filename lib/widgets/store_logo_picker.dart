import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';

/// Wiederverwendbares Widget für Store-Logo Upload
///
/// Zeigt aktuelles Logo (Bild) oder Store-Name-Initialen als Fallback.
/// Tap öffnet ImagePicker für neuen Upload.
class StoreLogoPicker extends StatefulWidget {
  final String? logoUrl;
  final String storeName;
  final String storeId;
  final Function(String newLogoUrl) onLogoChanged;
  final Function()? onLogoDeleted;
  final Function(String baseName)? onLogoUploaded;
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
  bool _uploading = false;
  double _uploadProgress = 0.0;

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
            // Logo Container
            GestureDetector(
              onTap: _uploading ? null : _pickAndUploadLogo,
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
                  child: _uploading
                      ? _buildUploadProgress(colors)
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
                  onTap: _uploading ? null : () => _confirmDelete(context, s),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.delete,
                      size: 14,
                      color: Colors.white,
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
        placeholder: (_, __) => _buildInitials(colors),
        errorWidget: (_, __, ___) => _buildInitials(colors),
      );
    }
    return _buildInitials(colors);
  }

  Widget _buildInitials(ColorScheme colors) {
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

  Widget _buildUploadProgress(ColorScheme colors) {
    return Container(
      color: colors.scrim.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              child: CircularProgressIndicator(
                value: _uploadProgress > 0 ? _uploadProgress : null,
                color: colors.onPrimary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(_uploadProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: colors.onPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zeigt Bestätigungsdialog vor dem Löschen des Logos
  Future<void> _confirmDelete(BuildContext context, AppLocalizations s) async {
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: colors.error),
            const SizedBox(width: 12),
            Expanded(child: Text(s.deleteLogo)),
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
      widget.onLogoDeleted?.call();
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
      _uploading = true;
      _uploadProgress = 0.0;
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

      final task = imageRef.putData(
        await file.readAsBytes(),
        SettableMetadata(
          contentType: 'image/png',
          cacheControl: 'public, max-age=3600',
        ),
      );

      task.snapshotEvents.listen((snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await task;
      debugPrint('Logo upload complete: $uniqueName.png');

      // Signal upload finished — viewmodel polls for resized variant
      widget.onLogoUploaded?.call(uniqueName);

      if (mounted) {
        setState(() {
          _uploading = false;
        });
        widget.onUploadStateChanged?.call(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.saveChangesButton),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Logo upload error: $e');
      if (mounted) {
        setState(() {
          _uploading = false;
        });
        widget.onUploadStateChanged?.call(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.uploadError)),
        );
      }
    }
  }
}
