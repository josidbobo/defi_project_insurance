import 'package:flutter/material.dart';
import 'package:insurance_dapp/widgets/portfolios_view.dart';
import 'package:insurance_dapp/widgets/progressIndicator.dart';
import 'package:insurance_dapp/widgets/toastBody.dart';
import 'package:provider/provider.dart';
import '../widgets/text_field.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/insurance_provider.dart';
import '../providers/metamask_provider.dart';

class Portfolio extends StatefulWidget {
  final insureAmount = TextEditingController();
  final insureBeneficiary = TextEditingController();
  final insurePassword = TextEditingController();
  final typeOfInsurance = TextEditingController();
  final amountForBenef = TextEditingController();
  Portfolio({Key? key}) : super(key: key);

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  FToast? fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast!.init(context);
  }

  showToast(String msg, IconData anyOther, [bool? bl]) => fToast!.showToast(
        child: ToastBody(anyOther, msg, bl ?? false),
        gravity: ToastGravity.TOP,
        toastDuration: Duration(seconds: 3),
      );

  void _showCreateDialog(context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return ChangeNotifierProvider(
              create: (context) => InsuranceProvider()..isInsured(),
              builder: (context, child) {
                return Dialog(
                  child: SizedBox(
                    height: 410,
                    width: 710,
                    child: Consumer<InsuranceProvider>(
                        builder: (context, provider, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          TextView(
                              text: 'Amount in EVMOS eg: 0.01',
                              controller: widget.insureAmount),
                          TextView(
                              text: 'Title of Insurance',
                              controller: widget.typeOfInsurance),
                          TextView(
                              text: 'Beneficiary address',
                              controller: widget.insureBeneficiary),
                          TextView(
                              text: 'Max amount beneficiary can withdraw',
                              controller: widget.amountForBenef),
                          !provider.isInsureed
                              ? TextView(
                                  text: 'password',
                                  controller: widget.insurePassword)
                              : const SizedBox(),
                          ListTile(
                            trailing: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                    Colors.orange[600],
                                  )),
                              onPressed: () {
                                provider.isInsureed
                                    ? context.read<InsuranceProvider>().insure(
                                        widget.typeOfInsurance.text,
                                        widget.insureAmount.text,
                                        widget.insureBeneficiary.text,
                                        widget.amountForBenef.text,
                                        "")
                                    : context.read<InsuranceProvider>().insure(
                                        widget.typeOfInsurance.text,
                                        widget.insureAmount.text,
                                        widget.insureBeneficiary.text,
                                        widget.amountForBenef.text,
                                        widget.insurePassword.text);
                                if (provider.noErrors) {
                                  Navigator.of(context).pop();
                                  showToast(provider.msg,
                                      Icons.playlist_add_check_rounded);
                                }
                                if (provider.error) {
                                  showToast(
                                      provider.msg, Icons.error_outline, true);
                                }
                              },
                              child: provider.isLoading
                                  ? const CircularProgress()
                                  : const Text(
                                      "Create Portfolio",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => MetaMaskProvider()..connect()),
        ChangeNotifierProvider(create: (context) => InsuranceProvider())
      ],
      builder: (context, child) {
        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 50, left: 50),
            child: Column(
              children: [
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(
                      width: 33,
                    ),
                    Text(
                      'Egbon Adugbo - Portfolios ',
                      style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(width: 656),
                    Text('Welcome,',
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Consumer<MetaMaskProvider>(
                        builder: (context, provider, child) {
                      return Text(context.read<MetaMaskProvider>().address,
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(
                                  fontSize: 16, fontWeight: FontWeight.bold));
                    }),
                    const SizedBox(width: 39),
                    Consumer<MetaMaskProvider>(
                        builder: (context, provider, child) {
                      return ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                Colors.blue[600],
                              )),
                          onPressed: () {
                            context.read<MetaMaskProvider>().disconnect();
                            Navigator.of(context).pushReplacementNamed('/');
                          },
                          child: const Text(
                            "Disconnect",
                            style: TextStyle(color: Colors.white),
                          ));
                    }),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(
                    width: 135,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 43,
                        child: ElevatedButton(
                            onPressed: () {
                              _showCreateDialog(context);
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            child: const Text(
                              "Create Portfolio",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: 43,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/makeClaims');
                            },
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            child: const Text(
                              "Make Claim",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 75,
                  ),
                  Container(
                    height: 780,
                    width: 860,
                    child: Consumer<InsuranceProvider>(
                        builder: (context, provider, child) {
                      if (provider.insuranceList.isEmpty) {
                        return Center(
                          child: Text(
                            'No Portfolios to display!',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemBuilder: ((context, index) {
                          return PortfolioView(
                            amountOfInsurance:
                                provider.insuranceList[index].amount,
                            id: provider.insuranceList[index].id,
                            beneficiaryAddress:
                                provider.insuranceList[index].beneficiary,
                            nameOfInsurance:
                                provider.insuranceList[index].insuranceName,
                          );
                        }),
                        itemCount: provider.insuranceList.length,
                        padding: const EdgeInsets.all(10),
                      );
                    }),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                ])
              ],
            ),
          ),
        );
      },
    );
  }
}
