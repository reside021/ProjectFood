import 'package:stream_mixin/stream_mixin.dart';


class IsItemCart with StreamMixin<bool>{
  IsItemCart();

  setStatus(bool element){
    update(element);
  }
}