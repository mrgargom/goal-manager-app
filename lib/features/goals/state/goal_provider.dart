import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/goal_model.dart';
import '../data/goal_repository.dart';
import '../services/backup_service.dart';

// تعريف حالات تصفية الأهداف
enum GoalFilter { all, notStarted, inProgress, completed }

// فئة مزود الحالة لإدارة الأهداف
class GoalProvider extends ChangeNotifier {
  // كائن المستودع للتعامل مع البيانات
  GoalRepository _repository;
  // خدمة النسخ الاحتياطي
  final BackupService _backupService = BackupService();
  // حالة التصفية الحالية
  GoalFilter _filter = GoalFilter.all;
  // نص البحث الحالي
  String _searchQuery = '';
  // حالة التحميل
  bool _isLoading = false;
  // رسالة الخطأ (إن وجدت)
  String? _error;

  // البناء (Constructor)
  GoalProvider({GoalRepository? repository, String? userId})
    : _repository = repository ?? GoalRepository(userId: userId);

  // تحديث المستودع عند تغير المستخدم
  void update(String? userId) {
    _repository = GoalRepository(userId: userId);
    notifyListeners();
  }

  // الوصول إلى القيم الحالية (Getters)
  GoalFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // تغيير حالة التصفية
  void setFilter(GoalFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  // تغيير نص البحث
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // تدفق الأهداف المصفاة
  Stream<List<GoalModel>> get goalsStream {
    return _repository.getGoals().map((goals) {
      // أولاً تطبيق تصفية البحث
      var filteredGoals = goals;
      if (_searchQuery.isNotEmpty) {
        filteredGoals = filteredGoals
            .where(
              (goal) =>
                  goal.title.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }

      // ثم تطبيق تصفية الحالة
      switch (_filter) {
        case GoalFilter.notStarted:
          return filteredGoals.where((goal) => goal.progress == 0).toList();
        case GoalFilter.inProgress:
          return filteredGoals
              .where((goal) => goal.progress > 0 && goal.progress < 100)
              .toList();
        case GoalFilter.completed:
          return filteredGoals.where((goal) => goal.progress == 100).toList();
        case GoalFilter.all:
          return filteredGoals;
      }
    });
  }

  // إضافة هدف جديد
  Future<void> addGoal(
    String title,
    String description, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final goal = GoalModel(
        id: '', // سيتم توليد المعرف بواسطة Firestore
        title: title,
        description: description,
        progress: 0,
        startDate: startDate != null ? Timestamp.fromDate(startDate) : null,
        endDate: endDate != null ? Timestamp.fromDate(endDate) : null,
        createdAt: Timestamp.now(),
      );
      await _repository.addGoal(goal);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تحديث نسبة التقدم لهدف
  Future<void> updateProgress(GoalModel goal, int newProgress) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

  // حذف هدف
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

  // تصدير الأهداف إلى ملف JSON
  Future<String> exportGoals(List<GoalModel> goals) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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

  // استيراد الأهداف من ملف JSON
  Future<void> importGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final goals = await _backupService.importGoals();
      for (final goal in goals) {
        // إضافة الأهداف المستوردة كأهداف جديدة
        // دالة addGoal في المستودع تستخدم .add()، لذا ستولد معرفاً جديداً
        // وتتجاهل المعرف الموجود في النموذج (لأن toFirestore لا يتضمن 'id')
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
