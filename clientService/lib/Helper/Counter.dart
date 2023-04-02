import 'package:stream_mixin/stream_mixin.dart';

class Counter with StreamMixin<int> { // CODE TO NOTICE
  Counter._();
  static Counter instance = Counter._();

  factory Counter(){
    return Counter();
  }

  increment() {
    update((lastUpdate ?? 1) + 1);
  }

  decrement() {
    if ((lastUpdate ?? 1) > 1){
      update(lastUpdate! - 1);
    }
  }
}