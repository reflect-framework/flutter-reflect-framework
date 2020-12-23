
import '../reflect_meta_service_object.dart';

class Person {
  String givenName;
  String surName;
  String get fullName {return givenName??"" + " "+ surName??"".trim();}

  Person({this.givenName, this.surName});
}

@ServiceClass()
class PersonService {

  createPerson(Person person) {
    //TODO
  }

  List<Person> allPersons() {
    //TODO
    return [
      Person(givenName:"Martin", surName:"Fowler"),
      Person(givenName:"Richard", surName:"Pawson"),
    ];
  }
}