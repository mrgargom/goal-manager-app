import 'dart:ui' as ui;
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';

// ---------------------------------------------------------------------------
// هذا الملف يمثل "بطاقة الهدف" (GoalCard).
// ---------------------------------------------------------------------------
// الغرض منه:
// عرض تفاصيل هدف واحد بشكل جميل ومنسق داخل بطاقة (Card) في القائمة.
//
// الخصائص التي توفرها البطاقة:
// 1. عرض العنوان مع تلوين النص المطابق للبحث (Search Highlighting).
// 2. عرض الوصف وتواريخ البداية والنهاية.
// 3. شريط تقدم (Progress Bar) ملون حسب نسبة الإنجاز.
// 4. خيارات التعديل والحذف.
// 5. ميزة إضافية: تنزيل البطاقة كصورة (خاصة بنسخة الويب).
// ---------------------------------------------------------------------------

class GoalCard extends StatefulWidget {
  // نموذج الهدف الذي سيتم عرض بياناته
  final GoalModel goal;

  // دالة تُستدعى عند الضغط على زر "تعديل"
  final VoidCallback onEdit;

  // دالة تُستدعى عند الضغط على زر "حذف"
  final VoidCallback onDelete;

  // نص البحث الحالي (لتلوين الكلمات المطابقة في العنوان)
  final String searchQuery;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  // مفتاح فريد (GlobalKey) يستخدم لتحديد هذا الجزء من الواجهة
  // نحتاجه لالتقاط صورة للبطاقة (Screenshot)
  final GlobalKey _globalKey = GlobalKey();

  // ---------------------------------------------------------------------------
  // دالة: تحميل صورة البطاقة
  // تقوم بتحويل الـ Widget إلى صورة PNG وتنزيلها (تعمل برمجياً على الويب)
  // ---------------------------------------------------------------------------
  Future<void> _downloadGoalImage() async {
    try {
      // 1. العثور على حدود الرسم (RepaintBoundary) باستخدام المفتاح
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 2. التقاط الصورة (pixelRatio 3.0 لجودة عالية)
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // 3. تحويل الصورة إلى بيانات ثنائية (Bytes) بصيغة PNG
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // تجهيز اسم الملف: goal_اسم_الهدف.png (استبدال المسافات بشرطة سفلية)
        final String fileName =
            'goal_${widget.goal.title.replaceAll(RegExp(r'\s+'), '_')}.png';

        // 4. منطق التنزيل الخاص بالويب (utilizing package:web)
        // إنشاء كائن Blob من البيانات
        final blob = web.Blob([pngBytes.toJS].toJS);
        // إنشاء رابط مؤقت للكائن
        final url = web.URL.createObjectURL(blob);
        // إنشاء عنصر رابط (anchor) وهمي
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        // محاكاة ضغطة الزر لبدء التنزيل
        anchor.click();
        // تنظيف الرابط من الذاكرة
        web.URL.revokeObjectURL(url);

        // إعلام المستخدم بالنجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully!')),
          );
        }
      }
    } catch (e) {
      // إعلام المستخدم بالفشل
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download goal: $e')));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // دالة مساعدة لتحديد لون شريط التقدم بناءً على النسبة
  // ---------------------------------------------------------------------------
  Color _getProgressColor(BuildContext context, int progress) {
    final scheme = Theme.of(context).colorScheme;

    // 0% -> لون الخطأ (أحمر عادة)
    if (progress == 0) return scheme.error;

    // 100% -> اللون الأساسي (للمكافأة/الإتمام)
    if (progress == 100) return scheme.primary;

    // بينهما -> اللون الثانوي
    return scheme.secondary;
  }

  // ---------------------------------------------------------------------------
  // دالة بناء عنوان البطاقة (مع ميزة البحث)
  // تقوم بتجزئة النص لتلوين الجزء المطابق للبحث
  // ---------------------------------------------------------------------------
  Widget _buildTitle(BuildContext context) {
    // إذا لم يكن هناك بحث، اعرض العنوان كما هو
    if (widget.searchQuery.isEmpty) {
      return Text(
        widget.goal.title,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    // تحويل النصوص لأحرف صغيرة للمقارنة (Case-insensitive)
    final lowerTitle = widget.goal.title.toLowerCase();
    final lowerQuery = widget.searchQuery.toLowerCase();

    // البحث عن مكان النص المطابق
    final startIndex = lowerTitle.indexOf(lowerQuery);

    // إذا لم يوجد تطابق، اعرض العنوان عادي
    if (startIndex == -1) {
      return Text(
        widget.goal.title,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    // تقسيم العنوان لثلاثة أجزاء: ما قبل البحث، البحث نفسه، وما بعده
    final endIndex = startIndex + lowerQuery.length;
    final beforeMatch = widget.goal.title.substring(0, startIndex);
    final match = widget.goal.title.substring(startIndex, endIndex);
    final afterMatch = widget.goal.title.substring(endIndex);

    // تجهيز التنسيقات
    final style = Theme.of(context).textTheme.titleLarge;
    final colorScheme = Theme.of(context).colorScheme;

    // تنسيق التمييز (خلفية ملونة للنص المطابق)
    final highlightStyle = style?.copyWith(
      backgroundColor: colorScheme.tertiaryContainer,
      color: colorScheme.onTertiaryContainer,
    );

    // استخدام RichText لدمج النصوص بتنسيقات مختلفة
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: beforeMatch), // النص العادي قبل التطابق
          TextSpan(text: match, style: highlightStyle), // النص المطابق (ملون)
          TextSpan(text: afterMatch), // النص العادي بعد التطابق
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // دالة بناء الواجهة الرئيسية للبطاقة
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // RepaintBoundary: ضروري لالتقاط صورة لهذا الجزء فقط من الشاشة
    return RepaintBoundary(
      key: _globalKey, // ربط المفتاح هنا
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ), // هوامش خارجية
        child: Padding(
          padding: const EdgeInsets.all(16.0), // هوامش داخلية للمحتوى
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // محاذاة لليسار/للبداية
            children: [
              // الصف الأول: العنوان + زر التحميل + قائمة الخيارات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // العنوان (يأخذ المساحة المتاحة)
                  Expanded(child: _buildTitle(context)),

                  // زر تنزيل الصورة
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _downloadGoalImage, // استدعاء دالة التنزيل
                    tooltip: 'Download Image',
                  ),

                  // قائمة منبثقة (تعديل / حذف)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit(); // تنفيذ دالة التعديل الممررة
                      } else if (value == 'delete') {
                        widget.onDelete(); // تنفيذ دالة الحذف الممررة
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red), // لون أحمر للحذف
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // عرض الوصف إن وجد
              if (widget.goal.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.goal.description),
              ],

              // عرض التواريخ (بداية ونهاية) إن وجدت
              if (widget.goal.startDate != null ||
                  widget.goal.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.goal.startDate != null)
                      Text(
                        'Start: ${DateFormat.yMMMd().format(widget.goal.startDate!.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (widget.goal.startDate != null &&
                        widget.goal.endDate != null)
                      const SizedBox(width: 16),
                    if (widget.goal.endDate != null)
                      Text(
                        'End: ${DateFormat.yMMMd().format(widget.goal.endDate!.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // شريط التقدم ونسبة الإنجاز
              Row(
                children: [
                  // الشريط يأخذ المساحة المتبقية
                  Expanded(
                    child: LinearProgressIndicator(
                      value: widget.goal.progress / 100, // قيمة بين 0.0 و 1.0
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: _getProgressColor(context, widget.goal.progress),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // النص الرقمي للنسبة (مثلاً 50%)
                  Text(
                    '${widget.goal.progress}%',
                    style: TextStyle(
                      color: _getProgressColor(context, widget.goal.progress),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
