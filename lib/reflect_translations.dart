//TODO reuse in TranslationBuilder
import 'package:analyzer/dart/element/element.dart';

class TranslationFactory {
  static final invalidCharacters = RegExp('[^a-z0-9\.]');
  static final precedingDots = RegExp('^\.+');
  static final trailingDots = RegExp('\.+\$');

  static String createKeyForElement(Element element) {
    String key = _createElementKey(element).toLowerCase();
    return key;
  }

  static String createKeyForElementWithSuffix(
      Element element, String keySuffix) {
    String key =
        createKeyForElement(element) + '.' + _validKeySuffix(keySuffix);
    return key;
  }

  static String _validKeySuffix(String keySuffix) {
    return keySuffix
        .toLowerCase()
        .replaceAll(invalidCharacters, '')
        .replaceAll(precedingDots, '')
        .replaceAll(trailingDots, '')
        .replaceAll('..', '.');
  }

  static String _createElementKey(Element element) {
    var parent = element.enclosingElement;
    if (element is CompilationUnitElement) {
      return _createLibraryKey(element);
    } else if (parent == null) {
      return element.name;
    } else {
      return _createElementKey(parent) + '.' + element.name; //recursive call
    }
  }

  static String _createLibraryKey(CompilationUnitElement element) {
    String name = element.toString();
    String key = name
        .replaceAll(RegExp('^.*lib/'), '')
        .replaceAll(RegExp('\.dart\$'), '')
        .replaceAll('_', '');
    return key;
  }

  // TODO for service class
  // TODO Translate annotations
  static createEnglishTextForElement(Element element) {
    String text = element.name;
    StringBuffer sentence = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      String nextChar = i + 1 == text.length ? null : text[i + 1];
      sentence.write(i == 0 ? char.toUpperCase() : char.toLowerCase());

      if (nextChar != null) {
        bool isEndOfWord =
            char.toLowerCase() == char && nextChar.toUpperCase() == nextChar;

        if (isEndOfWord) {
          sentence.write(' ');
        }
      }
    }
    return sentence.toString();
  }
}
