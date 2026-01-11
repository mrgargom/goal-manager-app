import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../auth/auth_provider.dart';
import '../theme/theme_provider.dart';
import '../models/goal_model.dart';
import 'add_goal_screen.dart';
import 'goal_details_screen.dart';
import '../widgets/goal_card.dart';

// ---------------------------------------------------------------------------
// هذا الملف يمثل "عقل" الواجهة الرئيسية للتطبيق.
// هو المسؤول عن عرض قائمة الأهداف للمستخدم، ويوفر الأدوات اللازمة للتعامل معها.
// ---------------------------------------------------------------------------
// الوظائف الرئيسية لهذه الشاشة:
// 1. عرض الأهداف: جلب البيانات من المزود (Provider) وعرضها في قائمة.
// 2. البحث: البحث داخل عناوين وتفاصيل الأهداف.
// 3. الفلترة: تصفية الأهداف حسب حالتها (الكل، قيد التنفيذ، مكتملة...).
// 4. العمليات: (إضافة، تعديل، حذف) + (استيراد وتصدير البيانات).
// ---------------------------------------------------------------------------

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

// فئة الحالة (State) التي تحتوي على المتغيرات والمنطق الخاص بالشاشة
class _GoalListScreenState extends State<GoalListScreen> {
  // ------------------------- المتغيرات (Variables) -------------------------

  // متغير منطقي (Boolean) لتحديد حالة واجهة المستخدم:
  // true: وضع البحث مفعل (يظهر شريط البحث).
  // false: وضع العرض العادي (يظهر عنوان التطبيق).
  bool _isSearching = false;

  // وحدة تحكم (Controller) لحقل النص الخاص بالبحث.
  // تستخدم لقراءة النص الذي يكتبه المستخدم أو مسحه.
  final TextEditingController _searchController = TextEditingController();

  // ------------------------- الميثودات (Methods) -------------------------

  // دالة dispose: تتنفيذ تلقائياً عند إغلاق الشاشة نهائياً.
  // نستخدمها لتنظيف الموارد وتفريغ الذاكرة (مثل إغلاق controllers).
  @override
  void dispose() {
    _searchController.dispose(); // التخلص من وحدة تحكم النص
    super.dispose();
  }

  // دالة لتفعيل وضع البحث.
  // تقوم بتحديث الحالة لإعادة بناء الشاشة وإظهار شريط البحث.
  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  // دالة لإلغاء وضع البحث.
  // تعيد الشاشة للوضع الطبيعي وتمسح نص البحث ونتائجه.
  void _stopSearch(GoalProvider provider) {
    setState(() {
      _isSearching = false; // إخفاء شريط البحث
      _searchController.clear(); // مسح النص المكتوب
    });
    // إعادة تعيين فلتر البحث في المزود ليعرض كل الأهداف مرة أخرى
    provider.setSearchQuery('');
  }

  // ---------------------------------------------------------------------------
  // دالة بناء الواجهة (Build Method).
  // يتم استدعاؤها كلما دعت الحاجة لتحديث شكل الشاشة (مثل تغيير حالة).
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // 1. نستخدم Consumer للاستماع لمزود الأهداف.
    // أي تغيير في GoalProvider سيؤدي لإعادة بناء هذا الجزء تلقائياً.
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        // 2. نستخدم StreamBuilder للاستماع لتدفق البيانات القادمة من قاعدة البيانات.
        // Stream: هو قناة تنقل البيانات بشكل مستمر (مثل أنبوب مياه).
        // هذا يسمح للتطبيق بعرض التحديثات لحظياً دون الحاجة لتحديث يدوي.
        return StreamBuilder<List<GoalModel>>(
          stream: goalProvider.goalsStream, // المصدر الذي نستمع إليه
          builder: (context, snapshot) {
            // أ) حالة الانتظار: البيانات لم تصل بعد.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()), // دائرة تحميل
              );
            }

            // ب) حالة الخطأ: حدثت مشكلة أثناء جلب البيانات.
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            // ج) حالة النجاح: البيانات وصلت.
            // نأخذ البيانات أو نستخدم قائمة فارغة إذا كانت null
            final goals = snapshot.data ?? [];

            // 3. بناء هيكل الصفحة (Scaffold)
            return Scaffold(
              // ------- شريط التطبيق العلوي (AppBar) -------
              appBar: AppBar(
                // العنوان يتغير: إما نص عادي أو حقل بحث
                title: _isSearching
                    ? TextField(
                        controller: _searchController,
                        autofocus: true, // المستطيل يفتح جاهزاً للكتابة
                        decoration: const InputDecoration(
                          hintText: 'Search goals...',
                          border: InputBorder.none,
                        ),
                        style: Theme.of(context).textTheme.titleLarge,
                        // عند الكتابة، نطلب من المزود فلترة القائمة
                        onChanged: (value) =>
                            goalProvider.setSearchQuery(value),
                      )
                    : const Text('My Goals'),

                // أزرار الإجراءات (Actions)
                actions: [
                  // زر 1: تبديل وضع البحث
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.close), // إغلاق البحث
                      onPressed: () => _stopSearch(goalProvider),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.search), // فتح البحث
                      onPressed: _startSearch,
                    ),

                  // زر 2: قائمة التصفية (Filter Menu)
                  PopupMenuButton<GoalFilter>(
                    initialValue: goalProvider.filter,
                    onSelected: (filter) => goalProvider.setFilter(filter),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: GoalFilter.all,
                        child: Text('All'),
                      ),
                      const PopupMenuItem(
                        value: GoalFilter.notStarted,
                        child: Text('Not Started'),
                      ),
                      const PopupMenuItem(
                        value: GoalFilter.inProgress,
                        child: Text('In Progress'),
                      ),
                      const PopupMenuItem(
                        value: GoalFilter.completed,
                        child: Text('Completed'),
                      ),
                    ],
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter Goals',
                  ),

                  // زر 3: قائمة الخيارات الإضافية (استيراد وتصدير JSON)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert), // 3 نقاط عمودية
                    tooltip: 'More Options',
                    onSelected: (value) async {
                      // أ) خيار التصدير (Export)
                      if (value == 'export') {
                        try {
                          // لا يمكن التصدير إذا كانت القائمة فارغة
                          if (goals.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No goals to export'),
                              ),
                            );
                            return;
                          }

                          // طلب التصدير من المزود وانتظار تحديد المسار
                          final path = await goalProvider.exportGoals(goals);

                          // إعلام المستخدم بالنجاح
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Goals exported to $path'),
                              ),
                            );
                          }
                        } catch (e) {
                          // إعلام المستخدم بالفشل
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Export failed: $e')),
                            );
                          }
                        }

                        // ب) خيار الاستيراد (Import)
                      } else if (value == 'import') {
                        try {
                          // طلب الاستيراد وانتظار اختيار الملف
                          await goalProvider.importGoals();

                          // إعلام المستخدم بالنجاح
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Goals imported successfully'),
                              ),
                            );
                          }
                        } catch (e) {
                          // إعلام المستخدم بالفشل
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Import failed: $e')),
                            );
                          }
                        }
                      }
                    },
                    // عناصر القائمة المنبثقة
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.upload_file),
                            SizedBox(width: 8),
                            Text('Export Goals to JSON'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'import',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Import Goals from JSON'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // زر 4: تبديل السمة (Dark/Light Mode)
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return IconButton(
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme(!themeProvider.isDarkMode);
                        },
                        tooltip: 'Toggle Theme',
                      );
                    },
                  ),

                  // زر 5: تسجيل الخروج
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut(); // استدعاء دالة الخروج من AuthProvider
                    },
                    tooltip: 'Sign Out',
                  ),
                ],
              ),

              // ------- جسم الصفحة (Body) -------
              body: goals.isEmpty
                  // الحالة 1: لا توجد أهداف لعرضها
                  ? Center(
                      child: Text(
                        // تحديد نص الرسالة بناءً على السياق (هل هو بحث؟ فلترة؟ أم جديد؟)
                        goalProvider.searchQuery.isNotEmpty
                            ? 'No goals found matching "${goalProvider.searchQuery}".'
                            : (goalProvider.filter != GoalFilter.all
                                  ? 'No goals found for this filter.'
                                  : 'No goals yet. Add one!'),
                      ),
                    )
                  // الحالة 2: عرض قائمة الأهداف
                  : ListView.builder(
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];

                        // عنصر قابل للسحب (للحذف السريع)
                        return Dismissible(
                          key: Key(goal.id), // مفتاح فريد لكل عنصر
                          // خلفية حمراء تظهر عند السحب
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection
                              .endToStart, // السحب من اليمين لليسار
                          onDismissed: (direction) {
                            // الحذف عند اكتمال السحب
                            goalProvider.deleteGoal(goal.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${goal.title} deleted')),
                            );
                          },
                          // محتوى العنصر: بطاقة الهدف
                          child: GestureDetector(
                            onTap: () {
                              // عند الضغط على البطاقة، ننتقل للتفاصيل
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GoalDetailsScreen(goal: goal),
                                ),
                              );
                            },
                            child: GoalCard(
                              goal: goal,
                              // تمرير دوال التعديل والحذف للبطاقة
                              onEdit: () =>
                                  _showUpdateProgressDialog(context, goal),
                              onDelete: () =>
                                  _confirmDelete(context, goalProvider, goal),
                              searchQuery: goalProvider.searchQuery,
                            ),
                          ),
                        );
                      },
                    ),

              // ------- الزر العائم (FAB) -------
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // الانتقال لشاشة إضافة هدف جديد
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddGoalScreen()),
                  );
                },
                child: const Icon(Icons.add),
              ),

              // ------- مؤشر التحميل السفلي -------
              // يظهر فقط عند وجود عملية جارية في المزود (المزامنة)
              bottomSheet: goalProvider.isLoading
                  ? Container(
                      color: Colors.black45,
                      height: 4,
                      child: const LinearProgressIndicator(),
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // دالة مساعدة تعرض نافذة منبثقة (Dialog) لتحديث نسبة تقدم الهدف.
  // تستخدم شريط تمرير (Slider) لتسهيل اختيار النسبة.
  // ---------------------------------------------------------------------------
  void _showUpdateProgressDialog(BuildContext context, GoalModel goal) {
    // نصل للمزود مرة واحدة هنا فقط لتنفيذ عملية التحديث لاحقاً (listen: false)
    final provider = Provider.of<GoalProvider>(context, listen: false);

    // متغير محلي لتخزين القيمة المؤقتة لشريط التمرير قبل الحفظ
    double currentProgress = goal.progress.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        // نستخدم StatefulBuilder هنا لأننا نحتاج لتحديث واجهة النافذة المنبثقة فقط
        // عندما يحرك المستخدم شريط التمرير، دون إعادة بناء الشاشة الرئيسية كاملة.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Progress: ${goal.title}'),
              // محتوى النافذة
              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // جعل العمود يأخذ أقل مساحة ممكنة
                children: [
                  // عرض النسبة المختارة حالياً كنص
                  Text('${currentProgress.round()}%'),

                  // شريط التمرير (Slider)
                  Slider(
                    value: currentProgress,
                    min: 0,
                    max: 100,
                    divisions: 100, // تقسيم الشريط لـ 100 خطوة
                    label: currentProgress
                        .round()
                        .toString(), // نص يظهر فوق المؤشر
                    onChanged: (value) {
                      // عند تحريك الشريط، نحدث القيمة المؤقتة
                      setState(() {
                        currentProgress = value;
                      });
                    },
                  ),
                ],
              ),
              // أزرار الإجراءات أسفل النافذة
              actions: [
                // زر الإلغاء: يغلق النافذة دون حفظ
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                // زر الحفظ: ينفذ التحديث ويغلق النافذة
                TextButton(
                  onPressed: () {
                    // استدعاء دالة التحديث في المزود
                    provider.updateProgress(goal, currentProgress.round());
                    Navigator.pop(context); // إغلاق النافذة
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // دالة مساعدة تعرض رسالة تحذير قبل حذف الهدف نهائياً.
  // تمنع الحذف الخطأ وتعطي المستخدم فرصة للتراجع.
  // ---------------------------------------------------------------------------
  void _confirmDelete(
    BuildContext context,
    GoalProvider provider,
    GoalModel goal,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // زر الحذف (ملون بالأحمر للدلالة على الخطر)
          TextButton(
            onPressed: () {
              provider.deleteGoal(goal.id); // الحذف الفعلي
              Navigator.pop(context); // إغلاق النافذة

              // عرض رسالة تأكيد صغيرة أسفل الشاشة (SnackBar)
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('${goal.title} deleted')));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
