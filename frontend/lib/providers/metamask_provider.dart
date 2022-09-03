import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter/material.dart';
import './insurance_provider.dart';
import 'package:walletconnect_qrcode_modal_dart/walletconnect_qrcode_modal_dart.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import '../models/insurance_model.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../constants/constants.dart';
import 'dart:math';

class MetaMaskProvider extends ChangeNotifier {
  static const operatingChain = 9000;

  String currentAddress = "";
  static String curentAddress = ''; 
  

  int currentChain = -1;

  bool rejected = false;
  bool connected = false;
  
  String get address => currentAddress;

  bool get isEnabled => ethereum != null;

  bool get isOperatingChain => currentChain == operatingChain;

  bool get isConnected => currentAddress.isNotEmpty && isEnabled;

  /// Second segment
  ///
  //Web3Provider? web3;

  List<Insurance> insurance = [];
  bool loading = false;

  get isLoading => loading;

  String compressAddress(String address) {
    String c = address.substring(0, 5);
    String d = address.substring(38);

    String result = '$c...$d';
    return result;
  }
  

  Future<void> connect() async {
    if (isEnabled) {
      final accounts = await ethereum!.requestAccount();

      if (accounts.isNotEmpty) {
        currentAddress = compressAddress(accounts.first);
        curentAddress = accounts.first;
        currentChain = await ethereum!.getChainId();
        notifyListeners();
      }
      notifyListeners();
    }
  }

  static final rpcProvider = JsonRpcProvider(
      'https://polygon-mumbai.infura.io/v3/6ae7a9cc55f84ca9b261e89f21ff5848');

  

  Future<void> disconnect() async {
    clear();
    //final acc = await ethereum!.request("wallet_requestPermissions", [ethereum!.requestAccount()]);

    // try {
    //   if (currentAddress.isEmpty) {
    //     final accounts = await ethereum!.requestAccount();

    //     if (accounts.isNotEmpty) {
    //       currentAddress = accounts.first;
    //       currentChain = await ethereum!.getChainId();
    //       print(currentAddress);
    //     }
    //   }
    // } catch (e) {
    //   rejected = true;
    //   notifyListeners();
    //   print(e.toString());
    // }
    notifyListeners();
  }

  clear() {
    currentAddress = "";
    currentChain = -1;
    ethereum!.onDisconnect((error) {
      print(error.message);
      connect();
      notifyListeners();
    });
    notifyListeners();
  }

  void onInit() {
    if (isEnabled) {
      ethereum!.onAccountsChanged((accounts) {
        clear();
      });
      ethereum!.onChainChanged((accounts) {
        clear();
      });
    }
  }
}
