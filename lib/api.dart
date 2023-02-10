import 'package:flutter/foundation.dart';
import 'package:flutter_feathersjs/flutter_feathersjs.dart';

class Api {
  static const String server = "https://data.animi.dev";

  // static const String server = "http://10.0.2.2:3030";
  // static const String server = "http://localhost:3030";

  static final Api instance = Api._internal();

  set oid(oid) {
    instance._oid = oid;
  }

  get oid {
    return instance._oid;
  }

  static FlutterFeathersjs feathers() {
    return instance.connection;
  }

  late FlutterFeathersjs connection;

  factory Api() {
    return instance;
  }

  Api._internal() {
    if (kDebugMode) {
      print("creating Feathers for $server");
    }
    connection = FlutterFeathersjs();
    connection.init(baseUrl: server);

    // flutterFeathersjs.listen(serviceName: "memories", fromJson: (e) {
    //   print("listen event: ");
    //   print(DateTime.now());
    //   print(e);
    // });
  }

  String _oid = "";
}

class Connection {}
