import 'package:cloud_firestore/cloud_firestore.dart';

// نموذج البيانات الذي يمثل الهدف
class GoalModel {
  // المعرف الفريد للهدف
  final String id;
  // عنوان الهدف
  final String title;
  // وصف الهدف
  final String description;
  // نسبة التقدم في الهدف (0-100)
  final int progress;
  // تاريخ بدء الهدف
  final Timestamp? startDate;
  // تاريخ نهاية الهدف
  final Timestamp? endDate;
  // تاريخ إنشاء الهدف
  final Timestamp createdAt;
  // تاريخ آخر تحديث للهدف (اختياري)
  final Timestamp? updatedAt;

  // البناء (Constructor) لإنشاء كائن من نوع GoalModel
  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  // دالة مصنع لإنشاء كائن GoalModel من خريطة بيانات (Map)
  // تستخدم عادة عند قراءة البيانات من JSON أو Firestore
  factory GoalModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GoalModel(
      id: documentId,
      // قراءة العنوان مع قيمة افتراضية فارغة
      title: data['title'] as String? ?? '',
      // قراءة الوصف مع قيمة افتراضية فارغة
      description: data['description'] as String? ?? '',
      // قراءة التقدم وتحويله إلى عدد صحيح
      progress: (data['progress'] as num?)?.toInt() ?? 0,
      // قراءة تاريخ البدء
      startDate: data['startDate'] as Timestamp?,
      // قراءة تاريخ النهاية
      endDate: data['endDate'] as Timestamp?,
      // قراءة تاريخ الإنشاء
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      // قراءة تاريخ التحديث
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  // تحويل كائن GoalModel إلى خريطة بيانات (Map)
  // تستخدم عند حفظ البيانات في Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'progress': progress,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      // استخدام توقيت السيرفر عند التحديث
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // دالة مساعدة لإنشاء GoalModel مباشرة من مستند Firestore
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel.fromMap(data, doc.id);
  }

  // دالة مساعدة لتحويل النموذج إلى صيغة Firestore
  Map<String, dynamic> toFirestore() => toMap();

  // دالة لإنشاء نسخة معدلة من الكائن الحالي
  // مفيدة لتحديث حقل واحد أو أكثر دون تغيير الباقي
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    int? progress,
    Timestamp? startDate,
    Timestamp? endDate,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}