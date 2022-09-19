import 'package:flutter/material.dart';

class Claims {
  final String beneficiary;
  final int amount;
  final String description;
  final bool approved;
  Widget? status;

  Claims(
      {Key? key,
      required this.beneficiary,
      required this.amount,
      required this.description,
      required this.approved});

  void set() {
    if (approved == true) {
      status = const Text(
        'Approved',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    } else {
      status = const Text(
        'Not Approved',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }
  }
}

class Insurance {
  final String owner;
  final int id;
  final String insuranceName;
  final int amount;
  final String beneficiary;
  final int amountForBeneficiary;
  final int numberOfClaims;
  List<Claims>? claims;

  Insurance(
      {Key? key,
      required this.owner,
      required this.id,
      required this.insuranceName,
      required this.amountForBeneficiary,
      required this.amount,
      required this.beneficiary,
      required this.numberOfClaims,
      this.claims});
}
