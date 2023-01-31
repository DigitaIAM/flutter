import 'package:nae_hr/api.dart';

class Memory {

  Future<dynamic> fetch(String name, List<String> ctx, int skip) async {
    var query = {
      "oid": Api.instance.oid,
      "ctx": ctx,
      "\$skip": skip,
    };
    return await Api.feathers().find(serviceName: name, query: query);
  }
}