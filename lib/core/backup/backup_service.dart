import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../settings/app_preferences.dart';
import '../utils/user_error.dart';

const _backupFormat = 'motorcheck-backup';
const _backupSchemaVersion = 20;

const _tables = <String>[
  'vehicles',
  'workshops',
  'maintenance_categories',
  'expense_categories',
  'maintenances',
  'maintenance_items',
  'maintenance_attachments',
  'fuel_logs',
  'expenses',
  'mileage_readings',
  'documents',
  'vehicle_restrictions',
  'components',
  'component_services',
  'checklists',
  'checklist_items',
  'inspection_runs',
  'inspection_answers',
  'budgets',
];

const _attachmentColumns = <String, String>{
  'documents': 'file_path',
  'expenses': 'receipt_path',
  'maintenance_attachments': 'file_path',
};

class BackupResult {
  const BackupResult({
    required this.file,
    required this.counts,
    required this.attachments,
    required this.createdAt,
  });

  final File file;
  final Map<String, int> counts;
  final int attachments;
  final DateTime createdAt;

  int get totalRecords => counts.values.fold(0, (sum, count) => sum + count);
}

class BackupPreview {
  const BackupPreview({
    required this.fileName,
    required this.createdAt,
    required this.schemaVersion,
    required this.counts,
    required this.attachments,
  });

  final String fileName;
  final DateTime createdAt;
  final int schemaVersion;
  final Map<String, int> counts;
  final int attachments;
}

class BackupService {
  BackupService({Directory? baseDirectory, Directory? temporaryDirectory})
    : _baseOverride = baseDirectory,
      _tempOverride = temporaryDirectory;

  final Directory? _baseOverride;
  final Directory? _tempOverride;
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Directory> _baseDirectory() async {
    if (_baseOverride != null) return _baseOverride;
    return getApplicationSupportDirectory();
  }

  Future<Directory> _backupsDirectory() async {
    final dir = Directory(p.join((await _baseDirectory()).path, 'backups'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _attachmentsDirectory() async {
    final dir = Directory(p.join((await _baseDirectory()).path, 'documents'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _tempDirectory() async {
    if (_tempOverride != null) {
      await _tempOverride.create(recursive: true);
      return _tempOverride;
    }
    return Directory.systemTemp.createTemp('motorcheck_backup_');
  }

  Future<BackupResult> createBackup({
    bool includeAttachments = true,
    bool auto = false,
  }) async {
    final now = DateTime.now();
    final archive = Archive();
    final counts = <String, int>{};
    final tablesJson = <String, List<dynamic>>{};
    final db = await _db.database;
    var attachmentCount = 0;

    for (final table in _tables) {
      final rows = await db.query(table);
      counts[table] = rows.length;
      final jsonRows = rows.map(_jsonSafe).toList();

      final attachmentColumn = _attachmentColumns[table];
      if (includeAttachments && attachmentColumn != null) {
        for (final row in jsonRows) {
          final rawPath = row[attachmentColumn] as String?;
          if (rawPath == null || rawPath.isEmpty) continue;
          final file = File(rawPath);
          if (!await file.exists()) {
            row[attachmentColumn] = null;
            continue;
          }
          final archivePath = _attachmentPath(
            table,
            row['id'] is int ? row['id'] as int : null,
            p.basename(rawPath),
          );
          archive.addFile(
            ArchiveFile.bytes(archivePath, await file.readAsBytes()),
          );
          row[attachmentColumn] = archivePath;
          attachmentCount++;
        }
      }

      tablesJson[table] = jsonRows;
    }

    final settings = await _exportSettings();
    final data = <String, dynamic>{
      'format': _backupFormat,
      'schemaVersion': _backupSchemaVersion,
      'appVersion': '0.2.0',
      'createdAt': now.toIso8601String(),
      'tables': tablesJson,
      'settings': settings,
    };

    archive.addFile(
      ArchiveFile.string(
        'data.json',
        const JsonEncoder.withIndent('  ').convert(data),
      ),
    );
    archive.addFile(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode({
          'format': _backupFormat,
          'schemaVersion': _backupSchemaVersion,
          'createdAt': now.toIso8601String(),
          'counts': counts,
          'attachments': attachmentCount,
        }),
      ),
    );

    final bytes = ZipEncoder().encode(archive);
    final prefix = auto ? 'motorcheck-auto' : 'motorcheck-backup';
    final file = File(
      p.join((await _backupsDirectory()).path, '$prefix-${_stamp(now)}.zip'),
    );
    await file.writeAsBytes(bytes, flush: true);

    await AppPreferences.setLastBackupAt(now);
    if (auto) {
      await _pruneAutoBackups();
    }

    return BackupResult(
      file: file,
      counts: counts,
      attachments: attachmentCount,
      createdAt: now,
    );
  }

  Future<File> exportCsv() async {
    final db = await _db.database;
    final archive = Archive();

    for (final table in _tables) {
      final rows = await db.query(table);
      if (rows.isEmpty) {
        archive.addFile(ArchiveFile.string('$table.csv', '\uFEFF'));
        continue;
      }
      final columns = rows.first.keys.toList();
      final data = <List<dynamic>>[
        columns,
        ...rows.map((row) => columns.map((column) => row[column]).toList()),
      ];
      final csv = Csv.excel().encode(data);
      archive.addFile(ArchiveFile.string('$table.csv', csv));
    }

    final now = DateTime.now();
    final file = File(
      p.join(
        (await _backupsDirectory()).path,
        'motorcheck-csv-${_stamp(now)}.zip',
      ),
    );
    await file.writeAsBytes(ZipEncoder().encode(archive), flush: true);
    return file;
  }

  Future<BackupPreview> inspect(File file) async {
    final archive = await _readArchive(file);
    final data = _readData(archive);
    _validateFormat(data);
    final tables = _tablesMap(data);
    final counts = <String, int>{
      for (final entry in tables.entries) entry.key: entry.value.length,
    };
    final attachments = archive.files
        .where((entry) => entry.name.startsWith('attachments/'))
        .length;
    return BackupPreview(
      fileName: p.basename(file.path),
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
          DateTime.now(),
      schemaVersion: data['schemaVersion'] as int? ?? 0,
      counts: counts,
      attachments: attachments,
    );
  }

  Future<void> restore(File file) async {
    final archive = await _readArchive(file);
    final data = _readData(archive);
    _validateFormat(data);

    final safety = await createBackup(auto: true);
    logError('restauración', 'Copia de seguridad previa: ${safety.file.path}');

    final temp = await _tempDirectory();
    final staging = Directory(
      p.join(temp.path, 'documents_${DateTime.now().millisecondsSinceEpoch}'),
    );
    await staging.create(recursive: true);

    final extracted = <String, String>{};
    for (final entry in archive.files) {
      if (!entry.name.startsWith('attachments/')) continue;
      final name = p.basename(entry.name);
      final target = File(p.join(staging.path, name));
      await target.writeAsBytes(entry.content as List<int>, flush: true);
      extracted[entry.name] = target.path;
    }

    final tables = _tablesMap(data);
    final db = await _db.database;
    final attachmentsDir = await _attachmentsDirectory();

    Directory? oldDocuments;
    var prepared = false;
    try {
      // Los archivos se preparan antes de la transacción. Si la base falla,
      // se restauran los adjuntos anteriores; si los archivos fallan, la base
      // todavía no se ha tocado.
      oldDocuments = await _prepareDocuments(staging);
      prepared = true;

      await db.execute('PRAGMA foreign_keys = OFF');
      await db.transaction((txn) async {
        for (final table in _tables.reversed) {
          await txn.delete(table);
        }
        for (final table in _tables) {
          final rows = tables[table] ?? const [];
          final columns = await _tableColumns(txn, table);
          for (final raw in rows) {
            final row = Map<String, dynamic>.from(raw);
            final clean = <String, dynamic>{};
            for (final entry in row.entries) {
              if (!columns.contains(entry.key)) continue;
              clean[entry.key] = entry.value;
            }
            final attachmentColumn = _attachmentColumns[table];
            if (attachmentColumn != null && clean[attachmentColumn] is String) {
              final relative = clean[attachmentColumn] as String;
              final target = extracted[relative];
              clean[attachmentColumn] = target != null
                  ? p.join(attachmentsDir.path, p.basename(target))
                  : null;
            }
            await txn.insert(table, clean);
          }
        }
      });
    } catch (error) {
      if (prepared) await _rollbackDocuments(oldDocuments);
      rethrow;
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }

    await _commitDocuments(oldDocuments);
    await _importSettings(data);

    await AppPreferences.setLastBackupAt(DateTime.now());
    try {
      await temp.delete(recursive: true);
    } catch (error) {
      logError('limpiar temporal', error, StackTrace.current);
    }
  }

  Future<void> createAutoBackupIfNeeded() async {
    try {
      final enabled = await AppPreferences.autoBackupEnabled();
      if (!enabled) return;
      final last = await AppPreferences.lastBackupAt();
      if (last != null &&
          DateTime.now().difference(last) < const Duration(hours: 24)) {
        return;
      }
      await createBackup(auto: true);
    } catch (error) {
      logError('copia automática', error, StackTrace.current);
    }
  }

  Future<List<File>> listBackups() async {
    final dir = await _backupsDirectory();
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.zip'))
            .toList()
          ..sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
          );
    return files;
  }

  Future<void> _pruneAutoBackups() async {
    final files = await listBackups();
    final auto = files
        .where((file) => p.basename(file.path).startsWith('motorcheck-auto-'))
        .toList();
    for (var i = 7; i < auto.length; i++) {
      try {
        await auto[i].delete();
      } catch (error) {
        logError('limpiar copias', error, StackTrace.current);
      }
    }
  }

  /// Mueve los documentos actuales a una carpeta temporal, crea la nueva
  /// carpeta y copia los adjuntos preparados. Si algo falla, restaura.
  Future<Directory?> _prepareDocuments(Directory staging) async {
    final documents = await _attachmentsDirectory();
    final old = Directory(
      p.join(
        documents.parent.path,
        'documents_old_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    try {
      if (await documents.exists()) {
        await documents.rename(old.path);
      }
      await documents.create(recursive: true);

      for (final file in staging.listSync().whereType<File>()) {
        await file.copy(p.join(documents.path, p.basename(file.path)));
      }
      return old.existsSync() ? old : null;
    } catch (error) {
      await _rollbackDocuments(old.existsSync() ? old : null);
      rethrow;
    }
  }

  Future<void> _rollbackDocuments(Directory? old) async {
    final documents = await _attachmentsDirectory();
    try {
      if (await documents.exists()) {
        await documents.delete(recursive: true);
      }
      if (old != null && await old.exists()) {
        await old.rename(documents.path);
      }
    } catch (error) {
      logError('rollback de adjuntos', error, StackTrace.current);
    }
  }

  Future<void> _commitDocuments(Directory? old) async {
    if (old == null) return;
    try {
      if (await old.exists()) await old.delete(recursive: true);
    } catch (error) {
      logError('limpiar adjuntos anteriores', error, StackTrace.current);
    }
  }

  Future<Set<String>> _tableColumns(DatabaseExecutor db, String table) async {
    final info = await db.rawQuery("PRAGMA table_info('$table')");
    return info.map((row) => row['name'] as String).toSet();
  }

  Future<Map<String, dynamic>> _exportSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {for (final key in prefs.getKeys()) key: prefs.get(key)};
  }

  Future<void> _importSettings(Map<String, dynamic> data) async {
    final settings = data['settings'];
    if (settings is! Map) return;
    final prefs = await SharedPreferences.getInstance();
    for (final entry in settings.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List) {
        await prefs.setStringList(
          key,
          value.map((item) => item.toString()).toList(),
        );
      }
    }
  }

  Map<String, dynamic> _jsonSafe(Map<String, Object?> row) {
    return {
      for (final entry in row.entries)
        entry.key: entry.value is num || entry.value == null
            ? entry.value
            : entry.value.toString(),
    };
  }

  String _attachmentPath(String table, int? id, String name) {
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return 'attachments/$table/${id ?? 'solo'}_$safeName';
  }

  String _stamp(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}$month$day-$hour$minute$second';
  }

  Future<Archive> _readArchive(File file) async {
    final bytes = await file.readAsBytes();
    return ZipDecoder().decodeBytes(bytes);
  }

  Map<String, dynamic> _readData(Archive archive) {
    final entry = archive.findFile('data.json');
    if (entry == null) {
      throw const FormatException('Falta data.json en la copia');
    }
    final decoded = jsonDecode(utf8.decode(entry.content as List<int>));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('data.json inválido');
    }
    return decoded;
  }

  void _validateFormat(Map<String, dynamic> data) {
    if (data['format'] != _backupFormat) {
      throw const FormatException('El archivo no es una copia de MotorCheck');
    }
    final version = data['schemaVersion'] as int? ?? 0;
    if (version > _backupSchemaVersion) {
      throw const FormatException(
        'La copia es de una versión más reciente de MotorCheck',
      );
    }
  }

  Map<String, List<dynamic>> _tablesMap(Map<String, dynamic> data) {
    final raw = data['tables'];
    if (raw is! Map) {
      throw const FormatException('La copia no contiene tablas');
    }
    return {
      for (final entry in raw.entries)
        if (entry.value is List)
          entry.key.toString(): (entry.value as List).cast<dynamic>(),
    };
  }
}
