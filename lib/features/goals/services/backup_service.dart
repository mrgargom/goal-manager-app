import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../data/goal_model.dart';

class BackupService {
  // Export goals to a JSON file
  Future<String> exportGoals(List<GoalModel> goals) async {
    try {
      // 1. Convert goals to List of Maps
      final goalsJson = goals.map((g) => g.toMap()).toList();

      // 2. Encode to JSON string
      final jsonString = jsonEncode(goalsJson);

      // 3. Get directory to save
      // For Android/iOS, we usually use getApplicationDocumentsDirectory
      // For user visibility, we might want to use getExternalStorageDirectory on Android
      // or just share the file after creating it.
      // For simplicity and cross-platform safety, we'll use ApplicationDocuments
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'goals_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      // 4. Write to file
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to export goals: $e');
    }
  }

  // Import goals from a JSON file
  Future<List<GoalModel>> importGoals() async {
    try {
      // 1. Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);

      // 2. Read file content
      final jsonString = await file.readAsString();

      // 3. Decode JSON
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 4. Convert to List<GoalModel>
      // Note: We pass an empty ID or generate a new one because we'll likely
      // want to add these as new entries in Firestore, or we need to handle ID conflicts.
      // Here we'll treat them as new imports.
      return jsonList.map((json) {
        // We use a temporary ID or the one from JSON if we want to preserve it.
        // Ideally, when importing to Firestore, we might let Firestore generate new IDs
        // or check if they exist. For this model, we'll just parse what's there.
        return GoalModel.fromMap(json, json['id'] ?? '');
      }).toList();
    } catch (e) {
      throw Exception('Failed to import goals: $e');
    }
  }
}
