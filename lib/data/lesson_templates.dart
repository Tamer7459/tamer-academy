import '../models/course.dart';

class ContentTemplates {
  static const lessonContentAr = r'''
## 🎯 هدف الدرس
اكتب هدف الدرس هنا بجملة واضحة.

## 📖 الشرح النظري
اشرح المفهوم الأساسي مع أمثلة مبسطة.

### النقطة الأولى
- شرح مختصر
- مثال سريع

### النقطة الثانية
> ملاحظة مهمة: ضع التنبيه هنا

## 💻 مثال كود
```dart
void main() {
  print('مرحبا Dart');
}
```

## 📊 جدول مقارنة
| العنصر | الوصف | الاستخدام |
|---|---|---|
| A | وصف A | حالة 1 |
| B | وصف B | حالة 2 |

## 📝 الخلاصة
- نقطة 1
- نقطة 2
''';

  static const lessonContentEn = r'''
## 🎯 Goal
Write lesson goal here.

## 📖 Theory
Explain concept.

## 💻 Example
```dart
void main() { print('Hello Dart'); }
```

## 📝 Summary
- point 1
- point 2
''';
  static const lessonContentFr = lessonContentEn;

  static const exerciseQuestionAr = 'ما هو الفرق بين var و final في Dart؟ ومتى تستخدم كل منهما؟';
  static const exerciseQuestionEn = 'What is the difference between var and final in Dart? When to use each?';
  static const exerciseQuestionFr = 'Quelle est la différence entre var et final en Dart ?';
  static const exerciseSolutionAr = 'var يستنتج النوع ويمكن إعادة الإسناد بنفس النوع، أما final فيُضبط مرة واحدة وقت التشغيل ولا يُعاد. استخدم var للمتغيرات العادية وfinal للقيم الثابتة بعد التهيئة.';
  static const exerciseSolutionEn = 'var infers type and allows reassignment same type, final is set once at runtime. Use var for normal vars and final for runtime constants.';
  static const exerciseSolutionFr = 'var infère le type, final est défini une fois à l\'exécution.';

  static const oralQuestionsAr = [
    {'q': 'ما هو المتغير؟ ولماذا نستخدمه؟', 'a': 'مكان في الذاكرة لتخزين قيمة والاحتفاظ بالبيانات ومعالجتها.'},
    {'q': 'ما الفرق بين var و dynamic؟', 'a': 'var يستنتج النوع ولا يغيره، dynamic يسمح بتغيير النوع أثناء التشغيل.'},
    {'q': 'ما الفرق بين final و const؟', 'a': 'كلاهما ثابت، const وقت الترجمة وfinal وقت التشغيل.'},
    {'q': 'متى تستخدم List ومتى Map؟', 'a': 'List لمجموعة مرتبة بالفهرس، Map لمفتاح/قيمة.'},
    {'q': 'ما فائدة Null Safety و ? و ??', 'a': '? يسمح بـ null و ?? يعطي قيمة بديلة عند null.'},
    {'q': 'ما الفرق بين int و double؟', 'a': 'int صحيح وdouble عشري. 15/2=7.5 و 15~/2=7.'},
    {'q': 'اشرح if/else بمثال', 'a': 'if تتحقق من شرط وتنفذ كوداً مختلفاً حسب النتيجة.'},
    {'q': 'ما الفرق بين for و while؟', 'a': 'for لعدد معروف، while لشرط قبل التنفيذ.'},
    {'q': 'ما هو Future ومتى نستخدمه؟', 'a': 'يمثل نتيجة ستتوفر لاحقاً مثل جلب بيانات من الشبكة.'},
  ];

  static const homeworkAr = r'''
📝 **الواجب المنزلي**

**المطلوب:**
1. عرّف متغيرات لأنواع مختلفة (String, int, double, bool, List, Map) واطبعها.
2. اكتب دالة تحسب ناتج عمليتين حسابيتين وتطبع النتيجة.
3. أنشئ قائمة وأضف/احذف عناصر ثم اعرضها.

**طريقة التسليم:** اكتب الكود في الأسفل واضغط إرسال — سيتم مراجعته من المدرس.
''';
  static const homeworkEn = r'''
📝 **Homework**

**Tasks:**
1. Define variables of different types and print them.
2. Write a function that calculates two operations.
3. Create a list, add/remove items and display it.
''';
  static const homeworkFr = homeworkEn;

  static const courseDescAr = r'''
دورة شاملة لتعلم البرمجة من الصفر حتى الاحتراف.

**ماذا ستتعلم:**
• الأساسيات والمفاهيم
• أمثلة عملية وكود مباشر
• مشاريع تطبيقية

**المتطلبات:** لا يحتاج خبرة سابقة.
''';
  static const courseDescEn = r'''
Comprehensive course from zero to hero.

**What you will learn:**
• Fundamentals
• Hands-on examples
• Projects

**Requirements:** No prior experience.
''';
  static const courseDescFr = courseDescEn;
}
