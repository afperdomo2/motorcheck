/// Normaliza texto para búsquedas tolerantes a mayúsculas y acentos.
String normalizeForSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
