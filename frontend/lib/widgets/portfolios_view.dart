import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insurance_dapp/providers/insurance_provider.dart';

class PortfolioView extends StatefulWidget {
  final String nameOfInsurance;
  final double amountOfInsurance;
  final String beneficiaryAddress;
  final int id;

  const PortfolioView(
      {Key? key,
      required this.nameOfInsurance,
      required this.amountOfInsurance,
      required this.beneficiaryAddress,
      required this.id})
      : super(key: key);

  @override
  State<PortfolioView> createState() => _PortfolioViewState();
}

class _PortfolioViewState extends State<PortfolioView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => InsuranceProvider(),
        builder: (context, child) {
          return Card(
            margin: const EdgeInsets.only(bottom: 7),
            child: Container(
              color: Colors.blueGrey,
              height: 70,
              width: 580,
              child: Row(children: [
                const SizedBox(
                  width: 5,
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(widget.nameOfInsurance,
                                style: Theme.of(context).textTheme.headline2),
                            const SizedBox(
                              width: 29,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // context.read<MetaMaskProvider>().disconnect();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                child: const Text(
                                  "Top Up Amount",
                                  style: TextStyle(color: Colors.white),
                                )),
                            const SizedBox(
                              width: 4,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // context.read<MetaMaskProvider>().disconnect();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                child: const Text(
                                  "Authorize to withdraw",
                                  style: TextStyle(color: Colors.white),
                                )),
                            const SizedBox(
                              width: 4,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // context.read<MetaMaskProvider>().disconnect();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                child: const Text(
                                  "Change Beneficiary",
                                  style: TextStyle(color: Colors.white),
                                )),
                            const SizedBox(
                              width: 4,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  // context.read<MetaMaskProvider>().disconnect();
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                                child: const Text(
                                  "Approve Claim",
                                  style: TextStyle(color: Colors.white),
                                )),
                          ]),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.amountOfInsurance.toString(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(widget.beneficiaryAddress),
                        ],
                      ),
                    ]),
              ]),
            ),
          );
        });
  }
}
