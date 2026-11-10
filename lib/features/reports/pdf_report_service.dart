import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/formatters.dart';
import '../documents/models/vehicle_document.dart';
import '../maintenance/models/maintenance_item.dart';
import 'report_data.dart';

const _graphite = PdfColor.fromInt(0xFF1B1D21);
const _amber = PdfColor.fromInt(0xFFB45309);
const _muted = PdfColor.fromInt(0xFF5A5F66);
const _line = PdfColor.fromInt(0xFFD9D6CF);
const _surface = PdfColor.fromInt(0xFFF5F4F1);
const _success = PdfColor.fromInt(0xFF047857);
const _danger = PdfColor.fromInt(0xFFB91C1C);

class PdfReportService {
  Future<Uint8List> build(
    VehicleReportData data, {
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final (baseFont, boldFont) = await _loadFonts();
    final document = pw.Document(
      title: 'Hoja de vida · ${data.vehicle.name}',
      author: 'MotorCheck',
      subject: 'Historial de mantenimiento',
      creator: 'MotorCheck',
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: format,
        maxPages: 50,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'MOTORCHECK',
                      style: const pw.TextStyle(
                        color: _amber,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      data.vehicle.name,
                      style: const pw.TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Datos suministrados por el propietario · '
                  'Generado por MotorCheck el ${data.generatedAtLabel}',
                  style: const pw.TextStyle(color: _muted, fontSize: 7),
                ),
              ),
              pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: const pw.TextStyle(color: _muted, fontSize: 7),
              ),
            ],
          ),
        ),
        build: (context) => [
          _titleBlock(data),
          pw.SizedBox(height: 14),
          _summaryGrid(data),
          pw.SizedBox(height: 16),
          _section('Documentos', _documentsTable(data.documents)),
          pw.SizedBox(height: 14),
          _section('Próximos mantenimientos', _upcomingTable(data)),
          pw.SizedBox(height: 14),
          _sectionTitle('Historial de mantenimientos'),
          ..._historyWidgets(data),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _surface,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Este documento resume la información registrada en MotorCheck. '
              'No reemplaza el historial oficial del fabricante, del taller '
              'ni los documentos emitidos por las autoridades.',
              style: const pw.TextStyle(color: _muted, fontSize: 8),
            ),
          ),
        ],
      ),
    );

    return document.save();
  }

  Future<(pw.Font, pw.Font)> _loadFonts() async {
    try {
      final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Barlow-Regular.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Barlow-Bold.ttf'),
      );
      return (regular, bold);
    } catch (_) {
      return (pw.Font.helvetica(), pw.Font.helveticaBold());
    }
  }

  pw.Widget _titleBlock(VehicleReportData data) {
    final vehicle = data.vehicle;
    final meta = <String>[
      if (vehicle.plate != null) vehicle.plate!,
      if (vehicle.brand != null || vehicle.model != null)
        [vehicle.brand, vehicle.model].whereType<String>().join(' '),
      if (vehicle.year != null) '${vehicle.year}',
      if (vehicle.currentMileage != null) formatMileage(vehicle.currentMileage),
    ];

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _graphite,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'MOTORCHECK',
            style: const pw.TextStyle(
              color: _amber,
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Hoja de vida del vehículo',
            style: const pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 22,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            vehicle.name,
            style: const pw.TextStyle(color: PdfColors.white, fontSize: 15),
          ),
          if (meta.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              meta.join(' · '),
              style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _summaryGrid(VehicleReportData data) {
    final scoreColor = data.health.value >= 90
        ? _success
        : data.health.value >= 70
        ? _amber
        : _danger;

    return pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: _summaryBox(
                'Mantenimientos',
                '${data.maintenances.length}',
                'registros',
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryBox(
                'Gasto total',
                formatCurrency(data.totalCost),
                'mano de obra + repuestos',
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: _summaryBox(
                'Costo por km',
                data.costPerKm != null
                    ? formatCurrency(data.costPerKm!)
                    : 'Sin datos',
                'mantenimiento',
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryBox(
                'Salud del vehículo',
                '${data.health.value}/100',
                data.health.label,
                valueColor: scoreColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _summaryBox(
    String title,
    String value,
    String subtitle, {
    PdfColor? valueColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: const pw.TextStyle(
              color: _muted,
              fontSize: 7,
              letterSpacing: 0.6,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: valueColor ?? _graphite,
              fontWeight: pw.FontWeight.bold,
              fontSize: 15,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(color: _muted, fontSize: 7),
          ),
        ],
      ),
    );
  }

  pw.Widget _section(String title, pw.Widget child) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [_sectionTitle(title), pw.SizedBox(height: 6), child],
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: const pw.TextStyle(
        color: _graphite,
        fontWeight: pw.FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  pw.Widget _documentsTable(List<VehicleDocument> documents) {
    if (documents.isEmpty) {
      return _empty('Sin documentos registrados');
    }
    return pw.TableHelper.fromTextArray(
      headers: const ['Documento', 'Número', 'Vence', 'Estado'],
      data: documents
          .map(
            (document) => [
              document.name ?? documentTypeFor(document.type).label,
              document.number ?? '-',
              formatDisplayDate(document.expiresAt),
              _documentStatus(document),
            ],
          )
          .toList(),
      headerStyle: const pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      headerDecoration: const pw.BoxDecoration(color: _graphite),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      border: pw.TableBorder.all(color: _line, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
    );
  }

  pw.Widget _upcomingTable(VehicleReportData data) {
    if (data.upcoming.isEmpty) {
      return _empty('Sin mantenimientos programados');
    }
    return pw.TableHelper.fromTextArray(
      headers: const ['Categoría', 'Estado', 'Próximo'],
      data: data.upcoming
          .take(12)
          .map(
            (item) => [
              item.category.name,
              item.statusLabel(),
              item.nextDateFormatted() ?? '-',
            ],
          )
          .toList(),
      headerStyle: const pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 8,
      ),
      headerDecoration: const pw.BoxDecoration(color: _graphite),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      border: pw.TableBorder.all(color: _line, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
      },
    );
  }

  /// Cada mantenimiento es un widget independiente para que `MultiPage` pueda
  /// repartirlos entre páginas. Un `Column` gigante no se puede dividir y
  /// provoca documentos con decenas de páginas.
  List<pw.Widget> _historyWidgets(VehicleReportData data) {
    if (data.maintenances.isEmpty) {
      return [_empty('Sin mantenimientos registrados')];
    }

    return data.maintenances.map((maintenance) {
      final items = data.itemsByMaintenance[maintenance.id] ?? const [];
      final workshop = maintenance.workshopId != null
          ? data.workshops[maintenance.workshopId!]?.name
          : null;
      final total = maintenance.maintenanceCost + maintenance.totalPartsCost;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        padding: const pw.EdgeInsets.all(9),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _line, width: 0.5),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    formatDisplayDate(maintenance.date),
                    style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                pw.Text(
                  formatCurrency(total),
                  style: const pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: _amber,
                  ),
                ),
              ],
            ),
            if (maintenance.mileage != null || workshop != null) ...[
              pw.SizedBox(height: 2),
              pw.Text(
                [
                  if (maintenance.mileage != null)
                    formatMileage(maintenance.mileage),
                  ?workshop,
                ].join(' · '),
                style: const pw.TextStyle(color: _muted, fontSize: 8),
              ),
            ],
            if (items.isNotEmpty) ...[
              pw.SizedBox(height: 5),
              pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: items.map((item) => _itemChip(data, item)).toList(),
              ),
            ],
            if (maintenance.notes != null && maintenance.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                maintenance.notes!,
                style: const pw.TextStyle(color: _muted, fontSize: 8),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  pw.Widget _itemChip(VehicleReportData data, MaintenanceItem item) {
    final category = data.categories[item.category]?.name ?? item.category;
    final cost = item.partsCost > 0
        ? ' · ${formatCurrency(item.partsCost)}'
        : '';
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Text(
        '$category$cost',
        style: const pw.TextStyle(color: _graphite, fontSize: 7.5),
      ),
    );
  }

  pw.Widget _empty(String message) {
    return pw.Text(
      message,
      style: const pw.TextStyle(color: _muted, fontSize: 9),
    );
  }

  String _documentStatus(VehicleDocument document) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      document.expiresAt.year,
      document.expiresAt.month,
      document.expiresAt.day,
    );
    final days = target.difference(today).inDays;
    if (days < 0) return 'Vencido hace ${-days} días';
    if (days == 0) return 'Vence hoy';
    return 'Vence en $days días';
  }
}
