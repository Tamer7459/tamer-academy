import '../models/course.dart';
import '../models/lesson.dart';

// Track 2 – Foundations of Flutter UI (06-11) + تفاصيل إضافية للمبتدئ/متوسط
List<Lesson> buildTrack2Lessons(String courseId) {
  return [
    _lesson06(courseId),
    _lesson07(courseId),
    _lesson08(courseId),
    _lesson09(courseId),
    _lesson10(courseId),
    _lesson11(courseId),
    _lesson12(courseId), // إضافي: Responsive & Adaptive
  ];
}

// ---------------------------------------------------------------------------
// Lesson 06: Project Structure for Flutter
// ---------------------------------------------------------------------------
Lesson _lesson06(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
فهم بنية مشروع Flutter القياسية وإعدادها للعمل الجماعي والتوسع.

## 📖 الشرح النظري المفصل

### إنشاء المشروع
```bash
flutter create my_app
cd my_app
flutter run
```

### الهيكلة
```
my_app/
  android/          # نيتف أندرويد
  ios/              # نيتف iOS
  web/              # ويب
  lib/
    main.dart       # نقطة الدخول
    screens/        # الشاشات
    widgets/        # ودجات مشتركة
    models/         # نماذج البيانات
    services/       # خدمات
    core/           # ثيم وألوان
  assets/           # صور، خطوط
  pubspec.yaml      # التبعيات
  analysis_options.yaml
```

### pubspec.yaml
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
```

### main.dart
```dart
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override Widget build(context) => MaterialApp(home: Scaffold(body: Center(child: Text('Hi'))));
}
```

### مجلدات مقترحة للمبتدئ/متوسط
- `core/app_theme.dart` للألوان
- `screens/` لكل شاشة
- `widgets/` لمكونات معاد استخدامها
- `services/` لـ Firestore/Auth

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هيكلة Flutter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: const Text('هيكلة المشروع')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_rounded, size: 60, color: Colors.teal),
              const SizedBox(height: 12),
              const Text('lib/main.dart هي نقطة البداية', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              FilledButton(onPressed: (){}, child: const Text('ابدأ')),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** أنشئ مشروع `flutter create structure_demo`، ثم أعد تنظيمه بإنشاء مجلدات `screens/home`, `widgets`, `core` وانقل `MyHomePage` إلى `screens/home/home_screen.dart` واعرضه من `main.dart`. استند إلى ما تعلمته في التركيب.
''';

  const contentEn = r'''## 🎯 Goal
Understand Flutter project structure.

## 📖 Theory
flutter create, lib/main.dart, pubspec.yaml, assets.

## 💻 Example
Full Flutter app as above.

## 📝 Exercise
Create structure_demo and reorganize into screens/widgets/core.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: const Text('هيكلة المشروع')),
        body: const Center(child: Text('lib/main.dart -> نقطة البداية', style: TextStyle(fontSize: 18))),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l06',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 06: هيكلة مشروع Flutter', en: 'Lesson 06: Project Structure for Flutter', fr: 'Leçon 06: Structure Flutter'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 7,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: أنشئ مشروع structure_demo وأعد تنظيمه إلى screens/home, widgets, core مع نقل الشاشة الرئيسية.', en: 'Create structure_demo and reorganize.', fr: 'Créez structure_demo.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: flutter create structure_demo → أنشئ lib/screens/home/home_screen.dart → انقل MyHomePage → استدعها في main.dart عبر import', en: 'Solution: Create folders and move MyHomePage.', fr: 'Solution: Créez dossiers.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 07: Layout Widgets
// ---------------------------------------------------------------------------
Lesson _lesson07(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
إتقان ودجات التخطيط الأساسية لبناء واجهات متجاوبة.

## 📖 الشرح النظري المفصل

### Row & Column
```dart
Row(children: [Icon(Icons.star), Text('نص')]) // أفقي
Column(children: [Text('1'), Text('2')]) // عمودي
```

### Expanded & Flexible
- `Expanded` يملأ المساحة المتبقية
```dart
Row(children: [Expanded(child: Container(color: Colors.red)), Container(width: 50, color: Colors.blue)])
```
- `Flexible` مشابه لكن لا يجبر الملء

### Stack & Positioned
تكديس فوق بعض:
```dart
Stack(children: [
  Container(color: Colors.teal, height: 100),
  Positioned(top: 10, right: 10, child: Icon(Icons.favorite, color: Colors.white)),
])
```

### Container, Center, Padding, Align
```dart
Container(padding: EdgeInsets.all(16), color: Colors.grey, child: Text('مرحبا'))
Center(child: Text('وسط'))
Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('هوامش'))
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Layout Widgets')),
        body: Column(
          children: [
            Container(color: Colors.teal, height: 80, child: const Center(child: Text('Header', style: TextStyle(color: Colors.white)))),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Container(color: Colors.amber, child: const Center(child: Text('يسار')))),
                  Container(width: 100, color: Colors.blue, child: const Center(child: Text('يمين'))),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 80, color: Colors.grey[200]),
                const Icon(Icons.star, size: 40, color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على الدروس 06-07، صمم شاشة Profile تحتوي على: `Column` رئيسي، `Row` للصورة والاسم، `Expanded` لقسم الإحصائيات، و `Stack` لصورة غلاف مع زر تعديل `Positioned`. استخدم `Container` و `Padding`.
''';

  const contentEn = r'''## 🎯 Goal
Master Row, Column, Expanded, Stack, Container.

## 📖 Theory
Layout widgets for responsive UI.

## 💻 Example
Header + Row + Stack demo.

## 📝 Exercise
Build Profile screen with Row, Expanded, Stack.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Layout')),
        body: Column(
          children: [
            Container(
              height: 100,
              color: Colors.teal,
              child: const Row(
                children: [
                  Padding(padding: EdgeInsets.all(12), child: CircleAvatar(child: Text('ت'))),
                  Text('تامر', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Container(margin: const EdgeInsets.all(8), color: Colors.orange[100], child: const Center(child: Text('إحصائيات')))),
                  const SizedBox(width: 8),
                  Container(width: 100, color: Colors.blue[100], child: const Center(child: Text('قائمة'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l07',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 07: ودجات التخطيط', en: 'Lesson 07: Layout Widgets', fr: 'Leçon 07: Layout'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 8,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: صمم شاشة Profile بـ Column وRow للصورة والاسم وExpanded للإحصائيات وStack للغلاف مع Positioned.', en: 'Build Profile with Row/Expanded/Stack.', fr: 'Construisez Profile.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: Column > Container(Row[CircleAvatar,Text]) + Expanded(Row[Expanded, Container]) + Stack[Container, Positioned(icon)]', en: 'Solution: Use Column, Row, Expanded, Stack.', fr: 'Solution: Utilisez Column, Row.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 08: Fundamental UI Elements
// ---------------------------------------------------------------------------
Lesson _lesson08(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
التحكم في العناصر الأساسية: نصوص، أيقونات، صور، أزرار، AppBar، Scaffold.

## 📖 الشرح النظري المفصل

### النصوص
```dart
Text('مرحبا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.teal))
```

### الأيقونات والصور
```dart
Icon(Icons.favorite, color: Colors.red)
Image.asset('assets/logo.png', width: 60)
Image.network('https://...', fit: BoxFit.cover)
```

### الأزرار
- `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton`
```dart
FilledButton(onPressed: (){}, child: Text('حفظ'))
OutlinedButton.icon(onPressed: (){}, icon: Icon(Icons.add), label: Text('إضافة'))
```

### AppBar & Scaffold
```dart
Scaffold(
  appBar: AppBar(title: Text('عنوان'), actions: [IconButton(icon: Icon(Icons.search), onPressed: (){})]),
  body: Center(child: Text('محتوى')),
  floatingActionButton: FloatingActionButton(onPressed: (){}, child: Icon(Icons.add)),
)
```

### Card, Chip, Divider
```dart
Card(child: Padding(padding: EdgeInsets.all(12), child: Text('بطاقة')))
Chip(label: Text('وسم'))
Divider()
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('عناصر UI'), actions: [IconButton(icon: const Icon(Icons.search), onPressed: (){})]),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مرحبا تامر', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network('https://picsum.photos/400/200', height: 120, width: double.infinity, fit: BoxFit.cover)),
              const SizedBox(height: 12),
              Row(children: [
                FilledButton(onPressed: (){}, child: const Text('متابعة')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: (){}, child: const Text('تخطي')),
                const Spacer(),
                const Icon(Icons.star, color: Colors.orange),
              ]),
              const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('بطاقة معلومات'))),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على 06-08، أنشئ شاشة بطاقة دورة تحتوي على: `AppBar` بعنوان، `Image.network` للغلاف، `Text` للعنوان والوصف، صف أزرار `Filled/Outlined`, و `Card` للإحصائيات.
''';

  const contentEn = r'''## 🎯 Goal
Master Text, Icon, Image, Buttons, AppBar, Scaffold.

## 💻 Example
AppBar + Image + Buttons + Card.

## 📝 Exercise
Build course card with AppBar, Image, Text, Buttons, Card.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('عناصر')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('دورة Flutter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network('https://picsum.photos/400/200', height: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Row(children: [
              FilledButton(onPressed: (){}, child: const Text('ابدأ')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: (){}, child: const Text('تفاصيل')),
            ]),
            const Card(child: ListTile(leading: Icon(Icons.play_circle), title: Text('12 درس'), subtitle: Text('مبتدئ'))),
          ],
        ),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l08',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 08: عناصر UI الأساسية', en: 'Lesson 08: Fundamental UI Elements', fr: 'Leçon 08: Éléments UI'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 9,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: شاشة بطاقة دورة بـ AppBar, Image.network, Text, Row أزرار, Card إحصائيات. اعتمد على 06-08.', en: 'Build course card with AppBar, Image, Text, Buttons, Card.', fr: 'Construisez carte cours.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: Scaffold > AppBar + ListView > Text + Image.network + Row[FilledButton, OutlinedButton] + Card[ListTile]', en: 'Solution: Use Scaffold, AppBar, Image, Buttons, Card.', fr: 'Solution: Utilisez Scaffold.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 09: Input & Forms
// ---------------------------------------------------------------------------
Lesson _lesson09(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
بناء نماذج إدخال متكاملة مع تحكم وتحقق.

## 📖 الشرح النظري المفصل

### TextField vs TextFormField
```dart
TextField(controller: ctrl, decoration: InputDecoration(labelText: 'الاسم'))
TextFormField(validator: (v)=> v!.isEmpty ? 'مطلوب' : null)
```

### Controller & Focus
```dart
final ctrl = TextEditingController();
TextField(controller: ctrl)
print(ctrl.text);
ctrl.dispose(); // في dispose
```

### Form + GlobalKey
```dart
final _key = GlobalKey<FormState>();
Form(key: _key, child: Column(children: [
  TextFormField(validator: (v)=> v!.length <3 ? 'قصير' : null),
  FilledButton(onPressed: (){ if(_key.currentState!.validate()) print('صحيح'); }, child: Text('حفظ'))
]))
```

### أنواع لوحة المفاتيح
`keyboardType: TextInputType.emailAddress/number/phone`

### obscureText, maxLines, decoration
```dart
TextField(obscureText: true, decoration: InputDecoration(prefixIcon: Icon(Icons.lock), hintText: 'كلمة المرور'))
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatefulWidget { const MyApp({super.key}); @override State<MyApp> createState()=> _MyAppState(); }
class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  @override Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('نموذج')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person)), validator: (v)=> v!.isEmpty?'مطلوب':null),
              const SizedBox(height: 12),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'البريد', prefixIcon: Icon(Icons.email)), validator: (v)=> !v!.contains('@')?'بريد غير صالح':null),
              const SizedBox(height: 16),
              FilledButton(onPressed: (){ if(_formKey.currentState!.validate()) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ'))); }, child: const Text('حفظ')),
            ]),
          ),
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على 06-09، أنشئ شاشة تسجيل دخول بحقول: الاسم، البريد، كلمة المرور (obscureText) مع `Form` و `validator` لكل حقل وزر حفظ يتحقق.
''';

  const contentEn = r'''## 🎯 Goal
Build forms with validation.

## 💻 Example
Form with name/email and validation.

## 📝 Exercise
Build login screen with name/email/password, Form and validators.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatefulWidget { const MyApp({super.key}); @override State<MyApp> createState()=> _S(); }
class _S extends State<MyApp> {
  final _k = GlobalKey<FormState>();
  final _n = TextEditingController();
  final _e = TextEditingController();
  final _p = TextEditingController();
  @override Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('تسجيل')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _k,
            child: Column(children: [
              TextFormField(controller: _n, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person)), validator: (v)=> v!.isEmpty?'مطلوب':null),
              const SizedBox(height: 10),
              TextFormField(controller: _e, decoration: const InputDecoration(labelText: 'البريد'), validator: (v)=> !v!.contains('@')?'خطأ':null),
              const SizedBox(height: 10),
              TextFormField(controller: _p, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)), validator: (v)=> v!.length<6?'قصيرة':null),
              const SizedBox(height: 16),
              FilledButton(onPressed: (){ if(_k.currentState!.validate()) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم'))); }, child: const Text('تسجيل')),
            ]),
          ),
        ),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l09',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 09: الإدخال والنماذج', en: 'Lesson 09: Input & Forms', fr: 'Leçon 09: Saisie & Formulaires'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 10,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: شاشة تسجيل دخول بحقول اسم/بريد/كلمة مرور مع Form و validator وزر حفظ. اعتمد على 06-09.', en: 'Build login with name/email/password, Form and validators.', fr: 'Construisez login.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: 3 TextFormField مع controllers و validator و Form(key) و FilledButton يتحقق عبر _formKey.currentState!.validate()', en: 'Solution: Use Form, controllers, validators.', fr: 'Solution: Utilisez Form.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 10: Grids, Lists, and Scroll
// ---------------------------------------------------------------------------
Lesson _lesson10(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
عرض قوائم وشبكات وتمرير احترافي.

## 📖 الشرح النظري المفصل

### ListView
```dart
ListView(children: [Text('1'), Text('2')])
ListView.separated(itemCount: 10, separatorBuilder: (_,_)=> Divider(), itemBuilder: (_,i)=> ListTile(title: Text('عنصر $i')))
ListView.builder(itemCount: 100, itemBuilder: (_,i)=> Text('$i'))
```

### GridView
```dart
GridView.count(crossAxisCount: 2, children: [Container(color: Colors.red), Container(color: Colors.blue)])
GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemBuilder: (_,i)=> Card(child: Text('$i')))
```

### Scroll
- `SingleChildScrollView` لمحتوى واحد طويل
- `CustomScrollView` + `SliverList`/`SliverGrid` لأداء عالي
- `ReorderableListView` لإعادة الترتيب
```dart
CustomScrollView(slivers: [
  SliverAppBar(title: Text('مرحبا')),
  SliverList.builder(itemCount: 20, itemBuilder: (_,i)=> ListTile(title: Text('عنصر $i'))),
])
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('قوائم وشبكات')),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(12), child: Text('قائمة عمودية', style: TextStyle(fontWeight: FontWeight.bold)))),
            SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_,_)=> const Divider(height: 1),
              itemBuilder: (_,i)=> ListTile(leading: CircleAvatar(child: Text('${i+1}')), title: Text('عنصر ${i+1}'), trailing: const Icon(Icons.chevron_right)),
            ),
            SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(12), child: Text('شبكة', style: TextStyle(fontWeight: FontWeight.bold)))),
            SliverGrid.count(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, children: List.generate(4, (i)=> Container(color: Colors.primaries[i % Colors.primaries.length], child: Center(child: Text('شبكة ${i+1}', style: TextStyle(color: Colors.white))))),
          ],
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على 06-10، أنشئ شاشة مع `CustomScrollView` يحتوي على: `SliverAppBar`, `SliverList` (5 عناصر بفاصل), و `SliverGrid` (4 مربعات ملونة).
''';

  const contentEn = r'''## 🎯 Goal
Master ListView, GridView, CustomScrollView.

## 💻 Example
CustomScrollView with SliverList and SliverGrid.

## 📝 Exercise
Build CustomScrollView with SliverAppBar, SliverList (5) and SliverGrid (4).
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(title: Text('قوائم'), pinned: true),
            SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_,_)=> const Divider(height: 1),
              itemBuilder: (_,i)=> ListTile(leading: CircleAvatar(child: Text('${i+1}')), title: Text('عنصر ${i+1}')),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(4, (i)=> Container(
                  decoration: BoxDecoration(color: Colors.primaries[i], borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text('شبكة ${i+1}', style: const TextStyle(color: Colors.white))),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l10',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 10: القوائم والشبكات والتمرير', en: 'Lesson 10: Grids, Lists, and Scroll', fr: 'Leçon 10: Grilles, Listes et Défilement'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 11,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: شاشة CustomScrollView مع SliverAppBar و SliverList (5 عناصر) و SliverGrid (4 مربعات). اعتمد على 06-10.', en: 'Build CustomScrollView with SliverAppBar, SliverList (5) and SliverGrid (4).', fr: 'Construisez CustomScrollView.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: CustomScrollView > SliverAppBar + SliverList.separated(5) + SliverGrid.count(4) كما في المثال.', en: 'Solution: Use CustomScrollView with slivers.', fr: 'Solution: Utilisez CustomScrollView.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 11: Custom Styling & Theming
// ---------------------------------------------------------------------------
Lesson _lesson11(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
بناء هوية بصرية موحدة عبر Theme و Styling.

## 📖 الشرح النظري المفصل

### ThemeData
```dart
MaterialApp(
  theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
  darkTheme: ThemeData(brightness: Brightness.dark),
  themeMode: ThemeMode.system,
)
```

### ColorScheme & TextTheme
```dart
Theme.of(context).colorScheme.primary // اللون الأساسي
Theme.of(context).textTheme.titleLarge // نمط النص
```

### GoogleFonts
```dart
import 'package:google_fonts/google_fonts.dart';
Text('مرحبا', style: GoogleFonts.cairo(fontWeight: FontWeight.w700))
```

### AppTheme مخصص
```dart
class AppTheme {
  static ThemeData light() => ThemeData(...);
  static ThemeData dark() => ThemeData(...);
}
```

### استخدام الثيم
```dart
Container(color: Theme.of(context).colorScheme.primary)
Text('نص', style: Theme.of(context).textTheme.titleMedium)
Icon(Icons.star, color: Theme.of(context).colorScheme.primary)
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatefulWidget { const MyApp({super.key}); @override State<MyApp> createState()=> _S(); }
class _S extends State<MyApp> {
  bool isDark = false;
  @override Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(title: const Text('الثيم'), actions: [IconButton(icon: Icon(isDark? Icons.light_mode: Icons.dark_mode), onPressed: ()=> setState(()=> isDark=!isDark))]),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(16), color: Theme.of(context).colorScheme.primary.withAlpha(30), child: Text('لون أساسي', style: TextStyle(color: Theme.of(context).colorScheme.primary))),
            const SizedBox(height: 12),
            FilledButton(onPressed: (){}, child: const Text('زر')),
          ]),
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على 06-11، أنشئ ثيمين `light/dark` مع `colorSchemeSeed` مختلف، وزر في `AppBar` يبدل `themeMode` مع حفظه في `SharedPreferences`، واعرض `Container` و `Text` و `FilledButton` بألوان الثيم.
''';

  const contentEn = r'''## 🎯 Goal
Master ThemeData, ColorScheme, GoogleFonts, custom AppTheme.

## 💻 Example
Toggle light/dark theme.

## 📝 Exercise
Build light/dark themes with toggle and SharedPreferences.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatefulWidget { const MyApp({super.key}); @override State<MyApp> createState()=> _MyAppState(); }
class _MyAppState extends State<MyApp> {
  bool dark=false;
  @override Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange, brightness: Brightness.dark),
      themeMode: dark? ThemeMode.dark: ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('الثيم'),
          actions: [IconButton(icon: Icon(dark? Icons.light_mode: Icons.dark_mode), onPressed: ()=> setState(()=> dark=!dark))],
        ),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(40), borderRadius: BorderRadius.circular(12)), child: Text('لون الثيم', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800))),
            const SizedBox(height: 12),
            FilledButton(onPressed: (){}, child: const Text('زر بالثيم')),
          ]),
        ),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l11',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 11: التخصيص والثيم', en: 'Lesson 11: Custom Styling & Theming', fr: 'Leçon 11: Style & Thème'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 12,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: ثيمين light/dark مع زر تبديل وحفظ في SharedPreferences وعرض Container/Text/Button بألوان الثيم. اعتمد على 06-11.', en: 'Build light/dark themes with toggle and save.', fr: 'Construisez thèmes.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: ThemeData.light/dark مع colorSchemeSeed، و IconButton يبدل themeMode ويحفظ في SharedPreferences.', en: 'Solution: Use ThemeData and toggle.', fr: 'Solution: Utilisez ThemeData.'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 12: Responsive & Adaptive (إضافي للمستوى المتوسط)
// ---------------------------------------------------------------------------
Lesson _lesson12(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
جعل الواجهات متجاوبة على كل الأحجام.

## 📖 الشرح النظري المفصل

### MediaQuery
```dart
final w = MediaQuery.of(context).size.width;
Text(w < 600 ? 'هاتف' : 'تابلت')
```

### LayoutBuilder
```dart
LayoutBuilder(builder: (_, c){
  if(c.maxWidth < 600) return Column(children: [...]);
  return Row(children: [...]);
})
```

### FittedBox, Expanded, Flexible
```dart
FittedBox(child: Text('نص كبير جدا'))
```

## 💻 مثال كود Flutter كامل

```dart
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('متجاوب')),
        body: LayoutBuilder(builder: (context, c){
          final isWide = c.maxWidth > 600;
          return isWide
              ? Row(children: [Expanded(child: Container(color: Colors.teal, child: const Center(child: Text('يسار')))), Expanded(child: Container(color: Colors.orange, child: const Center(child: Text('يمين'))))])
              : Column(children: [Container(height: 100, color: Colors.teal, child: const Center(child: Text('أعلى'))), Expanded(child: Container(color: Colors.orange, child: const Center(child: Text('أسفل'))))]);
        }),
      ),
    );
  }
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على 06-12، صمم شاشة متجاوبة: على الهاتف `Column` (صورة فوق نص)، وعلى الويب `Row` (صورة يسار نص يمين) باستخدام `LayoutBuilder` و `MediaQuery`.
''';

  const contentEn = r'''## 🎯 Goal
Make UI responsive.

## 💻 Example
LayoutBuilder Row/Column switch.

## 📝 Exercise
Build responsive screen with LayoutBuilder.
''';
  const contentFr = contentEn;

  const code = r'''
import 'package:flutter/material.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('متجاوب')),
        body: LayoutBuilder(builder: (context, c){
          bool wide = c.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: wide
                ? Row(children: [Expanded(child: Image.network('https://picsum.photos/300/200')), const SizedBox(width: 12), const Expanded(child: Text('وصف على اليمين'))])
                : Column(children: [Image.network('https://picsum.photos/300/200'), const SizedBox(height: 12), const Text('وصف أسفل')]),
          );
        }),
      ),
    );
  }
}
''';

  return Lesson(
    id: '${courseId}_t2_l12',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 12: واجهات متجاوبة', en: 'Lesson 12: Responsive UI', fr: 'Leçon 12: UI Responsive'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 13,
    exercise: const Exercise(
      question: LocalizedText(ar: 'المطلوب: شاشة متجاوبة بـ LayoutBuilder: هاتف Column وتابلت/ويب Row. اعتمد على 06-12.', en: 'Build responsive screen with LayoutBuilder.', fr: 'Construisez écran responsive.'),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(ar: 'الحل: LayoutBuilder > isWide ? Row[Image, Text] : Column[Image, Text]', en: 'Solution: Use LayoutBuilder.', fr: 'Solution: Utilisez LayoutBuilder.'),
    ),
  );
}
