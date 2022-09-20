import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter/material.dart';
import './insurance_provider.dart';
import 'package:walletconnect_qrcode_modal_dart/walletconnect_qrcode_modal_dart.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import '../models/insurance_model.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../constants/constants.dart';
import 'package:flutter_web3/wallet_connect.dart' as a;

class MetaMaskProvider extends ChangeNotifier {
  static const operatingChain = 9000;

  String currentAddress = "";
  static String curentAddress = '';

  int currentChain = -1;

  static bool isWC = false;
  bool rejected = false;
  bool connected = false;
  bool noBrowserWallet = false;

  String get address => currentAddress;

  bool get isEnabled => ethereum != null;

  bool get isOperatingChain => currentChain == operatingChain;

  bool get isConnected => currentAddress.isNotEmpty && isEnabled;

  /// Second segment
  ///
  static Web3Provider? web3;

  String compressAddress(String address) {
    String c = address.substring(0, 5);
    String d = address.substring(38);

    String result = '$c...$d';
    return result;
  }

  whichOne(BuildContext context) {
    if(isWC){
      cconnect(context);
    }
    connect();
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
    } else if (!isEnabled) {
      noBrowserWallet = true;
      notifyListeners();
    }
  }

  cconnect(BuildContext context) async {
    // Create a connector
    final qrCodeModal = WalletConnectQrCodeModal(
      connector: WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          // <-- Meta data of your app appearing in the wallet when connecting
          name: 'QRCodeModalExampleApp',
          description: 'WalletConnect Developer App',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
      ),
    );

    final wc = a.WalletConnectProvider.fromRpc(
      {9000: 'https://eth.bd.evmos.dev:8545'},
      chainId: 9000,
      network: 'Evmos Testnet',
    );
    // Subscribe to events
    qrCodeModal.registerListeners(
        onConnect: (session) {
          currentAddress = session.accounts.first;
          curentAddress = session.accounts.first;
          currentChain = session.chainId;
          notifyListeners();
          print('Connected: $session');
        },
        onSessionUpdate: (response) => print('Session updated: $response'),
        onDisconnect: () {
          clear();
          print('Disconnected');
        });

    // Create QR code modal and connect to a wallet
    await qrCodeModal.connect(context, chainId: 9000);
    web3 = Web3Provider.fromWalletConnect(wc);
    isWC = true;
    notifyListeners();
  }

  Future<void> disconnect() async {
    clear();
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
