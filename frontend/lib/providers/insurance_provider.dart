import 'package:flutter/material.dart';
import 'package:insurance_dapp/providers/metamask_provider.dart';
import '../models/insurance_model.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../constants/constants.dart';
import 'dart:math';

class InsuranceProvider extends ChangeNotifier {
  List<Insurance> insurance = [];
  static List<Insurance> portfolioInsurance = [];
  List<Claims>? adHoc = [];

  List<Insurance> get insuranceList => insurance;

  bool loading = false;
  bool error = false;
  bool noErrors = false;
  bool isInsureed = false;

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

  isInsured() async {
    final txResult = await anotherContract!
        .call<bool>('isInsuree', [MetaMaskProvider.curentAddress]);
    print(txResult);
    isInsureed = txResult;
    notifyListeners();
  }

  Future<void> insure(String name, String aamount, String beneficiary,
      String _amountForBenef, String password) async {
    try {
      loading = true;
      notifyListeners();
      final aamnt = num.parse(
          int.parse(EthUtils.parseEther(aamount).toString()).toString());
      final aamnt2 = num.parse(
          int.parse(EthUtils.parseEther(_amountForBenef).toString()).toString());
      Type type = aamnt.runtimeType;
      print(type);
      print('e reach here');

      final insuring = await contract!.send(
          'insure',
          [BigInt.from(aamnt), name, beneficiary, BigInt.from(aamnt2), password],
          TransactionOverride(value: BigInt.from(aamnt)));
      print(insuring.hash);

      final result = await anotherContract!.call<BigInt>(
          'portfolioCountOfEachUser', [MetaMaskProvider.curentAddress]);
      print(result);

      for (int i = 1; i <= result.toInt(); i++) {
        final struct = await anotherContract!
            .call('userInsurances', [MetaMaskProvider.curentAddress, i]);
        print(struct);

        for (int u = 0; u <= struct.numberOfClaims; u++) {
          adHoc!.add(Claims(
              beneficiary: struct.claims(u).beneficiary,
              amount: struct.claims(u).amount,
              description: struct.claims(u).description,
              approved: struct.claims(u).approved));
        }

        insurance.add(Insurance(
          owner: struct.owner,
          id: struct.insuranceId,
          insuranceName: struct.insuranceName,
          amount: int.parse(EthUtils.formatEther(struct.amount)),
          amountForBeneficiary:
              int.parse(EthUtils.formatEther(struct.amountForBeneficiary)),
          beneficiary: compressAddress(struct.beneficiary),
          numberOfClaims: struct.numberOfClaims,
          claims: adHoc,
        ));

        adHoc!.clear();
      }

      final count = await anotherContract!.call<BigInt>(
        'count',
      );
      print(count);

      for (int i = 1; i <= count.toInt(); i++) {
        final struct2 = await anotherContract!.call('portfolios', [i]);
        print(struct2);

        portfolioInsurance.add(Insurance(
          owner: struct2.owner,
          id: struct2.insuranceId,
          insuranceName: struct2.insuranceName,
          amount: int.parse(EthUtils.formatEther(struct2.amount)),
          amountForBeneficiary:
              int.parse(EthUtils.formatEther(struct2.amountForBeneficiary)),
          beneficiary: compressAddress(struct2.beneficiary),
          numberOfClaims: struct2.numberOfClaims,
        ));
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
