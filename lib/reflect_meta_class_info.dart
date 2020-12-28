import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ClassInfo {
  static const typeAttribute = 'type';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final TypeInfo type;
  final List<AnnotationInfo> annotations;
  final List<MethodInfo> methods;
  final List<PropertyInfo> properties;

  static bool isNeeded(ClassElement element) {
    if (!element.isPublic) return false;
    if (element.source.fullName.contains('lib/reflect_'))
      //domain classes and service classes are the only classes of interest
      return false;
    return true;
  }

  ClassInfo.fromElement(Element element)
      : type = TypeInfo.fromElement(element),
        annotations = _createAnnotations(element),
        methods = _createMethods(element),
        properties = _createProperties(element);

  ClassInfo.fromJson(Map<String, dynamic> json)
      : type = json[typeAttribute],
        annotations = json[annotationsAttribute],
        methods = json[methodsAttribute],
        properties = json[propertiesAttribute];

  Map<String, dynamic> toJson() =>
      {
        typeAttribute: type,
        if (annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods.isNotEmpty) methodsAttribute: methods,
        if (properties.isNotEmpty) propertiesAttribute: properties
      };
}

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
List<ClassInfo> createClasses(LibraryReader library) {
  List<ClassInfo> classes = [];
  for (Element element in library.allElements) {
    if (element is ClassElement && ClassInfo.isNeeded(element)) {
      ClassInfo classInfo = ClassInfo.fromElement(element);
      classes.add(classInfo);
    }
  }
  return classes;
}

class TypeInfo {
  static const libraryAttribute = 'library';
  static const nameAttribute = 'name';

  final String library;
  final String name;

  TypeInfo.fromElement(Element element)
      : library = element.source.fullName,
        name = element.name

  // TODO Trying to get generic types (e.g. get Person from List<Person>) but nu success so far
// {
//     if (element is TypeParameterizedElement) {
//       for (TypeParameterElement e in element.typeParameters) {
//         print("++ $element:${e.name}");
//
//       }
//     }
      ;

  TypeInfo.fromJson(Map<String, dynamic> json)
      : library = json[libraryAttribute],
        name = json[nameAttribute];

  Map<String, dynamic> toJson() =>
      {
        libraryAttribute: library,
        nameAttribute: name,
      };
}

class AnnotationInfo {
  static const typeAttribute = 'type';
  static const valuesAttribute = 'values';

  final TypeInfo type;
  final Map<String, Object> values;

  AnnotationInfo.fromElement(ElementAnnotation annotationElement)
      : type = TypeInfo.fromElement(
      annotationElement
          .computeConstantValue()
          .type
          .element),
        values = _values(annotationElement);

  AnnotationInfo.fromJson(Map<String, dynamic> json)
      : type = json[typeAttribute],
        values = json[valuesAttribute];

  Map<String, dynamic> toJson() =>
      {typeAttribute: type, if (values.isNotEmpty) valuesAttribute: values};

  static Map<String, Object> _values(ElementAnnotation annotationElement) {
    try {
      List<ParameterElement> parameters =
          (annotationElement.element as ConstructorElement).parameters;
      var dartObject = annotationElement.computeConstantValue();
      ConstantReader reader = ConstantReader(dartObject);
      return {
        for (ParameterElement parameter in parameters)
          parameter.name: reader
              .peek(parameter.name)
              .literalValue,
      };
    } catch (e) {
      return const {};
    }
  }
}

List<AnnotationInfo> _createAnnotations(Element element) {
  List<AnnotationInfo> annotations = [];
  // if (element is ClassElement) {
  List<ElementAnnotation> annotationElements = element.metadata;
  for (ElementAnnotation annotationElement in annotationElements) {
    AnnotationInfo annotation = AnnotationInfo.fromElement(annotationElement);
    annotations.add(annotation);
  }
  // }
  return annotations;
}

class MethodInfo {
  static const nameAttribute = 'name';
  static const returnTypeAttribute = 'returnType';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo returnType;
  final List<AnnotationInfo> annotations;

  MethodInfo.fromElement(MethodElement methodElement)
      : name = methodElement.name,
        returnType = TypeInfo.fromElement(methodElement.returnType.element),
        annotations=_createAnnotations(methodElement);

  MethodInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        returnType = json[returnTypeAttribute],
        annotations=json[annotationsAttribute];

  Map<String, dynamic> toJson() =>
      {
        nameAttribute: name,
        returnTypeAttribute: returnType,
        annotationsAttribute: annotations
      };

  static bool isNeeded(MethodElement methodElement) {
    if (methodElement.isPrivate) return false;
    if (methodElement.parameters.length > 1) return false;
    //public and zero or one parameter
    return true;
  }
}

List<MethodInfo> _createMethods(Element element) {
  List<MethodInfo> methods = [];
  if (element is ClassElement) {
    List<MethodElement> methodsElements = element.methods;
    for (MethodElement methodElement in methodsElements) {
      if (MethodInfo.isNeeded(methodElement)) {
        MethodInfo method = MethodInfo.fromElement(methodElement);
        methods.add(method);
      }
    }
  }
  return methods;
}

/// TODO: explain what a property is.
/// TODO include [_createAnnotations]
class PropertyInfo {
  static const nameAttribute = 'name';
  static const typeAttribute = 'type';
  static const hasSetterAttribute = 'hasSetter';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo type;
  final bool hasSetter;
  final List<AnnotationInfo> annotations;

  PropertyInfo.fromElement(PropertyAccessorElement propertyAccessorElement,
      this.hasSetter)
      : name = propertyAccessorElement.name,
        type = TypeInfo.fromElement(propertyAccessorElement.returnType.element),
        annotations = _createAnnotations(propertyAccessorElement);

  PropertyInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        hasSetter = json[hasSetterAttribute],
        type = json[typeAttribute],
        annotations = json[annotationsAttribute];

  Map<String, dynamic> toJson() =>
      {
        nameAttribute: name,
        hasSetterAttribute: hasSetter,
        typeAttribute: type,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };
}

/// The [ReflectFramework] recognized a property if there is property with a public getter accessor. It may have a public setter accessor.
List<PropertyInfo> _createProperties(Element element) {
  List<PropertyInfo> properties = [];
  if (element is ClassElement) {
    var publicAccessors =
    element.accessors.where((element) => element.isPublic);
    var getterAccessorElements =
    publicAccessors.where((element) => element.isGetter);
    var setterAccessorElements =
    publicAccessors.where((element) => element.isSetter);
    for (PropertyAccessorElement getterAccessorElement
    in getterAccessorElements) {
      bool hasSetter = setterAccessorElements
          .any((element) => element.name == getterAccessorElement.name + "=");
      PropertyInfo property =
      PropertyInfo.fromElement(getterAccessorElement, hasSetter);
      properties.add(property);
    }
  }
  return properties;
}
