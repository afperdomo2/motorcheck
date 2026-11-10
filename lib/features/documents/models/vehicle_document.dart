import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_document.freezed.dart';
part 'vehicle_document.g.dart';

@freezed
abstract class VehicleDocument with _$VehicleDocument {
  const factory VehicleDocument({
    int? id,
    int? vehicleId,
    required String type,
    String? name,
    String? number,
    DateTime? issuedAt,
    required DateTime expiresAt,
    String? filePath,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _VehicleDocument;

  factory VehicleDocument.fromJson(Map<String, dynamic> json) =>
      _$VehicleDocumentFromJson(json);
}

/// Tipos de documento soportados. `vehicleId == null` significa documento
/// del conductor (por ejemplo, la licencia).
class DocumentTypeOption {
  final String key;
  final String label;
  final IconData icon;

  const DocumentTypeOption(this.key, this.label, this.icon);
}

const documentTypeOptions = <DocumentTypeOption>[
  DocumentTypeOption('soat', 'SOAT', Icons.health_and_safety_outlined),
  DocumentTypeOption('rtm', 'Tecnomecánica', Icons.engineering_outlined),
  DocumentTypeOption(
    'tax',
    'Impuesto vehicular',
    Icons.account_balance_outlined,
  ),
  DocumentTypeOption('insurance', 'Seguro todo riesgo', Icons.shield_outlined),
  DocumentTypeOption('license', 'Licencia de conducción', Icons.badge_outlined),
  DocumentTypeOption('other', 'Otro documento', Icons.description_outlined),
];

DocumentTypeOption documentTypeFor(String type) {
  return documentTypeOptions.firstWhere(
    (option) => option.key == type,
    orElse: () => documentTypeOptions.last,
  );
}
