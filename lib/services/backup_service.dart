import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/goal_model.dart';

// هذا الملف مسؤول عن خدمات النسخ الاحتياطي (Backup) والاستعادة (Restore)
// يقوم بتحويل الأهداف إلى صيغة JSON لحفظها في ملف، أو قراءة ملف JSON لاسترجاع الأهداف
class BackupService {
  // دالة لتصدير الأهداف إلى ملف JSON
  // تأخذ قائمة من الكائنات من نوع GoalModel كمدخل
  Future<String> exportGoals(List<GoalModel> goals) async {
    try {
      // 1. تحويل قائمة الأهداف إلى قائمة من الخرائط (Maps)
      // كل هدف يتم تحويله لبيانات يمكن تمثيلها بـ JSON
      final goalsJson = goals.map((g) => g.toMap()).toList();

      // 2. تشفير القائمة إلى نص بصيغة JSON
      final jsonString = jsonEncode(goalsJson);

      // 3. الحصول على المجلد المسموح للتطبيق بالكتابة فيه
      // نستخدم getApplicationDocumentsDirectory للحصول على مسار المستندات الخاص بالتطبيق
      final directory = await getApplicationDocumentsDirectory();

      // إنشاء ملف جديد باسم يحتوي على الوقت الحالي لضمان عدم تكرار الاسم
      // millisecondsSinceEpoch يعطي رقمًا فريدًا يمثل الوقت الحالي
      final file = File(
        '${directory.path}/goals_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      // كتابة نص JSON داخل الملف
      await file.writeAsString(jsonString);

      // إرجاع مسار الملف الذي تم إنشاؤه بنجاح
      return file.path;
    } catch (e) {
      // في حالة حدوث خطأ، نرمي استثناء مع رسالة توضيحية
      throw Exception('Failed to export goals: $e');
    }
  }

  // دالة لاستيراد الأهداف من ملف JSON خارجي
  Future<List<GoalModel>> importGoals() async {
    try {
      // فتح نافذة لاختيار الملفات من قبل المستخدم
      // نقيد الاختيار بملفات الامتداد json فقط
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      // التحقق مما إذا قام المستخدم باختيار ملف فعلاً
      if (result != null) {
        // إنشاء كائن File يشير إلى الملف المختار
        File file = File(result.files.single.path!);

        // قراءة محتوى الملف كنص كامل
        String jsonString = await file.readAsString();

        // فك تشفير النص (JSON Parsing) إلى قائمة ديناميكية
        List<dynamic> jsonList = jsonDecode(jsonString);

        // تحويل كل عنصر في القائمة (Map) إلى كائن GoalModel
        return jsonList
            .map((json) => GoalModel.fromMap(json as Map<String, dynamic>, ''))
            .toList();
      }
      // إرجاع قائمة فارغة إذا ألغى المستخدم عملية الاختيار
      return [];
    } catch (e) {
      // التعامل مع الأخطاء التي قد تحدث أثناء القراءة أو التحويل
      throw Exception('Failed to import goals: $e');
    }
  }
}
