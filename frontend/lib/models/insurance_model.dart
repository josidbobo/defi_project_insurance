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

  factory Insurance(List<dynamic> stu){
    return Insurance._internal(
      owner: stu[0].toString(), 
      id: stu[1].toString(), 
      insuranceName: stu[2].toString(), 
      amountForBeneficiary: double.parse(stu[6]), 
      isApproved: stu[7], 
      amount: double.parse(stu[3]), 
      beneficiary: stu[5].toString());
  }

  ethersSplitter(int num) {
    double _result = num.toDouble();
    double d = _result * 0.000000000000000001;
    return d;
  }

  static List<dynamic> insurance = [];
  static List<dynamic> portfolioInsurance = [];
}
