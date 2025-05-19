import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../env.dart';
import '../../models/cart/cart_base.dart';
import '../../models/cart/discount_coupons.dart';
import '../../models/user_model.dart';
import '../../modules/dynamic_layout/config/app_config.dart';
import '../../widgets/common/loading_body.dart';
import '../common/app_bar_mixin.dart';
import 'my_cart_screen.dart';

class CartScreenArgument {
  final bool isModal;
  final bool isBuyNow;
  final bool hideNewAppBar;

  CartScreenArgument({
    required this.isModal,
    required this.isBuyNow,
    this.hideNewAppBar = false,
  });
}

class CartScreen extends StatefulWidget {
  final bool? isModal;
  final bool isBuyNow;
  final bool hideNewAppBar;
  final bool? showChat;

  const CartScreen(
      {this.isModal,
      this.isBuyNow = false,
      this.hideNewAppBar = false,
      this.showChat});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with AppBarMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var cartModel = Provider.of<CartModel>(context, listen: false);
    Future.delayed(const Duration(seconds: 2), () async {
      cartModel.setLoadedDiscount();
      await onloadCoupon();
    });
    screenScrollController = _scrollController;
  }

  Future onloadCoupon() async {
    // cartModel.setLoadingDiscount();
    print('onloadCoupon');
    var discountCodes = await getDiscountCodes();
    await createDiscount(
        couponCode: discountCodes?.data?[recordNumber].discountCode ?? '',
        priceRuleId: discountCodes?.data?[recordNumber].priceRuleId ?? '');
    print('onloadCoupon2');
    // cartModel.setLoadedDiscount();
  }

  Future createDiscount(
      {required String couponCode, required String priceRuleId}) async {
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request(
      'POST',
      Uri.parse(Configurations.proxyServerUrl),
    );
    request.body = json.encode({
      'discount_code': {'code': couponCode},
      'priceRuleId': priceRuleId,
    });
    request.headers.addAll(headers);

    var response = await request.send();
    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<DiscountCoupon?> getDiscountCodes() async {
    var headers = {
      'Cookie':
          '_shopify_y=bdaa2810-e172-4443-bdc3-8eff170be9f5; _y=bdaa2810-e172-4443-bdc3-8eff170be9f5'
    };

    var url = '$apiUrl/discountCodes/getDiscount';
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      var userID = Provider.of<UserModel>(context, listen: false).user?.id;
      recordNumber = (userID.hashCode) % 1000;
      discountCoupon = DiscountCoupon.fromJson(jsonDecode(response.body));
      couponList = [];
      welcomeCouponList = [];
      var firstCoupon =
          discountCoupon?.data?.elementAt(recordNumber).discountCode;
      couponList.add(firstCoupon);
      welcomeCouponList.add(firstCoupon);

      couponList.add(secondCoupon);
      welcomeCouponList.add(secondCoupon);
      couponList.add(thirdCoupon);
      welcomeCouponList.add(thirdCoupon);
      welcomeCouponList.add('FIRSTORDER25');
      return discountCoupon =
          DiscountCoupon.fromJson(jsonDecode(response.body));
    }
    return discountCoupon;
  }

  @override
  Widget build(BuildContext context) {
    return renderScaffold(
      routeName: RouteList.cart,
      hideNewAppBar: widget.hideNewAppBar,
      backgroundColor: Theme.of(context).backgroundColor,
      child: Selector<CartModel, bool>(
        selector: (_, cartModel) => cartModel.calculatingDiscount,
        builder: (context, calculatingDiscount, child) {
          return LoadingBody(
            isLoading: calculatingDiscount,
            child: child!,
          );
        },
        child: MyCart(
          isBuyNow: widget.isBuyNow,
          isModal: widget.isModal,
          scrollController: _scrollController,
          hasNewAppBar: showAppBar(RouteList.cart),
        ),
      ),
    );
  }

  @override
  Widget renderScaffold({
    required String routeName,
    required Widget child,
    bool? resizeToAvoidBottomInset,
    Color? backgroundColor,
    bool hideNewAppBar = false,
    Widget? floatingActionButton,
    AppBarConfig? appBarConfig,
    AppBar? secondAppBar,
  }) {
    if (child is Scaffold) {
      printLog(
        '[renderScaffold] Warning: Duplicate Scaffold can cause AppBar issue on iOS.',
      );
    }
    final appBar = appBarConfig ?? this.appBar;
    final showNewAppBar =
        (appBar?.shouldShowOn(routeName) ?? false) && !hideNewAppBar;
    if (showNewAppBar) {
      return Scaffold(
        body: Column(
          children: [
            getAppBarWidget(
              appBar: appBar,
              backgroundColor: backgroundColor,
            ),
            if (secondAppBar != null)
              MediaQuery.removePadding(
                context: context,
                removeTop: showNewAppBar,
                child: secondAppBar,
              ),
            Expanded(child: child),
          ],
        ),
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
      );
    }
    if (resizeToAvoidBottomInset != null ||
        backgroundColor != null ||
        floatingActionButton != null ||
        secondAppBar != null) {
      return Scaffold(
        appBar: secondAppBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: backgroundColor,
        body: SafeArea(
          left: false,
          right: false,
          bottom: false,
          child: child,
        ),
        floatingActionButton: floatingActionButton,
      );
    }
    return child;
  }
}
