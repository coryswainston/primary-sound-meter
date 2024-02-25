class Song {
  final String title;
  final List<String> lines;
  final List<String> pictures;

  const Song({
    required this.title,
    required this.lines,
    required this.pictures,
  }) : assert(lines.length == pictures.length);
}

final nephisCourage1 = Song(
  title: 'Nephi\'s Courage (verse 1)',
  lines: [
    'The Lord commanded Nephi\nto go and get the plates',
    'From the wicked Laban\ninside the city gates.',
    'Laman and Lemuel\nwere both afraid to try.',
    'Nephi was courageous.\nThis was his reply:',
    'I will go; I will do\nthe thing the Lord commands.',
    'I know the Lord provides a way;\nHe wants me to obey.',
    'I will go; I will do\nthe thing the Lord commands.',
    'I know the Lord provides a way;\nHe wants me to obey.',
  ],
  pictures: [
    'nephis_courage_1_1.png',
    'nephis_courage_1_2.png',
    'nephis_courage_1_3.png',
    'nephis_courage_1_4.png',
    'nephis_courage_1_5.png',
    'nephis_courage_1_7.png',
    'nephis_courage_1_7.png',
    'nephis_courage_1_8.png',
  ],
);

final nephisCourage2 = Song(
  title: 'Nephi\'s Courage (verse 2)',
  lines: [
    'The Lord commanded Nephi\nto go and build a boat.',
    'Nephi’s older brothers\nbelieved it would not float.',
    'Laughing and mocking,\nthey said he should not try.',
    'Nephi was courageous.\nThis was his reply:',
    'I will go; I will do\nthe thing the Lord commands.',
    'I know the Lord provides a way;\nHe wants me to obey.',
    'I will go; I will do\nthe thing the Lord commands.',
    'I know the Lord provides a way;\nHe wants me to obey.',
  ],
  pictures: [
    'nephis_courage_2_1.png',
    'nephis_courage_2_2.png',
    'nephis_courage_2_3.png',
    'nephis_courage_2_4.png',
    'nephis_courage_2_5.png',
    'nephis_courage_2_6.png',
    'nephis_courage_2_7.png',
    'nephis_courage_2_8.png',
  ],
);
