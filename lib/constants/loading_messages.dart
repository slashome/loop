const Map<String, List<String>> loadingMessagesByLocale = {
  "en": [
    "I'm breaking the habit tonight",
  ],
  "fr": [
    "Résiste, prouve que tu existes.",
    "C'est en forgeant qu'on devient forgeron.",
    "J'irai au bout de mes reves.",
    "Il n'y a pas de hasard, il n'y a que des rendez-vous.",
    "La liberte, c'est la discipline que l'on s'impose.",
    "Agir, c'est se liberer.",
    "Ce n'est pas le doute qui rend fou, c'est la certitude.",
    "Fais de ta vie un reve, et d'un reve une realite.",
  ],
};

List<String> loadingMessagesForLocaleTag(String localeTag) {
  final String normalized = localeTag.replaceAll("_", "-").toLowerCase();
  final List<String>? byFullTag = loadingMessagesByLocale[normalized];
  if (byFullTag != null) {
    return byFullTag;
  }

  final String languageCode =
      normalized.contains("-") ? normalized.split("-").first : normalized;
  return loadingMessagesByLocale[languageCode] ?? loadingMessagesByLocale["en"]!;
}
