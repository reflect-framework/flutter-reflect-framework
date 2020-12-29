import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:reflect_framework/reflect_meta_action_method_pre_processor_info.dart';
import 'package:reflect_framework/reflect_meta_action_method_processor_info.dart';
import 'package:source_gen/source_gen.dart';

/// Used by the [ReflectInfoJsonBuilder] to create intermediate json files to generate meta code later by another builder (TODO link to builder).
/// The meta data comes from source files using the [LibraryReader] class from the source_gen package
class ReflectInfo {
  static const actionMethodPreProcessorsAttribute = 'actionMethodPreProcessors';
  static const actionMethodProcessorsAttribute = 'actionMethodProcessors';
  static const classesAttribute = 'classes';

  final List<ActionMethodPreProcessorInfo> actionMethodPreProcessors;
  final List<ActionMethodProcessorInfo> actionMethodProcessors;
  final List<ClassInfo> classes;

  //TODO functions (ending with factory in name, when needed for service objects and as a replacement for ActionMethodPreProcessorInfo and ActionMethodProcessorInfo)
  //TODO add enums (with texts)
  //TODO add reflect texts

  ReflectInfo.fromLibrary(LibraryReader library)
      : this.actionMethodPreProcessors =
            createActionMethodPreProcessors(library),
        this.actionMethodProcessors = createActionMethodProcessors(library),
        this.classes = createClasses(library);

  ReflectInfo.fromJson(Map<String, dynamic> json)
      : actionMethodPreProcessors = json[actionMethodPreProcessorsAttribute],
        actionMethodProcessors = json[actionMethodProcessorsAttribute],
        classes = json[classesAttribute];

  Map<String, dynamic> toJson() => {
        if (actionMethodPreProcessors.isNotEmpty)
          actionMethodPreProcessorsAttribute: actionMethodPreProcessors,
        if (actionMethodProcessors.isNotEmpty)
          actionMethodProcessorsAttribute: actionMethodProcessors,
        if (classes.isNotEmpty) classesAttribute: classes,
      };
}

///Used by [ReflectInfo] to create json files with meta data from source files using the source_gen package
class ClassInfo {
  static const typeAttribute = 'type';
  static const annotationsAttribute = 'annotations';
  static const methodsAttribute = 'methods';
  static const propertiesAttribute = 'properties';

  final TypeInfo type;
  final List<AnnotationInfo> annotations;
  final List<ExecutableInfo> methods;
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

  Map<String, dynamic> toJson() => {
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
        genericTypes = json[genericTypesAttribute];

  Map<String, dynamic> toJson() => {
        libraryAttribute: library,
        nameAttribute: name,
        if (genericTypes.isNotEmpty) genericTypesAttribute: genericTypes
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
          parameter.name: reader.peek(parameter.name).literalValue,
      };
    } catch (e) {
      return const {};
    }
  }
}

List<AnnotationInfo> _createAnnotations(Element element) {
  List<AnnotationInfo> annotations = [];
  List<ElementAnnotation> annotationElements = element.metadata;
  for (ElementAnnotation annotationElement in annotationElements) {
    AnnotationInfo annotation = AnnotationInfo.fromElement(annotationElement);
    annotations.add(annotation);
  }
  return annotations;
}

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

  ExecutableInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        returnType = json[returnTypeAttribute],
        parameterTypes = json[parameterTypesAttribute],
        annotations = json[annotationsAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        returnTypeAttribute: returnType,
        if (parameterTypes.isNotEmpty) parameterTypesAttribute: parameterTypes,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static bool isNeededMethod(ExecutableElement executableElement) {
    return executableElement.isPublic &&
        executableElement.parameters.length <= 1;
  }

  static List<TypeInfo> _createParameterTypes(MethodElement methodElement) {
    return methodElement.parameters
        .map((p) => TypeInfo.fromDartType(p.type))
        .toList();
  }

  static TypeInfo _createReturnType(MethodElement methodElement) =>
      TypeInfo.fromDartType(methodElement.returnType);
}

List<ExecutableInfo> _createMethods(ClassElement classElement) {
  return classElement.methods
      .where((e) => ExecutableInfo.isNeededMethod(e))
      .map((e) => ExecutableInfo.fromElement(e))
      .toList();
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

  PropertyInfo.fromElements(PropertyAccessorElement propertyAccessorElement,
      this.hasSetter, FieldElement fieldElement)
      : name = propertyAccessorElement.name,
        type = TypeInfo.fromDartType(propertyAccessorElement.returnType),
        annotations = _createAnnotationsFrom2Elements(
            propertyAccessorElement, fieldElement);

  PropertyInfo.fromJson(Map<String, dynamic> json)
      : name = json[nameAttribute],
        hasSetter = json[hasSetterAttribute],
        type = json[typeAttribute],
        annotations = json[annotationsAttribute];

  Map<String, dynamic> toJson() => {
        nameAttribute: name,
        hasSetterAttribute: hasSetter,
        typeAttribute: type,
        if (annotations.isNotEmpty) annotationsAttribute: annotations
      };

  static List<AnnotationInfo> _createAnnotationsFrom2Elements(
      PropertyAccessorElement propertyAccessorElement,
      FieldElement fieldElement) {
    List<AnnotationInfo> annotations = [];
    annotations.addAll(_createAnnotations(propertyAccessorElement));
    annotations.addAll(_createAnnotations(fieldElement));
    return annotations;
  }
}

/// The [ReflectFramework] recognized a property if there is property with a public getter accessor. It may have a public setter accessor.
List<PropertyInfo> _createProperties(ClassElement classElement) {
  List<PropertyInfo> properties = [];
  var publicAccessors =
      classElement.accessors.where((element) => element.isPublic);
  var getterAccessorElements =
      publicAccessors.where((element) => element.isGetter);
  var setterAccessorElements =
      publicAccessors.where((element) => element.isSetter);
  var fieldElements = classElement.fields.where((element) => element.isPublic);

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
