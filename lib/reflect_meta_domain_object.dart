
/// TODO [DomainObject]s are ....
///
/// [DomainObject]s do not have to extend the [DomainObject] class nor need any annotation.
/// The reflect application will recognize all [DomainObject]s that are:
/// - A public class (name does not start with an underscore)
/// - Is not a Dart type
/// - Is not a Dart library
/// - Can be (directly or indirectly) reached from [ServiceObjectActionMethod]s
///

class DomainObject {
  /// For documentation only
}

/// The [DomainClass] annotation is only used by the [ReflectCodeGeneration] to indicate that a method parameter or return value is a [DomainObject].
/// See:
/// - [ActionMethodPreProcessor]s
/// - [ActionMethodProcessor]s

class DomainClass {
 const DomainClass();
}