/// CDN Helper für Cloudflare-gecachte Bilder
///
/// Verwendet anstelle von Firebase Storage Download-URLs die CDN-URL.
///
/// Funktionsweise:
/// Baut URLs, die auf https://cdn.aldeebtech.de/images/... zeigen.
/// Die Cloud Function dahinter streamt dann den Inhalt exakt von diesem Pfad
/// aus dem Firebase Storage Bucket.
class CdnHelper {
  /// CDN Base URL
  static const String cdnBaseUrl = 'https://cdn.aldeebtech.de/images';

  /// Regex, um alte Firebase Storage URLs zu erkennen und zu parsen
  static final RegExp _storageUrlPattern = RegExp(
    r'https://firebasestorage\.googleapis\.com/v0/b/[^/]+/o/(.+)\?alt=media',
  );

  /// Hauptmethode: Baut die URL für ein neues Bild
  ///
  /// [storeId]: Die ID des Stores
  /// [productId]: Die ID des Produkts
  /// [filename]: Der Dateiname (z.B. "img_170982312.jpg")
  static String buildUrl({
    required String storeId,
    required String productId,
    required String filename,
  }) {
    // WICHTIG: Hier fügen wir explizit die Ordnerstruktur hinzu.
    // Die Cloud Function erwartet genau den Pfad, der im Bucket existiert.
    return '$cdnBaseUrl/stores/$storeId/products/$productId/$filename';
  }

  /// Hilfsmethode: Erzeugt aus einer beliebigen URL die Thumbnail-Version
  ///
  /// Nützlich für Listenansichten, um Daten zu sparen.
  /// Wandelt "bild.jpg" oder "bild_1600x1600.jpeg" in "bild_360x360.jpeg" um.
  /// Für Logo-URLs (aus /logos/ Pfad) wird die URL unverändert zurückgegeben.
  static String getThumbnailUrl(String url) {
    if (url.isEmpty) return '';

    // Logo URLs from /logos/ path are already resized thumbnails
    if (url.contains('/logos/')) return url;

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
    // Regex sucht nach "_ZAHLxZAHL" am Ende
    basePath = basePath.replaceAll(RegExp(r'_\d+x\d+$'), '');

    // Thumbnail-Suffix anhängen
    // Resize Extension macht meistens .jpeg daraus, auch wenn Original .jpg war
    return '${basePath}_360x360.jpeg';
  }

  /// Konvertiert eine alte Firebase Storage URL zu einer CDN URL
  ///
  /// Beispiel Input: .../o/stores%2F123%2Fproducts%2F456%2Fimage.jpg?...
  /// Beispiel Output: .../images/stores/123/products/456/image.jpg
  static String convertToCdn(String? url) {
    if (url == null || url.isEmpty) return '';

    // 1. Ist es schon eine CDN URL? -> Fertig.
    if (url.startsWith(cdnBaseUrl)) return url;

    // 2. Ist es eine Firebase URL? -> Parsen.
    final match = _storageUrlPattern.firstMatch(url);
    if (match != null) {
      try {
        // Der Pfad ist URL-Encoded (stores%2F123...), wir müssen ihn decodieren
        String fullPath = Uri.decodeComponent(match.group(1)!);

        // fullPath ist jetzt z.B.: "stores/123/products/456/image.jpg"
        return '$cdnBaseUrl/$fullPath';
      } catch (e) {
        // Falls Parsing fehlschlägt, Original zurückgeben
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

  /// Generiert CDN-URL für Store-Logo (Original im /stores/ Pfad)
  ///
  /// [storeId]: Die ID des Stores
  /// [filename]: Der Dateiname (z.B. "logo_170982312.jpg")
  /// [size]: 360 für Thumbnail, 1600 für Full-Size, null für Original
  static String buildStoreLogoUrl({
    required String storeId,
    required String filename,
    int? size,
  }) {
    if (size == null) {
      return '$cdnBaseUrl/stores/$storeId/logo/$filename';
    }
    final dotIdx = filename.lastIndexOf('.');
    if (dotIdx == -1) return '$cdnBaseUrl/stores/$storeId/logo/$filename';
    final base = filename.substring(0, dotIdx);
    final ext = filename.substring(dotIdx); // e.g. ".jpg", ".png"
    // .jpg → .jpeg for resize extension compatibility, others stay as-is
    final resizedExt = ext == '.jpg' ? '.jpeg' : ext;
    return '$cdnBaseUrl/stores/$storeId/logo/${base}_${size}x$size$resizedExt';
  }

  /// Baut CDN-URLs für resized Logo-Varianten im /logos/ Output-Pfad.
  ///
  /// Die Resize Extension schreibt von stores/... nach logos/stores/...
  /// [storeId]: Store ID
  /// [baseName]: z.B. "logo_1739000000" (ohne Extension)
  /// [ext]: ".webp" oder ".png"
  static String buildResizedLogoCdnUrl({
    required String storeId,
    required String baseName,
    required String ext, // erwartet z.B. ".webp" oder ".png"
  }) {
    final safeExt = (ext == '.png') ? '.png' : '.webp';

    // ✅ echter Output-Pfad (von dir verifiziert)
    return '$cdnBaseUrl/stores/$storeId/logo/original/logos/${baseName}_360x360$safeExt';
  }

  /// Baut CDN-URL für das Original-Logo im /stores/ Pfad.
  static String buildOriginalLogoCdnUrl({
    required String storeId,
    required String baseName,
  }) {
    // Original bleibt PNG (Transparenz)
    return '$cdnBaseUrl/stores/$storeId/logo/original/$baseName.png';
  }

}
