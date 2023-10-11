import 'dart:math';

List<int> generateRandomIntegers(int n, int max, {int min = 0}) {
  final random = Random();
  final List<int> list = [];
  while (list.length < n) {
    final r = random.nextInt(max - min) + min;
    if (!list.contains(r)) {
      list.add(r);
    }
  }
  return list;
}

String getNormifiedString(String str) {
  return str
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^\w\s]+'), '')
      .withoutDiacriticalMarks;
}

extension DiacriticsAwareString on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);
}
