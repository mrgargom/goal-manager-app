import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import '../services/firestore_service.dart';
import '../services/backup_service.dart';

// تعريف حالات فلترة الأهداف الممكنة لاستخدامها في التطبيق
enum GoalFilter { all, notStarted, inProgress, completed }

// هذا الملف مسؤول عن إدارة حالة الأهداف (State Management)
// يمثل الوسيط بين واجهة المستخدم (UI) ومصدر البيانات (Firestore/Backup)
class GoalProvider extends ChangeNotifier {
  // كائن الخدمة للتعامل مع قاعدة بيانات Firestore
  FirestoreService _repository;

  // كائن الخدمة للتعامل مع عمليات النسخ الاحتياطي
  final BackupService _backupService = BackupService();

  // المتغير الذي يخزن حالة الفلترة الحالية (افتراضياً: عرض الكل)
  GoalFilter _filter = GoalFilter.all;

  // المتغير الذي يخزن نص البحث الحالي
  String _searchQuery = '';

  // متغير لتتبع حالة التحميل (أثناء تنفيذ العمليات)
  bool _isLoading = false;

  // متغير لتخزين رسائل الخطأ إن وجدت
  String? _error;

  // المُشيد (Constructor): يقوم بتهيئة المستودع
  // يمكن تمرير userId لربط البيانات بمستخدم معين
  GoalProvider({FirestoreService? repository, String? userId})
    : _repository = repository ?? FirestoreService(userId: userId);

  // دالة لتحديث المستودع بمعرف المستخدم الجديد عند تسجيل الدخول/الخروج
  // هذه الدالة ضرورية لأننا نستخدم ProxyProvider في main.dart
  void update(String? userId) {
    _repository = FirestoreService(userId: userId);
    notifyListeners(); // إعلام المستمعين بالتغيير
  }

  // دوال الوصول (Getters) لقراءة قيم الحالة الحالية
  GoalFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // دالة لتغيير حالة الفلترة وتحديث الواجهة
  void setFilter(GoalFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  // دالة لتغيير نص البحث وتحديث الواجهة
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // دالة تُرجع تدفق (Stream) من الأهداف بعد تطبيق الفلترة والبحث
  // يتم تحديث القائمة تلقائياً عند أي تغيير في قاعدة البيانات
  Stream<List<GoalModel>> get goalsStream {
    // الحصول على كل الأهداف من المستودع ثم تطبيق المنطق عليها
    return _repository.getGoals().map((goals) {
      // 1. تطبيق فلترة البحث (بالعنوان)
      var filteredGoals = goals;
      if (_searchQuery.isNotEmpty) {
        filteredGoals = filteredGoals
            .where(
              (goal) =>
                  goal.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      // 2. تطبيق فلترة الحالة (الكل، لم يبدأ، قيد التنفيذ، مكتمل)
      switch (_filter) {
        case GoalFilter.notStarted:
          // عرض الأهداف التي نسبة تقدمها 0
          return filteredGoals.where((goal) => goal.progress == 0).toList();
        case GoalFilter.inProgress:
          // عرض الأهداف التي بدأ العمل عليها ولكن لم تكتمل
          return filteredGoals
              .where((goal) => goal.progress > 0 && goal.progress < 100)
              .toList();
        case GoalFilter.completed:
          // عرض الأهداف المكتملة بنسبة 100%
          return filteredGoals.where((goal) => goal.progress == 100).toList();
        case GoalFilter.all:
          // عرض جميع الأهداف بدون تصفية إضافية
          return filteredGoals;
      }
    });
  }

  // دالة لإضافة هدف جديد إلى قاعدة البيانات
  Future<void> addGoal(
    String title,
    String description, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true; // بدء مؤشر التحميل
    _error = null;
    notifyListeners();

    try {
      // إنشاء كائن هدف جديد
      final goal = GoalModel(
        id: '', // سيتم توليد المعرف تلقائياً بواسطة Firestore عند الإضافة
        title: title,
        description: description,
        progress: 0, // التقدم الافتراضي 0%
        startDate: startDate != null ? Timestamp.fromDate(startDate) : null,
        endDate: endDate != null ? Timestamp.fromDate(endDate) : null,
        createdAt: Timestamp.now(), // تاريخ الإنشاء الحالي
      );

      // إرسال الطلب للمستودع
      await _repository.addGoal(goal);
    } catch (e) {
      _error = e.toString();
      rethrow; // إعادة رمي الخطأ ليتم التعامل معه في الواجهة
    } finally {
      _isLoading = false; // إيقاف مؤشر التحميل
      notifyListeners();
    }
  }

  // دالة لتحديث بيانات هدف موجود بالكامل (مثل تعديل العنوان أو التواريخ)
  Future<void> updateGoal(GoalModel goal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // تحديث وقت التعديل "updatedAt" قبل الحفظ
      final updatedGoal = goal.copyWith(updatedAt: Timestamp.now());
      await _repository.updateGoal(updatedGoal);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة خاصة لتحديث نسبة التقدم لهدف معين
  Future<void> updateProgress(GoalModel goal, int newProgress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // إنشاء نسخة محدثة مع نسبة التقدم الجديدة ووقت التعديل
      final updatedGoal = goal.copyWith(
        progress: newProgress,
        updatedAt: Timestamp.now(),
      );
      await _repository.updateGoal(updatedGoal);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لحذف هدف معين باستخدام معرفه الفريد (ID)
  Future<void> deleteGoal(String goalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteGoal(goalId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لتصدير القائمة الحالية من الأهداف إلى ملف JSON
  Future<String> exportGoals(List<GoalModel> goals) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // استدعاء خدمة النسخ الاحتياطي والحصول على مسار الملف الناتج
      final path = await _backupService.exportGoals(goals);
      return path;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لاستيراد الأهداف من ملف JSON وإضافتها للتطبيق
  Future<void> importGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // الحصول على قائمة الأهداف من الملف المختار
      final goals = await _backupService.importGoals();

      // إضافة كل هدف مستورد إلى قاعدة البيانات
      for (final goal in goals) {
        // نستخدم addGoal لإعطاء كل هدف معرف جديد (ID) خاص به في Firestore
        // لتجنب تضارب المعرفات مع الأهداف الموجودة
        await _repository.addGoal(goal);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
