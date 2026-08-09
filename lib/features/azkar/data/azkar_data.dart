class AzkarItem {
  final String text;
  final int repeat;
  final String? source;

  const AzkarItem({required this.text, required this.repeat, this.source});
}

class AzkarCategory {
  final String title;
  final List<AzkarItem> items;
  const AzkarCategory({required this.title, required this.items});
}

const AzkarCategory morningAzkar = AzkarCategory(
  title: 'أذكار الصباح',
  items: [
    AzkarItem(
      text:
          'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، '
          'له الملك وله الحمد وهو على كل شيء قدير.',
      repeat: 1,
      source: 'رواه أبو داود',
    ),
    AzkarItem(
      text: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
      repeat: 1,
      source: 'رواه الترمذي',
    ),
    AzkarItem(text: 'سبحان الله وبحمده', repeat: 100),
    AzkarItem(text: 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.', repeat: 1),
    AzkarItem(
      text: 'رضيت بالله ربًا، وبالإسلام دينًا، وبمحمد صلى الله عليه وسلم نبيًا.',
      repeat: 3,
      source: 'رواه أبو داود والترمذي',
    ),
    AzkarItem(
      text:
          'اللهم عافني في بدني، اللهم عافني في سمعي، اللهم عافني في بصري، '
          'لا إله إلا أنت.',
      repeat: 3,
      source: 'رواه أبو داود',
    ),
  ],
);

const AzkarCategory eveningAzkar = AzkarCategory(
  title: 'أذكار المساء',
  items: [
    AzkarItem(
      text:
          'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، '
          'له الملك وله الحمد وهو على كل شيء قدير.',
      repeat: 1,
      source: 'رواه أبو داود',
    ),
    AzkarItem(
      text: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير.',
      repeat: 1,
      source: 'رواه الترمذي',
    ),
    AzkarItem(text: 'سبحان الله وبحمده', repeat: 100),
    AzkarItem(
      text: 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.',
      repeat: 1,
    ),
    AzkarItem(
      text:
          'أعوذ بكلمات الله التامات من شر ما خلق.',
      repeat: 3,
      source: 'رواه مسلم',
    ),
    AzkarItem(
      text: 'اللهم إني أمسيت أشهدك وأشهد حملة عرشك وملائكتك وجميع خلقك، أنك أنت الله لا إله إلا أنت وحدك لا شريك لك، وأن محمدًا عبدك ورسولك.',
      repeat: 4,
      source: 'رواه أبو داود',
    ),
  ],
);

const AzkarCategory sleepAzkar = AzkarCategory(
  title: 'أذكار النوم',
  items: [
    AzkarItem(
      text: 'باسمك اللهم أموت وأحيا.',
      repeat: 1,
      source: 'رواه البخاري',
    ),
    AzkarItem(
      text:
          'اللهم قني عذابك يوم تبعث عبادك.',
      repeat: 3,
      source: 'رواه أبو داود والترمذي',
    ),
    AzkarItem(text: 'سبحان الله', repeat: 33),
    AzkarItem(text: 'الحمد لله', repeat: 33),
    AzkarItem(text: 'الله أكبر', repeat: 34),
    AzkarItem(
      text:
          'اللهم أسلمت نفسي إليك، وفوضت أمري إليك، وألجأت ظهري إليك، رغبة '
          'ورهبة إليك، لا ملجأ ولا منجى منك إلا إليك، آمنت بكتابك الذي أنزلت، '
          'وبنبيك الذي أرسلت.',
      repeat: 1,
      source: 'رواه البخاري ومسلم',
    ),
  ],
);

const AzkarCategory travelAzkar = AzkarCategory(
  title: 'أذكار السفر',
  items: [
    AzkarItem(
      text:
          'الله أكبر، الله أكبر، الله أكبر، سبحان الذي سخر لنا هذا وما كنا له '
          'مقرنين وإنا إلى ربنا لمنقلبون.',
      repeat: 1,
      source: 'رواه مسلم',
    ),
    AzkarItem(
      text:
          'اللهم إنا نسألك في سفرنا هذا البر والتقوى، ومن العمل ما ترضى، '
          'اللهم هوّن علينا سفرنا هذا واطوِ عنا بعده.',
      repeat: 1,
      source: 'رواه مسلم',
    ),
    AzkarItem(
      text:
          'اللهم أنت الصاحب في السفر، والخليفة في الأهل، اللهم إني أعوذ بك من '
          'وعثاء السفر، وكآبة المنظر، وسوء المنقلب في المال والأهل.',
      repeat: 1,
      source: 'رواه مسلم',
    ),
  ],
);

const AzkarCategory prayerAzkar = AzkarCategory(
  title: 'أذكار الصلاة',
  items: [
    AzkarItem(text: 'أستغفر الله، أستغفر الله، أستغفر الله', repeat: 1, source: 'رواه مسلم'),
    AzkarItem(
      text:
          'اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام.',
      repeat: 1,
      source: 'رواه مسلم',
    ),
    AzkarItem(text: 'سبحان الله', repeat: 33),
    AzkarItem(text: 'الحمد لله', repeat: 33),
    AzkarItem(text: 'الله أكبر', repeat: 33),
    AzkarItem(
      text:
          'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
      repeat: 1,
      source: 'رواه مسلم',
    ),
  ],
);

const List<AzkarCategory> azkarCategories = [
  morningAzkar,
  eveningAzkar,
  sleepAzkar,
  travelAzkar,
  prayerAzkar,
];

const List<String> azkarCategoryNames = [
  'أذكار الصباح',
  'أذكار المساء',
  'أذكار النوم',
  'أذكار السفر',
  'أذكار الصلاة',
];
