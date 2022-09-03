
import 'package:flutter/material.dart';
import 'package:insurance_dapp/providers/metamask_provider.dart';
import 'package:insurance_dapp/screens/portfolio.dart';
import 'package:insurance_dapp/widgets/home_page.dart';
import 'package:provider/provider.dart';
import './providers/insurance_provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MetaMaskProvider()),
      ChangeNotifierProvider(create: (_) => InsuranceProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          canvasColor: Colors.grey[100],
          textTheme: TextTheme(
              headline1: TextStyle(
                fontFamily: 'Amhara',
                fontSize: 21,
                color: Colors.green[800],
              ),
              headline2: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              bodyText1: const TextStyle(
                fontSize: 19,
              )),
          colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.white,
                  brightness: Brightness.light,
                  primary: Colors.black)
              .copyWith(secondary: Colors.blue[600]),
        ),
        //home: const MyHomePage(title: 'Egbon Adugbo Insurance Ltd'),
        initialRoute: '/',
        routes: {
          '/': (context) =>
              const MyHomePage(title: 'Egbon Adugbo Insurance Ltd'),
          '/portfolio': (context) => Portfolio(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MetaMaskProvider()..onInit(),
        builder: (context, child) {
          return Scaffold(
              body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 110, left: 100),
              child: Consumer<MetaMaskProvider>(
                  builder: (context, provider, child) {
                String text = '';
                if (provider.isConnected && provider.isOperatingChain) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacementNamed("/portfolio");
                  });
                } else if (provider.isConnected && !provider.isOperatingChain) {
                  text =
                      "Wrong Chain ${context.watch<MetaMaskProvider>().currentChain}. Please connect to Rinkeby!";
                } else if (provider.isEnabled && !provider.isConnected) {
                  return HomePageWidget();
                } else {
                  text =
                      'Please use an ethereum enabled browser to access this site';
                }
                return Center(
                    child: Text(
                  text,
                  style: Theme.of(context).textTheme.headline2,
                ));
              }),
            ),
          ));
        });
  }
}
