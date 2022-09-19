import "package:flutter/material.dart";
import "../models/insurance_model.dart";
import "../providers/insurance_provider.dart";
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();

  List<Insurance> foundUsers = [];
  List<Insurance> fullList = InsuranceProvider.portfolioInsurance;

  @override
  initState() {
    foundUsers = InsuranceProvider.portfolioInsurance;
    super.initState();
  }

  void filter(String enteredKeyword) {
    List<Insurance> results = [];
    if (enteredKeyword.isEmpty) {
      results = fullList;
    } else {
      results = fullList
          .where((user) =>
              user.owner.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              user.insuranceName
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => InsuranceProvider(),
        builder: (context, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5)),
                    child: Center(
                      child: TextField(
                        onChanged: (value) => filter(value),
                        controller: textEditingController,
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  textEditingController.clear();
                                  foundUsers = fullList;
                                });
                              },
                            ),
                            hintText: 'Search...',
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: foundUsers.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: Text(
                                      "Recent",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  )),
                              Expanded(
                                  flex: 20,
                                  child: ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: foundUsers.length,
                                    itemBuilder: (context, index) => Card(
                                      key: ValueKey(foundUsers[index].id),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        leading: Text(
                                          foundUsers[index].id.toString(),
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        title: Text(
                                            foundUsers[index].insuranceName),
                                        subtitle: Text(foundUsers[index].owner),
                                        trailing: ElevatedButton(
                                            onPressed: () {
                                              //context.read<InsuranceProvider>().makeClaim();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.blue),
                                            child: const Text(
                                              "Make Claim",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'No results found',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
