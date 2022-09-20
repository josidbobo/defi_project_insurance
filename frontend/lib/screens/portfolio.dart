import 'package:flutter/material.dart';
import 'package:insurance_dapp/models/insurance_model.dart';
import 'package:insurance_dapp/widgets/portfolios_view.dart';
import 'package:insurance_dapp/widgets/progressIndicator.dart';
import 'package:insurance_dapp/widgets/toastBody.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:provider/provider.dart';
import '../widgets/text_field.dart';
import 'package:motion_toast/motion_toast.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
    widget.insureAmount.clear();
    widget.amountForBenef.clear();
    widget.insureBeneficiary.clear();
    widget.insurePassword.clear();
    widget.typeOfInsurance.clear();
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
                              text: 'Max amount beneficiary allowed to withdraw',
                              controller: widget.amountForBenef),
                          !provider.isInsureed
                              ? TextView(
                                  text: 'password',
                                  controller: widget.insurePassword)
                              : const SizedBox(),
                          ListTile(
                            trailing: SizedBox(
                              height: 36,
                              width: 121,
                              child: ElevatedButton(
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
                                      ? context
                                          .read<InsuranceProvider>()
                                          .insure(
                                              widget.typeOfInsurance.text,
                                              widget.insureAmount.text,
                                              widget.insureBeneficiary.text,
                                              widget.amountForBenef.text,
                                              "")
                                      : context
                                          .read<InsuranceProvider>()
                                          .insure(
                                              widget.typeOfInsurance.text,
                                              widget.insureAmount.text,
                                              widget.insureBeneficiary.text,
                                              widget.amountForBenef.text,
                                              widget.insurePassword.text);
                                  if (provider.noErrors) {
                                    MotionToast.success(
                                      description: Text(
                                        provider.msg,
                                      ),
                                      title: const Text('Success'),
                                      dismissable: true,
                                      layoutOrientation: ToastOrientation.ltr,
                                      toastDuration: const Duration(seconds: 3),
                                      position: MotionToastPosition.top,
                                    ).show(context);
                                  }
                                  if (provider.error) {
                                    MotionToast.error(
                                      description: Text(
                                        provider.msg,
                                      ),
                                      title: const Text('Error'),
                                      dismissable: true,
                                      layoutOrientation: ToastOrientation.ltr,
                                      toastDuration: const Duration(seconds: 3),
                                      position: MotionToastPosition.top,
                                    ).show(context);
                                  }
                                  if (provider.isFinished) {
                                    Navigator.of(context).pop();
                                    dispose();
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
                      'SureBlocks - Portfolios ',
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
                      if (Insurance.insurance.isEmpty) {
                        return Center(
                          child: Text(
                            'No Portfolios created yet!',
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemBuilder: ((context, index) {
                          return PortfolioView(
                            amountOfInsurance:
                                double.parse(Insurance.insurance[index][3]),
                            id: int.parse(Insurance.insurance[index][1]),
                            beneficiaryAddress:
                                Insurance.insurance[index][5].toString(),
                            nameOfInsurance:
                                Insurance.insurance[index][2].toString(),
                          );
                        }),
                        itemCount: Insurance.insurance.length,
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
