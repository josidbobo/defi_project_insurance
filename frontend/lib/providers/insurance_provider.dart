import 'package:flutter/material.dart';
import 'package:insurance_dapp/providers/metamask_provider.dart';
import '../models/insurance_model.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../constants/constants.dart';
import 'dart:math';

import 'metamask_provider.dart';

class InsuranceProvider extends ChangeNotifier {
  // List<Insurance> get insuranceList => insurance;

  bool loading = false;
  bool error = false;
  bool noErrors = false;
  bool isInsureed = false;
  bool isFinished = false;

  get isLoading => loading;

  String msg = '';

  Contract? anotherContract;
  Contract? contract;

  InsuranceProvider() {
    if (MetaMaskProvider.isWC) {
      anotherContract = Contract(insuranceAddress, abii, MetaMaskProvider.web3);
      contract = anotherContract!.connect(MetaMaskProvider.web3!.getSigner());
    }
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
          int.parse(EthUtils.parseEther(_amountForBenef).toString())
              .toString());
      Type type = aamnt.runtimeType;
      print(type);

      final insuring = await contract!.send(
          'insure',
          [
            BigInt.from(aamnt),
            name,
            beneficiary,
            BigInt.from(aamnt2),
            password
          ],
          TransactionOverride(value: BigInt.from(aamnt)));
      print(insuring.hash);

      final result = await anotherContract!.call<BigInt>(
          'portfolioCountOfEachUser', [MetaMaskProvider.curentAddress]);
      print(result);

      for (int i = 1; i <= result.toInt() + 1; i++) {
        final struct = await anotherContract!
            .call('userInsurances', [MetaMaskProvider.curentAddress, i]);
        print('This is struct $struct');

        // Insurance _item = Insurance(struct);
        // print('This is item $_item');
        Insurance.insurance.add(struct);
        notifyListeners();

        print('This is insurance list ${Insurance.insurance[0]}');
      }

      final count = await anotherContract!.call<BigInt>(
        'count',
      );
      print(count);

      for (int i = 1; i <= count.toInt() + 1; i++) {
        final struct2 = await anotherContract!.call('portfolios', [i]);
        print(struct2);

        Insurance.portfolioInsurance.add(struct2);
        notifyListeners();
      }
      print('This is portfolio ${Insurance.portfolioInsurance[0]}');

      noErrors = true;
      msg = 'Successful';
      notifyListeners();
    } catch (e) {
      print(e.toString());
      msg = e.toString();
      error = true;
      notifyListeners();
    }
    noErrors = false;
    error = false;
    isFinished = true;
    loading = false;
    notifyListeners();
  }

  ethersSplitter(int num) {
    double _result = num.toDouble();
    double d = _result * 0.000000000000000001;
    return d;
  }
}
