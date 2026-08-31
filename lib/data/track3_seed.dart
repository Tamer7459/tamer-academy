import '../models/course.dart';
import '../models/lesson.dart';

// Track 3 – Advanced Flutter — 7 lessons (Navigation, State, Animations, Responsive, Storage, APIs, Native)
List<Lesson> buildTrack3Lessons(String courseId) {
  return [
    _lesson12(courseId),
    _lesson13(courseId),
    _lesson14(courseId),
    _lesson15(courseId),
    _lesson16(courseId),
    _lesson17(courseId),
    _lesson18(courseId),
  ];
}

// ---------------------------------------------------------------------------
// Lesson 12: Navigation & Routing
// ---------------------------------------------------------------------------
Lesson _lesson12(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
إتقان التنقل بين الشاشات في Flutter باستخدام Navigator 1.0 و 2.0 والتنقل المعتمد على الروابط.

## 📖 الشرح النظري المفصل

### لماذا التنقل مهم؟
كل تطبيق جوال يحتوي على شاشات متعددة. التنقل الجيد يصنع تجربة مستخدم سلسة.

### Navigator 1.0 — الطريقة الكلاسيكية

```dart
// 1. التنقل للخلفة (Push)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DetailScreen()),
);

// 2. العودة (Pop)
Navigator.pop(context);

// 3. العودة بقيمة
Navigator.pop(context, 'تم اختيار العنصر');

// 4. استقبال القيمة
final result = await Navigator.push<String>(
  context,
  MaterialPageRoute(builder: (context) => const SelectScreen()),
);
print('النتيجة: $result');
```

### تمرير البيانات بين الشاشات

```dart
class ProductDetail extends StatelessWidget {
  final String productName;
  final double price;

  const ProductDetail({
    super.key,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(productName)),
      body: Center(child: Text('السعر: $price')),
    );
  }
}

// الاستدعاء
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProductDetail(
      productName: 'هاتف',
      price: 999.99,
    ),
  ),
);
```

### Named Routes

```dart
// تعريف المسارات في MaterialApp
MaterialApp(
  routes: {
    '/': (context) => const HomeScreen(),
    '/details': (context) => const DetailScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
);

// التنقل
Navigator.pushNamed(context, '/details');

// تمرير بيانات مع Named Routes
Navigator.pushNamed(
  context,
  '/details',
  arguments: {'id': 42, 'name': 'منتج'},
);

// استقبال البيانات
class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return Text('ID: ${args['id']}');
  }
}
```

### Navigator 2.0 — الطريقة الحديثة

```dart
// يعتمد على Router و RouteInformationProvider
// مناسب للتطبيقات الكبيرة والـ Web

// استخدام package شهير: go_router
// pubspec.yaml: go_router: ^14.0.0

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

// التنقل
context.go('/product/42');
context.push('/product/42');

// العودة
context.pop();
```

### Bottom Navigation Bar

```dart
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search), label: 'بحث'),
          NavigationDestination(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
```

### PageRouteBuilder — تخصيص الانتقالات

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const DetailScreen(),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);
```

## 💻 مثال كود كاملم Dart كامل

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('صفحة التفاصيل'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => const DetailScreen(name: 'أحمد'),
                ),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('النتيجة: $result')),
                );
              }
            },
          ),
          ListTile(
            title: const Text('صفحة الإعدادات'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مرحبا $name')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, 'تم!'),
          child: const Text('ارجع'),
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
أنشئ تطبيق بـ 3 شاشات: Home, Detail, Settings مع BottomNavigationBar. شاشة Home تعرض قائمة عناصر، النقر يفتح Detail بتمرير بيانات، وزر الإعدادات يفتح Settings مع إمكانية العودة بقيمة.
''';

  const contentEn = r'''
## 🎯 Goal
Master navigation in Flutter with Navigator 1.0, 2.0, and link-based routing.

## 📖 Theory

### Navigator 1.0
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen()));
Navigator.pop(context);
final result = await Navigator.push<String>(context, MaterialPageRoute(...));
```

### Named Routes
```dart
MaterialApp(routes: {'/details': (_) => DetailScreen()});
Navigator.pushNamed(context, '/details', arguments: {'id': 42});
```

### go_router (Navigator 2.0)
```dart
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => HomeScreen()),
  GoRoute(path: 'product/:id', builder: (_, state) => ProductScreen(id: state.pathParameters['id']!)),
]);
context.go('/product/42');
```

### Bottom Navigation
```dart
NavigationBar(selectedIndex: idx, onDestinationSelected: (i) => setState(() => idx = i), destinations: [...]);
```

### Custom Transitions
```dart
PageRouteBuilder(transitionDuration: Duration(ms: 400), transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child));
```

## 📝 Exercise
Build a 3-screen app with Home, Detail, Settings and BottomNavigationBar.
''';

  const contentFr = r'''
## 🎯 Objectif
Maîtriser la navigation dans Flutter avec Navigator 1.0, 2.0 et go_router.

## 📖 Théorie
- Navigator 1.0: push/pop
- Named Routes
- go_router
- BottomNavigationBar
- Transitions personnalisées

## 📝 Exercice
Créez une app avec 3 écrans et BottomNavigationBar.
''';

  return Lesson(
    id: '${courseId}_t3_l12',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 12: التنقل وإدارة المسارات',
      en: 'Lesson 12: Navigation & Routing',
      fr: 'Leçon 12: Navigation & Routage',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Detail Screen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const DetailScreen(name: 'Ahmed')),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Result: $result')));
              }
            },
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen({super.key, required this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hello $name')),
      body: Center(
        child: ElevatedButton(onPressed: () => Navigator.pop(context, 'Done!'), child: const Text('Go Back')),
      ),
    );
  }
}
''',
    order: 11,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ تطبيق بـ 3 شاشات مع BottomNavigationBar وتنقل بينها ببيانات',
        en: 'Build 3-screen app with BottomNavigationBar and data passing',
        fr: 'Créez une app 3 écrans avec BottomNavigationBar',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'استخدم Navigator.push + pop + arguments مع NavigationBar',
        en: 'Use Navigator.push + pop + arguments with NavigationBar',
        fr: 'Utilisez Navigator.push + pop + arguments',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق مدونة بتنقل كامل مع go_router',
      en: 'Blog app with full go_router navigation',
      fr: 'App blog avec navigation go_router',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 13: State Administration
// ---------------------------------------------------------------------------
Lesson _lesson13(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
فهم إدارة الحالة (State Management) في Flutter — Provider, Riverpod, BLoC, GetX.

## 📖 الشرح النظري المفصل

### ما هي إدارة الحالة؟
State Management هو نمط يُستخدم لإدارة البيانات التي تتغير عبر التطبيق وجعل الواجهة تتحدث تلقائياً.

### 1. setState — الأصلي
```dart
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('العداد: $count'),
        ElevatedButton(
          onPressed: () => setState(() => count++),
          child: const Text('أضف'),
        ),
      ],
    );
  }
}
```
- مناسب للمشاريع الصغيرة فقط.

### 2. Provider — الأكثر شيوعاً

```dart
// pubspec.yaml: provider: ^6.1.0

// إنشاء Provider
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // إخطار المستمعين بالتحديث
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

// تسجيل الـ Provider
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CounterProvider(),
      child: const MyApp(),
    ),
  );
}

// الاستخدام
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>();
    return Column(
      children: [
        Text('العداد: ${counter.count}'),
        ElevatedButton(
          onPressed: () => context.read<CounterProvider>().increment(),
          child: const Text('أضف'),
        ),
      ],
    );
  }
}
```

### 3. Riverpod — بديل حديث

```dart
// pubspec.yaml: flutter_riverpod: ^2.5.0

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state++;
  void decrement() => state--;
}

// الاستخدام
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      child: Text('العداد: $count'),
    );
  }
}
```

### 4. BLoC — للتطبيقات الكبيرة

```dart
// pubspec.yaml: flutter_bloc: ^8.1.0

// Event
abstract class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}

// BLoC
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}

// الاستخدام
BlocProvider(
  create: (_) => CounterBloc(),
  child: Builder(
    builder: (context) {
      final count = context.watch<CounterBloc>().state;
      return ElevatedButton(
        onPressed: () => context.read<CounterBloc>().add(Increment()),
        child: Text('العداد: $count'),
      );
    },
  ),
);
```

### 5. GetX — الأسهل

```dart
// pubspec.yaml: get: ^4.6.6

class CounterController extends GetxController {
  var count = 0.obs; // Observable
  void increment() => count++;
}

// الاستخدام
final controller = Get.put(CounterController());
Obx(() => Text('العداد: ${controller.count}'));
controller.increment();
```

### مقارنة سريعة
| الميزة | Provider | Riverpod | BLoC | GetX |
|--------|----------|----------|------|------|
| التعقيد | متوسط | متوسط | عالي | منخفض |
| اختبار | سهل | سهل | ممتاز | متوسط |
| für حجم المشروع | صغير-متوسط | متوسط-كبير | كبير | صغير-متوسط |
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(create: (_) => CounterProvider(), child: const MyApp()),
);

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void increment() { _count++; notifyListeners(); }
  void decrement() { _count--; notifyListeners(); }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('العداد: ${counter.count}', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: () => context.read<CounterProvider>().decrement(), child: const Icon(Icons.remove)),
                const SizedBox(width: 16),
                FilledButton(onPressed: () => context.read<CounterProvider>().increment(), child: const Icon(Icons.add)),
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
أنشئ تطبيق قائمة مهام (Todo) باستخدام Provider — إضافة مهمة، حذفها، وتحديد كمكتملة. يجب أن يعمل العداد في الأعلى تلقائياً.
''';

  const contentEn = r'''
## 🎯 Goal
Master state management in Flutter: Provider, Riverpod, BLoC, GetX.

## 📖 Theory

### setState
For simple local state only.

### Provider
```dart
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  void increment() { _count++; notifyListeners(); }
}
ChangeNotifierProvider(create: (_) => CounterProvider(), child: MyApp());
context.watch<CounterProvider>().count;
context.read<CounterProvider>().increment();
```

### Riverpod
```dart
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) => CounterNotifier());
class CounterNotifier extends StateNotifier<int> { CounterNotifier() : super(0); void increment() => state++; }
ref.watch(counterProvider); ref.read(counterProvider.notifier).increment();
```

### BLoC
```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) { on<Increment>((e, emit) => emit(state + 1)); }
}
BlocProvider(create: (_) => CounterBloc(), child: ...);
```

### GetX
```dart
class CounterController extends GetxController { var count = 0.obs; }
Obx(() => Text('${controller.count}'));
```

## 📝 Exercise
Build a Todo app with Provider.
''';

  const contentFr = r'''
## 🎯 Objectif
Maîtriser la gestion d'état: Provider, Riverpod, BLoC, GetX.

## 📖 Théorie
- setState: local uniquement
- Provider: ChangeNotifierProvider
- Riverpod: StateNotifierProvider
- BLoC: Events + States
- GetX: observables

## 📝 Exercice
Créez un Todo avec Provider.
''';

  return Lesson(
    id: '${courseId}_t3_l13',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 13: إدارة الحالة',
      en: 'Lesson 13: State Administration',
      fr: 'Leçon 13: Gestion d\'État',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider(create: (_) => CounterProvider(), child: const MyApp()));

class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void increment() { _count++; notifyListeners(); }
  void decrement() { _count--; notifyListeners(); }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<CounterProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: ${counter.count}', style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(onPressed: () => context.read<CounterProvider>().decrement(), child: const Icon(Icons.remove)),
                const SizedBox(width: 16),
                FilledButton(onPressed: () => context.read<CounterProvider>().increment(), child: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''',
    order: 12,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ تطبيق Todo باستخدام Provider مع إضافة وحذف وتحديد كمكتملة',
        en: 'Build Todo app with Provider',
        fr: 'Créez un Todo avec Provider',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'ChangeNotifierProvider + notifyListeners + context.watch',
        en: 'ChangeNotifierProvider + notifyListeners + context.watch',
        fr: 'ChangeNotifierProvider + notifyListeners',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق مهام بـ Provider مع فلترة حسب الحالة',
      en: 'Todo with Provider and filtering',
      fr: 'Todo avec Provider et filtres',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 14: Animations
// ---------------------------------------------------------------------------
Lesson _lesson14(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
إتقان الرسوم المتحركة (Animations) في Flutter — Implicit, Explicit, Hero.

## 📖 الشرح النظري المفصل

### أنواع الرسوم المتحركة
1. **Implicit Animations** — الأنيميشن الجاهز (AnimatedContainer, AnimatedOpacity)
2. **Explicit Animations** — التحكم الكامل (AnimationController, Tween)
3. **Hero Animation** — الانتقال بين الشاشات

### 1. Implicit Animations — الأسهل

```dart
class ImplicitDemo extends StatefulWidget {
  @override
  State<ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<ImplicitDemo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: _isExpanded ? 200 : 100,
        height: _isExpanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _isExpanded ? Colors.red : Colors.blue,
          borderRadius: BorderRadius.circular(_isExpanded ? 50 : 8),
        ),
        child: const Center(child: Text('اضغط', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
```

###_widgets شائعة:
- `AnimatedContainer` — حجم، لون، حدود
- `AnimatedOpacity` — الشفافية
- `AnimatedPadding` — الحشو
- `AnimatedPositioned` — الموقع
- `AnimatedSwitcher` — تبديل العناصر
- `AnimatedCrossFade` — تلاشي بين عنصرين

### 2. Explicit Animations — التحكم الكامل

```dart
class ExplicitDemo extends StatefulWidget {
  @override
  State<ExplicitDemo> createState() => _ExplicitDemoState();
}

class _ExplicitDemoState extends State<ExplicitDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.red).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            color: _colorAnimation.value,
          ),
        );
      },
    );
  }
}
```

### Staggered Animations (تأخير متسلسل)

```dart
// بدء أنيميشنات بتأخيرات مختلفة
_controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

_animation1 = Tween(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
);
_animation2 = Tween(begin: 0.0, end: 1.0).animate(
  CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
);
```

### 3. Hero Animation — الانتقال بين الشاشات

```dart
// الشاشة الأولى
Hero(
  tag: 'product-1',
  child: Image.asset('product.jpg'),
)

// الشاشة الثانية
Hero(
  tag: 'product-1',
  child: Image.asset('product.jpg', width: double.infinity),
)

// التنقل自然是 تلقائي
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen()));
```

### Physics-based Animations

```dart
// Spring Simulation
_animation = _controller.drive(
  SpringDescription(mass: 1, stiffness: 100, damping: 10),
);
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AnimationDemo(),
    );
  }
}

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});
  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  bool _expanded = false;
  double _rotation = 0;
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: _expanded ? 200 : 100,
              height: _expanded ? 200 : 100,
              decoration: BoxDecoration(
                color: _expanded ? Colors.deepPurple : Colors.teal,
                borderRadius: BorderRadius.circular(_expanded ? 100 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: _expanded ? 20 : 8,
                    spreadRadius: _expanded ? 4 : 1,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.star, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('توسيع'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => setState(() => _rotation += 1.0),
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('دوران'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => setState(() => _scale = _scale == 1 ? 1.5 : 1),
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('تكبير'),
                ),
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
أنشئ شاشة فيها مربع يتغير حجمه ولونه وشكله عند الضغط عليه، مع أنيميشن سلس يستخدم AnimatedContainer و Transformation.
''';

  const contentEn = r'''
## 🎯 Goal
Master animations: Implicit, Explicit, Hero, Physics-based.

## 📖 Theory

### Implicit Animations
```dart
AnimatedContainer(duration: Duration(ms: 400), width: expanded ? 200 : 100, ...);
AnimatedOpacity(opacity: visible ? 1 : 0, duration: Duration(ms: 300));
AnimatedSwitcher(child: condition ? WidgetA() : WidgetB());
```

### Explicit Animations
```dart
AnimationController(vsync: this, duration: Duration(seconds: 1));
Animation<double> anim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(...));
AnimatedBuilder(animation: anim, builder: (_, __) => Transform.scale(scale: anim.value, child: ...));
```

### Hero Animation
```dart
Hero(tag: 'image', child: Image.asset('...')); // on both screens
```

### Staggered Animations
Use Interval(0.0, 0.5) and Interval(0.5, 1.0) for sequential effects.

## 📝 Exercise
Build an interactive animation demo with AnimatedContainer.
''';

  const contentFr = r'''
## 🎯 Objectif
Maîtriser les animations: Implicites, Explicites, Hero.

## 📖 Théorie
- Implicit: AnimatedContainer, AnimatedOpacity
- Explicit: AnimationController + Tween
- Hero: transitions entre écrans

## 📝 Exercice
Créez une démo d'animation interactive.
''';

  return Lesson(
    id: '${courseId}_t3_l14',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 14: الرسوم المتحركة',
      en: 'Lesson 14: Animations',
      fr: 'Leçon 14: Animations',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const AnimationDemo());
  }
}

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});
  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              width: _expanded ? 200 : 100,
              height: _expanded ? 200 : 100,
              decoration: BoxDecoration(
                color: _expanded ? Colors.deepPurple : Colors.teal,
                borderRadius: BorderRadius.circular(_expanded ? 100 : 16),
              ),
              child: const Center(child: Icon(Icons.star, color: Colors.white, size: 40)),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: const Text('Toggle Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
''',
    order: 13,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ مربع متحرك يتغير حجمه ولونه وشكله عند الضغط',
        en: 'Animated box that changes size, color, shape on tap',
        fr: 'Boîte animée avec taille, couleur, forme',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'AnimatedContainer مع duration و curve',
        en: 'AnimatedContainer with duration and curve',
        fr: 'AnimatedContainer avec duration',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق splash screen بأنيميشن احترافي',
      en: 'Splash screen with professional animation',
      fr: 'Splash screen avec animation pro',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 15: Adaptive & Responsive UI
// ---------------------------------------------------------------------------
Lesson _lesson15(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
بناء واجهات متجاوبة (Responsive) تتكيف مع أحجام الشاشات المختلفة — من الهاتف إلى الويب.

## 📖 الشرح النظري المفصل

### المفهوم
- **Responsive**: يتكيّف مع حجم الشاشة ((MediaQuery)
- **Adaptive**: يتكيّف مع نوع المنصة (Material vs Cupertino)

### 1. MediaQuery — قياس الشاشة

```dart
final width = MediaQuery.of(context).size.width;
final height = MediaQuery.of(context).size.height;
final orientation = MediaQuery.of(context).orientation;
final padding = MediaQuery.of(context).viewPadding;

// نقاط فاصلة
if (width > 1200) {
  // Desktop
} else if (width > 600) {
  // Tablet
} else {
  // Mobile
}
```

### 2. LayoutBuilder — بناء حسب المساحة

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1200) {
      return _buildDesktopLayout();
    } else if (constraints.maxWidth > 600) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  },
);
```

### 3. GridView متجاوب

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 300,
    childAspectRatio: 3 / 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
);
```

### 4. Flex — تصميم مرن

```dart
Row(
  children: [
    Expanded(flex: 2, child: Sidebar()),
    Expanded(flex: 5, child: Content()),
  ],
);

// Wrap للمحتوى المرن
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: tags.map((t) => Chip(label: Text(t))).toList(),
)
```

### 5. OrientationBuilder

```dart
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.portrait
        ? _buildPortrait()
        : _buildLandscape();
  },
);
```

### 6. Platform-Aware — Material vs Cupertino

```dart
import 'dart:io';
import 'package:flutter/cupertino.dart';

Widget buildButton() {
  if (Platform.isIOS) {
    return CupertinoButton(
      onPressed: () {},
      child: const Text('اضغط'),
    );
  } else {
    return ElevatedButton(
      onPressed: () {},
      child: const Text('اضغط'),
    );
  }
}
```

### 7._breakpoints.dart — نظام نقاط فاصلة

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobile && w < tablet;
  }
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}
```

### 8. Responsive Scaffold

```dart
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (!Breakpoints.isMobile(context))
            const NavigationRail(
              destinations: [
                NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.search), label: Text('Search')),
              ],
              selectedIndex: 0,
            ),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: Breakpoints.isMobile(context)
          ? NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              ],
              selectedIndex: 0,
            )
          : null,
    );
  }
}
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const ResponsiveScreen(),
    );
  }
}

class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive UI')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

          return Row(
            children: [
              if (!isMobile)
                Container(
                  width: isTablet ? 80 : 250,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: isTablet
                      ? const Column(children: [Icon(Icons.home, size: 32), Icon(Icons.search, size: 32)])
                      : const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.all(16), child: Text('القائمة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                            ListTile(leading: Icon(Icons.home), title: Text('الرئيسية')),
                            ListTile(leading: Icon(Icons.search), title: Text('بحث')),
                            ListTile(leading: Icon(Icons.person), title: Text('حسابي')),
                          ],
                        ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isMobile ? 200 : 300,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Center(child: Text('عنصر ${index + 1}')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? NavigationBar(
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
                NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
              ],
              selectedIndex: 0,
            )
          : null,
    );
  }
}
```

## 📝 تمرين عملي
أنشئ شاشة تعرض Sidebar في الويب والتابلت، و BottomNavigationBar في الموبايل، مع محتوى Grid متجاوب.
''';

  const contentEn = r'''
## 🎯 Goal
Build adaptive & responsive UIs: MediaQuery, LayoutBuilder, breakpoints.

## 📖 Theory

### MediaQuery
```dart
final width = MediaQuery.of(context).size.width;
if (width > 1200) { /* Desktop */ } else if (width > 600) { /* Tablet */ } else { /* Mobile */ }
```

### LayoutBuilder
```dart
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth > 1200) return DesktopLayout();
  return MobileLayout();
});
```

### Responsive GridView
```dart
GridView(gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300, childAspectRatio: 3/2));
```

### Platform-Aware
```dart
Platform.isIOS ? CupertinoButton() : ElevatedButton();
```

## 📝 Exercise
Build a responsive screen with sidebar on desktop, bottom nav on mobile.
''';

  const contentFr = r'''
## 🎯 Objectif
Construire des UI adaptatives et réactives.

## 📖 Théorie
- MediaQuery pour la taille
- LayoutBuilder pour les contraintes
- Plateforme-aware (Material/Cupertino)

## 📝 Exercice
Créez un écran responsive avec sidebar et bottom nav.
''';

  return Lesson(
    id: '${courseId}_t3_l15',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 15: واجهة تكيفية ومتجاوبة',
      en: 'Lesson 15: Adaptive & Responsive UI',
      fr: 'Leçon 15: UI Adaptative & Réactive',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const ResponsiveScreen(),
    );
  }
}

class ResponsiveScreen extends StatelessWidget {
  const ResponsiveScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive UI')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          return Row(
            children: [
              if (!isMobile)
                Container(
                  width: 250,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.all(16), child: Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      ListTile(leading: Icon(Icons.home), title: Text('Home')),
                      ListTile(leading: Icon(Icons.search), title: Text('Search')),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: isMobile ? 200 : 300,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 20,
                  itemBuilder: (_, i) => Card(child: Center(child: Text('Item ${i + 1}'))),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 600
          ? const NavigationBar(
              destinations: [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              ],
              selectedIndex: 0,
            )
          : null,
    );
  }
}
''',
    order: 14,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ شاشة Sidebar في الويب و BottomNav في الموبايل مع Grid متجاوب',
        en: 'Screen with sidebar on web, bottom nav on mobile, responsive grid',
        fr: 'Écran avec sidebar web, bottom nav mobile, grille responsive',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'LayoutBuilder + MediaQuery + NavigationBar/Rail',
        en: 'LayoutBuilder + MediaQuery + NavigationBar/Rail',
        fr: 'LayoutBuilder + MediaQuery + NavigationBar',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق مدونة متجاوب يعمل على جميع الأجهزة',
      en: 'Responsive blog app for all devices',
      fr: 'App blog responsive tous appareils',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 16: Caching & Local Storage
// ---------------------------------------------------------------------------
Lesson _lesson16(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
التخزين المحلي في Flutter — SharedPreferences, Hive, SQLite, و الكاش.

## 📖 الشرح النظري المفصل

### أنواع التخزين
| النوع | الحجم | السرعة | الاستخدام |
|-------|--------|--------|----------|
| SharedPreferences | صغير (~1MB) | سريع | إعدادات، tokens |
| Hive | كبير (~GB) | سريع جداً | كائنات، قوائم |
| SQLite | كبير | متوسط | بيانات معقدة، علاقات |
| File System | كبير | متوسط | ملفات، صور |

### 1. SharedPreferences — الأبسط

```dart
// pubspec.yaml: shared_preferences: ^2.2.0

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // حفظ
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // قراءة
  String? getString(String key) => _prefs.getString(key);
  bool? getBool(String key) => _prefs.getBool(key);

  // حذف
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

// الاستخدام
final storage = StorageService();
await storage.init();
await storage.saveString('username', 'أحمد');
final name = storage.getString('username');
```

### 2. Hive — الأسرع

```dart
// pubspec.yaml: hive: ^2.2.3, hive_flutter: ^1.1.0

import 'package:hive_flutter/hive_flutter.dart';

// تعريف Model
@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  Task({required this.title, this.isDone = false});
}

// تسجيل الـ Adapter
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(title: reader.read(), isDone: reader.read());
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.title);
    writer.write(obj.isDone);
  }
}

// الاستخدام
await Hive.initFlutter();
Hive.registerAdapter(TaskAdapter());
final box = await Hive.openBox<Task>('tasks');

// إضافة
box.add(Task(title: 'صلاة'));

// قراءة
final tasks = box.values.toList();

// حفظ
await box.put(0, Task(title: 'صلاة', isDone: true));

// حذف
await box.delete(0);
```

### 3. SQLite (sqflite) — للبيانات المعقدة

```dart
// pubspec.yaml: sqflite: ^2.3.0, path: ^1.8.0

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'app.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, isDone INTEGER DEFAULT 0, createdAt TEXT)',
        );
      },
    );
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    await db.insert('tasks', task, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'createdAt DESC');
  }

  Future<void> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
```

### 4. File Storage — للملفات الكبيرة

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// مسار التطبيق
final dir = await getApplicationDocumentsDirectory();
final file = File('${dir.path}/data.txt');

// كتابة
await file.writeAsString('مرحبا');

// قراءة
final content = await file.readAsString();
```

### 5. Cached Network Image

```dart
// pubspec.yaml: cached_network_image: ^3.3.0

CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (_, __) => const CircularProgressIndicator(),
  errorWidget: (_, __, ___) => const Icon(Icons.error),
  fit: BoxFit.cover,
);
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StorageDemo(prefs: prefs),
    );
  }
}

class StorageDemo extends StatefulWidget {
  final SharedPreferences prefs;
  const StorageDemo({super.key, required this.prefs});

  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  final _controller = TextEditingController();
  String _savedValue = '';

  @override
  void initState() {
    super.initState();
    _savedValue = widget.prefs.getString('name') ?? 'لم يتم الحفظ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'أدخل اسمك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: () async {
                    await widget.prefs.setString('name', _controller.text);
                    setState(() => _savedValue = _controller.text);
                  },
                  child: const Text('حفظ'),
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  onPressed: () async {
                    await widget.prefs.remove('name');
                    setState(() => _savedValue = 'لم يتم الحفظ');
                  },
                  child: const Text('حذف'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('القيمة المحفوظة: $_savedValue', style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 📝 تمرين عملي
أنشئ تطبيق ملاحظات يستخدم Hive للتخزين — إضافة ملاحظة، حذفها، وعرضها مع تاريخ الإنشاء.
''';

  const contentEn = r'''
## 🎯 Goal
Master local storage: SharedPreferences, Hive, SQLite, file storage.

## 📖 Theory

### SharedPreferences
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('key', 'value');
prefs.getString('key');
```

### Hive (Fast NoSQL)
```dart
await Hive.initFlutter();
final box = await Hive.openBox('tasks');
box.add({'title': 'Task', 'done': false});
box.values.toList();
```

### SQLite
```dart
final db = await openDatabase('app.db', version: 1, onCreate: (db, v) => db.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT)'));
await db.insert('tasks', {'title': 'Task'});
```

### File Storage
```dart
final file = File('${dir.path}/data.txt');
await file.writeAsString('content');
```

## 📝 Exercise
Build a notes app with Hive storage.
''';

  const contentFr = r'''
## 🎯 Objectif
Maîtriser le stockage local: SharedPreferences, Hive, SQLite.

## 📖 Théorie
- SharedPreferences: clé-valeur simple
- Hive: NoSQL rapide
- SQLite: données relationnelles
- File system: fichiers

## 📝 Exercice
Créez une app notes avec Hive.
''';

  return Lesson(
    id: '${courseId}_t3_l16',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 16: التخزين المحلي والكاش',
      en: 'Lesson 16: Caching & Local Storage',
      fr: 'Leçon 16: Cache & Stockage Local',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: StorageDemo(prefs: prefs));
  }
}

class StorageDemo extends StatefulWidget {
  final SharedPreferences prefs;
  const StorageDemo({super.key, required this.prefs});
  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  final _controller = TextEditingController();
  String _savedValue = '';

  @override
  void initState() {
    super.initState();
    _savedValue = widget.prefs.getString('name') ?? 'Not saved';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Storage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Enter name')),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(onPressed: () async { await widget.prefs.setString('name', _controller.text); setState(() => _savedValue = _controller.text); }, child: const Text('Save')),
                const SizedBox(width: 16),
                FilledButton.tonal(onPressed: () async { await widget.prefs.remove('name'); setState(() => _savedValue = 'Not saved'); }, child: const Text('Delete')),
              ],
            ),
            const SizedBox(height: 24),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Saved: $_savedValue'))),
          ],
        ),
      ),
    );
  }
}
''',
    order: 15,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ تطبيق ملاحظات باستخدام Hive للتخزين',
        en: 'Build notes app with Hive storage',
        fr: 'Créez une app notes avec Hive',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'Hive.initFlutter + openBox + add/put/delete',
        en: 'Hive.initFlutter + openBox + add/put/delete',
        fr: 'Hive.initFlutter + openBox',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق مهام مع Hive وفلترة وبحث',
      en: 'Todo with Hive, filter and search',
      fr: 'Todo avec Hive, filtres et recherche',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 17: REST and HTTP APIs
// ---------------------------------------------------------------------------
Lesson _lesson17(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
التعامل مع REST APIs في Flutter — http, dio, aut handling, pagination.

## 📖 الشرح النظري المفصل

### ما هو REST API؟
REST (Representational State Transfer) هو نمط لتصميم واجهات برمجة التطبيقات عبر HTTP.

### الطرق الأساسية:
| الطريقة | الغرض | مثال |
|---------|--------|------|
| GET | جلب بيانات | `GET /users` |
| POST | إنشاء بيانات | `POST /users` |
| PUT | تحديث كامل | `PUT /users/1` |
| PATCH | تحديث جزئي | `PATCH /users/1` |
| DELETE | حذف | `DELETE /users/1` |

### 1. مكتبة http — الأبسط

```dart
// pubspec.yaml: http: ^1.2.0

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  // GET
  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  // POST
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  // PUT
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    return json.decode(response.body);
  }

  // DELETE
  Future<void> deleteUser(int id) async {
    await http.delete(Uri.parse('$baseUrl/users/$id'));
  }
}
```

### 2. مكتبة dio — الأكثر قوة

```dart
// pubspec.yaml: dio: ^5.4.0

import 'package:dio/dio.dart';

class DioApiService {
  late Dio _dio;

  DioApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN',
      },
    ));

    // Interceptor لتسجيل الطلبات
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<List<dynamic>> getUsers() async {
    final response = await _dio.get('/users');
    return response.data;
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post('/users', data: data);
    return response.data;
  }
}
```

### 3. Model Class — تحويل البيانات

```dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

// الاستخدام
final users = (response.data as List).map((json) => User.fromJson(json)).toList();
```

### 4. Error Handling

```dart
try {
  final users = await apiService.getUsers();
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    print('انتهت مهلة الاتصال');
  } else if (e.response?.statusCode == 404) {
    print('غير موجود');
  }
} catch (e) {
  print('خطأ غير متوقع: $e');
}
```

### 5. Loading States

```dart
enum LoadingState { idle, loading, loaded, error }

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  LoadingState _state = LoadingState.idle;
  List<User> _users = [];
  String _error = '';

  LoadingState get state => _state;
  List<User> get users => _users;
  String get error => _error;

  Future<void> fetchUsers() async {
    _state = LoadingState.loading;
    notifyListeners();

    try {
      final data = await _api.getUsers();
      _users = data.map((json) => User.fromJson(json)).toList();
      _state = LoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = LoadingState.error;
    }
    notifyListeners();
  }
}
```

### 6. Pagination

```dart
class PaginatedApiService {
  int _page = 1;
  bool _hasMore = true;
  final List<dynamic> _allItems = [];

  bool get hasMore => _hasMore;

  Future<List<dynamic>> fetchNextPage() async {
    if (!_hasMore) return [];

    final response = await http.get(
      Uri.parse('https://api.example.com/items?page=$_page&limit=20'),
    );

    final items = json.decode(response.body);
    _allItems.addAll(items);
    _page++;
    _hasMore = items.length == 20;

    return _allItems;
  }
}
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const ApiDemo(),
    );
  }
}

class ApiDemo extends StatefulWidget {
  const ApiDemo({super.key});
  @override
  State<ApiDemo> createState() => _ApiDemoState();
}

class _ApiDemoState extends State<ApiDemo> {
  List<User> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _users = data.map((j) => User.fromJson(j)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REST API Demo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${user.id}')),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                    );
                  },
                ),
    );
  }
}
```

## 📝 تمرين عملي
أنشئ تطبيق يعرض قائمة مستخدمين من API مع إمكانية إضافة مستخدم جديد وتحديثه وحذفه مع معالجة الأخطاء وحالات التحميل.
''';

  const contentEn = r'''
## 🎯 Goal
Work with REST APIs: http, dio, error handling, pagination.

## 📖 Theory

### HTTP Methods
GET, POST, PUT, PATCH, DELETE

### http package
```dart
final response = await http.get(Uri.parse('https://api.example.com/users'));
final data = json.decode(response.body);
```

### dio package
```dart
final dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
dio.interceptors.add(LogInterceptor());
final response = await dio.get('/users');
```

### Model
```dart
class User { factory User.fromJson(Map<String, dynamic> json) => User(id: json['id'], name: json['name']); }
```

### Error Handling
```dart
try { await api.fetch(); } on DioException catch (e) { /* handle */ }
```

## 📝 Exercise
Build a users list app with CRUD operations.
''';

  const contentFr = r'''
## 🎯 Objectif
Travailler avec les APIs REST: http, dio, gestion d'erreurs.

## 📖 Théorie
- Méthodes HTTP
- http / dio packages
- Models JSON
- Error handling

## 📝 Exercice
Créez une app liste utilisateurs avec CRUD.
''';

  return Lesson(
    id: '${courseId}_t3_l17',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 17: REST و HTTP APIs',
      en: 'Lesson 17: REST and HTTP APIs',
      fr: 'Leçon 17: REST et APIs HTTP',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class User {
  final int id;
  final String name;
  final String email;
  User({required this.id, required this.name, required this.email});
  factory User.fromJson(Map<String, dynamic> json) => User(id: json['id'], name: json['name'], email: json['email']);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: const ApiDemo());
  }
}

class ApiDemo extends StatefulWidget {
  const ApiDemo({super.key});
  @override
  State<ApiDemo> createState() => _ApiDemoState();
}

class _ApiDemoState extends State<ApiDemo> {
  List<User> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() { _users = data.map((j) => User.fromJson(j)).toList(); _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REST API Demo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: CircleAvatar(child: Text('${_users[i].id}')),
                    title: Text(_users[i].name),
                    subtitle: Text(_users[i].email),
                  ),
                ),
    );
  }
}
''',
    order: 16,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ تطبيق CRUD مع API — إضافة وتحديث وحذف مستخدمين',
        en: 'Build CRUD app with user API',
        fr: 'Créez une app CRUD avec API utilisateurs',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'http.get/post/put/delete + Model.fromJson + error handling',
        en: 'http.get/post/put/delete + Model.fromJson + error handling',
        fr: 'http.get/post/put/delete + Model.fromJson',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق طقس يستخدم API حقيقي مع caching',
      en: 'Weather app with real API and caching',
      fr: 'App météo avec API réelle et cache',
    ),
    hasHomework: true,
  );
}

// ---------------------------------------------------------------------------
// Lesson 18: Native & Platform Features
// ---------------------------------------------------------------------------
Lesson _lesson18(String courseId) {
  const contentAr = r'''
## 🎯 الهدف من الدرس
الوصول للقدرات الأصلية (Native) في Android و iOS — Platform Channels, Permissions, URL Launcher.

## 📖 الشرح النظري المفصل

### ما هي Platform Channels؟
Flutter يتكلم مع الكود الأصلي (Swift/Kotlin) عبر قنوات اتصال.

### 1. URL Launcher — فتح روابط

```dart
// pubspec.yaml: url_launcher: ^6.2.0

import 'package:url_launcher/url_launcher.dart';

// فتح رابط
await launchUrl(Uri.parse('https://google.com'));

// فتح بريد
await launchUrl(Uri.parse('mailto:test@example.com?subject=مرحبا'));

// فتح اتصال
await launchUrl(Uri.parse('tel:+213555123456'));

// فتح خرائط
await launchUrl(Uri.parse('https://maps.google.com/?q=Algeria'));

// فتح رابط في تطبيق خارجي
await launchUrl(
  Uri.parse('https://google.com'),
  mode: LaunchMode.externalApplication,
);
```

### 2. Permissions — الأذونات

```dart
// pubspec.yaml: permission_handler: ^11.0.0

import 'package:permission_handler/permission_handler.dart';

// طلب إذن الكاميرا
if (await Permission.camera.request().isGranted) {
  // يمكن استخدام الكاميرا
}

// طلب إذن الموقع
if (await Permission.location.request().isGranted) {
  // يمكن الوصول للموقع
}

// طلب إذن التخزين
if (await Permission.storage.request().isGranted) {
  // يمكن الوصول للملفات
}

// فحص الإذن
final status = await Permission.camera.status;
if (status.isDenied) {
  // مرفوض
} else if (status.isPermanentlyDenied) {
  // مرفوض نهائياً — افتح الإعدادات
  await openAppSettings();
}
```

### 3. Image Picker — اختيار الصور

```dart
// pubspec.yaml: image_picker: ^1.0.0

import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

// الكاميرا
final photo = await picker.pickImage(source: ImageSource.camera);

// المعرض
final image = await picker.pickImage(source: ImageSource.gallery);

// فيديو
final video = await picker.pickVideo(source: ImageSource.gallery);

if (photo != null) {
  // photo.path هو المسار المحلي للصورة
}
```

### 4. Share — مشاركة

```dart
// pubspec.yaml: share_plus: ^9.0.0

import 'package:share_plus/share_plus.dart';

await Share.share('مرحبا! شاهد هذا التطبيق: https://example.com');

await Share.shareXFiles([XFile('path/to/image.jpg')], text: 'صورة جميلة');
```

### 5. Local Notifications — إشعارات محلية

```dart
// pubspec.yaml: flutter_local_notifications: ^17.0.0

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final plugin = FlutterLocalNotificationsPlugin();

// التهيئة
await plugin.initialize(
  InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ),
);

// إشعار فوري
await plugin.show(
  0,
  'عنوان الإشعار',
  'نص الإشعار',
  NotificationDetails(
    android: AndroidNotificationDetails('channel_id', 'القناة', importance: Importance.high),
    iOS: const DarwinNotificationDetails(),
  ),
);
```

### 6. Biometrics — البصمة

```dart
// pubspec.yaml: local_auth: ^2.1.0

import 'package:local_auth/local_auth.dart';

final auth = LocalAuthentication();

bool canCheck = await auth.canCheckBiometrics;
if (canCheck) {
  bool authenticated = await auth.authenticate(
    localizedReason: 'يرجى التحقق بهوية',
    options: const AuthenticationOptions(biometricOnly: true),
  );
}
```

### 7. Platform Channel (مخصص)

```dart
// في Flutter
import 'package:flutter/services.dart';

const platform = MethodChannel('com.example.app/battery');

Future<int> getBatteryLevel() async {
  try {
    final int result = await platform.invokeMethod('getBatteryLevel');
    return result;
  } on PlatformException catch (e) {
    return -1;
  }
}

// في Android (Kotlin)
class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.example.app/battery"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        if (call.method == "getBatteryLevel") {
          val batteryLevel = getBatteryLevel()
          result.success(batteryLevel)
        } else {
          result.notImplemented()
        }
      }
  }

  private fun getBatteryLevel(): Int {
    val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
  }
}
```

## 💻 مثال كود كامل Dart

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const NativeDemo(),
    );
  }
}

class NativeDemo extends StatelessWidget {
  const NativeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFeatureCard(
            icon: Icons.language,
            title: 'فتح رابط',
            onTap: () => launchUrl(Uri.parse('https://flutter.dev')),
          ),
          _buildFeatureCard(
            icon: Icons.email,
            title: 'إرسال بريد',
            onTap: () => launchUrl(Uri.parse('mailto:ahmed@example.com?subject=مرحبا')),
          ),
          _buildFeatureCard(
            icon: Icons.phone,
            title: 'إجراء اتصال',
            onTap: () => launchUrl(Uri.parse('tel:+213555123456')),
          ),
          _buildFeatureCard(
            icon: Icons.share,
            title: 'مشاركة',
            onTap: () => Share.share('تطبيق رائع! https://flutter.dev'),
          ),
          _buildFeatureCard(
            icon: Icons.location_on,
            title: 'فتح الخرائط',
            onTap: () => launchUrl(Uri.parse('https://maps.google.com/?q=Algeria')),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
```

## 📝 تمرين عملي
أنشئ تطبيق "معلوماتي" يعرض معلومات المستخدم مع أزرار: فتح هاتف، إرسال بريد، فتح خرائط، مشاركة البيانات.
''';

  const contentEn = r'''
## 🎯 Goal
Access native features: Platform Channels, permissions, URL launcher.

## 📖 Theory

### URL Launcher
```dart
await launchUrl(Uri.parse('https://flutter.dev'));
await launchUrl(Uri.parse('mailto:test@example.com'));
await launchUrl(Uri.parse('tel:+1234567890'));
```

### Permissions
```dart
if (await Permission.camera.request().isGranted) { /* camera */ }
```

### Image Picker
```dart
final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
```

### Share
```dart
await Share.share('Check this out!');
```

### Platform Channel
```dart
const channel = MethodChannel('com.example/battery');
final level = await channel.invokeMethod('getBatteryLevel');
```

## 📝 Exercise
Build "My Info" app with phone, email, maps, share buttons.
''';

  const contentFr = r'''
## 🎯 Objectif
Accéder aux fonctionnalités natives: Platform Channels, permissions.

## 📖 Théorie
- url_launcher: ouvrir liens
- permission_handler: demander permissions
- image_picker: choisir images
- share_plus: partager
- Platform Channel: Kotlin/Swift

## 📝 Exercice
Créez une app "Mes Infos" avec appels, emails, maps, partage.
''';

  return Lesson(
    id: '${courseId}_t3_l18',
    courseId: courseId,
    title: const LocalizedText(
      ar: 'الدرس 18: المنصات والأمكانيات الأصلية',
      en: 'Lesson 18: Native & Platform Features',
      fr: 'Leçon 18: Fonctionnalités Natives',
    ),
    content: const LocalizedText(ar: contentAr, en: contentEn, fr: contentFr),
    codeDart: r'''
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const NativeDemo(),
    );
  }
}

class NativeDemo extends StatelessWidget {
  const NativeDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.language)), title: const Text('Open Link'), trailing: const Icon(Icons.chevron_right), onTap: () => launchUrl(Uri.parse('https://flutter.dev')))),
          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.email)), title: const Text('Send Email'), trailing: const Icon(Icons.chevron_right), onTap: () => launchUrl(Uri.parse('mailto:test@example.com')))),
          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.phone)), title: const Text('Call'), trailing: const Icon(Icons.chevron_right), onTap: () => launchUrl(Uri.parse('tel:+1234567890')))),
          Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.share)), title: const Text('Share'), trailing: const Icon(Icons.chevron_right), onTap: () => Share.share('Flutter is awesome!'))),
        ],
      ),
    );
  }
}
''',
    order: 17,
    exercise: const Exercise(
      question: LocalizedText(
        ar: 'أنشئ تطبيق "معلوماتي" مع أزرار هاتف وبريد وخريطة ومشاركة',
        en: 'Build "My Info" app with phone, email, maps, share',
        fr: 'Créez "Mes Infos" avec tel, email, maps, partage',
      ),
      options: [],
      answerIndex: 0,
      solution: LocalizedText(
        ar: 'url_launcher + share_plus + permission_handler',
        en: 'url_launcher + share_plus + permission_handler',
        fr: 'url_launcher + share_plus',
      ),
    ),
    homeworkPrompt: const LocalizedText(
      ar: 'تطبيق " weiße بطاقة" بمشاركة وحفظ في القائمة وفتح في خرائط',
      en: 'Business card app with share, save, maps',
      fr: 'App carte visite avec partage, sauvegarde, maps',
    ),
    hasHomework: true,
  );
}
