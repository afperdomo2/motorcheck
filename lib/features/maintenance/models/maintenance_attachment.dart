import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_attachment.freezed.dart';
part 'maintenance_attachment.g.dart';

@freezed
abstract class MaintenanceAttachment with _$MaintenanceAttachment {
  const factory MaintenanceAttachment({
    int? id,
    required int maintenanceId,
    int? itemId,
    required String name,
    required String filePath,
    required DateTime createdAt,
  }) = _MaintenanceAttachment;

  factory MaintenanceAttachment.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceAttachmentFromJson(json);
}
