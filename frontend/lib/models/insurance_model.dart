import 'package:flutter/material.dart';

class Insurance {
  final String owner;
  final String id;
  final String insuranceName;
  final double amount;
  final String beneficiary;
  final bool isApproved;
  final double amountForBeneficiary;

  Insurance._internal({
    Key? key,
    required this.owner,
    required this.id,
    required this.insuranceName,
    required this.amountForBeneficiary,
    required this.isApproved,
    required this.amount,
    required this.beneficiary,
  });

  // Insurance copyWith({
  //   String? owner,
  //   String? id,
  //   String? insuranceName,
  //   double? amount,
  //   String? beneficiary,
  //   bool? isApproved,
  //   double? amountForBeneficiary,
  // }) {
  //   return Insurance(
  //     owner: owner ?? this.owner,
  //     id: id ?? this.id,
  //     insuranceName: insuranceName ?? this.insuranceName,
  //     amount: amount ?? this.amount,
  //     beneficiary: beneficiary ?? this.beneficiary,
  //     isApproved: isApproved ?? this.isApproved,
  //     amountForBeneficiary: amountForBeneficiary ?? this.amountForBeneficiary,
  //   );
  // }

  factory Insurance(
    String oowner, String iid, String iinsuranceName, double aamount, String bbeneficiary,
    bool iisApproved, double aamountForBeneficiary,){
    return Insurance._internal(
      owner: oowner, 
      id: iid, 
      insuranceName: iinsuranceName, 
      amountForBeneficiary: aamountForBeneficiary, 
      isApproved: iisApproved, 
      amount: aamount, 
      beneficiary: bbeneficiary);
  }

  static List<Insurance> insurance = <Insurance>[];
  static List<Insurance> portfolioInsurance = <Insurance> [];
}
