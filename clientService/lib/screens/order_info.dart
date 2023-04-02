import 'package:flutter/material.dart';


class OrderInfo extends StatefulWidget {
  static const String id = "order_info_screen";

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("data"),),);
  }
}
