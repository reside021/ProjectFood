import 'package:stream_mixin/stream_mixin.dart';


class CurrentCounter with StreamMixin<int>{
  CurrentCounter();

  increment() {
    update((lastUpdate ?? 1) + 1);
  }

  decrement() {
    if ((lastUpdate ?? 1) > 1){
      update(lastUpdate! - 1);
    }
  }
}