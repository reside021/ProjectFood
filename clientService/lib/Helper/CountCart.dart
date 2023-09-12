import 'package:stream_mixin/stream_mixin.dart';
import 'package:localstore/localstore.dart';

class CountCart with StreamMixin<int> {
  CountCart._();
  static CountCart instance = CountCart._();

  final db = Localstore.instance;

  factory CountCart(){
    return CountCart();
  }

  updateCountCart() async {
    final items = await db.collection('cart').get();
    update(items?.length ?? 0);
  }
}