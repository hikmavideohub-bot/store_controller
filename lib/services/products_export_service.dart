import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:store_controller/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/product.dart';

class ProductsExportService {
  ProductsExportService._();
  static final instance = ProductsExportService._();

  final _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Full flow: fetch products → build XLSX → trigger browser download.
  Future<void> exportStoreProductsToXlsx({
    required BuildContext context,
    required String storeId,
  }) async {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    try {
      // Fetch all products (paginated in batches of 500)
      final products = <Product>[];
      final createdAtMap = <String, Timestamp?>{};

      QueryDocumentSnapshot<Map<String, dynamic>>? lastDoc;
      const batchSize = 500;

      while (true) {
        Query<Map<String, dynamic>> query = _db
            .collection('stores_public')
            .doc(storeId)
            .collection('products')
            .orderBy('created_at', descending: true)
            .limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snap = await query.get();
        if (snap.docs.isEmpty) break;

        for (final doc in snap.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          products.add(Product.fromMap(data));
          createdAtMap[doc.id] = data['created_at'] as Timestamp?;
        }

        if (snap.docs.length < batchSize) break;
        lastDoc = snap.docs.last;
      }

      final bytes = await buildProductsXlsx(
        t: t,
        products: products,
        locale: locale,
        createdAtMap: createdAtMap,
      );

      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filename = 'products_$timestamp.xlsx';
      await _shareFile(bytes, filename);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.xlsExportSuccess)),
        );
      }
    } catch (e) {
      debugPrint('[ProductsExportService] Export error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.xlsExportError)),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build XLSX
  // ---------------------------------------------------------------------------

  Future<Uint8List> buildProductsXlsx({
    required AppLocalizations t,
    required List<Product> products,
    required Locale locale,
    Map<String, Timestamp?>? createdAtMap,
  }) async {
    await initializeDateFormatting(locale.toString(), null);

    final excel = Excel.createExcel();
    final sheetName = 'Products';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final sheet = excel[sheetName];

    // ---- Header row ----
    final headers = [
      t.xlsProductId,     // 0
      t.xlsName,          // 1
      t.xlsCategory,      // 2
      t.xlsQty,           // 3
      t.xlsUnit,          // 4
      t.xlsPurchasePrice,  // 5  (empty)
      t.xlsPrice,         // 6
      t.xlsVat,           // 7  (empty)
      t.xlsGrossPrice,    // 8  (empty)
      t.xlsStock,         // 9  (empty)
      t.xlsSupplier,      // 10 (empty)
      t.xlsActive,        // 11
      t.xlsOfferType,     // 12
      t.xlsCreatedAt,     // 13
      t.xlsNote,          // 14 (empty)
    ];

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // ---- Data rows ----
    final dateFmt = DateFormat.yMd(locale.toString()).add_Hm();
    final yes = t.commonYes;
    final no = t.commonNo;

    for (var row = 0; row < products.length; row++) {
      final p = products[row];
      final excelRow = row + 1;

      // 0 — Produkt-ID
      _setText(sheet, excelRow, 0, p.id);
      // 1 — Name
      _setText(sheet, excelRow, 1, p.name);
      // 2 — Kategorie
      _setText(sheet, excelRow, 2, p.category);
      // 3 — Menge (numeric)
      _setNum(sheet, excelRow, 3, p.sizeValue);
      // 4 — Einheit
      _setText(sheet, excelRow, 4, p.sizeUnit);
      // 5 — Einkaufspreis (EK) → leer
      // 6 — Preis (Einzel) (numeric)
      _setNum(sheet, excelRow, 6, p.price);
      // 7 — MwSt (%) → leer
      // 8 — Brutto-Preis → leer
      // 9 — Bestand → leer
      // 10 — Lieferant → leer
      // 11 — Status (aktiv)
      _setText(sheet, excelRow, 11, p.productActive ? yes : no);
      // 12 — Angebotsart
      _setText(sheet, excelRow, 12, p.offerType);
      // 13 — Erstellt am
      final ts = createdAtMap?[p.id];
      if (ts != null) {
        _setText(sheet, excelRow, 13, dateFmt.format(ts.toDate().toLocal()));
      }
      // 14 — Notiz → leer
    }

    final encoded = excel.encode();
    if (encoded == null) throw Exception('Excel encoding returned null');
    return Uint8List.fromList(encoded);
  }

  // ---------------------------------------------------------------------------
  // Share / Download
  // ---------------------------------------------------------------------------

  Future<void> _shareFile(Uint8List bytes, String filename) async {
    final xFile = XFile.fromData(
      bytes,
      name: filename,
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    await Share.shareXFiles([xFile], subject: filename);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setText(Sheet sheet, int row, int col, String value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = TextCellValue(value);
  }

  void _setNum(Sheet sheet, int row, int col, double value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = DoubleCellValue(value);
  }
}
