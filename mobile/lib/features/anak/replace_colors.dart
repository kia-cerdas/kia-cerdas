import 'package:ta_pa2_pa3_project/core/widgets/child_profile_card.dart';
import 'dart:io';

void main() {
  final dir = Directory('d:/Semester4/PA2/try/repo-baru/kia-cerdas/mobile/lib/features/anak');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final replacements = {
    // Primary
    RegExp(r'(?i)0xFF185FA5'): '0xFF185FA5',
    RegExp(r'(?i)0xFF185FA5'): '0xFF185FA5',
    RegExp(r'(?i)0xFF185FA5'): '0xFF185FA5',
    RegExp(r'(?i)0xFF185FA5'): '0xFF185FA5',
    RegExp(r'(?i)0xFF185FA5'): '0xFF185FA5', // Indigo used in pemantauan hero
    
    // Success / Normal
    RegExp(r'(?i)0xFF0F6E56'): '0xFF0F6E56',
    RegExp(r'(?i)0xFF0F6E56'): '0xFF0F6E56',
    RegExp(r'(?i)0xFF0F6E56'): '0xFF0F6E56',

    // Warning
    RegExp(r'(?i)0xFFBA7517'): '0xFFBA7517',
    RegExp(r'(?i)0xFFBA7517'): '0xFFBA7517',
    RegExp(r'(?i)0xFFBA7517'): '0xFFBA7517',

    // Danger
    RegExp(r'(?i)0xFFA32D2D'): '0xFFA32D2D',
    RegExp(r'(?i)0xFFA32D2D'): '0xFFA32D2D',
    RegExp(r'(?i)0xFFA32D2D'): '0xFFA32D2D',
  };

  int updatedFiles = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    String original = content;

    for (final entry in replacements.entries) {
      content = content.replaceAll(entry.key, entry.value);
    }

    if (content != original) {
      file.writeAsStringSync(content);
      updatedFiles++;
      print('Updated: ${file.path}');
    }
  }

  print('Total files updated: $updatedFiles');
}
