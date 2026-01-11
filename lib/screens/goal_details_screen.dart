import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_card.dart';
import 'add_goal_screen.dart';

// هذا الملف يمثل شاشة "تفاصيل الهدف"
// تعرض هذه الشاشة معلومات تفصيلية عن هدف محدد وتوفر خيارات للتعديل أو الحذف
class GoalDetailsScreen extends StatelessWidget {
  // كائن الهدف الذي سيتم عرض تفاصيله
  final GoalModel goal;

  const GoalDetailsScreen({super.key, required this.goal});

  // بناء واجهة المستخدم للشاشة
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // شريط التطبيق العلوي مع العنوان
      appBar: AppBar(title: const Text('Goal Details')),
      // استخدام SingleChildScrollView للسماح بالتمرير إذا كان المحتوى طويلاً
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // تمديد العناصر لتملأ العرض المتاح
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // إعادة استخدام ويدجت بطاقة الهدف (GoalCard) لعرض المعلومات
              GoalCard(
                goal: goal,
                // عند الضغط على زر التعديل
                onEdit: () {
                  // الانتقال إلى شاشة "إضافة/تعديل هدف" مع تمرير الهدف الحالي
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGoalScreen(goal: goal),
                    ),
                  );
                },
                // عند الضغط على زر الحذف
                onDelete: () {
                  // استدعاء دالة تأكيد الحذف
                  _confirmDelete(context, goal);
                },
              ),
              // يمكن إضافة المزيد من التفاصيل هنا إذا لزم الأمر مستقبلاً
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لإظهار نافذة تأكيد الحذف (Dialog)
  void _confirmDelete(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          // زر إلغاء عملية الحذف وإغلاق النافذة
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // زر تأكيد الحذف
          TextButton(
            onPressed: () {
              // استدعاء دالة الحذف الفعلي من مزود الأهداف (GoalProvider)
              // نستخدم listen: false لأننا نقوم بإجراء ولا نستمع للتغييرات هنا
              Provider.of<GoalProvider>(
                context,
                listen: false,
              ).deleteGoal(goal.id);

              Navigator.pop(context); // إغلاق نافذة الحوار (Dialog)
              Navigator.pop(
                context,
              ); // العودة إلى الشاشة السابقة (قائمة الأهداف)

              // إظهار رسالة قصيرة (SnackBar) لتأكيد الحذف للمستخدم
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${goal.title} deleted')));
            },
            // تلوين نص زر الحذف باللون الأحمر لتمييزه كإجراء خطر
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
