import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools/navigate_tools.dart';
import '../../models/index.dart' show Order;
import 'webview_provider.dart';
import 'widgets/success.dart';

class WebviewCheckoutSuccessScreen extends StatefulWidget {
  final Order? order;

  const WebviewCheckoutSuccessScreen({this.order});

  @override
  State<WebviewCheckoutSuccessScreen> createState() => _WebviewCheckoutSuccessScreenState();
}

class _WebviewCheckoutSuccessScreenState extends State<WebviewCheckoutSuccessScreen> {

  @override
  void initState() {
    var webViewVm = Provider.of<WebViewProvider>(context, listen: false);
    Future.delayed(Duration.zero).then((value) async{
      await webViewVm.createWalletCashback(customerId: widget.order?.customerId??'', orderSubtotalPrice: double.parse(widget.order?.subtotal.toString()??''), orderNumber: int.parse(widget.order?.id??''));
    });


    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              NavigateTools.navigateHome(context);
            }),
        backgroundColor: kGrey200,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: OrderedSuccess(order: widget.order),
      ),
    );
  }
}
