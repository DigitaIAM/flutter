import 'package:flutter/material.dart';

Widget checkBar (BuildContext context) {
  return Drawer(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      SizedBox(
          // width: MediaQuery.of(context).size.width * 0.1,
          // height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter a search item',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter a search date',
                  ),
                ),
              ),
              const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: 'Amount',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // default text style
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 4, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: '0.00',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green), // default text style
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: 'Discount',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // default text style
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 4, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: '0.00',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green), // default text style
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 20, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: 'Payable',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold), // default text style
                    ),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 4, left: 20),
                  child: Text.rich(
                    TextSpan(
                      text: '0.00',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green), // default text style
                    ),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      onPressed: () {
                        /* do something here */
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.white),
                      ))),
            ],
          ),
        ],
      )),
    ],
  ));
}
