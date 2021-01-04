import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

// We cant use ActionMethodPreProcessorContext type to convert it to a string,
// because it contains BuildContext and thus imports from a UI package, which does not go will with build_runner.
// Maybe this is because build_runner can use code reflection and Flutter does not allow this???
const actionMethodPreProcessorContextName = 'ActionMethodPreProcessorContext';

// We cant use ActionMethodPreProcessor type to convert it to a string,
// because its library uses a required annotation and thus imports from a UI package, which does not go will with build_runner.
// Maybe this is because build_runner can use code reflection and Flutter does not allow this???
const preProcessorAnnotation = '@ActionMethodPreProcessor';
const processorAnnotation = '@ActionMethodProcessor';
const translationAnnotation = 'Translation';

/// Used by the [ReflectInfoJsonBuilder] to create intermediate json files to generate meta code later by another builder (TODO link to builder).
/// The meta data comes from source files using the [LibraryElement] class from the source_gen package
class ReflectInfo {
  static const actionMethodPreProcessorsAttribute = 'actionMethodPreProcessors';
  static const actionMethodProcessorsAttribute = 'actionMethodProcessors';
  static const functionsAttribute = 'functions';
  static const classesAttribute = 'classes';
  static const voidName = 'void';

  final List<ExecutableInfo> functions;
  final List<ClassInfo> classes;

  //TODO functions (ending with factory in name, when needed for service objects and as a replacement for ActionMethodPreProcessorInfo and ActionMethodProcessorInfo)
  //TODO add enums (with texts)
  //TODO add TranslatableTextAnnotations

  ReflectInfo.fromLibrary(LibraryReader library)
      : this.functions = _createFunctions(library),
        this.classes = _createClasses(library);

  ReflectInfo.empty()
      : this.functions = [],
        this.classes = [];

  ReflectInfo.fromJson(Map<String, dynamic> json)
      : classes = json[classesAttribute] == null
            ? []
            : List<ClassInfo>.from(json[classesAttribute]
                .map((model) => ClassInfo.fromJson(model))),
        functions = json[functionsAttribute] == null
            ? []
            : List<ExecutableInfo>.from(json[functionsAttribute]
                .map((model) => ExecutableInfo.fromJson(model)));

  static const jsonExtension = '.reflect_info.json';

  Map<String, dynamic> toJson() => {
        if (functions!=null && functions.isNotEmpty) functionsAttribute: functions,
        if (classes!=null && classes.isNotEmpty) classesAttribute: classes,
      };

  static List<ClassInfo> _createClasses(LibraryReader library) {
    List<ClassInfo> classes = [];
    for (ClassElement classElement in library.classes) {
      if (_isNeededClass(classElement)) {
        classes.add(ClassInfo.fromElement(classElement));
      } else if (_classContainsTranslationAnnotations(classElement)) {
        classes.add(
            ClassInfo.fromElementWithTranslationAnnotationsOnly(classElement));
      }
    }
    return classes;
  }

  static bool _isNeededClass(ClassElement element) {
    return element.isPublic &&
        !element.source.fullName.contains('lib/reflect_');
  }

  static List<ExecutableInfo> _createFunctions(LibraryReader library) {
    List<ExecutableInfo> functions = [];
    for (Element element in library.allElements) {
      if (_isPublicFunction(element)) {
        if (_isNeededFunction(element)) {
          functions.add(ExecutableInfo.fromElement(element));
        } else if (_containsTranslationAnnotations(element)) {
          functions.add(
              ExecutableInfo.fromElementWithTranslationAnnotationsOnly(
                  element));
        }
      }
    }
    return functions;
  }

  static bool _isPublicFunction(Element element) {
    return element is FunctionElement && element.isPublic;
  }

  static bool _isNeededFunction(FunctionElement element) {
    return _isPotentialServiceObjectFactoryFunction(element) ||
        _isActionMethodPreProcessorFunction(element) ||
        _isActionMethodProcessorFunction(element) ||
        _containsTranslationAnnotations(element);
  }

  static _isPotentialServiceObjectFactoryFunction(FunctionElement element) {
    const factory = 'Factory';
    return element.name.endsWith(factory) &&
        element.name.length > factory.length &&
        element.returnType != null &&
        element.returnType.element.name != voidName;
  }

  static bool _isActionMethodPreProcessorFunction(FunctionElement element) {
    return element.returnType.element == null &&
        (element.parameters.length == 1 || element.parameters.length == 2) &&
        element.parameters[0].type.element.name ==
            actionMethodPreProcessorContextName &&
        element.metadata.toString().contains(preProcessorAnnotation);
  }

  static bool _isActionMethodProcessorFunction(FunctionElement element) {
    return (element.parameters.length == 1 || element.parameters.length == 2) &&
        element.parameters[0].type.element.name ==
            actionMethodPreProcessorContextName &&
        element.metadata.toString().contains(processorAnnotation);
  }

  static bool _classContainsTranslationAnnotations(ClassElement classElement) {
    return _containsTranslationAnnotations(classElement) ||
        classElement.accessors
            .any((element) => _containsTranslationAnnotations(element)) ||
        classElement.methods
            .any((element) => _containsTranslationAnnotations(element));
  }

  void add(String jsonString) {
    var json = jsonDecode(jsonString);
    ReflectInfo reflectInfo = ReflectInfo.fromJson(json);
    functions.addAll(reflectInfo.functions);
    classes.addAll(reflectInfo.classes);
  }
}

class ClassInfo {
  static const typeAttribute = 'type';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final TypeInfo type;
  final List<AnnotationInfo> annotations;
  final List<ExecutableInfo> methods;
  final List<PropertyInfo> properties;

  ClassInfo.fromElement(ClassElement element)
      : type = TypeInfo.fromElement(element),
        annotations = _createAnnotations(element),
        methods = _createMethods(element),
        properties = _createProperties(element);

  ClassInfo.fromElementWithTranslationAnnotationsOnly(ClassElement element)
      : type = TypeInfo.fromElement(element),
        annotations =
            _createAnnotations(element, forTranslationAnnotationsOnly: true),
        methods = _createMethodsWithTranslationAnnotationsOnly(element),
        properties = _createPropertiesWithTranslationAnnotationsOnly(element);

  ClassInfo.fromJson(Map<String, dynamic> json)
      : type = TypeInfo.fromJson(json[typeAttribute]),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationInfo>.from(json[annotationsAttribute]
                .map((model) => AnnotationInfo.fromJson(model))),
        methods = json[methodsAttribute] == null
            ? []
            : List<ExecutableInfo>.from(json[methodsAttribute]
                .map((model) => ExecutableInfo.fromJson(model))),
        properties = json[propertiesAttribute] == null
            ? []
            : List<PropertyInfo>.from(json[propertiesAttribute]
                .map((model) => PropertyInfo.fromJson(model)));

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
        if (annotations!=null &&  annotations.isNotEmpty) annotationsAttribute: annotations,
        if (methods!=null &&  methods.isNotEmpty) methodsAttribute: methods,
        if (properties!=null && properties.isNotEmpty) propertiesAttribute: properties
      };

  static List<ExecutableInfo> _createMethods(ClassElement classElement) {
    return classElement.methods
        .where((e) => _isNeededMethod(e))
        .map((e) => ExecutableInfo.fromElement(e))
        .toList();
  }

  static List<ExecutableInfo> _createMethodsWithTranslationAnnotationsOnly(
      ClassElement classElement) {
    return classElement.methods
        .where((e) => _containsTranslationAnnotations(e))
        .map((e) => ExecutableInfo.fromElementWithTranslationAnnotationsOnly(e))
        .toList();
  }

  static bool _isNeededMethod(ExecutableElement executableElement) {
    return executableElement.isPublic &&
        executableElement.parameters.length <= 1;
  }

  static List<PropertyInfo> _createProperties(ClassElement classElement) {
    List<PropertyInfo> properties = [];
    var publicAccessors =
        classElement.accessors.where((element) => element.isPublic);
    var getterAccessorElements =
        publicAccessors.where((element) => element.isGetter);
    var setterAccessorElements =
        publicAccessors.where((element) => element.isSetter);
    var fieldElements =
        classElement.fields.where((element) => element.isPublic);

    for (PropertyAccessorElement getterAccessorElement
        in getterAccessorElements) {
      bool hasSetter = setterAccessorElements
          .any((element) => element.name == getterAccessorElement.name + "=");
      FieldElement fieldElement = fieldElements
          .firstWhere((element) => element.name == getterAccessorElement.name);

      PropertyInfo property = PropertyInfo.fromElements(
          getterAccessorElement, hasSetter, fieldElement);
      properties.add(property);
    }
    return properties;
  }

  static List<PropertyInfo> _createPropertiesWithTranslationAnnotationsOnly(
      ClassElement classElement) {
    List<PropertyInfo> properties = [];
    var publicAccessors =
        classElement.accessors.where((element) => element.isPublic);
    var getterAccessorElements =
        publicAccessors.where((element) => element.isGetter);
    var setterAccessorElements =
        publicAccessors.where((element) => element.isSetter);
    var fieldElements =
        classElement.fields.where((element) => element.isPublic);

    for (PropertyAccessorElement getterAccessorElement
        in getterAccessorElements) {
      bool hasSetter = setterAccessorElements
          .any((element) => element.name == getterAccessorElement.name + "=");
      FieldElement fieldElement = fieldElements
          .firstWhere((element) => element.name == getterAccessorElement.name);

      if (_containsTranslationAnnotations(getterAccessorElement) ||
          _containsTranslationAnnotations(fieldElement)) {
        PropertyInfo property =
            PropertyInfo.fromElementsWithTranslateAnnotationOnly(
                getterAccessorElement, hasSetter, fieldElement);
        properties.add(property);
      }
    }
    return properties;
  }
}

class TypeInfo {
  static const libraryAttribute = 'library';
  static const nameAttribute = 'name';
  static const genericTypesAttribute = 'genericTypes';

  final String library;
  final String name;
  final List<TypeInfo> genericTypes;

  TypeInfo.fromElement(Element element)
      : library = element.source.fullName,
        name = element.name,
        genericTypes = const [];

  TypeInfo.fromDartType(DartType dartType)
      : library = dartType.element.source.fullName,
        name = dartType.element.name,
        genericTypes = _createGenericTypes(dartType);

  TypeInfo.fromJson(Map<String, dynamic> json)
      : library = json[libraryAttribute],
        name = json[nameAttribute],
        genericTypes = json[genericTypesAttribute] == null
            ? []
            : List<TypeInfo>.from(json[genericTypesAttribute]
                .map((model) => TypeInfo.fromJson(model)));

  Map<String, dynamic> toJson() => {
        libraryAttribute: library,
        nameAttribute: name,
        if (genericTypes!=null &&  genericTypes.isNotEmpty) genericTypesAttribute: genericTypes
      };

  static List<TypeInfo> _createGenericTypes(DartType dartType) {
    if (dartType is ParameterizedType) {
      List<TypeInfo> genericTypes = [];
      for (DartType genericDartType in dartType.typeArguments) {
        TypeInfo genericTypeInfo = TypeInfo.fromDartType(genericDartType);
        genericTypes.add(genericTypeInfo);
      }
      return genericTypes;
    } else {
      return const [];
    }
  }
}

class AnnotationInfo {
  static const typeAttribute = 'type';
  static const valuesAttribute = 'values';

  final TypeInfo type;
  final Map<String, Object> values;

  AnnotationInfo.fromElement(ElementAnnotation annotationElement)
      : type = TypeInfo.fromDartType(
            annotationElement.computeConstantValue().type),
        values = _values(annotationElement);

  AnnotationInfo.fromJson(Map<String, dynamic> json)
      : type = TypeInfo.fromJson(json[typeAttribute]),
        values = json[valuesAttribute];

  Map<String, dynamic> toJson() => {
        typeAttribute: type,
        if (values != null && values.isNotEmpty) valuesAttribute: values
      };

  static Map<String, Object> _values(ElementAnnotation annotationElement) {
    var dartObject = annotationElement.computeConstantValue();
    ConstantReader reader = ConstantReader(dartObject);
    Map<String, Object> values = {};
    for (String name in _valueNames(annotationElement)) {
      try {
        Object value = reader.peek(name).literalValue;
        values.putIfAbsent(name, () => value);
      } catch (e) {
        // We will skip the value, if we cant get it (value is likely null)
      }
    }
    return values;
  }

  static List<String> _valueNames(ElementAnnotation annotationElement) {
    try {
      return (annotationElement.element as ConstructorElement)
          .parameters
          .map((p) => p.name)
          .toList();
    } catch (e) {
      return const [];
    }
  }
}

bool _containsTranslationAnnotations(Element element) {
  return element.metadata.toString().contains(translationAnnotation);
}

List<AnnotationInfo> _createAnnotations(Element element,
    {bool forTranslationAnnotationsOnly = false}) {
  List<AnnotationInfo> annotations = [];
  List<ElementAnnotation> annotationElements = element.metadata;
  for (ElementAnnotation annotationElement in annotationElements) {
    AnnotationInfo annotation = AnnotationInfo.fromElement(annotationElement);
    if (!forTranslationAnnotationsOnly ||
        annotation.type.name == translationAnnotation) {
      annotations.add(annotation);
    }
  }
  return annotations;
}

/// Information for dart functions and methods
class ExecutableInfo {
  static const nameAttribute = 'name';
  static const returnTypeAttribute = 'returnType';
  static const parameterTypesAttribute = 'parameterTypes';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo returnType;
  final List<TypeInfo> parameterTypes;
  final List<AnnotationInfo> annotations;

  ExecutableInfo.fromElement(ExecutableElement executableElement)
      : name = executableElement.name,
        returnType = _createReturnType(executableElement),
        parameterTypes = _createParameterTypes(executableElement),
        annotations = _createAnnotations(executableElement);

  ExecutableInfo.fromElementWithTranslationAnnotationsOnly(
      ExecutableElement executableElement)
      : name = executableElement.name,
        returnType = null,
        parameterTypes = const [],
        annotations = _createAnnotations(executableElement,
            forTranslationAnnotationsOnly: true);

  ExecutableInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        returnType = json[returnTypeAttribute] == null
            ? null
            : TypeInfo.fromJson(json[returnTypeAttribute]),
        parameterTypes = json[parameterTypesAttribute] == null
            ? []
            : List<TypeInfo>.from(json[parameterTypesAttribute]
                .map((model) => TypeInfo.fromJson(model))),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationInfo>.from(json[annotationsAttribute]
                .map((model) => AnnotationInfo.fromJson(model)));

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        if (returnType != null) returnTypeAttribute: returnType,
        if (parameterTypes!=null &&  parameterTypes.isNotEmpty) parameterTypesAttribute: parameterTypes,
        if (annotations!=null &&  annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<TypeInfo> _createParameterTypes(
      ExecutableElement executableElement) {
    return executableElement.parameters
        .map((p) => TypeInfo.fromDartType(p.type))
        .toList();
  }

  static TypeInfo _createReturnType(ExecutableElement executableElement) {
    DartType returnType = executableElement.returnType;
    var returnTypeVoid = returnType.element == null;
    if (returnTypeVoid) {
      return null;
    } else {
      return TypeInfo.fromDartType(returnType);
    }
  }
}

/// TODO: explain what a property is.
class PropertyInfo {
  static const nameAttribute = 'name';
  static const typeAttribute = 'type';
  static const hasSetterAttribute = 'hasSetter';
  static const annotationsAttribute = 'annotations';

  final String name;
  final TypeInfo type;
  final bool hasSetter;
  final List<AnnotationInfo> annotations;

  PropertyInfo.fromElements(PropertyAccessorElement propertyGetterElement,
      this.hasSetter, FieldElement fieldElement)
      : name = propertyGetterElement.name,
        type = TypeInfo.fromDartType(propertyGetterElement.returnType),
        annotations = _createAnnotationsFrom2Elements(
            propertyGetterElement, fieldElement);

  PropertyInfo.fromElementsWithTranslateAnnotationOnly(
      PropertyAccessorElement propertyAccessorElement,
      this.hasSetter,
      FieldElement fieldElement)
      : name = propertyAccessorElement.name,
        type = TypeInfo.fromDartType(propertyAccessorElement.returnType),
        annotations =
            _createAnnotationsFrom2ElementsWithTranslateAnnotationOnly(
                propertyAccessorElement, fieldElement);

  PropertyInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        hasSetter = json[hasSetterAttribute],
        type = TypeInfo.fromJson(json[typeAttribute]),
        annotations = json[annotationsAttribute] == null
            ? []
            : List<AnnotationInfo>.from(json[annotationsAttribute]
                .map((model) => AnnotationInfo.fromJson(model)));

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        hasSetterAttribute: hasSetter,
        typeAttribute: type,
        if (annotations!=null &&  annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<AnnotationInfo> _createAnnotationsFrom2Elements(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationInfo> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement));
    annotations.addAll(_createAnnotations(fieldElement));
    return annotations;
  }

  static _createAnnotationsFrom2ElementsWithTranslateAnnotationOnly(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationInfo> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement,
        forTranslationAnnotationsOnly: true));
    annotations.addAll(
        _createAnnotations(fieldElement, forTranslationAnnotationsOnly: true));
    return annotations;
  }
}
