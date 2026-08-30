import '../models/course.dart';
import '../models/lesson.dart';

// Track 1 – Foundations of the Dart Language - 7 lessons
List<Lesson> buildTrack1Lessons(String courseId) {
  return [
    _lesson1(courseId),
    _lesson2(courseId),
    _lesson3(courseId),
    _lesson4(courseId),
    _lesson5(courseId),
    _lesson6(courseId),
    _lesson7(courseId),
  ];
}

// ---------------------------------------------------------------------------
// Lesson 1: Dart Toolchain & Environment
// ---------------------------------------------------------------------------
Lesson _lesson1(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
تمكينك من تثبيت Dart SDK وفهم أدواته (CLI, pub, DartPad) وبنية المشروع وتشغيل أول برنامج.

## 📖 الشرح النظري المفصل

### ما هي Dart ولماذا قبل Flutter؟
Dart لغة من Google تجمع بين سهولة JavaScript وقوة الأنظمة المكتوبة بلغات مثل Java. أهم ميزاتها:
- **Null Safety** يمنع أخطاء null الشهيرة
- **JIT** للتطوير السريع و **AOT** للأداء في الإنتاج
- مكتبة قياسية غنية ودعم غير متزامن ممتاز — كلها أساس فهم Flutter.

### تثبيت SDK
- **Windows:** `choco install dart-sdk` أو حمّل من `dart.dev/get-dart`
- **macOS:** `brew tap dart-lang/dart && brew install dart`
- **تحقق:** `dart --version`

```bash
dart --version
# Dart SDK version: 3.5.0
```

### Dart CLI
- `dart --help` المساعدة
- `dart create -t console hello` إنشاء مشروع
- `dart run` تشغيل
- `dart analyze` فحص
- `dart format .` تنسيق
- `dart pub get/add` إدارة الحزم

### بنية المشروع
```
hello/
  bin/hello.dart      # نقطة الدخول main()
  lib/                # كود مشترك
  pubspec.yaml        # التبعيات
  analysis_options.yaml
```

### DartPad
https://dartpad.dev محرر فوري في المتصفح — مثالي للتجربة والمشاركة دون تثبيت.

### تشغيل أول برنامج
```dart
void main() {
  print('مرحبا Dart!');
}
```
- `void` نوع الإرجاع (لا شيء)
- `main()` نقطة البداية
- `print()` تطبع في الطرفية

## 💻 مثال كود Dart كامل

```dart
// برنامج معلومات المستخدم - يطبق كل ما تعلمناه
void main() {
  // تعريف متغيرات
  String name = 'أحمد';
  int age = 20;
  String city = 'الرياض';
  String hobby = 'البرمجة';

  // طباعة منسقة
  print('=== معلوماتي ===');
  print('الاسم: $name');
  print('العمر: $age');
  print('المدينة: $city');
  print('الهواية: $hobby');
  print('مرحبا $name من $city!');
}
```

## 📝 تمرين عملي
**المطلوب:** أنشئ مشروع `my_info` عبر `dart create -t console my_info`، ثم عدّل `bin/my_info.dart` ليطبع اسمك، عمرك، مدينتك، وهوايتك، وشغّله عبر `dart run`. جرّب أيضاً `dart analyze` و `dart format`.

**تلميح الحل:** استخدم `String` و `int` و `print` مع `String interpolation` كما في المثال أعلاه.
''';

  const contentEn = r'''
## 🎯 Goal
Install Dart SDK and master CLI, pub, DartPad and project structure.

## 📖 Theory
Dart is Google's language for Flutter – null safe, JIT/AOT, great tooling.

## 💻 Example
```dart
void main(){ print('Hello Dart!'); }
```

## 📝 Exercise
Create my_info project and print your info, run with dart run, analyze and format.
''';
  const contentFr = contentEn;

  const code = r'''
void main() {
  // معلومات المستخدم - تمرين الدرس 1
  String name = 'أحمد'; // اسم المستخدم
  int age = 20; // العمر
  String city = 'الرياض'; // المدينة
  String hobby = 'البرمجة'; // الهواية

  print('=== معلوماتي ===');
  print('الاسم: $name');
  print('العمر: $age');
  print('المدينة: $city');
  print('الهواية: $hobby');
  print('مرحبا $name من $city! أتمنى لك رحلة ممتعة مع Dart');
}
''';

  return Lesson(
    id: '${courseId}_t1_l1',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 1: بيئة Dart وأدوات التطوير', en: 'Lesson 1: Dart Toolchain & Environment', fr: 'Leçon 1: Environnement Dart'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 0,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: أنشئ مشروع Dart جديد باسم my_info واكتب برنامج يطبع اسمك وعمرك ومدينتك وهوايتك. استخدم dart create و dart run. اكتب حلك في الخانة أدناه.',
        en: 'Create a Dart project my_info and print your name, age, city, hobby. Use dart create and dart run.',
        fr: 'Créez un projet my_info et affichez vos infos.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل النموذجي:\nvoid main(){\n  String name="أحمد";\n  int age=20;\n  String city="الرياض";\n  print("الاسم: \$name");\n  print("العمر: \$age");\n  print("المدينة: \$city");\n}\nشغّل عبر: dart create -t console my_info && dart run',
        en: 'Solution: Use String/int variables and print with interpolation, run with dart run.',
        fr: 'Solution: Utilisez String/int et print.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 2: Dart Core Syntax
// ---------------------------------------------------------------------------
Lesson _lesson2(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
إتقان القواعد الأساسية لكتابة كود Dart: main، التعليقات، print، والبنية العامة.

## 📖 الشرح النظري المفصل

### بنية البرنامج
كل برنامج Dart يبدأ بدالة `main()`:
```dart
void main() {
  print('Hello');
}
```

### التعليقات
```dart
// سطر واحد
/* متعدد
   أسطر */
/** توثيقي يظهر في IDE */
```

### main()
- `void` تعني لا ترجع قيمة
- يمكن أن تكون `void main() async` للعمليات غير المتزامنة

### print و الإخراج
```dart
print('مرحبا');
print(42);
print(true);
```

### القواعد
- كل جملة تنتهي بـ `;`
- الكتل بين `{ }`
- أسماء الملفات `snake_case`

## 💻 مثال كود Dart كامل

```dart
// برنامج يوضح القواعد الأساسية مع تعليقات
void main() {
  // معلومات الطالب
  String name = 'ليلى'; // اسم
  int age = 23; // عمر
  // طباعة ترحيب
  print('أهلاً $name!'); // استخدام String interpolation
  print('عمرك $age وسوف يصبح ${age + 1} العام القادم');
}
```

## 📝 تمرين عملي
**المطلوب:** اكتب برنامج يطبع بطاقة تعريف بسيطة تحتوي على اسمك، عمرك، ومدينتك، مع استخدام تعليق لكل سطر و `print` و `main()`. اعتمد على ما تعلمته في الدرس 1 أيضاً (إنشاء ملف وتشغيله).

**تلميح الحل:** استخدم `String name`, `int age`, `String city` وثلاثة أسطر `print`.
''';

  const contentEn = r'''
## 🎯 Goal
Master Dart core syntax: main, comments, print, structure.

## 📖 Theory
Every program starts with main(), comments // /* */, print for output.

## 💻 Example
```dart
void main(){ print('Hello'); }
```

## 📝 Exercise
Write a program printing your ID card with comments, main and print.
''';
  const contentFr = contentEn;

  const code = r'''
// بطاقة تعريف - يطبق قواعد الكتابة الأساسية
void main() {
  // تعريف البيانات
  String name = 'ليلى'; // الاسم
  int age = 23; // العمر
  String city = 'جدة'; // المدينة

  // طباعة البطاقة
  print('=== بطاقتي ==='); // عنوان
  print('الاسم: $name'); // طباعة الاسم
  print('العمر: $age'); // طباعة العمر
  print('المدينة: $city'); // طباعة المدينة
  print('مرحبا $name من $city!'); // رسالة ترحيب
}
''';

  return Lesson(
    id: '${courseId}_t1_l2',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 2: قواعد Dart الأساسية', en: 'Lesson 2: Dart Core Syntax', fr: 'Leçon 2: Syntaxe de base'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 1,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: اكتب برنامج يطبع بطاقتك (الاسم، العمر، المدينة) مع تعليق فوق كل سطر يوضح وظيفته. استخدم main() و print فقط.',
        en: 'Write a program printing your ID card with comments, main and print.',
        fr: 'Écrivez un programme affichant votre carte avec commentaires.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل:\nvoid main(){\n  // الاسم\n  String name="ليلى";\n  // العمر\n  int age=23;\n  print("الاسم: \$name");\n  print("العمر: \$age");\n}',
        en: 'Solution: Use main, comments and print with variables.',
        fr: 'Solution: Utilisez main, commentaires et print.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 3: Variables & Data Types
// ---------------------------------------------------------------------------
Lesson _lesson3(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
التمييز بين var/final/const/dynamic وإتقان الأنواع الأساسية والعمليات.

## 📖 الشرح النظري المفصل

### var vs final vs const vs dynamic
```dart
var name = 'Ali'; // يستنتج String، يمكن إعادة الإسناد بنفس النوع
final time = DateTime.now(); // يُحدد مرة وقت التشغيل، لا يُعاد
const pi = 3.14; // ثابت وقت الترجمة
dynamic x = 5; x = 'hi'; // يسمح بتغيير النوع (تجنبه)
```

| الكلمة | إعادة إسناد | وقت التحديد | استخدام |
|--------|-------------|-------------|---------|
| var | نعم (نفس النوع) | تشغيل | متغير عادي |
| final | لا | تشغيل | قيمة لا تتغير بعد الضبط |
| const | لا | ترجمة | ثابت معروف مسبقاً |
| dynamic | نعم (أي نوع) | تشغيل | تجنبه إلا للضرورة |

### أنواع البيانات
```dart
int count = 10;
double temp = 36.6;
String title = 'Dart';
bool done = true;
List<int> nums = [1,2,3];
Map<String,String> capitals = {'EG':'Cairo'};
```

### Operators
- حسابية: `+ - * / % ~/` (~/ قسمة صحيحة)
- مقارنة: `== != > < >= <=`
- منطقية: `&& || !`
- إسناد: `+= -= *=`
- زيادة: `i++` `++i`

### String interpolation المتقدم
```dart
String name='سعيد';
int age=22;
print('أنا $name وعمري $age'); // بسيط
print('العام القادم ${age+1}'); // تعبير
String stars = '*' * 10; // تكرار
```

## 💻 مثال كود Dart كامل

```dart
// حاسبة تطبق المتغيرات والأنواع
void main() {
  // أعداد
  int a = 12;
  int b = 4;
  // عمليات
  print('=== الحاسبة ===');
  print('$a + $b = ${a + b}'); // جمع
  print('$a - $b = ${a - b}'); // طرح
  print('$a * $b = ${a * b}'); // ضرب
  print('$a / $b = ${a / b}'); // قسمة
  print('$a ~/ $b = ${a ~/ b}'); // صحيحة
  print('$a % $b = ${a % b}'); // باقي

  // أنواع أخرى
  String op = 'جمع';
  bool isReady = true;
  List<String> ops = ['جمع','طرح'];
  print('حالة: $isReady والعمليات ${ops.join(', ')}');
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على ما تعلمته في الدروس 1-3، أنشئ حاسبة تفاعلية تحسب: الجمع، الطرح، الضرب، القسمة، القسمة الصحيحة `~/` وباقي القسمة `%` لعددين `a=15, b=4`. اعرض النتائج مع `print` واستخدم `var/final` بشكل صحيح.

**تلميح الحل:** عرّف `int a=15, b=4;` ثم احسب كل عملية في متغير منفصل واطبعها.
''';

  const contentEn = r'''## 🎯 Goal
Master var/final/const/dynamic and core types with operators.

## 💻 Example
Calculator with int/double.

## 📝 Exercise
Build calculator for a=15,b=4 with all operators.
''';
  const contentFr = contentEn;

  const code = r'''
void main() {
  // حاسبة شاملة - تطبق الدرس 3 معتمداً على 1 و 2
  final int a = 15; // ثابت لا يتغير بعد الضبط
  final int b = 4;
  var sum = a + b; // var يستنتج int
  var diff = a - b;
  const String title = 'حاسبة'; // ثابت وقت الترجمة

  print('=== $title ===');
  print('$a + $b = $sum'); // جمع
  print('$a - $b = $diff'); // طرح
  print('$a * $b = ${a * b}'); // ضرب
  print('$a / $b = ${a / b}'); // قسمة
  print('$a ~/ $b = ${a ~/ b}'); // قسمة صحيحة
  print('$a % $b = ${a % b}'); // باقي

  // dynamic - تجنبه لكن للتوضيح
  dynamic x = 10;
  print('dynamic قبل: $x');
  x = 'تم التغيير';
  print('dynamic بعد: $x');

  List<int> results = [sum, diff, a * b];
  print('النتائج: $results');
}
''';

  return Lesson(
    id: '${courseId}_t1_l3',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 3: المتغيرات والأنواع', en: 'Lesson 3: Variables & Data Types', fr: 'Leçon 3: Variables et Types'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 2,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: لعددين a=15 و b=4 احسب واطبع: الجمع، الطرح، الضرب، القسمة، القسمة الصحيحة، الباقي. استخدم var/final بشكل صحيح واعتمد على دروس 1-2 في الطباعة.',
        en: 'For a=15,b=4 calculate +, -, *, /, ~/, % and print with var/final.',
        fr: 'Pour a=15,b=4 calculez les opérations.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل:\nfinal a=15,b=4;\nprint(a+b); // 19\nprint(a-b); // 11\nprint(a*b); // 60\nprint(a/b); // 3.75\nprint(a~/b); // 3\nprint(a%b); // 3',
        en: 'Solution: Use var/final and print each operation.',
        fr: 'Solution: Utilisez var/final.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 4: Control Flow & Functions
// ---------------------------------------------------------------------------
Lesson _lesson4(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
التحكم في تدفق البرنامج عبر الشروط والحلقات وبناء دوال نظيفة.

## 📖 الشرح النظري المفصل

### الشروط
```dart
int grade = 85;
if (grade >= 90) {
  print('ممتاز');
} else if (grade >= 80) {
  print('جيد جداً');
} else {
  print('جيد');
}

String lang = 'dart';
switch (lang) {
  case 'dart': print('Flutter'); break;
  case 'js': print('Web'); break;
  default: print('أخرى');
}
```

### الحلقات
```dart
for (int i=0; i<3; i++) print(i); // 0 1 2
int j=0; while(j<3){ print(j); j++; }
int k=0; do{ print(k); k++; } while(k<3);
List<String> names=['A','B']; for(var n in names) print(n);
```

| الحلقة | استخدام |
|--------|---------|
| for | عدد معروف |
| while | شرط قبل |
| do-while | تنفيذ مرة على الأقل |
| for-in | عناصر List/Map |

### الدوال
```dart
// عادية
void greet(String name){ print('مرحبا $name'); }
// إرجاع
int add(int a,int b){ return a+b; }
// سهمية
int mul(int a,int b) => a*b;
// اختيارية
void foo(String name, [int? age]){}
// مسمّاة
void bar({required String name, int age=18}){}
```

## 💻 مثال كود Dart كامل

```dart
// مدير مهام يطبق الشروط والحلقات والدوال
List<String> tasks = [];
List<bool> done = [];

void add(String t){
  tasks.add(t);
  done.add(false);
  print('أضيف: $t');
}
void show(){
  print('\n=== المهام ===');
  if(tasks.isEmpty){ print('لا مهام'); return; }
  for(int i=0;i<tasks.length;i++){
    String s = done[i] ? '[✓]' : '[ ]';
    print('${i+1}. $s ${tasks[i]}');
  }
}
void complete(int i){
  if(i>=0 && i<done.length){ done[i]=true; }
}
void main(){
  add('تعلم Dart'); add('حل تمارين');
  show(); complete(0); show();
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على الدروس 1-4، أنشئ مدير مهام يعمل في الطرفية يسمح بـ: إضافة مهمة، عرض المهام، حذف مهمة، البحث عن مهمة، وتحديدها كمكتملة. يجب أن تستخدم `List`, `if`, `for`, `functions`.

**تلميح الحل:** استخدم `List<String> tasks` و `List<bool> done` ودوال `add/show/delete/search/complete` كما في المثال، مع `switch` لاختيار العملية.
''';

  const contentEn = r'''## 🎯 Goal
Master if/else/switch, loops, functions.

## 💻 Example
Todo manager with functions.

## 📝 Exercise
Build terminal todo manager with add/show/delete/search/complete using Lists and functions.
''';
  const contentFr = contentEn;

  const code = r'''
// مدير مهام متكامل - يطبق الدرس 4 معتمداً على 1-3
List<String> tasks = [];
List<bool> done = [];

// إضافة مهمة
void addTask(String t) {
  tasks.add(t);
  done.add(false);
  print('تمت إضافة: $t');
}

// عرض المهام
void showTasks() {
  print('\n=== قائمة المهام (${tasks.length}) ===');
  if (tasks.isEmpty) {
    print('لا توجد مهام');
    return;
  }
  for (int i = 0; i < tasks.length; i++) {
    String status = done[i] ? '[✓]' : '[ ]';
    print('${i + 1}. $status ${tasks[i]}');
  }
}

// حذف
void deleteTask(int index) {
  if (index < 0 || index >= tasks.length) {
    print('رقم غير صحيح');
    return;
  }
  print('حذف: ${tasks[index]}');
  tasks.removeAt(index);
  done.removeAt(index);
}

// بحث
void search(String q) {
  print('\nبحث عن "$q":');
  bool found = false;
  for (var t in tasks) {
    if (t.contains(q)) {
      print('- $t');
      found = true;
    }
  }
  if (!found) print('لا نتائج');
}

// إكمال
void complete(int index) {
  if (index >= 0 && index < done.length) {
    done[index] = true;
    print('اكتملت: ${tasks[index]}');
  }
}

void main() {
  addTask('تعلم Dart');
  addTask('حل تمارين');
  addTask('بناء مشروع');
  showTasks();
  complete(0);
  showTasks();
  search('حل');
  deleteTask(1);
  showTasks();
}
''';

  return Lesson(
    id: '${courseId}_t1_l4',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 4: التحكم والدوال', en: 'Lesson 4: Control Flow & Functions', fr: 'Leçon 4: Flux et Fonctions'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 3,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: أنشئ مدير مهام (List<String> tasks) مع دوال: add (إضافة), show (عرض مع for و if), delete (حذف), search (بحث بـ for), complete (تحديد مكتملة). استخدم ما تعلمته في الدروس 1-4.',
        en: 'Create todo manager with add/show/delete/search/complete using Lists, if, for, functions.',
        fr: 'Créez un gestionnaire de tâches avec List, if, for, fonctions.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل: استخدم List<String> tasks و List<bool> done ودوال كما في المثال. مثال addTask تضيف، showTasks تطبع بـ for، search تبحث بـ contains.',
        en: 'Solution: Use lists and functions as in example.',
        fr: 'Solution: Utilisez listes et fonctions comme exemple.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 5: OOP
// ---------------------------------------------------------------------------
Lesson _lesson5(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
بناء تفكير كائني عبر Classes, Inheritance, Polymorphism, Abstract, Mixins, Enums, Extensions.

## 📖 الشرح النظري المفصل

### Class & Object
```dart
class Book {
  String title;
  String author;
  Book(this.title, this.author);
  void info() => print('$title - $author');
}
var b = Book('Dart','Tamer');
b.info();
```

### Constructors
```dart
class User {
  String name;
  User(this.name);
  User.guest(): name='ضيف';
  User.fromMap(Map m): name=m['name'];
}
```

### Private & Getters/Setters
```dart
class Account {
  double _balance=0; // خاص
  double get balance => _balance;
  set balance(double v){ if(v>=0) _balance=v; }
}
```

### Inheritance
```dart
class Animal{ void sound()=> print('...'); }
class Cat extends Animal{
  @override void sound()=> print('مياو');
}
```

### Polymorphism
```dart
Animal a = Cat();
a.sound(); // مياو
```

### Abstract
```dart
abstract class Shape{ double area(); }
class Circle extends Shape{
  double r; Circle(this.r);
  @override double area()=> 3.14*r*r;
}
```

### Mixins
```dart
mixin Flyable{ void fly()=> print('يطير'); }
class Bird with Flyable{}
```

### Enums
```dart
enum Status{ available, borrowed }
Status s=Status.available;
```

### Extensions
```dart
extension StringExt on String{
  String get capitalized => '${this[0].toUpperCase()}${substring(1)}';
}
```

## 💻 مثال كود Dart كامل

```dart
// نظام مكتبة مصغر يطبق OOP
enum Status{ available, borrowed }
mixin Searchable{
  bool matches(String q,String t)=> t.contains(q);
}
abstract class Item{ void display(); }
class Book extends Item with Searchable{
  String id,title,author;
  Status status=Status.available;
  Book(this.id,this.title,this.author);
  @override void display()=> print('[$id] $title - $status');
}
class Member{
  String name; List<Book> borrowed=[];
  Member(this.name);
}
class Library with Searchable{
  List<Book> books=[]; List<Member> members=[];
  void addBook(Book b)=> books.add(b);
  void borrow(String bid,String mid){
    var b=books.firstWhere((x)=>x.id==bid);
    var m=members.firstWhere((x)=>x.name==mid);
    b.status=Status.borrowed; m.borrowed.add(b);
  }
  void list(){ for(var b in books) b.display(); }
}
void main(){
  var lib=Library();
  lib.addBook(Book('1','Dart','Tamer'));
  lib.addBook(Book('2','Flutter','Ahmed'));
  lib.members.add(Member('Sara'));
  lib.list();
  lib.borrow('1','Sara');
  lib.list();
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على الدروس 1-5، أنشئ نظام مكتبة كامل (Console) يحتوي على: `Book(id,title,author,status)`, `Member(id,name,borrowed)`, `Library(books,members)` مع دوال: إضافة/حذف/بحث/استعارة/إرجاع/حالة الكتاب، وإدارة الأعضاء، مع استخدام `extends`, `with`, `abstract`, `enum`, `extension`.

**تلميح الحل:** عرّف `enum BookStatus`, `mixin Searchable`, `abstract class LibraryItem`, `class Book extends LibraryItem with Searchable`, `extension StringExt`.
''';

  const contentEn = r'''## 🎯 Goal
Master OOP: classes, inheritance, polymorphism, abstract, mixins, enums, extensions.

## 💻 Example
Library system.

## 📝 Exercise
Build console library system with Book/Member/Library and required features using OOP.
''';
  const contentFr = contentEn;

  const code = r'''
// نظام مكتبة - يطبق OOP كاملاً معتمداً على الدروس 1-4
enum BookStatus { available, borrowed }

mixin Searchable {
  bool matches(String query, String text) =>
      text.toLowerCase().contains(query.toLowerCase());
}

extension StringExt on String {
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

abstract class LibraryItem {
  String get id;
  void display();
}

class Book extends LibraryItem with Searchable {
  @override final String id;
  String title;
  String author;
  BookStatus status = BookStatus.available;
  Book(this.id, this.title, this.author);
  @override void display() => print('[$id] $title - $author [${status.name}]');
}

class Member {
  String id;
  String name;
  List<Book> borrowed = [];
  Member(this.id, this.name);
  void info() => print('عضو: $name (${borrowed.length} كتب)');
}

class Library with Searchable {
  List<Book> books = [];
  List<Member> members = [];
  void addBook(Book b) {
    books.add(b);
    print('تمت إضافة كتاب: ${b.title}');
  }

  void addMember(Member m) {
    members.add(m);
    print('تمت إضافة عضو: ${m.name}');
  }

  Book? search(String q) {
    for (var b in books) {
      if (b.title.contains(q) || b.author.contains(q)) return b;
    }
    return null;
  }

  void borrow(String bookId, String memberId) {
    var book = books.firstWhere((b) => b.id == bookId);
    var member = members.firstWhere((m) => m.id == memberId);
    if (book.status == BookStatus.borrowed) {
      print('الكتاب مستعار بالفعل');
      return;
    }
    book.status = BookStatus.borrowed;
    member.borrowed.add(book);
    print('${member.name} استعار "${book.title}"');
  }

  void returnBook(String bookId, String memberId) {
    var book = books.firstWhere((b) => b.id == bookId);
    var member = members.firstWhere((m) => m.id == memberId);
    book.status = BookStatus.available;
    member.borrowed.removeWhere((b) => b.id == bookId);
    print('${member.name} أرجع "${book.title}"');
  }

  void listBooks() {
    print('\n=== المكتبة (${books.length} كتب) ===');
    for (var b in books) b.display();
  }
}

void main() {
  var lib = Library();
  lib.addBook(Book('1', 'تعلم Dart', 'تامر'));
  lib.addBook(Book('2', 'Flutter للمبتدئين', 'أحمد'));
  lib.addMember(Member('m1', 'سارة'));
  lib.listBooks();
  lib.borrow('1', 'm1');
  lib.listBooks();
  print('بحث: ${lib.search("Flutter")?.title.capitalized}');
  lib.returnBook('1', 'm1');
  lib.listBooks();
}
''';

  return Lesson(
    id: '${courseId}_t1_l5',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 5: البرمجة الكائنية OOP', en: 'Lesson 5: OOP in Dart', fr: 'Leçon 5: POO en Dart'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 4,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: أنشئ نظام مكتبة (Book, Member, Library) مع إضافة/حذف/بحث/استعارة/إرجاع/حالة، واستخدم extends, with, abstract, enum, extension. اعتمد على كل الدروس السابقة.',
        en: 'Build library system with Book/Member/Library and required features using OOP, based on previous lessons.',
        fr: 'Construisez un système de bibliothèque avec POO.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل: عرّف enum BookStatus, mixin Searchable, abstract LibraryItem, class Book extends LibraryItem with Searchable, extension StringExt كما في المثال.',
        en: 'Solution: Use enum, mixin, abstract, extension as in example.',
        fr: 'Solution: Utilisez enum, mixin, abstract, extension.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 6: Null Safety & Collections
// ---------------------------------------------------------------------------
Lesson _lesson6(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
إتقان Null Safety (`?`, `!`, `late`) والمجموعات الآمنة `List/Map/Set`.

## 📖 الشرح النظري المفصل

### ? و ! و late
```dart
String? name; // قد تكون null
print(name?.length); // آمن
print(name!.length); // تأكيد عدم null (خطر إذا كانت null)
late String city; // سيتم تهيئتها لاحقاً
city = 'Riyadh';
print(city);
```

### List الآمنة
```dart
List<String> names = ['Ali','Sara'];
List<String?> nullableNames = ['Ali', null, 'Omar'];
names.add('Zain'); // آمن
// nullableNames.add(null); مسموح لكن انتبه عند الاستخدام
for(var n in names){ print(n.length); }
for(var n in nullableNames){ print(n?.length ?? 0); }
```

### Map الآمنة
```dart
Map<String,int> scores = {'math':90};
print(scores['math']!); // 90 مع تأكيد
print(scores['science'] ?? 0); // 0 إذا غير موجود

Map<String,String?> capitals = {'EG':'Cairo','XX':null};
print(capitals['EG']?.toUpperCase());
```

### Set الآمنة
```dart
Set<int> nums = {1,2,3,2}; // {1,2,3} بدون تكرار
Set<String?> tags = {'dart', null};
print(nums.length); // 3
```

### دمج Null Safety مع Collections
```dart
List<String>? users; // القائمة نفسها قد تكون null
users = ['A','B'];
print(users?.length ?? 0);
users?.add('C');
```

## 💻 مثال كود Dart كامل

```dart
// معالجة قائمة مستخدمين قد تحتوي null بأمان
void main() {
  // قائمة أسماء قد تحتوي null
  List<String?> names = ['أحمد', null, 'سارة', 'عمر', null];
  
  // late - سيتم التهيئة قبل الاستخدام
  late List<String> cleanNames;
  cleanNames = names.where((n) => n != null).map((n) => n!).toList();
  print('الأسماء النظيفة: $cleanNames');

  // Map آمن
  Map<String, int?> scores = {'أحمد': 90, 'سارة': null, 'عمر': 85};
  for (var entry in scores.entries) {
    // استخدام ?? لتوفير قيمة افتراضية
    int score = entry.value ?? 0;
    String status = score >= 50 ? 'ناجح' : 'راسب';
    print('${entry.key}: $score - $status');
  }

  // Set لإزالة التكرار مع null safety
  Set<String> unique = {'dart','flutter','dart', 'null Safety'};
  print('فريدة: $unique');

  // استخدام ! بحذر
  String? maybe = 'Dart';
  print('الطول: ${maybe!.length}'); // آمن لأننا نعلم أنها ليست null
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على الدروس 1-6، أنشئ برنامج يعالج قائمة طلاب قد تحتوي `null` وأسماء مكررة: نظّف القائمة من `null` والمكررات باستخدام `Set`، ثم احسب متوسط درجاتهم من `Map<String,int?>` مع التعامل مع `null` عبر `??`، واطبع النتائج. استخدم `late` لمتغير سيتم تهيئته لاحقاً.
''';

  const contentEn = r'''## 🎯 Goal
Master Null Safety and safe Collections.

## 💻 Example
Handle nullable lists and maps safely.

## 📝 Exercise
Clean nullable list, deduplicate with Set, compute average with ?? and late.
''';
  const contentFr = contentEn;

  const code = r'''
void main() {
  // معالجة بيانات طلاب مع Null Safety - يطبق الدروس 1-6
  List<String?> rawNames = ['أحمد', null, 'سارة', 'أحمد', null, 'عمر'];
  
  // إزالة null والمكررات
  late Set<String> uniqueNames; // late
  uniqueNames = rawNames.where((n) => n != null).map((n) => n!).toSet();
  print('الأسماء الفريدة: $uniqueNames'); // {أحمد, سارة, عمر}

  // درجات قد تحتوي null
  Map<String, int?> scores = {'أحمد': 90, 'سارة': null, 'عمر': 85, 'ليلى': 70};
  
  // حساب المتوسط مع معالجة null
  int total = 0;
  int count = 0;
  for (var e in scores.entries) {
    int score = e.value ?? 0; // إذا null اعتبره 0
    print('${e.key}: $score');
    total += score;
    count++;
  }
  double avg = count > 0 ? total / count : 0;
  print('المتوسط: ${avg.toStringAsFixed(1)}');

  // استخدام ! بأمان
  String? city = 'الرياض';
  print('المدينة: ${city!.toUpperCase()}');

  // List آمنة قد تكون null نفسها
  List<String>? maybeList;
  print('الطول: ${maybeList?.length ?? 0}'); // 0
  maybeList = ['Dart'];
  print('بعد التهيئة: ${maybeList!.length}'); // 1
}
''';

  return Lesson(
    id: '${courseId}_t1_l6',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 6: Null Safety والمجموعات', en: 'Lesson 6: Null Safety & Collections', fr: 'Leçon 6: Null Safety & Collections'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 5,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: عالج قائمة أسماء قد تحتوي null ومكررات: نظفها من null والمكررات بـ Set، واحسب متوسط درجات Map<String,int?> مع ??، واستخدم late. اعتمد على الدروس 1-6.',
        en: 'Clean nullable list, deduplicate, compute average with ?? and late, based on lessons 1-6.',
        fr: 'Nettoyez liste nullable, dédupliquez, calculez moyenne.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل: استخدم where((n)=>n!=null).map((n)=>n!).toSet() لإزالة null والمكررات، و loop على Map مع ?? 0 لحساب المتوسط، و late Set.',
        en: 'Solution: Use where+toSet and ?? for average.',
        fr: 'Solution: Utilisez where+toSet et ??.',
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Lesson 7: Streams & Async
// ---------------------------------------------------------------------------
Lesson _lesson7(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
فهم البرمجة غير المتزامنة عبر `Future`, `async/await`, `Stream`.

## 📖 الشرح النظري المفصل

### Future
يمثل قيمة ستأتي لاحقاً:
```dart
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds:1));
  return 'بيانات';
}
```

### async / await
```dart
void main() async {
  print('بداية');
  String data = await fetchData();
  print(data);
  print('نهاية');
}
```

### Stream
تدفق قيم عبر الزمن:
```dart
Stream<int> count() async* {
  for(int i=1;i<=3;i++){
    await Future.delayed(Duration(seconds:1));
    yield i;
  }
}
void main() async {
  await for(var n in count()){
    print(n);
  }
}
```

### الفرق
| الميزة | Future | Stream |
|--------|--------|--------|
| قيم | واحدة | متعددة |
| مثال | تحميل ملف | عداد حي |

## 💻 مثال كود Dart كامل

```dart
// محاكاة جلب بيانات مستخدم ثم بث تحديثات
import 'dart:async';

Future<String> fetchUser() async {
  print('جلب المستخدم...');
  await Future.delayed(Duration(seconds:1)); // محاكاة شبكة
  return 'أحمد';
}

Stream<int> progress() async* {
  for(int i=0;i<=100;i+=25){
    await Future.delayed(Duration(milliseconds:300));
    yield i;
  }
}

void main() async {
  // Future
  String user = await fetchUser();
  print('مرحبا $user');

  // Stream
  print('التقدم:');
  await for(int p in progress()){
    print('$p%');
  }
  print('اكتمل!');
}
```

## 📝 تمرين عملي
**المطلوب:** بناءً على كل الدروس 1-7، أنشئ برنامج غير متزامن يحاكي متجراً: دالة `Future<List<String>> fetchProducts()` تتأخر ثانية ثم ترجع قائمة منتجات، ودالة `Stream<int> downloadProgress()` تبث 0% إلى 100%، واعرض المنتجات مع التقدم باستخدام `async/await` و `await for`.

**تلميح الحل:** استخدم `Future.delayed` و `async*` و `yield`.
''';

  const contentEn = r'''## 🎯 Goal
Understand Future, async/await, Stream.

## 💻 Example
Fetch user with Future and progress with Stream.

## 📝 Exercise
Simulate store with Future products and Stream progress.
''';
  const contentFr = contentEn;

  const code = r'''
import 'dart:async';

// محاكاة متجر غير متزامن - يطبق كل الدروس
Future<List<String>> fetchProducts() async {
  print('جلب المنتجات...');
  await Future.delayed(Duration(seconds: 1)); // تأخير شبكة
  return ['هاتف', 'لابتوب', 'ساعة'];
}

Stream<int> downloadProgress() async* {
  for (int i = 0; i <= 100; i += 25) {
    await Future.delayed(Duration(milliseconds: 400));
    yield i; // إرسال قيمة
  }
}

void main() async {
  // استخدام Future
  print('=== المتجر ===');
  List<String> products = await fetchProducts();
  print('المنتجات: $products');

  // استخدام Stream
  print('\nالتحميل:');
  await for (int p in downloadProgress()) {
    print('التقدم: $p%');
  }

  print('\nاكتمل التحميل! المنتجات جاهزة:');
  for (var p in products) {
    print('- $p');
  }
}
''';

  return Lesson(
    id: '${courseId}_t1_l7',
    courseId: courseId,
    title: const LocalizedText(ar: 'الدرس 7: Streams و Async', en: 'Lesson 7: Streams & Async', fr: 'Leçon 7: Streams & Async'),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: code,
    order: 6,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'المطلوب: أنشئ Future<List<String>> fetchProducts() ترجع منتجات بعد تأخير ثانية، و Stream<int> downloadProgress() تبث 0-100، واعرضهما بـ async/await و await for. اعتمد على كل الدروس السابقة.',
        en: 'Create Future products and Stream progress and display with async/await.',
        fr: 'Créez Future produits et Stream progression.',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'الحل: استخدم Future.delayed و async* مع yield، و await fetchProducts() و await for (var p in downloadProgress()) كما في المثال.',
        en: 'Solution: Use Future.delayed and async* yield.',
        fr: 'Solution: Utilisez Future.delayed et async*.',
      ),
    ),
  );
}
