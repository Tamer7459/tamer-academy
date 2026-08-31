import '../models/course.dart';
import '../models/lesson.dart';
import '../services/database_service.dart';

// Web courses — كل ملف PDF أصبح دورة مستقلة
List<Course> buildWebCourses() {
  return [
    Course(
      id: 'cours_html_2025',
      title: LocalizedText(ar: 'دورة HTML', en: 'HTML Course', fr: 'Cours HTML'),
      description: LocalizedText(
        ar: 'من الصفر إلى بناء موقع شخصي متكامل بـ 12 درساً مع مشاريع عملية.',
        en: 'From zero to complete personal website — 12 lessons.',
        fr: 'De zéro au site personnel complet — 12 leçons.',
      ),
      track: 'web',
      level: 'beginner',
      price: 0,
      order: 10,
      published: true,
      colorSeed: 2,
      imageUrl: '',
    ),
    Course(
      id: 'cours_css_2025',
      title: LocalizedText(ar: 'دورة CSS', en: 'CSS Course', fr: 'Cours CSS'),
      description: LocalizedText(ar: 'تنسيق احترافي: من Box Model إلى Grid والتصميم المتجاوب.', en: 'From Box Model to Grid and Responsive.', fr: 'Du Box Model au Grid et Responsive.'),
      track: 'web',
      level: 'beginner',
      price: 0,
      order: 11,
      published: true,
      colorSeed: 3,
    ),
    Course(
      id: 'cours_bootstrap_2025',
      title: LocalizedText(ar: 'دورة Bootstrap 5', en: 'Bootstrap 5 Course', fr: 'Cours Bootstrap 5'),
      description: LocalizedText(ar: '8 دروس تفاعلية — Grid، مكونات، وتنقل متجاوب.', en: '8 interactive lessons.', fr: '8 leçons interactives.'),
      track: 'web',
      level: 'beginner',
      price: 0,
      order: 12,
      published: true,
      colorSeed: 4,
    ),
    Course(
      id: 'cours_tailwind_2025',
      title: LocalizedText(ar: 'دورة Tailwind CSS', en: 'Tailwind CSS Course', fr: 'Cours Tailwind CSS'),
      description: LocalizedText(ar: 'Utility-First مع 8 دروس وساحة تجربة حية.', en: 'Utility-First with 8 lessons.', fr: 'Utility-First avec 8 leçons.'),
      track: 'web',
      level: 'intermediate',
      price: 0,
      order: 13,
      published: true,
      colorSeed: 5,
    ),
    Course(
      id: 'cours_js_2025',
      title: LocalizedText(ar: 'دورة JavaScript', en: 'JavaScript Course', fr: 'Cours JavaScript'),
      description: LocalizedText(ar: 'لغة البرمجة الأساسية للويب — 12 درساً من المتغيرات إلى Async/Await.', en: 'Core web language — 12 lessons from variables to async/await.', fr: 'Langage principal du web — 12 leçons.'),
      track: 'web',
      level: 'beginner',
      price: 0,
      order: 14,
      published: true,
      colorSeed: 6,
    ),
    Course(
      id: 'cours_git_2025',
      title: LocalizedText(ar: 'دورة Git و GitHub', en: 'Git & GitHub Course', fr: 'Cours Git & GitHub'),
      description: LocalizedText(ar: 'التحكم بالإصدارات والتعاون — 8 دروس عملية.', en: 'Version control & collaboration — 8 practical lessons.', fr: 'Contrôle de version & collaboration — 8 leçons.'),
      track: 'web',
      level: 'beginner',
      price: 0,
      order: 15,
      published: true,
      colorSeed: 7,
    ),
    Course(
      id: 'cours_react_2025',
      title: LocalizedText(ar: 'دورة React.js', en: 'React.js Course', fr: 'Cours React.js'),
      description: LocalizedText(ar: 'بناء واجهات تفاعلية — 12 درساً من المكونات إلى الحالة والإدارة.', en: 'Build interactive UIs — 12 lessons from components to state.', fr: 'Construire des interfaces — 12 leçons.'),
      track: 'web',
      level: 'intermediate',
      price: 0,
      order: 16,
      published: true,
      colorSeed: 8,
    ),
  ];
}

List<Lesson> buildHtmlLessons(String courseId) => [
      _html1(courseId),
      _html2(courseId),
      _html3(courseId),
      _html4(courseId),
      _html5(courseId),
      _html6(courseId),
      _html7(courseId),
      _html8(courseId),
      _html9(courseId),
      _html10(courseId),
      _html11(courseId),
      _html12(courseId),
    ];

List<Lesson> buildCssLessons(String courseId) => List.generate(12, (i) => _genericLesson(courseId, 'CSS', i + 1, 'تصميم', 'Design'));
List<Lesson> buildBootstrapLessons(String courseId) => List.generate(8, (i) => _genericLesson(courseId, 'Bootstrap', i + 1, 'مكوّن', 'Component'));
List<Lesson> buildTailwindLessons(String courseId) => List.generate(8, (i) => _genericLesson(courseId, 'Tailwind', i + 1, 'فائدة', 'Utility'));

List<Lesson> buildJsLessons(String courseId) => [
      _js1(courseId),
      _js2(courseId),
      _js3(courseId),
      _js4(courseId),
      _js5(courseId),
      _js6(courseId),
      _js7(courseId),
      _js8(courseId),
      _js9(courseId),
      _js10(courseId),
      _js11(courseId),
      _js12(courseId),
    ];

List<Lesson> buildGitLessons(String courseId) => [
      _git1(courseId),
      _git2(courseId),
      _git3(courseId),
      _git4(courseId),
      _git5(courseId),
      _git6(courseId),
      _git7(courseId),
      _git8(courseId),
    ];

List<Lesson> buildReactLessons(String courseId) => [
      _react1(courseId),
      _react2(courseId),
      _react3(courseId),
      _react4(courseId),
      _react5(courseId),
      _react6(courseId),
      _react7(courseId),
      _react8(courseId),
      _react9(courseId),
      _react10(courseId),
      _react11(courseId),
      _react12(courseId),
    ];

Future<void> seedWebCourses(DatabaseService db) async {
  for (final c in buildWebCourses()) {
    await db.saveCourse(c);
  }
  for (final l in buildHtmlLessons('cours_html_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildCssLessons('cours_css_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildBootstrapLessons('cours_bootstrap_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildTailwindLessons('cours_tailwind_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildJsLessons('cours_js_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildGitLessons('cours_git_2025')) {
    await db.saveLesson(l);
  }
  for (final l in buildReactLessons('cours_react_2025')) {
    await db.saveLesson(l);
  }
}

// ————————————————————————————————————————————————————————————————————
// HTML Lessons — detailed from PDF
// ————————————————————————————————————————————————————————————————————

Lesson _html1(String c) => Lesson(
      id: '${c}_l1',
      courseId: c,
      title: LocalizedText(ar: 'الدرس 1: ما هو HTML وكيف يعمل المتصفح', en: 'Lesson 1: What is HTML', fr: 'Leçon 1: Qu\'est-ce que HTML'),
      content: LocalizedText(
        ar: r'''
## 🎯 الهدف
فهم ما هو HTML ودور المتصفح وكيف يبني شجرة DOM.

## 📖 الشرح
**HTML** لغة ترميز تحدد هيكل الصفحة — العظام. **CSS** المظهر — الجلد. **JavaScript** السلوك.
- الوسم: `<tag>محتوى</tag>` ومعظمها مزدوج، وبعضها ذاتي الإغلاق مثل `<img>` و `<br>`.
- الخاصية: `name="value"` داخل الوسم الافتتاحي، مثل `<a href="https://...">`.
- كيف يقرأ المتصفح: 1) يقرأ من الأعلى للأسفل 2) يبني DOM 3) يبني CSSOM 4) يدمجها في شجرة العرض.

```html
<p>هذه فقرة نصية</p>
<h1>مرحبا بالعالم</h1>
```
''',
        en: 'What is HTML, tags, attributes, and browser parsing to DOM.',
        fr: 'Qu\'est-ce que HTML, balises et parsing.',
      ),
      videoUrl: '',
      codeHtml: '<h1>Hello World</h1>\n<p>This is my first HTML page</p>',
      codeDart: '',
      exercise: Exercise(
        question: LocalizedText(ar: 'أنشئ أول وسوم HTML وحفظها كـ test.html', en: 'Create first tags', fr: 'Créez les premières balises'),
        options: [],
        answerIndex: 0,
        solution: LocalizedText(ar: 'h1 + p كما في المثال', en: 'h1 + p', fr: 'h1 + p'),
      ),
      questions: [
        LessonQuestion(question: LocalizedText(ar: 'ما الفرق بين HTML و CSS؟', en: 'Difference?', fr: 'Différence?'), solution: LocalizedText(ar: 'HTML هيكل، CSS مظهر', en: 'Structure vs style', fr: 'Structure vs style')),
      ],
      homeworkPrompt: LocalizedText(ar: 'طبق التمرين 1 وحفظ test.html', en: 'Do exercise 1', fr: 'Faites exercice 1'),
      hasHomework: true,
      order: 1,
    );

Lesson _html2(String c) => Lesson(
      id: '${c}_l2',
      courseId: c,
      title: LocalizedText(ar: 'الدرس 2: هيكلة الصفحة الكاملة', en: 'Lesson 2: Complete page', fr: 'Leçon 2: Page complète'),
      content: LocalizedText(
        ar: r'''
## الهيكل الكامل
```html
<!DOCTYPE html>
<html lang="ar">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width">
  <title>About Me</title>
</head>
<body>
  <h1>اسمي</h1>
</body>
</html>
```
- `<!DOCTYPE html>` ليست وسماً بل إعلان HTML5.
- `<html lang="ar">` الجذر — يحدد اللغة لقارئات الشاشة.
- `<head>` معلومات غير ظاهرة، `<meta charset="UTF-8">` ضروري للعربية.
- `viewport` يجعل الصفحة متجاوبة.
''',
        en: 'Complete HTML5 structure.',
        fr: 'Structure HTML5 complète.',
      ),
      videoUrl: '',
      codeHtml: '<!DOCTYPE html>\n<html lang="ar">\n<head><meta charset="UTF-8"><title>About Me</title></head>\n<body><h1>الاسم</h1></body>\n</html>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ about.html كاملة بعنوان واسمك', en: 'Create about.html', fr: 'Créez about.html'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'الهيكل الكامل', en: 'Full structure', fr: 'Structure complète')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'بناء صفحة Who Am I كاملة', en: 'Who Am I page', fr: 'Page Qui suis-je'),
      hasHomework: true,
      order: 2,
    );

Lesson _html3(String c) => Lesson(
      id: '${c}_l3',
      courseId: c,
      title: LocalizedText(ar: 'الدرس 3: العناوين والفقرات والتنسيق', en: 'Headings & formatting', fr: 'Titres et mise en forme'),
      content: LocalizedText(ar: 'h1 مرة واحدة، p يدمج المسافات، strong/em للدلالة، b/i بصري فقط، استخدام del/ins و sub/sup.', en: 'Headings hierarchy, p, strong/em vs b/i', fr: 'Hiérarchie des titres'),
      videoUrl: '',
      codeHtml: '<h1>اسمي</h1>\n<h2>ملخص</h2>\n<p>نص <strong>مهم</strong> و <em>مميز</em></p>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'صفحة CV بتنسيق', en: 'CV page', fr: 'Page CV'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'استخدم strong/em/del/sub', en: 'Use formatting', fr: 'Utilisez mise en forme')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'CV page', en: 'CV', fr: 'CV'),
      hasHomework: true,
      order: 3,
    );

Lesson _html4(String c) => Lesson(id: '${c}_l4', courseId: c, title: LocalizedText(ar: 'الدرس 4: القوائم', en: 'Lists', fr: 'Listes'), content: LocalizedText(ar: 'ul غير مرتبة، ol مرتبة، dl تعريفية، وقوائم متداخلة.', en: 'ul, ol, dl, nested', fr: 'ul, ol, dl'), videoUrl: '', codeHtml: '<ul><li>HTML</li></ul>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'صفحة مهارات بقوائم', en: 'Skills page', fr: 'Page compétences'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'ul/ol/dl', en: 'ul/ol/dl', fr: 'ul/ol/dl')), questions: [], homeworkPrompt: LocalizedText(ar: 'Skills lists', en: 'Skills', fr: 'Compétences'), hasHomework: true, order: 4);
Lesson _html5(String c) => Lesson(id: '${c}_l5', courseId: c, title: LocalizedText(ar: 'الدرس 5: الروابط والتنقل', en: 'Links', fr: 'Liens'), content: LocalizedText(ar: 'a + href, target blank مع rel noopener, روابط داخلية id, mailto/tel, جعل أي عنصر رابطاً.', en: 'Links', fr: 'Liens'), videoUrl: '', codeHtml: '<a href="about.html">About</a>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'موقع 3 صفحات بروابط', en: '3-page site', fr: 'Site 3 pages'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'index/about/contact', en: '3 pages', fr: '3 pages')), questions: [], homeworkPrompt: LocalizedText(ar: 'Navigation', en: 'Navigation', fr: 'Navigation'), hasHomework: true, order: 5);
Lesson _html6(String c) => Lesson(id: '${c}_l6', courseId: c, title: LocalizedText(ar: 'الدرس 6: الصور والوسائط', en: 'Images', fr: 'Images'), content: LocalizedText(ar: 'img ذاتية الإغلاق، alt وصفي، figure/figcaption، مسار نسبي/مطلق.', en: 'img, alt, figure', fr: 'img, alt'), videoUrl: '', codeHtml: '<figure><img src="images/photo.jpg" alt="وصف"><figcaption>تعليق</figcaption></figure>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'معرض صور', en: 'Gallery', fr: 'Galerie'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'gallery.html', en: 'gallery', fr: 'galerie')), questions: [], homeworkPrompt: LocalizedText(ar: 'Gallery', en: 'Gallery', fr: 'Galerie'), hasHomework: true, order: 6);
Lesson _html7(String c) => Lesson(id: '${c}_l7', courseId: c, title: LocalizedText(ar: 'الدرس 7: الجداول', en: 'Tables', fr: 'Tableaux'), content: LocalizedText(ar: 'table/thead/tbody/tfoot/th/td, colspan/rowspan, caption.', en: 'Tables', fr: 'Tableaux'), videoUrl: '', codeHtml: '<table><caption>جدول</caption><tr><th>يوم</th></tr></table>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'جدول أسبوعي', en: 'Timetable', fr: 'Emploi du temps'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'colspan/rowspan', en: 'span', fr: 'span')), questions: [], homeworkPrompt: LocalizedText(ar: 'Timetable', en: 'Timetable', fr: 'Emploi'), hasHomework: true, order: 7);
Lesson _html8(String c) => Lesson(id: '${c}_l8', courseId: c, title: LocalizedText(ar: 'الدرس 8: متى تستخدم الجداول', en: 'When to use tables', fr: 'Quand utiliser tableaux'), content: LocalizedText(ar: 'الجداول للبيانات فقط، ليس للتخطيط — استخدم Flex/Grid بدلا منها.', en: 'Tables for data only', fr: 'Tableaux pour données'), videoUrl: '', codeHtml: '', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'جدول مقارنة لغات', en: 'Compare table', fr: 'Tableau comparatif'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'scope col/row', en: 'scope', fr: 'scope')), questions: [], homeworkPrompt: LocalizedText(ar: 'Comparison', en: 'Comparison', fr: 'Comparaison'), hasHomework: true, order: 8);
Lesson _html9(String c) => Lesson(id: '${c}_l9', courseId: c, title: LocalizedText(ar: 'الدرس 9: النماذج وأساسياتها', en: 'Forms basics', fr: 'Formulaires'), content: LocalizedText(ar: 'form, label+for/id, input types, textarea/select/button, method post.', en: 'Forms', fr: 'Formulaires'), videoUrl: '', codeHtml: '<form method="post"><label for="name">الاسم</label><input id="name" required></form>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'نموذج تسجيل', en: 'Register form', fr: 'Formulaire'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'form', en: 'form', fr: 'formulaire')), questions: [], homeworkPrompt: LocalizedText(ar: 'Register', en: 'Register', fr: 'Inscription'), hasHomework: true, order: 9);
Lesson _html10(String c) => Lesson(id: '${c}_l10', courseId: c, title: LocalizedText(ar: 'الدرس 10: نماذج HTML5 متقدمة', en: 'Advanced forms', fr: 'Formulaires avancés'), content: LocalizedText(ar: 'أنواع HTML5, datalist, fieldset/legend, خصائص التحقق.', en: 'datalist, fieldset', fr: 'datalist'), videoUrl: '', codeHtml: '<datalist><option>الجزائر</option></datalist>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'استبيان كامل', en: 'Survey', fr: 'Sondage'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'survey.html', en: 'survey', fr: 'sondage')), questions: [], homeworkPrompt: LocalizedText(ar: 'Survey', en: 'Survey', fr: 'Sondage'), hasHomework: true, order: 10);
Lesson _html11(String c) => Lesson(id: '${c}_l11', courseId: c, title: LocalizedText(ar: 'الدرس 11: العناصر الدلالية', en: 'Semantic', fr: 'Sémantique'), content: LocalizedText(ar: 'مشكلة div, عناصر header/nav/main/article/aside/footer, الفرق section/article/div, أثر SEO.', en: 'Semantic elements', fr: 'Éléments sémantiques'), videoUrl: '', codeHtml: '<header><nav></nav></header><main><article></article></main><footer></footer>', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'تحويل div إلى دلالية', en: 'Rewrite divs', fr: 'Réécrire'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'semantic', en: 'semantic', fr: 'sémantique')), questions: [], homeworkPrompt: LocalizedText(ar: 'Semantic', en: 'Semantic', fr: 'Sémantique'), hasHomework: true, order: 11);
Lesson _html12(String c) => Lesson(id: '${c}_l12', courseId: c, title: LocalizedText(ar: 'الدرس 12: الوسوم الوصفية و SEO', en: 'Meta & SEO', fr: 'Meta & SEO'), content: LocalizedText(ar: 'title, meta description 150-160, robots, Open Graph 1200x630, canonical, favicon.', en: 'Meta SEO', fr: 'Meta SEO'), videoUrl: '', codeHtml: '<meta name="description" content="..."><meta property="og:image" content="...">', codeDart: '', exercise: Exercise(question: LocalizedText(ar: 'رأس احترافي لـ TechDZ', en: 'TechDZ header', fr: 'En-tête TechDZ'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'og tags', en: 'og', fr: 'og')), questions: [], homeworkPrompt: LocalizedText(ar: 'SEO', en: 'SEO', fr: 'SEO'), hasHomework: true, order: 12);

// ————————————————————————————————————————————————————————————————————
// JavaScript Lessons — detailed
// ————————————————————————————————————————————————————————————————————

Lesson _js1(String c) => Lesson(
      id: '${c}_l1', courseId: c,
      title: LocalizedText(ar: 'الدرس 1: مقدمة في JavaScript', en: 'Lesson 1: Intro to JS', fr: 'Leçon 1: Intro JS'),
      content: LocalizedText(ar: r'''
## 🎯 الهدف
فهم ما هي JavaScript ولماذا تُعتبر لغة الويب الأساسية.

## 📖 الشرح
- **JavaScript** هي لغة برمجة تُشغّل في المتصفح responsible عن التفاعل.
- أضيفت لملف HTML عبر وسم `<script>` أو ملف خارجي.
- تُفسّر (Interpreted) لا تُترجم — تعمل سطر بسطر.
- تعمل في المتصفح **و** في الخادم (Node.js).

```html
<script>
  console.log("مرحبا بالعالم");
  document.write("<h1>أول برنامج JS</h1>");
</script>
```

## 📝 ملاحظات
- `console.log()` لطباعة في وحدة التحكم.
- `alert()` لعرض رسالة.
- `document.write()` لكتابة في الصفحة.
''',
        en: 'What is JavaScript, how it runs in browser, console, alert.',
        fr: 'Qu\'est-ce que JavaScript, comment ça marche.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  console.log("Hello JS");\n  alert("Welcome!");\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ صفحة تطبع اسمك في console', en: 'Print name in console', fr: 'Affichez votre nom'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'console.log("اسمي")', en: 'console.log()', fr: 'console.log()')),
      questions: [LessonQuestion(question: LocalizedText(ar: 'لماذا JavaScript لغة مفسّرة؟', en: 'Why interpreted?', fr: 'Pourquoi interprétée?'), solution: LocalizedText(ar: 'تُنفّذ سطر بسطر بدون خطوة ترجمة', en: 'Executes line by line', fr: 'Exécute ligne par ligne'))],
      homeworkPrompt: LocalizedText(ar: 'أنشئ صفحة بـ script يطبع رسالة ترحيب', en: 'Create welcome page script', fr: 'Page de bienvenue'), hasHomework: true, order: 1,
    );

Lesson _js2(String c) => Lesson(
      id: '${c}_l2', courseId: c,
      title: LocalizedText(ar: 'الدرس 2: المتغيرات وأنواع البيانات', en: 'Lesson 2: Variables & Types', fr: 'Leçon 2: Variables & Types'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
- **let** — متغير قابل للتعديل (يُفضّل استخدامه).
- **const** — ثابت لا يتغير.
- **var** — القديم، يتجاهل النطاق (تجنبه).

### أنواع البيانات Primitive:
| النوع | مثال |
|-------|------|
| String | `"أحمد"` |
| Number | `25`, `3.14` |
| Boolean | `true`, `false` |
| Undefined | `let x;` |
| Null | `let y = null;` |

```js
let name = "أحمد";
const age = 25;
let isStudent = true;
console.log(typeof name); // "string"
```
''',
        en: 'let, const, var, primitive types: string, number, boolean, null, undefined.',
        fr: 'let, const, var, types primitifs.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  let name = "Ahmed";\n  const age = 25;\n  console.log(typeof name);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'عرّف متغيرات بأنواع مختلفة', en: 'Declare variables', fr: 'Déclarez des variables'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'let + const + typeof', en: 'let + const + typeof', fr: 'let + const')),
      questions: [LessonQuestion(question: LocalizedText(ar: 'ما الفرق بين let و const؟', en: 'let vs const?', fr: 'let vs const?'), solution: LocalizedText(ar: 'let يتغير، const ثابت', en: 'let can change, const fixed', fr: 'let modifiable, const fixe'))],
      homeworkPrompt: LocalizedText(ar: 'أنشئ ملف JS بمتغيرات من كل الأنواع', en: 'Variables of all types', fr: 'Variables de tous types'), hasHomework: true, order: 2,
    );

Lesson _js3(String c) => Lesson(
      id: '${c}_l3', courseId: c,
      title: LocalizedText(ar: 'الدرس 3: العمليات الحسابية والمنطقية', en: 'Lesson 3: Operators', fr: 'Leçon 3: Opérateurs'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### حسابية: `+` `-` `*` `/` `%` `**`
### مقارنة: `==` `===` `!=` `!==` `>` `<`
### منطقية: `&&` `||` `!`

⚠️ **فرق هام:** `==` يقارن القيمة فقط، `===` يقارن القيمة والنوع.

```js
console.log(5 + 3);    // 8
console.log(10 % 3);   // 1
console.log(2 ** 3);   // 8
console.log(5 == "5");  // true
console.log(5 === "5"); // false
```

- **Nullish Coalescing:** `value ?? "default"` — يستخدم القيمة الافتراضية إذا كانت null أو undefined.
- **Logical OR:** `value || "default"` — يستخدم القيمة الافتراضية إذا كانت falsy.
''',
        en: 'Arithmetic, comparison, logical operators, == vs ===.',
        fr: 'Opérateurs arithmétiques, comparaison, logique.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  let a = 10, b = 3;\n  console.log(a + b, a - b, a * b, a / b, a % b);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'احسب متوسط 3 أعداد', en: 'Average of 3', fr: 'Moyenne de 3'), options: [], answerIndex: 0, solution: LocalizedText(ar: '(a+b+c)/3', en: '(a+b+c)/3', fr: '(a+b+c)/3')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'آلة حاسبة بسيطة ت接受 رقمين وتعمل كل العمليات', en: 'Simple calculator', fr: 'Calculatrice'), hasHomework: true, order: 3,
    );

Lesson _js4(String c) => Lesson(
      id: '${c}_l4', courseId: c,
      title: LocalizedText(ar: 'الدرس 4: الجمل الشرطية', en: 'Lesson 4: Conditionals', fr: 'Leçon 4: Conditionnels'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### if / else if / else
```js
if (grade >= 90) {
  console.log("ممتاز");
} else if (grade >= 70) {
  console.log("جيد جداً");
} else {
  console.log("يحتاج تحسين");
}
```

### switch
```js
let day = "Monday";
switch (day) {
  case "Monday": console.log("بداية الأسبوع"); break;
  case "Friday": console.log("نهاية الأسبوع"); break;
  default: console.log("أيام العمل");
}
```

### Ternary Operator
```js
let status = age >= 18 ? "بالغ" : "قاصر";
```
''',
        en: 'if/else, switch, ternary operator.',
        fr: 'if/else, switch, opérateur ternaire.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  let grade = 85;\n  let result = grade >= 90 ? "ممتاز" : grade >= 70 ? "جيد" : "ضعيف";\n  console.log(result);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'اكتب شرط يحدد نوع الدم (A, B, AB, O)', en: 'Blood type checker', fr: 'Vérificateur de groupe'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'if/else + switch', en: 'if/else + switch', fr: 'if/else')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'محفظة درجات — ي INPUT درجة ي OUTPUT التقدير', en: 'Grade calculator app', fr: 'Calculateur de notes'), hasHomework: true, order: 4,
    );

Lesson _js5(String c) => Lesson(
      id: '${c}_l5', courseId: c,
      title: LocalizedText(ar: 'الدرس 5: الحلقات التكرارية', en: 'Lesson 5: Loops', fr: 'Leçon 5: Boucles'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### for
```js
for (let i = 1; i <= 10; i++) {
  console.log(i);
}
```

### while / do...while
```js
let i = 1;
while (i <= 5) {
  console.log(i);
  i++;
}
```

### for...of (للقوائم) و for...in (للعناصر)
```js
let colors = ["red", "green", "blue"];
for (let c of colors) console.log(c);

let user = {name: "Ahmed", age: 25};
for (let key in user) console.log(key, user[key]);
```

### break و continue
- `break` يخرج من الحلقة.
- `continue` يتجاوز التكرار الحالي.
''',
        en: 'for, while, do...while, for...of, for...in, break, continue.',
        fr: 'for, while, for...of, for...in.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  for (let i = 1; i <= 5; i++) {\n    console.log(i * i);\n  }\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'اطبع جدول ضرب رقم معين', en: 'Multiplication table', fr: 'Table de multiplication'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'for loop', en: 'for loop', fr: 'for loop')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'لعبة تخمين رقم عشوائي بين 1-100', en: 'Guess number game', fr: 'Jeu de devinette'), hasHomework: true, order: 5,
    );

Lesson _js6(String c) => Lesson(
      id: '${c}_l6', courseId: c,
      title: LocalizedText(ar: 'الدرس 6: الدوال', en: 'Lesson 6: Functions', fr: 'Leçon 6: Fonctions'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Three ways to define:
```js
// 1. Function Declaration
function greet(name) {
  return `مرحبا ${name}`;
}

// 2. Function Expression
const add = function(a, b) {
  return a + b;
};

// 3. Arrow Function
const multiply = (a, b) => a * b;
```

### Default Parameters & Rest
```js
function greet(name = "زائر") {
  return `مرحبا ${name}`;
}

function sum(...nums) {
  return nums.reduce((total, n) => total + n, 0);
}
```

### Scope
- **Global:** متاحة لكل مكان.
- **Function:** داخل الدالة فقط.
- **Block:** داخل `{}` مع `let/const`.
''',
        en: 'Function declaration, expression, arrow function, scope.',
        fr: 'Déclaration, expression, fléchée, portée.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  const greet = (name) => `مرحبا \${name}`;\n  console.log(greet("أحمد"));\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'اكتب دالة تحوّل سلسلاً إلى PascalCase', en: 'toPascalCase function', fr: 'Fonction toPascalCase'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'split + map + join', en: 'split + map + join', fr: 'split + map + join')),
      questions: [LessonQuestion(question: LocalizedText(ar: 'ما الفرق بين arrow function والعادية؟', en: 'Arrow vs regular?', fr: 'Fléchée vs normale?'), solution: LocalizedText(ar: 'Arrow أقصر، لا تملك own `this`', en: 'Shorter, no own this', fr: 'Plus courte, pas de this'))],
      homeworkPrompt: LocalizedText(ar: '一组 مmath utility functions: add, subtract, multiply, divide', en: 'Math utilities', fr: 'Utilitaires math'), hasHomework: true, order: 6,
    );

Lesson _js7(String c) => Lesson(
      id: '${c}_l7', courseId: c,
      title: LocalizedText(ar: 'الدرس 7: المصفوفات', en: 'Lesson 7: Arrays', fr: 'Leçon 7: Tableaux'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### إنشاء و Access
```js
let fruits = ["تفاح", "موز", "برتقال"];
fruits[0]; // "تفاح"
fruits.length; // 3
```

### الطرق الأساسية:
- `push()` / `pop()` — إضافة من النهاية / حذف.
- `unshift()` / `shift()` — إضافة من البداية / حذف.
- `splice(i, n)` — حذف من موضع محدد.
- `includes()` — التحقق من وجود عنصر.
- `indexOf()` — معرفة موضع عنصر.
- `concat()` — دمج مصفوفتين.
- `slice()` — نسخ جزء.
- `reverse()` / `sort()` — عكس / ترتيب.

### الطرق الوظيفية (Functional):
```js
let nums = [1, 2, 3, 4, 5];
nums.map(n => n * 2);        // [2,4,6,8,10]
nums.filter(n => n > 3);     // [4,5]
nums.reduce((sum, n) => sum + n, 0); // 15
nums.find(n => n > 3);       // 4
nums.every(n => n > 0);      // true
```

### Destructuring
```js
let [first, second, ...rest] = [1, 2, 3, 4, 5];
// first=1, second=2, rest=[3,4,5]
```
''',
        en: 'Array methods: push, pop, map, filter, reduce, find, destructuring.',
        fr: 'Méthodes tableau: push, pop, map, filter, reduce.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  let nums = [10, 20, 30, 40, 50];\n  let doubled = nums.map(n => n * 2);\n  console.log(doubled);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'احذف العناصر المكررة من مصفوفة', en: 'Remove duplicates', fr: 'Supprimer doublons'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'Set أو filter', en: 'Set or filter', fr: 'Set ou filter')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'لوحة مهام (Todo List) باستخدام مصفوفة', en: 'Todo List', fr: 'Liste de tâches'), hasHomework: true, order: 7,
    );

Lesson _js8(String c) => Lesson(
      id: '${c}_l8', courseId: c,
      title: LocalizedText(ar: 'الدرس 8: الكائنات', en: 'Lesson 8: Objects', fr: 'Leçon 8: Objets'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### إنشاء و Access
```js
let user = {
  name: "أحمد",
  age: 25,
  hobbies: ["reading", "coding"],
  greet() {
    return `مرحبا، أنا ${this.name}`;
  }
};
user.name;       // dot notation
user["age"];     // bracket notation
user.email = "a@b.com"; // إضافة خاصية
```

### Destructuring
```js
let { name, age, ...rest } = user;
```

### Object Methods
- `Object.keys()` — مصفوفة المفاتيح.
- `Object.values()` — مصفوفة القيم.
- `Object.entries()` — مصفوفة `[key, value]`.
- `Object.assign()` — دمج كائنات.
- Spread: `{...obj1, ...obj2}`

### Optional Chaining
```js
let city = user?.address?.city ?? "غير محدد";
```
''',
        en: 'Object creation, properties, methods, destructuring, spread.',
        fr: 'Création objet, propriétés, méthodes, destructuring.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  let user = { name: "Ahmed", age: 25 };\n  let { name, age } = user;\n  console.log(name, age);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ كائن طالب ببيانات كاملة', en: 'Student object', fr: 'Objet étudiant'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'Object literal', en: 'Object literal', fr: 'Littéral objet')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'Address book — إضافة / حذف / بحث جهات اتصال', en: 'Address book', fr: 'Carnet d\'adresses'), hasHomework: true, order: 8,
    );

Lesson _js9(String c) => Lesson(
      id: '${c}_l9', courseId: c,
      title: LocalizedText(ar: 'الدرس 9: DOM — التعامل مع الصفحة', en: 'Lesson 9: DOM Manipulation', fr: 'Leçon 9: Manipulation DOM'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
DOM هو تمثيل شجري للصفحة يمكن لـ JS التعامل معه.

### اختيار العناصر:
```js
document.getElementById("myId");
document.querySelector(".myClass");     // أول عنصر
document.querySelectorAll("p");         // كل العناصر
```

### التعديل:
```js
el.textContent = "نص جديد";
el.innerHTML = "<b>bold</b>";
el.setAttribute("class", "active");
el.style.color = "red";
el.classList.add("visible");
el.classList.toggle("hidden");
```

### إنشاء و حذف:
```js
let div = document.createElement("div");
div.textContent = "عنصر جديد";
document.body.appendChild(div);
el.remove();
```

### الأحداث:
```js
el.addEventListener("click", function() {
  console.log("تم النقر!");
});

el.removeEventListener("click", handler);
```

### Event Object
```js
function handler(e) {
  e.preventDefault();   // منع السلوك الافتراضي
  e.stopPropagation();  // إيقاف الانتشار
  console.log(e.target);
}
```
''',
        en: 'Select, modify, create, remove elements, event listeners, event object.',
        fr: 'Sélectionner, modifier, créer, supprimer éléments, événements.',
      ),
      videoUrl: '',
      codeHtml: '<button id="btn">اضغط</button>\n<div id="output"></div>\n<script>\n  document.getElementById("btn").addEventListener("click", () => {\n    document.getElementById("output").textContent = "تم النقر!";\n  });\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ عداد أزرار (+ و -)', en: 'Counter app', fr: 'Compteur'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'addEventListener + textContent', en: 'addEventListener + textContent', fr: 'addEventListener')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق ملاحظات قابل للحذف والتعديل', en: 'Sticky notes app', fr: 'Appli post-it'), hasHomework: true, order: 9,
    );

Lesson _js10(String c) => Lesson(
      id: '${c}_l10', courseId: c,
      title: LocalizedText(ar: 'الدرس 10: Async/Await و Promises', en: 'Lesson 10: Async/Await', fr: 'Leçon 10: Async/Await'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Callback → Promise → Async/Await

#### Promise
```js
let promise = new Promise((resolve, reject) => {
  setTimeout(() => resolve("تم!"), 1000);
});
promise.then(data => console.log(data));
```

#### Fetch API
```js
fetch("https://api.example.com/data")
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

#### Async/Await
```js
async function getData() {
  try {
    let res = await fetch("https://api.example.com/data");
    let data = await res.json();
    console.log(data);
  } catch (err) {
    console.error("خطأ:", err);
  }
}
```

### الترتيب المتوازي
```js
// المتتالي — بطيء
let a = await fetch(url1);
let b = await fetch(url2);

// المتوازي — سريع
let [a, b] = await Promise.all([fetch(url1), fetch(url2)]);
```
''',
        en: 'Promises, fetch, async/await, error handling.',
        fr: 'Promesses, fetch, async/await.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  async function getPost() {\n    const res = await fetch("https://jsonplaceholder.typicode.com/posts/1");\n    const data = await res.json();\n    console.log(data);\n  }\n  getPost();\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'اجلب بيانات من API واعرضها', en: 'Fetch and display data', fr: 'Récupérer des données'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'async/await + fetch', en: 'async/await + fetch', fr: 'async/await')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق جلب بيانات من JSONPlaceholder وعرضها', en: 'API data viewer', fr: 'Afficheur de données API'), hasHomework: true, order: 10,
    );

Lesson _js11(String c) => Lesson(
      id: '${c}_l11', courseId: c,
      title: LocalizedText(ar: 'الدرس 11: التخزين المحلي', en: 'Lesson 11: Local Storage', fr: 'Leçon 11: Stockage Local'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### أنواع التخزين في المتصفح:
| الخاصية | localStorage | sessionStorage | Cookie |
|---------|-------------|----------------|--------|
| المدة | للأبد | جلسة التصفّح | مدة محددة |
| الحجم | ~5MB | ~5MB | ~4KB |
| الإرسال | لا | لا | مع كل طلب |

### localStorage
```js
// حفظ
localStorage.setItem("username", "أحمد");
localStorage.setItem("user", JSON.stringify({name: "أحمد", age: 25}));

// قراءة
let name = localStorage.getItem("username");
let user = JSON.parse(localStorage.getItem("user"));

// حذف
localStorage.removeItem("username");
localStorage.clear(); // حذف كل شيء
```

### مثال عملي: حفظ المهام
```js
function saveTasks(tasks) {
  localStorage.setItem("tasks", JSON.stringify(tasks));
}
function loadTasks() {
  return JSON.parse(localStorage.getItem("tasks")) || [];
}
```
''',
        en: 'localStorage, sessionStorage, cookies, JSON serialization.',
        fr: 'localStorage, sessionStorage, cookies.',
      ),
      videoUrl: '',
      codeHtml: '<script>\n  localStorage.setItem("theme", "dark");\n  console.log(localStorage.getItem("theme"));\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'احفظ مظهر المستخدم (فاتح/داكن) وستخدمه في التحميل', en: 'Save theme preference', fr: 'Préférence de thème'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'localStorage.setItem/getItem', en: 'localStorage', fr: 'localStorage')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق مهام يحفظ في localStorage', en: 'Todo app with persistence', fr: 'Todo avec persistance'), hasHomework: true, order: 11,
    );

Lesson _js12(String c) => Lesson(
      id: '${c}_l12', courseId: c,
      title: LocalizedText(ar: 'الدرس 12: مفاهيم متقدمة', en: 'Lesson 12: Advanced Concepts', fr: 'Leçon 12: Concepts Avancés'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Closures
دالة تحتوي على متغيرات من النطاق الخارجي即使 بعد انتهاء الدالة الخارجية.
```js
function counter() {
  let count = 0;
  return {
    increment: () => ++count,
    getCount: () => count
  };
}
let c = counter();
c.increment(); c.increment();
c.getCount(); // 2
```

### Hoisting
```js
console.log(x); // undefined (hoisted)
var x = 5;
// let/const لا تُhoisted like var
```

### This
```js
const obj = {
  name: "أحمد",
  greet() {
    console.log(`مرحبا ${this.name}`);
  }
};
```

### ES6 Modules
```js
// utils.js
export const add = (a, b) => a + b;
export default class User { ... }

// main.js
import User, { add } from "./utils.js";
```

### Destructuring متقدم
```js
let { name: userName, age: userAge } = user;
let { address: { city } } = user; // nested
```
''',
        en: 'Closures, hoisting, this, modules, advanced destructuring.',
        fr: 'Closures, hoisting, this, modules.',
      ),
      videoUrl: '',
      codeHtml: '<script type="module">\n  import { add } from "./utils.js";\n  console.log(add(2, 3));\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ counter باستخدام closure', en: 'Counter with closure', fr: 'Compteur avec closure'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'Closure pattern', en: 'Closure pattern', fr: 'Closure')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'ملخص شامل لدورة JS — مشروع بسيط يستخدم كل ما تعلمته', en: 'JS final project', fr: 'Projet final JS'), hasHomework: true, order: 12,
    );

// ————————————————————————————————————————————————————————————————————
// Git & GitHub Lessons — detailed
// ————————————————————————————————————————————————————————————————————

Lesson _git1(String c) => Lesson(
      id: '${c}_l1', courseId: c,
      title: LocalizedText(ar: 'الدرس 1: مقدمة في Git', en: 'Lesson 1: Intro to Git', fr: 'Leçon 1: Intro Git'),
      content: LocalizedText(ar: r'''
## 🎯 الهدف
فهم لماذا نحتاج Git وكيف يعمل التحكم بالإصدارات.

## 📖 الشرح
**Git** هو نظام تحكم بالإصدارات (VCS) — يتتبع التغييرات على الملفات ويسجّل تاريخها.

### لماذا Git؟
- تتبع كل تغيير في الكود.
- العودة لإصدار سابق بسهولة.
- التعاون مع فريق بدون تعارض.
- فرع (Branch) للتجربة دون التأثير على الكود الأساسي.

### التثبيت
```bash
# Windows
git --version
git config --global user.name "اسمك"
git config --global user.email "email@example.com"
```

### إنشاء مستودع
```bash
mkdir my-project
cd my-project
git init                    # إنشاء مستودع محلي
git init remote-url         # نسخ مستودع موجود
```

### الحالات الثلاث:
- **Working Directory:** الملفات الحالية.
- **Staging Area:** الملفات المُعدّة للCommit.
- **Repository:** السجل النهائي.
''',
        en: 'What is Git, why use it, install, init, three states.',
        fr: 'Qu\'est-ce que Git, pourquoi l\'utiliser.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit init\ngit config --global user.name "Tamer"',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'ثبّت Git وأعدّ إعداداته الأساسية', en: 'Install and configure Git', fr: 'Installez Git'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'git init + config', en: 'git init + config', fr: 'git init')),
      questions: [LessonQuestion(question: LocalizedText(ar: 'ما الفرق بين git init و git clone؟', en: 'init vs clone?', fr: 'init vs clone?'), solution: LocalizedText(ar: 'init ينشئ مستودع جديد، clone ينسخ موجود', en: 'init creates new, clone copies existing', fr: 'init crée, clone copie'))],
      homeworkPrompt: LocalizedText(ar: 'أنشئ مستودع Git جديد وسجّل أول commit', en: 'Create repo and first commit', fr: 'Créez un dépôt'), hasHomework: true, order: 1,
    );

Lesson _git2(String c) => Lesson(
      id: '${c}_l2', courseId: c,
      title: LocalizedText(ar: 'الدرس 2: أوامر الأساسيات', en: 'Lesson 2: Basic Commands', fr: 'Leçon 2: Commandes de Base'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### دورة حياة الملف:
```bash
# 1. إنشاء/تعديل ملف
echo "Hello" > file.txt

# 2. إضافته للStaging
git add file.txt          # ملف محدد
git add .                 # كل الملفات

# 3. Commit
git commit -m "رسالة وصفية"

# 4. تعديل مرة أخرى
echo "Updated" >> file.txt
git add .
git commit -m "تحديث الملف"
```

### أوامر المراقبة:
```bash
git status                # حالة الملفات
git diff                  # التغييرات غير المُضافّة
git diff --staged         # التغييرات في Staging
git log                   # سجل Commits
git log --oneline         # مختصر
git log --graph           # مع الشجرة
```

### حذف من Staging:
```bash
git restore file.txt      # إزالة من Staging
git restore --staged file.txt
```
''',
        en: 'git add, commit, status, diff, log, restore.',
        fr: 'git add, commit, status, diff, log, restore.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit add .\ngit commit -m "First commit"\ngit log --oneline',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ 3 ملفات وسجّلهم في commit واحد', en: 'Create and commit 3 files', fr: 'Créez 3 fichiers'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'git add + commit', en: 'git add + commit', fr: 'git add')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'سجل 5 commits برسائل وصفية مختلفة', en: '5 descriptive commits', fr: '5 commits descriptifs'), hasHomework: true, order: 2,
    );

Lesson _git3(String c) => Lesson(
      id: '${c}_l3', courseId: c,
      title: LocalizedText(ar: 'الدرس 3: الفروع (Branches)', en: 'Lesson 3: Branches', fr: 'Leçon 3: Branches'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### لماذا الفروع؟
تتيح العمل على ميزة أو إصلاح دون تعطيل الكود الرئيسي.

### أوامر الفروع:
```bash
git branch                # عرض الفروع
git branch feature-login  # إنشاء فرع جديد
git checkout feature-login # الانتقال لفرع
git checkout -b bugfix     # إنشاء والانتقال معاً
git switch feature-login   # الطرق الحديثة
git merge feature-login    # دمج في الفرع الحالي
git branch -d feature-login # حذف فرع (بعد الدمج)
```

### الحل النموذجي:
1. `main` — الكود المستقر.
2. `develop` — التطوير المستمر.
3. `feature/*` — ميزات جديدة.
4. `bugfix/*` — إصلاح أخطاء.
5. `hotfix/*` — إصلاح عاجل.

### التعامل مع التعارض (Merge Conflict):
- يظهر علامة `<<<<<<<` و `=======` و `>>>>>>>`.
- حرر الملف يدوياً واختر التغييرات الصحيحة.
- `git add` ثم `git commit`.
''',
        en: 'Branches, merge, conflict resolution.',
        fr: 'Branches, merge, résolution de conflits.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit checkout -b feature\ngit add .\ngit commit -m "Add feature"\ngit checkout main\ngit merge feature',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ فرع ودمجه في main', en: 'Create and merge branch', fr: 'Créez et fusionnez'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'checkout -b + merge', en: 'checkout -b + merge', fr: 'checkout -b')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: '模拟: أنشئ فرع feature وأصلح bug ودمج两者', en: 'Branch & merge workflow', fr: 'Workflow branch'), hasHomework: true, order: 3,
    );

Lesson _git4(String c) => Lesson(
      id: '${c}_l4', courseId: c,
      title: LocalizedText(ar: 'الدرس 4: GitHub — النشر والتعاون', en: 'Lesson 4: GitHub Basics', fr: 'Leçon 4: GitHub'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### ربط المستودع المحلي بـ GitHub:
```bash
git remote add origin https://github.com/user/repo.git
git branch -M main
git push -u origin main
```

### أوامر نقل:
```bash
git push                  # رفع التغييرات
git push origin main
git pull                  # سحب + دمج
git pull --rebase         # سحب بدون merge commit
git fetch                 # سحب فقط بدون دمج
```

### Fork و Clone:
- **Fork:** نسخ مستودع شخص آخر إلى حسابك.
- **Clone:** نسخ مستودع محلياً.

### Pull Request (PR):
1. أنشئ فرع جديد.
2. اعمل التغييرات وافعل push.
3. أنشئ PR على GitHub.
4. راجع المراجعة (Code Review).
5. ادمج (Merge).

### README.md
```markdown
# اسم المشروع
وصف مختصر
## التثبيت
npm install
## الاستخدام
npm start
```
''',
        en: 'Remote, push, pull, fork, clone, pull requests, README.',
        fr: 'Remote, push, pull, fork, PR.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit remote add origin https://github.com/user/repo\ngit push -u origin main',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ مستودعاً على GitHub وافعل push', en: 'Create GitHub repo and push', fr: 'Créez un dépôt GitHub'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'remote add + push', en: 'remote add + push', fr: 'remote add')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'أنشئ README.md احترافي لمشروعك', en: 'Professional README', fr: 'README professionnel'), hasHomework: true, order: 4,
    );

Lesson _git5(String c) => Lesson(
      id: '${c}_l5', courseId: c,
      title: LocalizedText(ar: 'الدرس 5: أوامر متقدمة', en: 'Lesson 5: Advanced Commands', fr: 'Leçon 5: Commandes Avancées'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Stash — حفظ مؤقت:
```bash
git stash                # حفظ التعديلات مؤقتاً
git stash list           # عرض القائمة
git stash pop            # استرجاع وحذف
git stash apply          # استرجاع بدون حذف
```

### Reset — التراجع:
```bash
git reset --soft HEAD~1   # التراجع عن Commit (يبقي التغييرات في Staging)
git reset --mixed HEAD~1  # التراجع ونقل للWorking Directory
git reset --hard HEAD~1   # حذف كل شيء (!)
```

### Cherry-pick — نسخ commit محدد:
```bash
git cherry-pick abc123   # نسخ commit معين
```

### Tag — تعليم إصدار:
```bash
git tag v1.0.0           # إنشاء tag
git tag -a v1.0.0 -m "Release"  # tag مع رسالة
git push origin --tags   # رفع الـ tags
```

### .gitignore
```
node_modules/
.env
*.log
build/
```
''',
        en: 'Stash, reset, cherry-pick, tags, .gitignore.',
        fr: 'Stash, reset, cherry-pick, tags, .gitignore.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit stash\ngit checkout feature\n# work...\ngit stash pop',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'استخدم stash لحفظ تعديلات وانتقل لفرع آخر', en: 'Use stash workflow', fr: 'Utilisez stash'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'stash + checkout + pop', en: 'stash + checkout + pop', fr: 'stash + pop')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'أنشئ .gitignore لمشروع Flutter', en: 'Flutter .gitignore', fr: '.gitignore Flutter'), hasHomework: true, order: 5,
    );

Lesson _git6(String c) => Lesson(
      id: '${c}_l6', courseId: c,
      title: LocalizedText(ar: 'الدرس 6: Git Actions و GitHub Pages', en: 'Lesson 6: GitHub Actions & Pages', fr: 'Leçon 6: Actions & Pages'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### GitHub Actions — CI/CD:
```yaml
# .github/workflows/build.yml
name: Build & Test
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm install
      - run: npm test
```

### GitHub Pages — استضافة مجانية:
1. افتح Settings → Pages.
2. اختر الفرع `main` ومجلد `/docs` أو Root.
3. ستحصل على رابط `https://user.github.io/repo`.

### GitHub Releases:
```bash
git tag v1.0.0
git push origin v1.0.0
# اذهب لـ Releases على GitHub وأنشئ إصدار جديد
```
''',
        en: 'GitHub Actions CI/CD, GitHub Pages hosting, Releases.',
        fr: 'GitHub Actions CI/CD, GitHub Pages.',
      ),
      videoUrl: '',
      codeHtml: '<!-- GitHub Actions workflow example -->\nname: CI\non: push\njobs:\n  build:\n    runs-on: ubuntu-latest',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ GitHub Action يشغّل اختبارات تلقائياً', en: 'Create CI workflow', fr: 'Créez un workflow CI'), options: [], answerIndex: 0, solution: LocalizedText(ar: '.github/workflows/', en: '.github/workflows/', fr: '.github/workflows/')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'نشر موقع HTML على GitHub Pages', en: 'Deploy to GitHub Pages', fr: 'Déployez sur GitHub Pages'), hasHomework: true, order: 6,
    );

Lesson _git7(String c) => Lesson(
      id: '${c}_l7', courseId: c,
      title: LocalizedText(ar: 'الدرس 7: أفضل ممارسات Git', en: 'Lesson 7: Git Best Practices', fr: 'Leçon 7: Bonnes Pratiques'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### 1. رسائل Commit واضحة:
```
feat: إضافة نظام تسجيل دخول
fix: إصلاح خطأ في صفحة الرئيسية
docs: تحديث README
style: تنسيق الكود
refactor: إعادة هيكلة دالة الحساب
test: إضافة اختبارات
chore: تحديث الـ dependencies
```

### 2. Commits صغيرة ومحددة:
- كل commit يفعل شيء واحد فقط.
- لا تخلط تعديلات وظيفية مع تنسيق.

### 3. المراجعة قبل Commit:
```bash
git diff --staged    # راجع قبل commit
git status          // تأكد من الملفات
```

### 4. لا تفعل force push على main:
```bash
git push --force     # ⚠️ خطر!
```

### 5. استخدم Branches:
- لا تعمل مباشرة على `main`.
- ادمج عبر Pull Request مع مراجعة.

### 6. حدّث بانتظام:
```bash
git pull origin main   # قبل البدء
```
''',
        en: 'Commit messages, small commits, review, force push warning.',
        fr: 'Messages de commit, petits commits.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Commit message convention -->\nfeat: add login\nfix: resolve crash',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'راجع سجل Commits وحسّن الرسائل', en: 'Review commit history', fr: 'Révisez l\'historique'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'git log --oneline', en: 'git log --oneline', fr: 'git log')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'مسح 프로젝트 كامل — أنشئ PR واصنع Code Review', en: 'Full project cleanup', fr: 'Nettoyage complet'), hasHomework: true, order: 7,
    );

Lesson _git8(String c) => Lesson(
      id: '${c}_l8', courseId: c,
      title: LocalizedText(ar: 'الدرس 8: مشاريع عملية', en: 'Lesson 8: Practical Projects', fr: 'Leçon 8: Projets Pratiques'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### مشروع 1: Portfolio Site
```bash
mkdir portfolio && cd portfolio
git init
# أنشئ index.html و style.css
git add .
git commit -m "feat: initial portfolio"
git remote add origin https://github.com/user/portfolio.git
git push -u origin main
# أنشئ فرع gh-pages وافعل نشر
```

### مشروع 2: Collaboration Workflow
```bash
# 1. Fork المستودع
# 2. Clone لجهازك
# 3. أنشئ فرع للاختبار
# 4. اعمل التغييرات
# 5. Push لحسابك
# 6. أنشئ PR للمستودع الأصلي
```

### مشروع 3: Open Source Contribution
1. ابحث عن مشروع مفتوح المصدر.
2. اقرأ `CONTRIBUTING.md`.
3. اختر Issue مفتوح.
4. أنشئ فرع، اعمل الحل، أنشئ PR.

### أوامر مفيدة:
```bash
git log --author="اسمك"    # commits لشخص محدد
git shortlog -sn           # عدد commits لكل شخص
git blame file.txt         # من كتب كل سطر
git bisect start           # البحث عن commit خاطئ
```
''',
        en: 'Portfolio site, collaboration workflow, open source contribution.',
        fr: 'Site portfolio, workflow collaboration, open source.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Terminal -->\ngit log --oneline --graph --all',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ مشروع ونشره على GitHub', en: 'Create and publish project', fr: 'Créez et publiez'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'init + push + pages', en: 'init + push + pages', fr: 'init + push')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'ساهم في مشروع مفتوح المصدر على GitHub', en: 'Contribute to open source', fr: 'Contribuez en open source'), hasHomework: true, order: 8,
    );

// ————————————————————————————————————————————————————————————————————
// React Lessons — detailed
// ————————————————————————————————————————————————————————————————————

Lesson _react1(String c) => Lesson(
      id: '${c}_l1', courseId: c,
      title: LocalizedText(ar: 'الدرس 1: مقدمة في React', en: 'Lesson 1: Intro to React', fr: 'Leçon 1: Intro React'),
      content: LocalizedText(ar: r'''
## 🎯 الهدف
فهم لماذا React وكيف يعمل.

## 📖 الشرح
**React** هو مكتبة (Library) لبناء واجهات المستخدم ت развّرها Facebook (Meta).

### لماذا React؟
- **Component-based:** الواجهة مقسمة لأجزاء قابلة لإعادة الاستخدام.
- **Virtual DOM:** تحديث سريع وفعال.
- **One-way data flow:** بيانات تتبع سهلاً.
- **Ecosystem كبير:** React Router, Redux, Next.js.

### إنشاء مشروع:
```bash
npx create-react-app my-app
cd my-app
npm start
```

### هيكل المشروع:
```
src/
  App.js         — المكون الرئيسي
  App.css        — التنسيقات
  index.js       — نقطة الدخول
  components/    — المكونات
```

### JSX — JavaScript XML:
```jsx
const element = <h1>مرحبا بالعالم</h1>;
const App = () => {
  return (
    <div>
      <h1>مرحبا</h1>
      <p>أنا أتعلم React</p>
    </div>
  );
};
```
''',
        en: 'Why React, create-react-app, JSX, component structure.',
        fr: 'Pourquoi React, create-react-app, JSX.',
      ),
      videoUrl: '',
      codeHtml: '<div id="root"></div>\n<script src="app.js"></script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ مشروع React جديد', en: 'Create React project', fr: 'Créez un projet React'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'npx create-react-app', en: 'npx create-react-app', fr: 'npx create-react-app')),
      questions: [LessonQuestion(question: LocalizedText(ar: 'ما الفرق بين React ومكتبة أخرى مثل jQuery؟', en: 'React vs jQuery?', fr: 'React vs jQuery?'), solution: LocalizedText(ar: 'React: component-based + virtual DOM، jQuery: تعديل DOM مباشرة', en: 'React is component-based, jQuery modifies DOM directly', fr: 'React: composants, jQuery: DOM direct'))],
      homeworkPrompt: LocalizedText(ar: 'أنشئ مشروع React و عدّل App.js لعرض اسمك', en: 'Customize React app', fr: 'Personnalisez l\'app'), hasHomework: true, order: 1,
    );

Lesson _react2(String c) => Lesson(
      id: '${c}_l2', courseId: c,
      title: LocalizedText(ar: 'الدرس 2: Components والخصائص (Props)', en: 'Lesson 2: Components & Props', fr: 'Leçon 2: Composants & Props'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Types of Components:
```jsx
// 1. Function Component (الأكثر شيوعاً)
function Welcome({ name, age }) {
  return <h1>مرحبا {name}، عمرك {age}</h1>;
}

// 2. Arrow Function
const Welcome = ({ name, age }) => (
  <h1>مرحبا {name}، عمرك {age}</h1>
);
```

### Props — خصائص تُمرَّر من الأب:
```jsx
function App() {
  return (
    <div>
      <Welcome name="أحمد" age={25} />
      <Welcome name="سارة" age={22} />
    </div>
  );
}
```

### Children Prop:
```jsx
function Card({ title, children }) {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div>{children}</div>
    </div>
  );
}

<Card title="ملاحظة">
  <p>هذا محتوى البطاقة</p>
</Card>
```

### Props передаются للأعلى لأسفل فقط (One-way).
''',
        en: 'Function components, props, children prop.',
        fr: 'Composants fonction, props, children.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction App() {\n  return <Welcome name="Ahmed" />;\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ مكون UserCard يستقبل اسم وصورة', en: 'Create UserCard component', fr: 'Composant UserCard'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'function UserCard({name, avatar})', en: 'function UserCard({name, avatar})', fr: 'function UserCard')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'أنشئ 3 مكونات: Header, Content, Footer', en: '3 components layout', fr: '3 composants'), hasHomework: true, order: 2,
    );

Lesson _react3(String c) => Lesson(
      id: '${c}_l3', courseId: c,
      title: LocalizedText(ar: 'الدرس 3: الحالة (State) والتفاعل', en: 'Lesson 3: State & Interaction', fr: 'Leçon 3: State & Interaction'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### useState Hook:
```jsx
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>العداد: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
    </div>
  );
}
```

### قواعد Hooks:
1. استخدمها في أعلى Component فقط.
2. لا تضعها داخل if/for/function.
3. استخدمها في Function Components فقط.

### تحديث State بناءً على الحالة السابقة:
```jsx
setCount(prev => prev + 1);  // ✓ آمن
setCount(count + 1);         // ⚠️ قد يسبب خطأ
```

### State مع Object:
```jsx
const [user, setUser] = useState({ name: "", age: 0 });

// تحديث خاصية واحدة فقط
setUser(prev => ({ ...prev, name: "أحمد" }));
```
''',
        en: 'useState hook, rules of hooks, updating state.',
        fr: 'Hook useState, règles des hooks.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  return <button onClick={() => setCount(count+1)}>{count}</button>;\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ عداد بزررين + و -', en: 'Counter with +/- buttons', fr: 'Compteur +/-'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'useState + onClick', en: 'useState + onClick', fr: 'useState')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق Toggle — يبدّل بين فاتح/داكن', en: 'Dark mode toggle', fr: 'Toggle sombre'), hasHomework: true, order: 3,
    );

Lesson _react4(String c) => Lesson(
      id: '${c}_l4', courseId: c,
      title: LocalizedText(ar: 'الدرس 4: القوائم والبحث', en: 'Lesson 4: Lists & Filtering', fr: 'Leçon 4: Listes & Filtrage'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### عرض القوائم:
```jsx
const users = [
  { id: 1, name: "أحمد" },
  { id: 2, name: "سارة" },
  { id: 3, name: "محمد" }
];

function UserList() {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

⚠️ **الـ `key` ضروري** — يساعد React على تتبع العناصر بكفاءة.

### التصفية:
```jsx
const [search, setSearch] = useState("");
const filtered = users.filter(u =>
  u.name.includes(search)
);
```

### شروط عرض مشروطة:
```jsx
{isLoggedIn ? <Welcome /> : <Login />}
{items.length === 0 && <p>لا توجد عناصر</p>}
```
''',
        en: 'Render lists with map, key prop, filtering.',
        fr: 'Afficher listes avec map, clé, filtrage.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction App() {\n  const items = ["HTML", "CSS", "JS"];\n  return <ul>{items.map(i => <li key={i}>{i}</li>)}</ul>;\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ قائمة مهام قابلة للحذف', en: 'Deleteable todo list', fr: 'Liste supprimable'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'filter + map + key', en: 'filter + map + key', fr: 'filter + map')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'لوحة مهام مع إضافة وحذف وتصفية', en: 'Todo with add/delete/filter', fr: 'Todo avec filtre'), hasHomework: true, order: 4,
    );

Lesson _react5(String c) => Lesson(
      id: '${c}_l5', courseId: c,
      title: LocalizedText(ar: 'الدرس 5: النماذج (Forms)', en: 'Lesson 5: Forms', fr: 'Leçon 5: Formulaires'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### Controlled Inputs:
```jsx
function LoginForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log(email, password);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={e => setEmail(e.target.value)}
        placeholder="البريد الإلكتروني"
      />
      <input
        type="password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        placeholder="كلمة المرور"
      />
      <button type="submit">تسجيل الدخول</button>
    </form>
  );
}
```

### Multiple Fields:
```jsx
const [form, setForm] = useState({ name: "", email: "" });

const handleChange = (e) => {
  setForm({ ...form, [e.target.name]: e.target.value });
};
```

### textarea و select:
```jsx
<textarea value={bio} onChange={e => setBio(e.target.value)} />
<select value={city} onChange={e => setCity(e.target.value)}>
  <option value="algiers">الجزائر</option>
  <option value="oran">وهران</option>
</select>
```
''',
        en: 'Controlled inputs, form submission, multiple fields.',
        fr: 'Inputs contrôlés, soumission formulaire.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction Form() {\n  const [val, setVal] = useState("");\n  return <input value={val} onChange={e => setVal(e.target.value)} />;\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ نموذج تسجيل دخول متكامل', en: 'Login form', fr: 'Formulaire de connexion'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'controlled input + onSubmit', en: 'controlled + onSubmit', fr: 'contrôlé')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'نموذج تسجيل مستخدم مع تحقق من البيانات', en: 'Registration form with validation', fr: 'Formulaire avec validation'), hasHomework: true, order: 5,
    );

Lesson _react6(String c) => Lesson(
      id: '${c}_l6', courseId: c,
      title: LocalizedText(ar: 'الدرس 6: useEffect والبيانات', en: 'Lesson 6: useEffect & Data', fr: 'Leçon 6: useEffect & Données'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### useEffect — تنفيذ أ_effects بعد التصيير:
```jsx
import { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    // يُنفّذ بعد كل تصيير
    fetchUser(userId).then(data => setUser(data));
  }, [userId]); // يُنفّذ فقط عند تغيير userId

  if (!user) return <p>جاري التحميل...</p>;
  return <h1>{user.name}</h1>;
}
```

### Cleanup:
```jsx
useEffect(() => {
  const timer = setInterval(() => console.log("tick"), 1000);
  return () => clearInterval(timer); // cleanup
}, []);
```

### Dependency Array:
- `[]` — مرة واحدة بعد التحميل فقط.
- `[dep1, dep2]` — عند تغيير أي依赖。
- بدون array — بعد كل تصيير (⚠️小心).

### جلب البيانات:
```jsx
const [data, setData] = useState([]);
const [loading, setLoading] = useState(true);
const [error, setError] = useState(null);

useEffect(() => {
  fetch(url)
    .then(res => res.json())
    .then(data => setData(data))
    .catch(err => setError(err))
    .finally(() => setLoading(false));
}, []);
```
''',
        en: 'useEffect, cleanup, dependency array, fetching data.',
        fr: 'useEffect, cleanup, dépendances, récupération de données.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nuseEffect(() => {\n  document.title = `Count: \${count}`;\n}, [count]);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'جلب بيانات من API وعرضها', en: 'Fetch data from API', fr: 'Récupérez des données'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'useEffect + fetch', en: 'useEffect + fetch', fr: 'useEffect + fetch')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق طقس يجلب بيانات من API', en: 'Weather app with API', fr: 'Appli météo'), hasHomework: true, order: 6,
    );

Lesson _react7(String c) => Lesson(
      id: '${c}_l7', courseId: c,
      title: LocalizedText(ar: 'الدرس 7: التصيير الشرطي وال configure', en: 'Lesson 7: Conditional & Styling', fr: 'Leçon 7: Conditionnel & Style'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### التصيير الشرطي:
```jsx
function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  // الطريقة 1: ternary
  return isLoggedIn ? <Dashboard /> : <Login />;

  // الطريقة 2: && operator
  return <div>{isLoggedIn && <Logout />}</div>;

  // الطريقة 3: variable
  let content;
  if (isLoggedIn) content = <Dashboard />;
  else content = <Login />;
  return content;
}
```

### التنسيق في React:
```jsx
// 1. Inline styles (كائن JS)
<h1 style={{ color: "red", fontSize: "24px" }}>مرحبا</h1>

// 2. CSS عادي
import "./App.css";
<h1 className="title">مرحبا</h1>

// 3. تغيير ديناميكي
<button style={{
  backgroundColor: isActive ? "green" : "gray"
}}>اضغط</button>
```

### Conditional Classes:
```jsx
<button className={`btn ${isActive ? "active" : ""}`}>
  اضغط
</button>
```
''',
        en: 'Conditional rendering, inline styles, CSS classes.',
        fr: 'Rendu conditionnel, styles inline.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction Greeting({ name }) {\n  return name ? <h1>مرحبا {name}</h1> : <h1>زائر</h1>;\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ واجهة تتحول بين فاتح/داكن', en: 'Light/Dark theme UI', fr: 'Interface thème'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'ternary + inline style', en: 'ternary + inline style', fr: 'ternaire')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'بطاقة منتج بتقييم نجوم ديناميكي', en: 'Product card with star rating', fr: 'Carte produit avec étoiles'), hasHomework: true, order: 7,
    );

Lesson _react8(String c) => Lesson(
      id: '${c}_l8', courseId: c,
      title: LocalizedText(ar: 'الدرس 8: إدارة الحالة (useReducer)', en: 'Lesson 8: useReducer', fr: 'Leçon 8: useReducer'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### متى نستخدم useReducer؟
- عندما يكون الحالة معقدة (عدة خصائص).
- عندما تكون التحديثات معقدة (تعتمد على الحالة السابقة).

### المثال الأساسي:
```jsx
const initialState = { count: 0 };

function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    case 'reset':
      return initialState;
    default:
      throw new Error();
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, initialState);
  return (
    <div>
      Count: {state.count}
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
    </div>
  );
}
```

### التمرير بالبيانات:
```jsx
dispatch({ type: 'add', payload: { name: "أحمد" } });
```
''',
        en: 'useReducer for complex state, dispatch, actions.',
        fr: 'useReducer pour état complexe.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nconst [state, dispatch] = useReducer(reducer, init);\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ عداد بـ useReducer', en: 'Counter with useReducer', fr: 'Compteur useReducer'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'useReducer + dispatch', en: 'useReducer + dispatch', fr: 'useReducer')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق مهام بـ useReducer', en: 'Todo with useReducer', fr: 'Todo avec useReducer'), hasHomework: true, order: 8,
    );

Lesson _react9(String c) => Lesson(
      id: '${c}_l9', courseId: c,
      title: LocalizedText(ar: 'الدرس 9: Context API', en: 'Lesson 9: Context API', fr: 'Leçon 9: API Context'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### المشكلة: Props Drilling
تمرير Props عبر很多 أبناء tucked وصل للعنصر المطلوب.

### الحل: Context
```jsx
const ThemeContext = createContext();

function App() {
  const [theme, setTheme] = useState("light");

  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      <Header />
      <Content />
    </ThemeContext.Provider>
  );
}

// في أي عنصرchild
function Header() {
  const { theme, setTheme } = useContext(ThemeContext);
  return (
    <header style={{ background: theme === "dark" ? "#333" : "#fff" }}>
      <button onClick={() => setTheme(theme === "light" ? "dark" : "light")}>
        تبديل المظهر
      </button>
    </header>
  );
}
```

### مثال عملي: تسجيل دخول
```jsx
const AuthContext = createContext();

function App() {
  const [user, setUser] = useState(null);

  const login = (userData) => setUser(userData);
  const logout = () => setUser(null);

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      <Navigation />
      <Main />
    </AuthContext.Provider>
  );
}
```
''',
        en: 'Context API to avoid props drilling.',
        fr: 'API Context pour éviter props drilling.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nconst Ctx = createContext();\n<Ctx.Provider value={val}><Child /></Ctx.Provider>\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ Context للمظهر (فاتح/داكن)', en: 'Theme context', fr: 'Contexte thème'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'createContext + useContext', en: 'createContext + useContext', fr: 'createContext')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق Auth بـ Context: تسجيل دخول وخروج وحماية صفحات', en: 'Auth with Context', fr: 'Auth avec Context'), hasHomework: true, order: 9,
    );

Lesson _react10(String c) => Lesson(
      id: '${c}_l10', courseId: c,
      title: LocalizedText(ar: 'الدرس 10: React Router', en: 'Lesson 10: React Router', fr: 'Leçon 10: React Router'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### التثبيت:
```bash
npm install react-router-dom
```

### الإعداد:
```jsx
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';

function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">الرئيسية</Link>
        <Link to="/about">من نحن</Link>
        <Link to="/contact">تواصل معنا</Link>
      </nav>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="*" element={<NotFound />} />
      </Routes>
    </BrowserRouter>
  );
}
```

### الروابط الديناميكية:
```jsx
<Route path="/user/:id" element={<UserProfile />} />

function UserProfile() {
  const { id } = useParams();
  return <h1>الملف الشخصي: {id}</h1>;
}
```

### التنقل البرمجي:
```jsx
import { useNavigate } from 'react-router-dom';

function Login() {
  const navigate = useNavigate();
  const handleLogin = () => {
    // بعد تسجيل الدخول
    navigate("/dashboard");
  };
}
```

### الحماية (Protected Routes):
```jsx
function ProtectedRoute({ children }) {
  const { user } = useAuth();
  return user ? children : <Navigate to="/login" />;
}
```
''',
        en: 'Routes, links, useParams, useNavigate, protected routes.',
        fr: 'Routes, links, useParams, routes protégées.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\n<BrowserRouter>\n  <Routes>\n    <Route path="/" element={<Home />} />\n  </Routes>\n</BrowserRouter>\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ موقع بـ 3 صفحات متنقلة', en: 'Multi-page site', fr: 'Site multi-pages'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'BrowserRouter + Routes', en: 'BrowserRouter + Routes', fr: 'BrowserRouter')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'تطبيق مدونة مع صفحة رئيسية وصفحات مقالات', en: 'Blog app with routing', fr: 'Blog avec routage'), hasHomework: true, order: 10,
    );

Lesson _react11(String c) => Lesson(
      id: '${c}_l11', courseId: c,
      title: LocalizedText(ar: 'الدرس 11: Custom Hooks', en: 'Lesson 11: Custom Hooks', fr: 'Leçon 11: Hooks Personnalisés'),
      content: LocalizedText(ar: r'''
## 📖 الشرح
### ما هو Custom Hook؟
دالة تبدأ بـ `use` تอกع logique مشتركة بين المكونات.

### مثال 1: useLocalStorage
```jsx
function useLocalStorage(key, initialValue) {
  const [value, setValue] = useState(() => {
    const saved = localStorage.getItem(key);
    return saved ? JSON.parse(saved) : initialValue;
  });

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue];
}

// الاستخدام
function App() {
  const [theme, setTheme] = useLocalStorage("theme", "light");
  return <button onClick={() => setTheme(theme === "light" ? "dark" : "light")}>{theme}</button>;
}
```

### مثال 2: useFetch
```jsx
function useFetch(url) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(data => setData(data))
      .catch(err => setError(err))
      .finally(() => setLoading(false));
  }, [url]);

  return { data, loading, error };
}

// الاستخدام
function UserList() {
  const { data, loading, error } = useFetch("/api/users");
  if (loading) return <p>جاري التحميل...</p>;
  return data.map(user => <p key={user.id}>{user.name}</p>);
}
```

### مثال 3: useToggle
```jsx
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = () => setValue(v => !v);
  return [value, toggle];
}
```
''',
        en: 'Custom hooks: useLocalStorage, useFetch, useToggle.',
        fr: 'Hooks personnalisés.',
      ),
      videoUrl: '',
      codeHtml: '<script type="text/babel">\nfunction useCounter(init) {\n  const [count, setCount] = useState(init);\n  const inc = () => setCount(c => c + 1);\n  return { count, inc };\n}\n</script>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'أنشئ hook مخصص لجلب البيانات', en: 'useFetch custom hook', fr: 'Hook useFetch'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'use + useEffect + useState', en: 'use + useEffect + useState', fr: 'use + useEffect')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'أنشئ 3 custom hooks واستخدمها في مشروع', en: '3 custom hooks project', fr: '3 hooks personnalisés'), hasHomework: true, order: 11,
    );

Lesson _react12(String c) => Lesson(
      id: '${c}_l12', courseId: c,
      title: LocalizedText(ar: 'الدرس 12: مشروع تطبيقي نهائي', en: 'Lesson 12: Final Project', fr: 'Leçon 12: Projet Final'),
      content: LocalizedText(ar: r'''
## 🎯 المشروع: تطبيق مهام (Task Manager)

### الميزات:
- إضافة / حذف / تعديل مهام
- تصفية حسب الحالة (مكتملة / جارية / الكل)
- حفظ في localStorage
- تنقل بين الصفحات
- تصميم متجاوب

### الهيكل:
```
src/
  components/
    TaskForm.js
    TaskItem.js
    TaskList.js
    Filter.js
  hooks/
    useLocalStorage.js
    useTasks.js
  pages/
    Home.js
    About.js
  App.js
  index.js
```

### الخطوات:
1. إنشاء المشروع وتنصيب المكتبات.
2. بناء Custom Hooks أولاً.
3. إنشاء المكونات الأساسية.
4. ربط النماذج بالحالة.
5. إضافة التصفية.
6. حفظ البيانات محلياً.
7. إضافة التنقل.
8. التنسيق النهائي.
9. اختبار وتحسين.

### النصيحة:
- ابدأ بسيطاً وأضف التحسينات تدريجياً.
- استخدم React Developer Tools لل debugging.
- اكتب كود نظيف ومُعلّم.
''',
        en: 'Build a complete task manager app with all learned concepts.',
        fr: 'Construisez une appli tâches complète.',
      ),
      videoUrl: '',
      codeHtml: '<!-- Task Manager App -->\n<div id="root"></div>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'ابدأ بناء مشروع المهام', en: 'Start task manager', fr: 'Commencez le projet'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'npm create-react-app', en: 'create-react-app', fr: 'create-react-app')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'أكمل مشروع Task Manager ونشره على GitHub', en: 'Complete and publish task manager', fr: 'Complétez et publiez'), hasHomework: true, order: 12,
    );

Lesson _genericLesson(String courseId, String prefix, int n, String arSuffix, String enSuffix) => Lesson(
      id: '${courseId}_l$n',
      courseId: courseId,
      title: LocalizedText(ar: 'الدرس $n: $prefix — $arSuffix $n', en: 'Lesson $n: $prefix - $enSuffix $n', fr: 'Leçon $n: $prefix'),
      content: LocalizedText(ar: 'محتوى $prefix درس $n — مستوحى من ملفات PDF المرفوعة. سيتم تطويره بالتفصيل.', en: 'Content for $prefix lesson $n', fr: 'Contenu $prefix leçon $n'),
      videoUrl: '',
      codeHtml: '<!-- مثال $prefix $n -->\n<div>محتوى</div>',
      codeDart: '',
      exercise: Exercise(question: LocalizedText(ar: 'تمرين $n', en: 'Exercise $n', fr: 'Exercice $n'), options: [], answerIndex: 0, solution: LocalizedText(ar: 'الحل $n', en: 'Solution $n', fr: 'Solution $n')),
      questions: [],
      homeworkPrompt: LocalizedText(ar: 'واجب $n', en: 'Homework $n', fr: 'Devoir $n'),
      hasHomework: true,
      order: n,
    );
