import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

// فئة المستودع المسؤولة عن التعامل مع قاعدة البيانات Firestore
class FirestoreService {
  // معرف المستخدم الحالي
  final String? userId;
  // كائن Firestore للتعامل مع قاعدة البيانات
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // البناء (Constructor)
  FirestoreService({this.userId});

  // خاصية للوصول إلى مجموعة الأهداف الخاصة بالمستخدم الحالي
  CollectionReference get _goalsCollection {
    if (userId == null) {
      // رمي استثناء إذا لم يكن المستخدم مسجلاً للدخول
      throw Exception('User not authenticated');
    }
    // الوصول إلى المسار: users -> userId -> goals
    return _firestore.collection('users').doc(userId).collection('goals');
  }

  // دالة لجلب الأهداف كتدفق بيانات (Stream) في الوقت الفعلي
  Stream<List<GoalModel>> getGoals() {
    if (userId == null) return Stream.value([]);

    return _goalsCollection
        // ترتيب الأهداف حسب تاريخ الإنشاء تنازلياً (الأحدث أولاً)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // تحويل كل مستند في اللقطة (Snapshot) إلى كائن GoalModel
          return snapshot.docs.map((doc) {
            return GoalModel.fromFirestore(doc);
          }).toList();
        });
  }

  // دالة لإضافة هدف جديد
  Future<void> addGoal(GoalModel goal) async {
    await _goalsCollection.add(goal.toFirestore());
  }

  // دالة لتحديث بيانات هدف موجود
  Future<void> updateGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.id).update(goal.toFirestore());
  }

  // دالة لحذف هدف
  Future<void> deleteGoal(String goalId) async {
    await _goalsCollection.doc(goalId).delete();
  }
}
