import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:nae/api.dart';
import 'package:nae/constants.dart';
import 'package:nae/models/memory/item.dart';
import 'package:nae/utils/cache.dart';

class Qty {
  const Qty(this.nums);

  final List<Named> nums;

  static Qty zero() => const Qty([]);

  static Qty fromJson(dynamic json) {
    //  print("Qty.fromJson $json");
    if (json == null) {
      return Qty.zero();
    }

    List<Named> nums = [];
    if (json != null) {
      if (json is List) {
        //  print("list case");
        for (Map<String, dynamic> o in json) {
          nums.add(Named.fromJson(o));
        }
      } else if (json is Map<String, dynamic>) {
        // print("map case");
        nums.add(Named.fromJson(json));
      }
    }
    // print("Qty.fromJson done");
    return Qty(nums);
  }

  bool get isNotEmpty => nums.isNotEmpty;

  Decimal get lower {
    // print("lower $nums");
    if (nums.isEmpty) {
      return Decimal.zero;
    }

    var total = Decimal.zero;

    for (final num in nums) {
      var deeper = num.named.deeper;
      var number = num.number;
      while (deeper != null) {
        number *= deeper.$1;
        deeper = deeper.$2.deeper;
      }

      total += number;
    }

    return total;
  }

  Uom? get lowerUOM {
    for (final num in nums) {
      var deeper = num.named.deeper;
      while (deeper != null) {
        if (deeper.$2.deeper == null) {
          return deeper.$2;
        }
        deeper = deeper.$2.deeper;
      }
    }

    return null;
  }

  Decimal get upper {
    if (nums.isEmpty) {
      return Decimal.zero;
    }

    var total = Decimal.zero;
    for (final num in nums) {
      total += num.number;
    }

    return total;
  }

  Uom? get upperUOM {
    for (final num in nums) {
      return num.named;
    }

    return null;
  }

  bool error() {
    for (final num in nums) {
      if (num.error()) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    // print("Qty.toString $nums");
    var text = '';

    for (final num in nums) {
      if (text.isNotEmpty) {
        text += ', ';
      }
      // print("num ${num.number}");
      text += '${num.number.toString()} ${num.named.toString()}';
    }

    if (error()) {
      return '!? $text';
    } else {
      return text;
    }
  }

  Qty operator +(Qty other) {
    // print("SUM $this + $other = ?");

    final oNums = List.from(other.nums);
    List<Named> answer = [];
    top:
    for (final nl in nums) {
      for (final (i, nr) in oNums.indexed) {
        if (nl.named.hashCode == nr.named.hashCode) {
          answer.add(Named(number: nl.number + nr.number, named: nl.named));
          oNums.removeAt(i);
          continue top;
        }
      }
      answer.add(nl);
    }

    for (final nr in oNums) {
      answer.add(nr);
    }

    final result = Qty(answer);
    // print("SUM $this + $other = $result");
    return result;
  }

  Future<Qty> enrich(Cache cache) async {
    for (final nam in nums) {
      await nam.named.resolve_(cache);
    }
    return this;
  }

  void toData(Map<String, dynamic> data) {
    var index = 0;
    Named? num = nums[0];

    var number = num.number;
    var uom = num.named;

    data['qty_$index'] = number.toString();
    data['uom_$index'] = uom.memory;
    index++;

    while (uom.deeper != null) {
      number = uom.deeper!.$1;
      uom = uom.deeper!.$2;

      data['qty_$index'] = number.toString();
      data['uom_$index'] = uom.id;
      index++;
    }
  }
}

class Uom extends Equatable {
  final String id;
  final Map<String, dynamic> json;
  final (Decimal, Uom)? deeper;
  final bool haveError;
  MemoryItem? memory;

  Uom(this.id, this.json, this.deeper, {this.haveError = false});

  static Uom fromJson(dynamic json) {
    // print("Uom.fromJson $json");

    if (json == null) {
      return Uom(
          '',
          const {
            'uom': {'name': '?'}
          },
          null);
    } else if (json is String) {
      return Uom(json, {'uom': json}, null);
    } else {
      final uuid = json['_uuid'];
      if (uuid != null) {
        return Uom(uuid, json, null);
      }

      final factor = Decimal.parse(json['number'] ?? '1');
      final deeper = Uom.fromJson(json['uom']);

      final id = json['in'];
      if (id is String) {
        return Uom(id, json, (factor, deeper));
      } else {
        return Uom(id['_uuid'], json, (factor, deeper));
      }
    }
  }

  bool error() {
    if (haveError) {
      return true;
    }
    if (deeper != null) {
      return deeper!.$2.error();
    }
    return false;
  }

  Future<MemoryItem> resolve() async {
    final response = await Api.feathers()
        .get(serviceName: "memories", objectId: id, params: {
      "oid": Api.instance.oid,
      "ctx": [cUom],
    });

    return MemoryItem.from(response);
  }

  Future<void> resolve_(Cache cache) async {
    // workaround for unknown
    if (id == '') {
      return;
    }

    if (memory == null) {
      var cached = cache.get(id);
      if (cached == null) {
        final response = await Api.feathers()
            .get(serviceName: "memories", objectId: id, params: {
          "oid": Api.instance.oid,
          "ctx": [cUom],
        });
        //  print('response $response');

        cached = MemoryItem.from(response);
        cache.add(cached);
      }
      memory = cached;
    }
    if (deeper != null) {
      deeper!.$2.resolve_(cache);
    }
  }

  String name() {
    if (memory != null) {
      return memory!.name();
    }

    // print("name $json");
    final uom = json['in'];
    if (uom != null) {
      return uom['name'];
    }
    return json['name'] ?? '';
  }

  @override
  String toString() {
    if (memory != null) {
      if (deeper == null) {
        return memory!.name();
      } else {
        return '${memory!.name()} [${deeper!.$1} ${deeper!.$2.toString()}]';
      }
    }
    // print("Uom.toString $json");
    dynamic uom = json;
    var text = '';

    while (uom is Map) {
      if (uom['number'] == null) {
        text += ' ${nameOrId(uom['uom'])}';
        break;
      }
      if (uom['uom'] == null) {
        text += ' ${uom['name'] ?? ''}';
        break;
      }

      text = '$text ${nameOrId(uom['in'])} по ${uom['number'] ?? ''}';

      final label = nameOrId(uom['uom']);
      if (label != null) {
        text += ' $label';
      }
      uom = uom['uom'];
    }

    // if (uom is String) {
    //   text += uom;
    // }

    return text.trim();
  }

  @override
  List<Object?> get props => [id, deeper];
}

String nameOrId(dynamic json) {
  if (json == null) {
    return "NULL";
  } else if (json is String) {
    return json;
  } else {
    return json['name'] ?? '';
  }
}

class Named {
  final Decimal number;
  final Uom named;
  final bool haveError;

  Named({required this.number, required this.named, this.haveError = false});

  static Named fromJson(dynamic json) {
    //print("Named.fromJson $json");
    bool error = false;
    String str = json['number']?.toString() ?? '';
    var number = Decimal.tryParse(str);
    if (number == null) {
      error = true;
      number = Decimal.parse(str.replaceAll(',', '.').trim());
    }

    // print("number $number");

    return Named(
        number: number, named: Uom.fromJson(json['uom']), haveError: error);
  }

  bool error() {
    if (haveError) {
      return true;
    }
    return named.error();
  }
}
