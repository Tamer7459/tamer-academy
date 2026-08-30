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
