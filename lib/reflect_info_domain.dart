import 'package:reflect_framework/reflect_info_service.dart';

/// TODO [DomainObject]s are ....
///
/// [DomainObject]s do not have to extend the [DomainObject] class nor need any annotation.
/// The reflect application will recognize all [DomainObject]s that are:
/// - A public class (name does not start with an underscore)
/// - Is not a Dart type (not in a Dart library)
/// - Has one or more [Propteries]
/// - Can be (directly or indirectly) reached from [ServiceObjectActionMethod]s

class DomainObject {
  /// For documentation only
}

/// The [ReflectFramework] creates info classes (with [DomainClassInfoCode]) that implement [DomainClassInfo] for all classes that are recognized as [DomainObject]s.
abstract class DomainClassInfo extends ClassInfo {
  // [DomainObject]s do not have an icon (for now)
  //   List<ActionMethodInfo> get actionMethods;
  //   List<PropertyInfo> get propertyInfos;

}
