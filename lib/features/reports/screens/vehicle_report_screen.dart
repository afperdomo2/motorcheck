import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../pdf_report_service.dart';
import '../report_data.dart';

class VehicleReportScreen extends ConsumerWidget {
  const VehicleReportScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(vehicleReportDataProvider(vehicleId));
    final service = PdfReportService();

    return Scaffold(
      appBar: AppBar(title: const Text('Hoja de vida')),
      body: dataAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo preparar la hoja de vida',
          onRetry: () => ref.invalidate(vehicleReportDataProvider(vehicleId)),
        ),
        data: (data) => PdfPreview(
          build: (format) => service.build(data, format: format),
          pdfFileName:
              'hoja-vida-${data.vehicle.name.replaceAll(' ', '-')}.pdf',
          allowPrinting: true,
          allowSharing: true,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          useActions: true,
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }
}
