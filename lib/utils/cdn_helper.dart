/// CDN Helper für Cloudflare-gecachte Bilder
///
/// Verwendet anstelle von Firebase Storage Download-URLs die CDN-URL.
///
/// Funktionsweise:
/// Baut URLs, die auf https://cdn.aldeebtech.de/images/... zeigen.
/// Der CDN-Proxy erwartet den Storage-Pfad als ein URL-encoded Segment,
/// d.h. Slashes werden als %2F kodiert:
///   https://cdn.aldeebtech.de/images/stores%2Fabc%2Fproducts%2F123%2Fimg.jpg
class CdnHelper {
  /// CDN Base URL
  static const String cdnBaseUrl = 'https://cdn.aldeebtech.de/images';

  /// Regex, um alte Firebase Storage URLs zu erkennen und zu parsen
  static final RegExp _storageUrlPattern = RegExp(
    r'https://firebasestorage\.googleapis\.com/v0/b/[^/]+/o/(.+)\?alt=media',
  );

  // ---------------------------------------------------------------------------
  // Zentrale Encoding-Funktion
  // ---------------------------------------------------------------------------

  /// Baut eine CDN-URL aus einem Firebase Storage Pfad.
  /// Der Pfad wird mit Uri.encodeComponent kodiert (%2F statt /).
  static String cdnUrlForStoragePath(String storagePath) {
    final encoded = Uri.encodeComponent(storagePath);
    return '$cdnBaseUrl/$encoded';
  }

  // ---------------------------------------------------------------------------
  // Produkt-Bilder
  // ---------------------------------------------------------------------------

  /// Baut die URL für ein Produktbild.
  static String buildUrl({
    required String storeId,
    required String productId,
    required String filename,
  }) {
    return cdnUrlForStoragePath(
      'stores/$storeId/products/$productId/$filename',
    );
  }

  // ---------------------------------------------------------------------------
  // Thumbnails
  // ---------------------------------------------------------------------------

  /// Erzeugt aus einer beliebigen URL die Thumbnail-Version.
  ///
  /// Wandelt "bild.jpg" oder "bild_1600x1600.jpeg" in "bild_360x360.jpeg" um.
  /// Für Logo-URLs (mit /logos/ im Pfad) wird die URL unverändert zurückgegeben,
  /// da sie bereits die resized Variante darstellen.
  static String getThumbnailUrl(String url) {
    if (url.isEmpty) return '';

    // Logo URLs mit /logos/ im Pfad sind bereits resized — unverändert zurückgeben
    // Prüfe sowohl unencoded (/logos/) als auch encoded (%2Flogos%2F)
    if (url.contains('/logos/') ||
        url.toLowerCase().contains('%2flogos%2f')) {
      return url;
    }

    // Wenn es keine CDN URL ist, versuchen wir sie erst zu konvertieren
    String workUrl = url;
    if (!workUrl.startsWith(cdnBaseUrl)) {
      workUrl = convertToCdn(url);
    }

    // Dateiendung finden
    final int lastDot = workUrl.lastIndexOf('.');
    if (lastDot == -1) return workUrl;

    String basePath = workUrl.substring(0, lastDot);
    // Falls schon eine Dimension im Namen ist (z.B. _1600x1600), diese entfernen
    basePath = basePath.replaceAll(RegExp(r'_\d+x\d+$'), '');

    // Thumbnail-Suffix anhängen
    // Resize Extension macht meistens .jpeg daraus, auch wenn Original .jpg war
    return '${basePath}_360x360.jpeg';
  }

  // ---------------------------------------------------------------------------
  // Konvertierung
  // ---------------------------------------------------------------------------

  /// Konvertiert eine alte Firebase Storage URL zu einer CDN URL.
  ///
  /// Beispiel Input:  .../o/stores%2F123%2Fproducts%2F456%2Fimage.jpg?...
  /// Beispiel Output: .../images/stores%2F123%2Fproducts%2F456%2Fimage.jpg
  static String convertToCdn(String? url) {
    if (url == null || url.isEmpty) return '';

    // 1. Ist es schon eine CDN URL? -> Fertig.
    if (url.startsWith(cdnBaseUrl)) return url;

    // 2. Ist es eine Firebase URL? -> Parsen.
    final match = _storageUrlPattern.firstMatch(url);
    if (match != null) {
      try {
        // Der Pfad ist URL-Encoded (stores%2F123...), wir müssen ihn decodieren
        final fullPath = Uri.decodeComponent(match.group(1)!);
        // Und dann korrekt für den CDN-Proxy wieder encoden
        return cdnUrlForStoragePath(fullPath);
      } catch (e) {
        return url;
      }
    }

    // 3. Weder noch -> Original zurückgeben (z.B. externes Bild)
    return url;
  }

  /// Prüft, ob ein String eine gültige CDN URL ist
  static bool isCdnUrl(String? url) {
    return url != null && url.startsWith(cdnBaseUrl);
  }

  /// Prüft, ob eine URL auf ein resized Logo zeigt (encoded oder unencoded).
  static bool isResizedLogoUrl(String? url) {
    if (url == null) return false;
    return url.contains('/logos/') ||
        url.toLowerCase().contains('%2flogos%2f');
  }

  /// Extrahiert den Storage-Pfad aus einer CDN-URL (decoded).
  /// Gibt null zurück wenn keine CDN-URL.
  static String? extractStoragePath(String url) {
    if (!url.startsWith(cdnBaseUrl)) return null;
    final encoded = url.substring(cdnBaseUrl.length + 1); // +1 für "/"
    try {
      return Uri.decodeComponent(encoded);
    } catch (_) {
      return encoded;
    }
  }

  // ---------------------------------------------------------------------------
  // Store-Logo (Legacy — alt, vor dem /original/ Flow)
  // ---------------------------------------------------------------------------

  /// Generiert CDN-URL für Store-Logo (Legacy-Pfad ohne /original/).
  static String buildStoreLogoUrl({
    required String storeId,
    required String filename,
    int? size,
  }) {
    if (size == null) {
      return cdnUrlForStoragePath('stores/$storeId/logo/$filename');
    }
    final dotIdx = filename.lastIndexOf('.');
    if (dotIdx == -1) {
      return cdnUrlForStoragePath('stores/$storeId/logo/$filename');
    }
    final base = filename.substring(0, dotIdx);
    final ext = filename.substring(dotIdx);
    final resizedExt = ext == '.jpg' ? '.jpeg' : ext;
    return cdnUrlForStoragePath(
      'stores/$storeId/logo/${base}_${size}x$size$resizedExt',
    );
  }

  // ---------------------------------------------------------------------------
  // Store-Logo (Neuer Flow — /original/ + Resize Extension)
  // ---------------------------------------------------------------------------

  /// CDN-URL für resized Logo-Variante.
  ///
  /// Resize Extension schreibt in /logos/ Unterordner:
  ///   stores/{storeId}/logo/original/logos/{baseName}_360x360.{webp|png}
  static String buildResizedLogoCdnUrl({
    required String storeId,
    required String baseName,
    required String ext,
  }) {
    final safeExt = (ext == '.png') ? '.png' : '.webp';
    return cdnUrlForStoragePath(
      'stores/$storeId/logo/original/logos/${baseName}_360x360$safeExt',
    );
  }

  /// CDN-URL für das Original-Logo (PNG, Transparenz).
  static String buildOriginalLogoCdnUrl({
    required String storeId,
    required String baseName,
  }) {
    return cdnUrlForStoragePath(
      'stores/$storeId/logo/original/$baseName.png',
    );
  }
}
