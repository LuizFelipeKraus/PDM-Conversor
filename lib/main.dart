import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var url = Uri.https(
    'api.hgbrasil.com', '/finance', {'?': 'format=json&key=a6bde695'});

void main() async {
  //print(await getData());
  
  runApp(MaterialApp(home: Home()));
}

Future<Map> getData() async {
  var response = await http.get(url);
  //print(json.decode(response.body)["results"]["currencies"]["USD"]);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // TextEditingController
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  double dolar = 0;
  double euro = 0;
  double bitcoin = 0;

  _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    bitcoinController.text = (real / bitcoin).toStringAsFixed(2);
  }

  _dolarChanged(String text) {
    double dolar = double.parse(text);
    //usei a estratégia de pegar o valor dolar e multiplicar pelo this.dolar (da classe)
    realController.text = (dolar * this.dolar).toStringAsFixed(2);

    // transformo em reais e depois transformo em euro.
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);

    bitcoinController.text = (dolar * this.dolar / bitcoin).toStringAsFixed(2);
  }

  _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    bitcoinController.text = (euro * this.euro / bitcoin).toStringAsFixed(2);
  }

  _bitcoinChanged(String text) {
    double bitcoin = double.parse(text);
    realController.text = (bitcoin * this.bitcoin).toStringAsFixed(2);
    dolarController.text = (bitcoin * this.bitcoin / dolar).toStringAsFixed(2);
  }

  void _resetFields() {
    euroController.text = "";
    dolarController.text = "";
    realController.text = "";
    bitcoinController.text ="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar os dados..",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                  bitcoin = snapshot.data!["results"]["currencies"]["BTC"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        buildTextField(
                            "Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "EUR\€", euroController, _euroChanged),
                        Divider(),
                        buildTextField(
                            "Bitcoin", "₿", bitcoinController, _bitcoinChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController value,
    Function changed) {
  return TextField(
    controller: value,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 0.0),
        ),
        prefixText: prefix,
        prefixStyle: TextStyle(color: Colors.black)),
    style: TextStyle(color: Colors.black, fontSize: 25.0),
    onChanged: changed as void Function(String)?,
    keyboardType: TextInputType.number,
  );
}
