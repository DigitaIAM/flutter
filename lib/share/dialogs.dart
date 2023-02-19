import 'package:flutter/material.dart';

void showMyInputText(BuildContext context, TextEditingController controller, VoidCallback callback) {
  Dialog myDialog = Dialog(
    child: Container(
      height: 250.0,
      width: 300.0,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: TextField(
              controller: controller,
              autofocus: true,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                callback();
                Navigator.of(context).pop();
              },
              child: const Text(
                "Saqlash",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ),
  );

  showDialog(context: context, builder: (BuildContext context) => myDialog);
}

Future<dynamic>? showYesNo(BuildContext context, String msg, VoidCallback callbackYes, VoidCallback callbackNo,
    {String? yesText, String? noText}) {
  Dialog dialogWithImage = Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      height: 300.0,
      width: 440.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(msg, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6),
              ),
            ),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        callbackNo();
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        noText ?? "Yo'q",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        callbackYes();
                        Navigator.of(context).pop(true);
                      },
                      child: Text(
                        yesText ?? "Ha",
                        style: const TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  return showDialog(context: context, builder: (BuildContext context) => dialogWithImage);
}

void showAlert(BuildContext context, String msg, {String? okText}) {
  Dialog dialogWithImage = Dialog(
    child: Container(
      height: 200.0,
      width: 300.0,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: Text(msg,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).errorColor,
                  fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                okText ?? 'OK',
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ),
  );

  showDialog(context: context, builder: (BuildContext context) => dialogWithImage);
}

void showYesNoCancel(BuildContext context, String msg, VoidCallback callbackYes, VoidCallback callbackNo,
    {String? yesText, String? noText, String? cancelText}) {
  Dialog dialogWithImage = Dialog(
    child: Container(
      height: 310.0,
      width: 300.0,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: 200,
            height: 60,
            child: Text(msg, style: Theme.of(context).textTheme.headline6),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              onPressed: () {
                callbackYes();
                Navigator.of(context).pop();
              },
              child: Text(
                yesText ?? "Ha",
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () {
                callbackNo();
                Navigator.of(context).pop();
              },
              child: Text(
                noText ?? "Yo'q",
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.grey),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                cancelText ?? "Bekor qilish",
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ),
  );

  showDialog(context: context, builder: (BuildContext context) => dialogWithImage);
}
