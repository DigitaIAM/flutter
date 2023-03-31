import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget sideBar(BuildContext context) {
  String dateText = DateFormat("MMMM, dd, yyyy").format(DateTime.now());
  String timeText = DateFormat("hh:mm a").format(DateTime.now());
  return Drawer(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      SizedBox(
          child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      dateText,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(timeText,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.money),
                          label: const Text(
                            "Cash",
                            style: TextStyle(color: Colors.white),
                          ))),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.card_giftcard),
                          label: const Text(
                            "Humo",
                            style: TextStyle(color: Colors.white),
                          ))),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.card_membership),
                          label: const Text(
                            "UzCard",
                            style: TextStyle(color: Colors.white),
                          ))),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.other_houses),
                          label: const Text(
                            "Others",
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              ))),
      SizedBox(
          child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.reset_tv_outlined),
                          label: const Text(
                            "Return",
                            style: TextStyle(color: Colors.white),
                          ))),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            minimumSize: const Size.fromHeight(50), // NEW
                          ),
                          onPressed: () {
                            /* do something here */
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text(
                            "Exit",
                            style: TextStyle(color: Colors.white),
                          ))),
                ],
              )))
    ],
  ));
}
