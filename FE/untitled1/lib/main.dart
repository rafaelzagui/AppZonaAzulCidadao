import 'package:flutter/material.dart';
import 'package:flutter_credit_card_brazilian/credit_card_form.dart';
import 'package:flutter_credit_card_brazilian/credit_card_model.dart';
import 'package:flutter_credit_card_brazilian/flutter_credit_card.dart';
import 'package:cloud_functions/cloud_functions.dart';
import "package:firebase_core/firebase_core.dart";
import 'firebase_options.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:clipboard/clipboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: 'Navegação Básica',
    theme: ThemeData(
        primaryColor: Color(0xFFE3B866),
        scaffoldBackgroundColor: Color(0xFF669CE3)),
    home: PrimeiraRota(),
  ));
}

class PrimeiraRota extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 40,
                ),
                Image.asset(
                  'assets/images/logo.png',
                  scale: 0.8,
                ), // <-- SEE HERE
              ],
            ),
            SizedBox(
              height: 80,
              width: 40,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                primary: const Color(0xffffffff),
              ),
              child: Container(
                margin: const EdgeInsets.all(8),
                child: const Text(
                  '       COMPRAR TICKET       ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: 'halter',
                    fontSize: 14,
                    package: 'flutter_credit_card',
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SelectPaymentMPage(title: "")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PaymentPageState();
  }
}

class PaymentPageState extends State<PaymentPage> {
  String _result = "";
  String _status = "";
  String _transactionId = "";
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  Future<void> simulatePayment() async {
    var monthString = expiryDate.substring(0, 2);
    var yearString = expiryDate.substring(3);

    var month = int.parse(monthString);
    var year = int.parse(yearString);

    var data = {
      "cardHolderName": cardHolderName.toUpperCase(),
      "cardNumber": cardNumber.replaceAll(" ", ""),
      "cardValidityYear": year,
      "cardValidityMonth": month,
      "cvv": cvvCode,
      "placa": placa.text.toUpperCase(),
      "amount": 10,
      "hours": 1,
    };
    final result =
        await FirebaseFunctions.instanceFor(region: "southamerica-east1")
            .httpsCallable('simulatePayment')
            .call(data);
    setState(() {
      _result = result.data["message"];

      print(_result);
      if (_result == "Sucesso") {
        Navigator.push(
            context,

            // TODO: Trocar TicketPage para o nome da pagina escrito
            MaterialPageRoute(
                builder: (context) => SuccessPaymentPage(title: "")));
      } else {
        var snackBar = SnackBar(
          content: Text(_result.toString()),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController placa = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Credit Card View Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF669CE3)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade900,
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              CreditCardWidget(
                cardName: (String value) {
                  print(value);
                },
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: Colors.blue,
                        cardNumberDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Número do cartão',
                          hintText: 'XXXX XXXX XXXX XXXX',
                        ),
                        expiryDateDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Validade',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 5),
                          ),
                          labelText: 'CVV',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nome completo',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(14, 13, 14, 0),
                              child: TextFormField(
                                controller: placa,
                                decoration: InputDecoration(
                                    labelText: 'Insira a placa do veículo',
                                    border: OutlineInputBorder()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          primary: const Color(0xffffffff),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: const Text(
                            '          PAGAR          ',
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'halter',
                              fontSize: 14,
                              package: 'flutter_credit_card',
                            ),
                          ),
                        ),
                        onPressed: () {
                          simulatePayment();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}

class SuccessPayment extends StatelessWidget {
  const SuccessPayment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFF0004FB),
          scaffoldBackgroundColor: Color(0xFF669CE3)),
      home: const SuccessPaymentPage(title: ''),
    );
  }
}

class SuccessPaymentPage extends StatefulWidget {
  const SuccessPaymentPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SuccessPaymentPage> createState() => _SuccessPaymentState();
}

class _SuccessPaymentState extends State<SuccessPaymentPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 0,
              color: Colors.orangeAccent,
              child: const SizedBox(
                width: 300,
                height: 250,
                child: Center(
                  child: Text(
                    '  PAGAMENTO REALIZADO\n            COM SUCESSO\n\n  Veículo regular por 1 hora!',
                    style: TextStyle(
                        color: Color(0xFF004FB9),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 40,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: const Color(0xffffffff),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: const Text(
                    '        Menu       ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'halter',
                      fontSize: 14,
                      package: 'flutter_credit_card',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrimeiraRota()));
                })
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SelectPaymentM extends StatelessWidget {
  const SelectPaymentM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Color(0xFF1C1C86),
          scaffoldBackgroundColor: Color(0xFF669CE3)),
      home: const SelectPaymentMPage(title: ''),
    );
  }
}

class SelectPaymentMPage extends StatefulWidget {
  const SelectPaymentMPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SelectPaymentMPage> createState() => _SelectPaymentMPageState();
}

class _SelectPaymentMPageState extends State<SelectPaymentMPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 60,
              height: 85,
            ),
            Card(
              elevation: 10,
              color: Colors.orangeAccent,
              child: const SizedBox(
                width: 350,
                height: 250,
                child: Center(
                  child: Text(
                    'Selecione o método \n\n     de pagamento',
                    style: TextStyle(
                        color: Color(0xFF004FB9),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              height: 40,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: const Color(0xffffffff),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: const Text(
                    ' Cartão de crédito ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'halter',
                      fontSize: 20,
                      package: 'flutter_credit_card',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PaymentPage()));
                }),
            SizedBox(
              width: 40,
              height: 30,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  primary: const Color(0xffffffff),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: const Text(
                    '              Pix              ',
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: 'halter',
                      fontSize: 20,
                      package: 'flutter_credit_card',
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PaymentPixPage()));
                })
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PaymentPixPage extends StatefulWidget {
  PaymentPixPage({Key? key}) : super(key: key);
  _PaymentPixPageState createState() => _PaymentPixPageState();
}

class _PaymentPixPageState extends State<PaymentPixPage> {
  TextEditingController controller = TextEditingController();
  final String data = (randomAlphaNumeric(35));
  String paste = 'data';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(60),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 5,
                height: 5,
              ),
              QrImage(
                data: data,
                size: 300,
                embeddedImageStyle:
                    QrEmbeddedImageStyle(size: const Size(80, 80)),
              ),
              Text("Copiar para área de transferência:"),
              SizedBox(
                height: 30,
                width: 40,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
                      child: TextFormField(
                        readOnly: true,
                        initialValue: data,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(35),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(30, 0, 0, 0),
                    child: IconButton(
                      icon: Icon(Icons.content_copy),
                      onPressed: () async {
                        await FlutterClipboard.copy(data);
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Copiado para a área de transferência')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                    width: 40,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary: const Color(0xffffffff),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: const Text(
                          '              Menu             ',
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrimeiraRota()));
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
