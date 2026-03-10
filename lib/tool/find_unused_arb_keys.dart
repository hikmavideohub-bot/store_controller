import 'dart:convert';
import 'dart:io';

void main() async {
  const arbPath = 'lib/l10n/app_en.arb';
  const scanRoot = 'lib';

  final arbFile = File(arbPath);
  if (!arbFile.existsSync()) {
    stderr.writeln('ARB file not found: $arbPath');
    exit(1);
  }

  final arbJson = jsonDecode(await arbFile.readAsString()) as Map<String, dynamic>;

  final keys = arbJson.keys
      .where((k) => !k.startsWith('@'))
      .where((k) => k != '@@locale')
      .toList()
    ..sort();

  final dartFiles = Directory(scanRoot)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final fileContents = <String, String>{};
  for (final file in dartFiles) {
    try {
      fileContents[file.path] = await file.readAsString();
    } catch (_) {
      // ignore unreadable files
    }
  }

  final usedKeys = <String>{};
  final unusedKeys = <String>[];

  for (final key in keys) {
    final patterns = [
      'l10n.$key',
      '.$key,',
      '.$key)',
      '.$key;',
      '.$key ',
      '.$key?',
      '.$key:',
      '.$key}',
    ];

    bool used = false;

    for (final entry in fileContents.entries) {
      final content = entry.value;
      if (patterns.any(content.contains)) {
        used = true;
        usedKeys.add(key);
        break;
      }
    }

    if (!used) {
      unusedKeys.add(key);
    }
  }

  stdout.writeln('ARB file: $arbPath');
  stdout.writeln('Scanned Dart files: ${dartFiles.length}');
  stdout.writeln('Total translation keys: ${keys.length}');
  stdout.writeln('Used keys found: ${usedKeys.length}');
  stdout.writeln('Unused keys: ${unusedKeys.length}');
  stdout.writeln('');

  if (unusedKeys.isEmpty) {
    stdout.writeln('No obviously unused keys found.');
    return;
  }

  stdout.writeln('Possibly unused ARB keys:');
  for (final key in unusedKeys) {
    stdout.writeln('- $key');
  }
}