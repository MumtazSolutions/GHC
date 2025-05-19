// ignore_for_file: omit_local_variable_types

import 'dart:convert';
import 'dart:developer';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app.dart';
import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../env.dart';
import '../../../frameworks/General_api.dart';
import '../../../generated/l10n.dart';
import '../../../models/cart/discount_coupons.dart';
import '../../../models/entities/product.dart';
import '../../../models/index.dart' show AppModel, CartModel, Coupons, Discount;
import '../../../models/progress/progress_tracking_model.dart';
import '../../../models/user_model.dart';
import '../../../services/index.dart';
import 'apply_coupon.dart';
import 'point_reward.dart';

// bool canCheckout = false;
bool fromCart = false;
bool setEndDate = false;
var initialTotalPrice = 0.0;
FocusNode myFocusNode = FocusNode();
bool enterPincode = false;
// bool firstTimeCoupon = false;
// bool isCouponApplied = false;

class ShoppingCartSummary extends StatefulWidget {
  final bool showPrice;

  const ShoppingCartSummary({this.showPrice = true});

  @override
  State<ShoppingCartSummary> createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  var product;
  int quantity = 0;
  bool isBogo = false;
  final services = Services();

  final bool _enable = true;
  bool pincodeSubmit = false;
  var responseMsg = '';

  String link = '';
  var deliveryDate;
  String? pinCode;

  bool serviceable = false;

  String _productsInCartJson = '';
  final _debounceApplyCouponTag = 'debounceApplyCouponTag';
  final defaultCurrency = kAdvanceConfig.defaultCurrency;

  CartModel get cartModel => Provider.of<CartModel>(context, listen: false);
  final LocalStorage storage = LocalStorage('localStorage_app');

  final couponController = TextEditingController();
  final pincodeController = TextEditingController();

  final bool _showCouponList = kAdvanceConfig.showCouponList &&
      ServerConfig().type != ConfigType.magento;

  bool isPopup = false;

  var couponDescription = [
    'Get 20% off',
    'Get 15% off',
    'Get 10% off',
  ];

  @override
  void initState() {
    super.initState();

    var productList = [];
    productList.add(cartModel.productsInCart);
    cartModel.productsInCart.keys.map(
      (key) {
        var productId = Product.cleanProductID(key);
      },
    ).toList();
    WidgetsBinding.instance.endOfFrame.then((_) async {
      if (mounted) {
        if (storage.getItem('pinCode').toString().isNotEmpty &&
            storage.getItem('pinCode') != null) {
          String pin = storage.getItem('pinCode').toString();
          pincodeController.text = pin;
          setState(() {});
        }

        final savedCoupon = cartModel.savedCoupon;
        couponController.text = savedCoupon ?? '';
        _productsInCartJson = jsonEncode(cartModel.productsInCart);
      }
    });
    if (firstTimeCoupon == false) {
      onloadCoupon();
    }
  }

  onloadCoupon() async {
    var discountCodes = await getDiscountCodes();
    await createDiscount(
        couponCode: discountCodes?.data?[recordNumber].discountCode ?? '',
        priceRuleId: discountCodes?.data?[recordNumber].priceRuleId ?? '');
    try {
      await checkCoupon(
          discountCodes?.data?[recordNumber].discountCode ?? '', cartModel);
      cartModel.isCouponApplied = true;
      selectedIndex = 0;
    } catch (e) {
      cartModel.isCouponApplied = false;
    }
  }

  void _onProductInCartChange(CartModel cartModel) {
    // If app success a coupon before
    // Need to apply again when any change in cart
    EasyDebounce.debounce(
        _debounceApplyCouponTag, const Duration(milliseconds: 300), () {
      if (cartModel.productsInCart.isEmpty) {
        removeCoupon(cartModel);
        return;
      }
      final newData = jsonEncode(cartModel.productsInCart);
      if (_productsInCartJson != newData) {
        _productsInCartJson = newData;
        checkCoupon(couponController.text, cartModel);
      }
    });
  }

  var totalOrders;
  var moons;
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (totalOrders == null &&
          Provider.of<UserModel>(context, listen: false).user != null) {
        totalOrders = await Services().api.getMyOrders(
              user: Provider.of<UserModel>(context, listen: false).user,
            );
      } else {}
    });
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  // @override
  // void dispose() {
  //   // couponController.dispose();
  //   super.dispose();
  // }

  getErrorText() {
    if (pincodeController.text.isEmpty) {
      return 'Enter pincode to checkout';
    }
    if (pincodeController.text.length != 6) {
      return 'Incorrect pincode';
    }
  }

  Future<void> getCoupon() async {
    try {
      coupons = await services.api.getCoupons();
    } catch (e) {
      //  print(e.toString());
    }
  }

  void showError(String message) {
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Check coupon code
  checkCoupon(String couponCode, CartModel cartModel) {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
      return;
    }
    cartModel.setLoadingDiscount();

    Services().widget.applyCoupon(
      context,
      coupons: coupons,
      code: couponCode,
      success: (Discount discount) async {
        try {
          await cartModel.updateDiscount(discount: discount);
        } on Exception catch (e) {
          cartModel.setLoadedDiscount();
        }
        cartModel.setLoadedDiscount();
      },
      error: (String errMess) {
        log("____HERE IN ERROR");

        if (cartModel.couponObj != null) {
          removeCoupon(cartModel);
        }
        cartModel.setLoadedDiscount();
        var user = Provider.of<UserModel>(context, listen: false);
        user.errorMsg = errMess;
        // showError(errMess);
      },
    );
  }

  Future applyTextCoupon(String couponCode, CartModel cartModel) async {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
    }

    cartModel.setLoadingDiscount();

    await Services().widget.applyCoupon(
      context,
      coupons: coupons,
      code: couponCode,
      success: (Discount discount) async {
        await cartModel.updateDiscount(discount: discount);
        cartModel.setLoadedDiscount();
        Navigator.of(context).pop();
      },
      error: (String errMess) {
        if (cartModel.couponObj != null) {
          removeCoupon(cartModel);
        }
        cartModel.setLoadedDiscount();
        var user = Provider.of<UserModel>(context, listen: false);
        user.errorMsg = errMess;
        // Navigator.of(context).pop();
        // showError(errMess);
      },
    );
    var isFalse;
    return isFalse;
  }

  Future<void> removeCoupon(CartModel cartModel) async {
    await Services().widget.removeCoupon(context);
    cartModel.resetCoupon();
    cartModel.discountAmount = 0.0;
    cartModel.setLoadedDiscount();

    setState(() {});
  }

  Future createDiscount(
      {required String couponCode, required String priceRuleId}) async {
    var headers = {'Content-Type': 'application/json'};
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

  var couponSnapshot;

  @override
  Widget build(BuildContext context) {
    var progressVm = Provider.of<ProgressTrackingVM>(context, listen: false);
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final smallAmountStyle =
        TextStyle(color: Theme.of(context).colorScheme.secondary);
    final largeAmountStyle = TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontSize: 20,
    );
    final formatter = NumberFormat.currency(
      locale: 'en',
      symbol: defaultCurrency?.symbol,
      decimalDigits: defaultCurrency?.decimalDigits,
    );
    final screenSize = MediaQuery.of(context).size;
    log("___________not_EMPTY:${storage.getItem('pinCode').toString().isNotEmpty}");

    return Consumer<CartModel>(builder: (context, cartModel, child) {
      cartModel.productsInCart.forEach((key, value) async {
        var productId = Product.cleanProductID(key);
        quantity = cartModel.productsInCart[key] ?? 0;
        product = cartModel.getProductById(productId);
        log('product: $product quantity ${cartModel.productsInCart[key]}');
      });
      for (var i = 0;
          i < int.parse(product?.tags.length.toString() ?? '0');
          i++) {
        log('this bogo ${product?.tags[i].id}');
        if ((product?.tags[i].id == 'bogo' ||
                product?.tags[i].id == 'buy1getany1') &&
            quantity == 2) {
          isBogo = true;
        }
      }

      // ignore: unused_local_variable
      var couponMsg = '';
      var isApplyCouponSuccess = false;
      if (cartModel.couponObj != null &&
          (cartModel.couponObj!.amount ?? 0) > 0) {
        isApplyCouponSuccess = true;
        _onProductInCartChange(cartModel);
        couponController.text = cartModel.couponObj!.code ?? '';
        // couponController.text = couponList[selectedIndex] ?? '';
        couponMsg = S.of(context).couponMsgSuccess;
        if (cartModel.couponObj!.discountType == 'percent') {
          couponMsg += ' ${cartModel.couponObj!.amount}% OFF';
        } else {
          couponMsg += ' - ${formatter.format(cartModel.couponObj!.amount)}';
        }
      } else {
        couponController.clear();
      }
      if (cartModel.productsInCart.isEmpty) {
        return const SizedBox();
      }
      final enablePointReward = !cartModel.isWalletCart();
      if (cartModel.couponObj != null) {
        moons = 0.25 *
            ((cartModel.checkout?.subtotalPrice ?? 0) +
                (double.parse(
                    '${double.parse(cartModel.checkout?.totalPrice.toString() ?? '0') / (100.0 - double.parse(cartModel.couponObj?.amount.toString() ?? '0')) * 100 - double.parse(cartModel.checkout?.totalPrice.toString() ?? '0')}')));
      } else {
        moons = 0.25 * cartModel.getTotal()! - cartModel.getShippingCost()!;
      }

      double getClosestToHundred(double value) {
        double lowerValue = (value / 100).floorToDouble() * 100;
        double upperValue = lowerValue + 100;

        if ((value - lowerValue) <= (upperValue - value)) {
          return lowerValue;
        } else {
          return upperValue;
        }
      }

      return SizedBox(
        width: screenSize.width,
        child: SizedBox(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 12.0, bottom: 4.0, left: 8.0, right: 8.0),
                child: Container(
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    gradient: LinearGradient(
                      colors: [Color(0xff0B2041), Color(0xff0F345C)],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
                        child: SizedBox(
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          child: Image.asset(
                            'assets/images/moonIcon.png',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 16.0),
                        child: Text(
                          '${getClosestToHundred(moons)} Moons will be credited to your wallet',
                          style: const TextStyle(
                              fontFamily: 'Roboto',
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: const [
                    Text(
                      'Use pincode to check delivery info',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextField(
                  keyboardType: TextInputType.number,
                  // focusNode: myFocusNode,
                  onChanged: (val) {
                    setState(() {
                      responseMsg = '';
                      if (pincodeController.text.isNotEmpty) {
                        pincodeSubmit = true;
                      } else if (fromCart != null) {
                        pinCode = pincodeController.text;
                      }
                    });
                  },
                  controller: pincodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter pincode to checkout',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    suffixIcon: Container(
                      margin:
                          const EdgeInsets.only(top: 5, bottom: 5, right: 10),
                      child: Consumer<UserModel>(builder: (context, userVm, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 35),
                            backgroundColor: pincodeController.text.length != 6
                                ? const Color(0xFFE5E5E5)
                                : const Color(0xFFFF8277),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          child: Text('Submit',
                              style: TextStyle(
                                color: pincodeController.text.length != 6
                                    ? const Color(0xffC0C0C0)
                                    : Colors.white,
                              )),
                          onPressed: () {
                            if (pincodeController.text.length < 6) {
                              Fluttertoast.showToast(
                                  msg: 'Please enter a valid pincode',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[600],
                                  textColor: Colors.white);
                            } else {
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              List cproducts = [];
                              cartModel.productsInCart.forEach((key, value) {
                                var productId = Product.cleanProductID(key);

                                product = cartModel.getProductById(productId);
                                log('product: $product quantity ${cartModel.productsInCart[key]}');

                                var dId = utf8.decode(productId.codeUnits);

                                var pId =
                                    dId.replaceAll(RegExp(r'[^0-9]'), '');
                                cproducts.add('{"id":$pId,"quantity": $value}');
                                userVm.enterPincode = false;
                                userVm.notifyListeners();
                              });
                              GeneralApis()
                                  .pincodeCheck(
                                      pincode: pincodeController.text,
                                      products: cproducts)
                                  .then((value) {
                                setState(() {
                                  if (value['status'] == 200) {
                                    serviceable = true;
                                    storage.setItem(
                                        'pinCode', pincodeController.text);
                                    log("__________PINCODE HER:${storage.getItem('pinCode')}");
                                    responseMsg = 'Free Delivery by';
                                    deliveryDate = value['data']
                                        ['available_courier_companies'][(value[
                                                    'data']
                                                ['available_courier_companies'])
                                            .length -
                                        1]['etd'];
                                    userVm.canCheckout = true;
                                  } else {
                                    serviceable = false;
                                    responseMsg =
                                        'Sorry, we don\'t deliver to this location';
                                    link = value['link'];

                                    userVm.canCheckout = false;
                                  }
                                  userVm.notifyListeners();
                                });
                              });
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Consumer<UserModel>(builder: (context, userVm, _) {
                return userVm.enterPincode == true
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Submit pincode to checkout',
                                style: TextStyle(
                                    color: Color(0xffBD0E0E),
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox();
              }),

              if (responseMsg != '' && serviceable == true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: responseMsg,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                          children: <TextSpan>[
                            TextSpan(
                                text: ' $deliveryDate',
                                style: const TextStyle(
                                    color: Color(0xFF109E2F),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (responseMsg != '' && serviceable == false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: responseMsg,
                          style: const TextStyle(
                              color: Color(0xffBD0E0E),
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ),
              if (responseMsg != '' && serviceable == false)
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xffD9FEDE),
                      // border: Border.all(color: Colors.green)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text(
                            'But we are on Amazon too!',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: GestureDetector(
                              onTap: () {
                                launchUrl(Uri.parse(link));
                              },
                              child:
                                  Image.asset('assets/images/amazonButton.png'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: const [
                    Text(
                      'Offers & Coupons',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 12.0, left: 12.0, bottom: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Color.fromRGBO(178, 178, 178, 1)),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10.0, vertical: 10.0),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       Expanded(
                      //         child: Container(
                      //           margin: const EdgeInsets.only(
                      //               top: 5.0, bottom: 5.0),
                      //           decoration: _enable
                      //               ? BoxDecoration(
                      //                   color:
                      //                       Theme.of(context).backgroundColor)
                      //               : const BoxDecoration(
                      //                   color: Color(0xFFF1F2F3)),
                      //           child: GestureDetector(
                      //             onTap: _showCouponList ? () {} : null,
                      //             child: TextField(
                      //               controller: couponController,
                      //               enabled: _enable && !_loading,
                      //               decoration: InputDecoration(
                      //                   prefixIcon: _showCouponList
                      //                       ? Icon(
                      //                           CupertinoIcons.search,
                      //                           color: Theme.of(context)
                      //                               .primaryColor,
                      //                         )
                      //                       : null,
                      //                   labelText: _enable
                      //                       ? S.of(context).couponCode
                      //                       : cartModel.couponObj?.code,
                      //                   //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                      //                   contentPadding:
                      //                       const EdgeInsets.all(2)),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Container(
                      //         width: 10,
                      //       ),
                      //       ElevatedButton.icon(
                      //         style: ElevatedButton.styleFrom(
                      //           foregroundColor: Theme.of(context).primaryColor,
                      //           backgroundColor:
                      //               Theme.of(context).primaryColorLight,
                      //           elevation: 0.0,
                      //         ),
                      //         label: Text(
                      //           cartModel.calculatingDiscount
                      //               ? S.of(context).loading
                      //               : !isApplyCouponSuccess
                      //                   ? S.of(context).apply
                      //                   : S.of(context).remove,
                      //         ),
                      //         icon: const Icon(
                      //           CupertinoIcons.checkmark_seal_fill,
                      //           size: 18,
                      //         ),
                      //         onPressed: !cartModel.calculatingDiscount
                      //             ? () {
                      //                 if (!isApplyCouponSuccess) {
                      //                   WebEngagePlugin.trackEvent(
                      //                       'Coupon Code Applied', {
                      //                     'Value Entered': true,
                      //                     'Coupon code': couponController.text
                      //                   });
                      //                   checkCoupon(
                      //                       couponController.text, cartModel);
                      //                 } else {
                      //                   removeCoupon(cartModel);
                      //                 }
                      //               }
                      //             : null,
                      //       )
                      //     ],
                      //   ),
                      // ),
                      cartModel.isCouponApplied &&
                              (double.parse(
                                          '${double.parse(cartModel.checkout?.totalPrice.toString() ?? '0') / (100.0 - double.parse(cartModel.couponObj?.amount.toString() ?? '0')) * 100 - double.parse(cartModel.checkout?.totalPrice.toString() ?? '0')}')
                                      .toStringAsFixed(2) !=
                                  '0.00')
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color.fromRGBO(178, 178, 178, 1))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.discount,
                                          color:
                                              Color.fromRGBO(255, 130, 119, 1),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0,
                                              bottom: 16.0,
                                              top: 16.0),
                                          child: Column(
                                            children: [
                                              const Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Coupon Applied!',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          51, 51, 51, 1),
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Gilmer'),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'You just saved ₹${double.parse('${double.parse(cartModel.checkout?.totalPrice.toString() ?? '0') / (100.0 - double.parse(cartModel.couponObj?.amount.toString() ?? '0')) * 100 - double.parse(cartModel.checkout?.totalPrice.toString() ?? '0')}').toStringAsFixed(2)}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                      color: Color(0xff109E2F),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'Gilmer',
                                                      fontStyle:
                                                          FontStyle.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TextButton(
                                        onPressed: () async {
                                          cartModel.setLoadingDiscount();
                                          setState(() {});
                                          await Future.delayed(const Duration(
                                                  milliseconds: 2))
                                              .then((value) async {
                                            await removeCoupon(cartModel);
                                          });
                                          cartModel.isCouponApplied = false;
                                          cartModel.notifyListeners();
                                          selectedIndex = null;
                                        },
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 130, 119, 1),
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14),
                                        )),
                                  )
                                  // Padding(
                                  //     padding:
                                  //         const EdgeInsets.only(right: 20.0),
                                  //     child: GestureDetector(
                                  //         onTap: () async {
                                  //           await removeCoupon(cartModel);
                                  //           isCouponApplied = false;
                                  //           selectedIndex = null;
                                  //         },
                                  //         child: const Text(
                                  //           'Remove',
                                  //           style: TextStyle(
                                  //               color: Color.fromRGBO(
                                  //                   255, 130, 119, 1),
                                  //               fontFamily: 'Roboto',
                                  //               fontWeight: FontWeight.w600,
                                  //               fontSize: 14),
                                  //         ))),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: () async {
                                isBogo == false
                                    ? Get.dialog(
                                        buildPopup(
                                          isApplyCouponSuccess:
                                              isApplyCouponSuccess,
                                          initialTotalPrice: initialTotalPrice,
                                          couponList: Provider.of<UserModel>(
                                                          context,
                                                          listen: false)
                                                      .user ==
                                                  null
                                              ? couponList
                                              : totalOrders.data.length != 0
                                                  ? couponList
                                                  : welcomeCouponList,
                                        ),
                                      )
                                    : () {};
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0)),
                                    color: const Color(0xffE9FAF5),
                                    border: Border.all(
                                        color: const Color(0xff177D5D),
                                        width: 1.5,
                                        style: BorderStyle.solid)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 14.0, right: 14.0),
                                      child: Icon(
                                        Icons.discount_sharp,
                                        size: 22,
                                        color: isBogo
                                            ? const Color(0xffC0C0C0)
                                            : const Color(0xff177D5D),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16.0, top: 16.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Click here to apply ',
                                              style: TextStyle(
                                                color: isBogo
                                                    ? const Color(0xffC0C0C0)
                                                    : const Color(0xff177D5D),
                                                fontSize: 14,
                                                fontWeight: isBogo
                                                    ? FontWeight.normal
                                                    : FontWeight.w400,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'discount',
                                              style: TextStyle(
                                                color: isBogo
                                                    ? const Color(0xffC0C0C0)
                                                    : const Color(0xff177D5D),
                                                fontSize: 14,
                                                fontWeight: isBogo
                                                    ? FontWeight.normal
                                                    : FontWeight.w700,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 80.0, right: 1.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 22,
                                        color: isBogo
                                            ? const Color(0xffC0C0C0)
                                            : const Color(0xff177D5D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              isBogo
                  ? const Padding(
                      padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        'Discount codes cannot be applied on special products ',
                        style: TextStyle(
                            color: Color(0xffBD0E0E),
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  : const SizedBox.shrink(),

              if ((selectedIndex != null && selectedIndex == 0) &&
                  double.parse(
                              '${double.parse(cartModel.checkout?.totalPrice.toString() ?? '0') / (100.0 - double.parse(cartModel.couponObj?.amount.toString() ?? '0')) * 100 - double.parse(cartModel.checkout?.totalPrice.toString() ?? '0')}')
                          .toStringAsFixed(2) !=
                      '0.00')
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/appOnlyDiscount.jpg',
                      )),
                ),
              // if (isApplyCouponSuccess)
              //   Padding(
              //     padding: const EdgeInsets.only(
              //       left: 20,
              //       right: 20,
              //       bottom: 15,
              //     ),
              //     child: Text(
              //       couponMsg,
              //       style: TextStyle(color: Colors.green[400]),
              //       textAlign: TextAlign.start,
              //     ),
              //   ),
              if (enablePointReward) const PointReward(),
              if (widget.showPrice)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 15.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).products,
                                  style: smallAmountStyle,
                                ),
                              ),
                              Text(
                                'x${cartModel.totalCartQuantity}',
                                style: smallAmountStyle,
                              ),
                            ],
                          ),
                          if (cartModel.rewardTotal > 0) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(S.of(context).cartDiscount,
                                      style: smallAmountStyle),
                                ),
                                Text(
                                  PriceTools.getCurrencyFormatted(
                                      cartModel.rewardTotal, currencyRate,
                                      currency: currency)!,
                                  style: smallAmountStyle,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${S.of(context).total}:',
                                  style: largeAmountStyle,
                                ),
                              ),
                              cartModel.calculatingDiscount
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : Text(
                                      PriceTools.getCurrencyFormatted(
                                          cartModel.getTotal()! -
                                              cartModel.getShippingCost()!,
                                          currencyRate,
                                          currency: cartModel.isWalletCart()
                                              ? defaultCurrency?.currencyCode
                                              : currency)!,
                                      style: largeAmountStyle,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Services().widget.renderRecurringTotals(context),
            ],
          ),
        ),
      );
    });
  }
}
