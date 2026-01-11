import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/goal_provider.dart';
import '../models/goal_model.dart';

// هذا الملف يمثل شاشة "إضافة هدف جديد" أو "تعديل هدف حالي"
// إذا تم تمرير هدف (GoalModel) لهذه الشاشة، فإنها تعمل في وضع "التعديل"
// وإلا، فإنها تعمل في وضع "الإضافة"
class AddGoalScreen extends StatefulWidget {
  // متغير اختياري لاستقبال الهدف المراد تعديله
  final GoalModel? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

// فئة الحالة للشاشة، تحتوي على المنطق وبيانات النموذج
class _AddGoalScreenState extends State<AddGoalScreen> {
  // مفتاح النموذج للتحقق من صحة المدخلات
  final _formKey = GlobalKey<FormState>();

  // وحدات تحكم لحقول النصوص (العنوان والوصف)
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // متغيرات لتخزين تواريخ البداية والنهاية المختارة
  DateTime? _startDate;
  DateTime? _endDate;

  // متغير لتتبع حالة التحميل (لإظهار مؤشر الانتظار عند الحفظ)
  bool _isLoading = false;

  // دالة التهيئة الأولية (تستدعى مرة واحدة عند بناء الشاشة)
  @override
  void initState() {
    super.initState();
    // إذا كان هناك هدف ممرر (وضع التعديل)، نقوم بملء الحقول ببياناته
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description;
      // تحويل Timestamp الخاص بـ Firestore إلى DateTime
      _startDate = widget.goal!.startDate?.toDate();
      _endDate = widget.goal!.endDate?.toDate();
    }
  }

  // تنظيف الموارد عند إغلاق الشاشة
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // دالة لفتح نافذة اختيار التاريخ
  // المعامل isStart يحدد ما إذا كنا نختار تاريخ البداية أم النهاية
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // التاريخ الافتراضي هو اليوم
      firstDate: DateTime(2000), // أقل تاريخ مسموح به
      lastDate: DateTime(2101), // أقصى تاريخ مسموح به
    );
    // إذا قام المستخدم باختيار تاريخ (لم يضغط إلغاء)
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // دالة الحفظ (تُستدعى عند الضغط على زر الإضافة/التحديث)
  Future<void> _submit() async {
    // التحقق من صحة النموذج (مثل وجود العنوان)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // بدء التحميل
      try {
        final title = _titleController.text;
        final description = _descriptionController.text;

        // الحصول على مزود الأهداف (GoalProvider) للقيام بالعمليات
        final provider = Provider.of<GoalProvider>(context, listen: false);

        // التحقق: هل نحن في وضع إضافة جديد أم تعديل؟
        if (widget.goal == null) {
          // إضافة هدف جديد
          await provider.addGoal(
            title,
            description,
            startDate: _startDate,
            endDate: _endDate,
          );
        } else {
          // تعديل هدف موجود
          // نستخدم copyWith لإنشاء نسخة معدلة من الهدف الحالي
          final updatedGoal = widget.goal!.copyWith(
            title: title,
            description: description,
            // تحويل DateTime إلى Timestamp لقاعدة البيانات، أو الاحتفاظ بالقديم إذا لم يتغير
            startDate: _startDate != null
                ? Timestamp.fromDate(_startDate!)
                : widget.goal!.startDate,
            endDate: _endDate != null
                ? Timestamp.fromDate(_endDate!)
                : widget.goal!.endDate,
          );

          // إرسال التحديث للمزود
          await provider.updateGoal(updatedGoal);
        }

        // إغلاق الشاشة والعودة للقائمة بعد الانتهاء بنجاح
        if (mounted) Navigator.pop(context);
      } catch (e) {
        // عرض رسالة خطأ في حالة الفشل
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding goal: $e')));
        }
      } finally {
        // إيقاف التحميل في كل الأحوال
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // بناء واجهة المستخدم
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // تغيير عنوان الشاشة بناءً على الوضع (إضافة أو تعديل)
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // حقل إدخال العنوان
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                // التحقق من أن العنوان ليس فارغاً
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // حقل إدخال الوصف (متعدد الأسطر)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // عنصر لاختيار تاريخ البداية
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Select Start Date'
                      : 'Start Date: ${DateFormat.yMMMd().format(_startDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () =>
                    _selectDate(context, true), // true تعني تاريخ البداية
              ),
              // عنصر لاختيار تاريخ النهاية
              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Select End Date'
                      : 'End Date: ${DateFormat.yMMMd().format(_endDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () =>
                    _selectDate(context, false), // false تعني تاريخ النهاية
              ),
              const SizedBox(height: 24),
              // زر الحفظ
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submit, // تعطيل الزر أثناء التحميل
                child: _isLoading
                    // عرض مؤشر تحميل صغير داخل الزر
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    // تغيير نص الزر حسب الوضع
                    : Text(widget.goal == null ? 'Add Goal' : 'Update Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
