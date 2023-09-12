import 'package:stream_mixin/stream_mixin.dart';
import 'package:localstore/localstore.dart';


class TotalSumCart with StreamMixin<int>{
  TotalSumCart._();
  static TotalSumCart instance = TotalSumCart._();

  final db = Localstore.instance;


  factory TotalSumCart(){
    return instance;
  }

  updateTotalSumCart() async {
    var sum = 0;
    final items = await db.collection('cart').get();
    if (items == null) {
      update(sum);
      return;
    }

    var keys = items.keys;


    for (var key in keys){
      var count = items[key]['count'] as int;
      var price = items[key]['price'] as int;

      var mul = count * price;

      sum += mul;
    }

    update(sum);

  }
}