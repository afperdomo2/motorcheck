import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:printing/printing.dart';

class AttachmentPreviewScreen extends StatelessWidget {
  const AttachmentPreviewScreen({
    super.key,
    required this.filePath,
    required this.name,
  });

  final String filePath;
  final String name;

  bool get _isImage {
    final extension = p.extension(name).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.webp'].contains(extension);
  }

  bool get _isPdf => p.extension(name).toLowerCase() == '.pdf';

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);

    return Scaffold(
      appBar: AppBar(
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: !file.existsSync()
          ? const _Message(
              icon: Icons.error_outline,
              text: 'El archivo ya no existe en este dispositivo.',
            )
          : _isImage
          ? _ImageView(file: file)
          : _isPdf
          ? PdfPreview(
              build: (format) async =>
                  Uint8List.fromList(await file.readAsBytes()),
              pdfFileName: name,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              useActions: true,
              padding: const EdgeInsets.all(8),
            )
          : const _Message(
              icon: Icons.insert_drive_file_outlined,
              text: 'Este tipo de archivo no tiene vista previa.',
            ),
    );
  }
}

class _ImageView extends StatelessWidget {
  const _ImageView({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4,
      child: Center(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const _Message(
            icon: Icons.broken_image_outlined,
            text: 'No se pudo abrir la imagen.',
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
