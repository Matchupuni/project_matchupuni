import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('api_config.dart')) continue;
    
    final content = file.readAsStringSync();
    if (content.contains('ApiConfig')) {
      if (!content.contains("import 'package:project_matchupuni/config/api_config.dart';")) {
        // Find last import
        final lines = content.split('\n');
        int lastImportIndex = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            lastImportIndex = i;
          }
        }
        
        if (lastImportIndex != -1) {
          lines.insert(lastImportIndex + 1, "import 'package:project_matchupuni/config/api_config.dart';");
          file.writeAsStringSync(lines.join('\n'));
          print('Added import to \${file.path}');
        } else {
           lines.insert(0, "import 'package:project_matchupuni/config/api_config.dart';");
           file.writeAsStringSync(lines.join('\n'));
           print('Added import to \${file.path}');
        }
      }
    }
  }
}
