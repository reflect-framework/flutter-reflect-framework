import 'package:reflect_framework/reflect_meta_action_method_pre_processor.dart';
import 'package:reflect_framework/reflect_meta_service_object.dart';

class Payment {
  Address address;
  CardDetails cardDetails;

  Payment({this.address, this.cardDetails});
}

class CardDetails {
  String cardHolderName;
  String cardNumber;
  String expiryMonth;
  String expiryYear;
  int securityCode;

  CardDetails({this.cardHolderName,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.securityCode});
}

class Address {
  String postCode;
  String addressLine;

  Address({this.postCode, this.addressLine});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      postCode: json['postCode'],
      addressLine: json['address'],
    );
  }
}

@ActionMethodPreProcessor(12)
@ServiceClass()
class PersonService {

  List<Person> allPersons() {
    return [
      Person("James", "Gosling"),
      Person("Eric", "Evans"),
      Person("Martin", "Fowler"),
      Person("Richard", "Pawson"),
      Person("Nils", "ten Hoeve")
    ];
  }
}

class Person {
  String givenName;
  String surName;

  Person(this.givenName, this.surName);

  String get fullName {
    return givenName ?? "" + " " + surName ?? "".trim();
  }

}