import 'package:flutter/foundation.dart';

/// A [ActionMethodPreProcessor] does something with [ActionMethod] parameters, for a given method parameter signature, before the [ActionMethodProcessor] is called to process the method result.
///
/// [ActionMethodPreProcessor]s are functions that:
///  - are preceded with a [ActionMethodPreProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ServiceObjectActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodPreProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.
class ActionMethodPreProcessor {
  /// A number to set the index compared to other [ActionParameterAction]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  /// If the [ActionMethod] must have a [ProcessDirectly] annotation, in order to be pre-processed by the [ActionMethodPreProcessor]. Default=false
  final bool actionMethodMustHaveProcessDirectlyAnnotation;

  const ActionMethodPreProcessor({this.index,
      this.actionMethodMustHaveProcessDirectlyAnnotation = false});
}

/// A [ActionMethodProcessor] processed the [ActionMethod] results (e.g. displays the results to the user or sends back an reply)
///
///  [ActionMethodProcessor]s are functions that:
///  - are preceded with a [ActionMethodProcessor] annotation
///  - are public (function name does not start with underscore)
///  - with return type void
///  - with parameters: [ActionMethodPreProcessorContext] followed by zero or more parameters with the same type of the  [ActionMethod] that it supports.
///
///  The [ReflectCodeGenerator] will look for all the [ActionMethodProcessor]s. These will be used to generate [ActionMethodInfo]s.
///
/// See the annotated functions in this file for the default implementations and inspiration.

class ActionMethodProcessor {
  /// A number to set the index compared to other [ActionMethodProcessor]s.
  /// This becomes important if multiple [ActionParameterAction]s handle the same [Type]s and annotations
  /// A double is used so that there are endless numbers to put between to existing numbers.
  final double index;

  const ActionMethodProcessor(this.index);
}

/// Annotation to indicate that [ActionMethodInfo.preProcess] needs to call [ActionMethodInfo.process] directly.
class ProcessDirectly {
  const ProcessDirectly();
}

/// The [DomainClass] annotation is only used by the [ReflectCodeGeneration] to indicate that a method parameter or return value is a [DomainObject].
/// See:
/// - [ActionMethodPreProcessor]s
/// - [ActionMethodProcessor]s

class DomainClass {
  const DomainClass();
}

/// The [Translation] annotation is used to add or correct a translatable text.
/// It is an alternative for the intl package (https://pub.dev/packages/intl).
/// The key and English text will automatically be stored in [\lib\translations\translations.csv].
/// You can than later add other languages by adding another column.
/// The key will be the library name + annotation path + suffix. All words will be in lower camelCase and all words will be separated with dots.
///
/// You can place a [Translation] annotation before a class, method or property declaration.
///
/// e.g.:
///
/// import 'package:reflect_framework/reflect_annotations.dart';
///
/// //library acme_domain
///
/// class Product {
///
///   // We add a Translation annotation here otherwise the Reflect application would show this property as 'Ups code' instead of 'UPS code'
///   // This will create key: 'acmeDomain.product.upsCode' with English value 'UPS code'
///   @Translation(englishText: 'UPS code')
///   String get upsCode {
///     return '<a UPS code>';//for example only
///   }
///
///   // We add a Translation annotation here so that we can use a translatable text in our text, with a key that refers to this property
///   // this will create key: 'acmeDomain.product.availability.soldOut' with English value 'Sold out' to be used in the code
///   @Translation(keySuffix: 'soldOut', englishText: 'Sold out')
///   String get availability {
///     return Translations.forThisApp().acmeDomain.product.availability.soldOut;//to demonstrate how to use the translation
///   }
/// }
class Translation {
  /// If keySuffix=null: than the translation refers to a library member (Class, Method, Property)
  /// If keySuffix=(a camelCase string): than the translation refers to a translatable string that could be used in your dart code
  final String keySuffix;
  final String englishText;
  const Translation({this.keySuffix, @required this.englishText});
}