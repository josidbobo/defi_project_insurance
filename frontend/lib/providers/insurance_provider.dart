import 'package:flutter/material.dart';
import 'package:insurance_dapp/providers/metamask_provider.dart';
import '../models/insurance_model.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../constants/constants.dart';
import 'dart:math';

class InsuranceProvider extends ChangeNotifier {
  List<Insurance> insurance = [];

  List<Insurance> get insuranceList => insurance;

  bool loading = false;
  bool error = false;
  bool noErrors = false;

  get isLoading => loading;

  String msg = '';

  Contract? anotherContract;
  Contract? contract;

  InsuranceProvider() {
    anotherContract = Contract(insuranceAddress, abii, provider);
    contract = anotherContract!.connect(provider!.getSigner());
  }

  static String compressAddress(String address) {
    String c = address.substring(0, 5);
    String d = address.substring(38);

    String result = '$c...$d';

    return result;
  }

  String compressNumber(double num) {
    String _num = num.toString();
    String c = _num.substring(0, 4);
    return c;
  }

  //

  Future<void> insure(String name, String aamount, String beneficiary,
      String _amountForBenef, String password) async {
    try {
      loading = true;
      notifyListeners();
      final aamnt = num.parse(
          int.parse(EthUtils.parseEther(aamount).toString()).toString());
      Type type = aamnt.runtimeType;
      print(type);
      print('e reach here');

      final insuring = await contract!.send(
          'insure',
          [BigInt.from(aamnt), name, beneficiary, password],
          TransactionOverride(value: BigInt.from(aamnt)));
      print(insuring.hash);

      final result = await anotherContract!.call<BigInt>(
          'portfolioCountOfEachUser', [MetaMaskProvider.curentAddress]);
      print(result);

      final struct = await anotherContract!.call('userInsurances',
          [MetaMaskProvider.curentAddress, result - BigInt.from(2)]);
      print(struct);

      for (int i = 1; i <= result.toInt(); i++){
          insurance.add(Insurance(
            owner: struct(i).owner,
            id: struct(i).insuranceId,
            insuranceName: struct(i).insuranceName,
            amount: int.parse(EthUtils.formatEther(struct(i).amount)),
            amountForBeneficiary:
                int.parse(EthUtils.formatEther(struct(i).amountForBeneficiary)),
            beneficiary: compressAddress(struct(i).beneficiary),
            numberOfClaims: struct(i).numberOfClaims));
      }

      noErrors = true;
      msg = 'Successful';
      notifyListeners();
    } catch (e) {
      print(e.toString());
      msg = e.toString();
      error = true;
      notifyListeners();
    }
    loading = false;
    notifyListeners();
  }

  // priceOfMatic() async {
  //   try {
  //     final result = await anotherContract!.call<BigInt>(
  //       'getLatestPrice',
  //     );
  //     print('result is $result');
  //     int _result = result.toInt();
  //     double d = _result * 0.00000001;
  //     maticPrice = compressNumber(d);
  //     notifyListeners();
  //   } catch (e) {
  //     print(e.toString());
  //     throw e;
  //   }
  // }
}
