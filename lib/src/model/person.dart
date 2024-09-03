import 'package:flutter/material.dart';

class Person {
  String? relation;
  TextEditingController firstNameController;
  TextEditingController lastNameController;
  DateTime? birthdate;
  TextEditingController addressController;
  TextEditingController phoneController;
  String? preferredProduct;
  TextEditingController preferredProductController;

  Person({
    this.relation,
    required this.firstNameController,
    required this.lastNameController,
    this.birthdate,
    required this.addressController,
    required this.phoneController,
    this.preferredProduct,
    required this.preferredProductController,
  });
}
