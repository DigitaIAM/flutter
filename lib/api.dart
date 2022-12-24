import 'package:flutter_feathersjs/flutter_feathersjs.dart';

class Api {
  static const String server = "https://data.nss.uz";
  // static const String server = "http://localhost:3030";

  static final Api instance = Api._internal();

  static FlutterFeathersjs feathers() {
    return instance.flutterFeathersjs;
  }

  late FlutterFeathersjs flutterFeathersjs;

  factory Api() {
    return instance;
  }

  Api._internal() {
    flutterFeathersjs = FlutterFeathersjs();
    flutterFeathersjs.init(baseUrl: server);
  }

}