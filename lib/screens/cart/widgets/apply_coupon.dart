import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../../app.dart';
import '../../../common/config.dart';
import '../../../env.dart';
import '../../../generated/l10n.dart';
import '../../../models/cart/cart_model.dart';
import '../../../models/cart/discount_coupons.dart';
import '../../../models/entities/coupon.dart';
import '../../../models/user_model.dart';
import '../../../services/service_config.dart';
import '../../../services/services.dart';
import '../../../widgets/common/loading_widget.dart';
import 'shopping_cart_sumary.dart';

class buildPopup extends StatefulWidget {
  bool isApplyCouponSuccess;
  var initialTotalPrice;
  var couponList;
  buildPopup(
      {super.key,
      required this.isApplyCouponSuccess,
      required this.initialTotalPrice,
      required this.couponList});

  @override
  State<buildPopup> createState() => _buildPopupState();
}

class _buildPopupState extends State<buildPopup> {
  final services = Services();
  Coupons? coupons;
  final bool _enable = true;
  bool pincodeSubmit = false;
  final bool _loading = false;
  var responseMsg = '';

  String link = '';
  var deliveryDate;
  String? pinCode;

  bool serviceable = false;
  bool isBogo = false;

  final defaultCurrency = kAdvanceConfig.defaultCurrency;

  CartModel get cartModel =>
      Provider.of<CartModel>(Get.context!, listen: false);
  final LocalStorage storage = LocalStorage('localStorage_app');

  final couponController = TextEditingController();
  final pincodeController = TextEditingController();

  final bool _showCouponList = kAdvanceConfig.showCouponList &&
      ServerConfig().type != ConfigType.magento;

  DiscountCoupon? discountCoupon;
  // var selectedIndex;

  var secondCoupon = 'APPDISCOUNT15';
  var thirdCoupon = 'REBUY10';
  var couponDescription = [
    'Get 20% off',
    'Get 15% off',
    'Get 10% off',
    'Get 25% off'
  ];

  var recordNumber;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getDiscountCodes();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: cartModel.calculatingDiscount
          ? SizedBox(height: Get.height * .5, child: const LoadingWidget())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 15),
                  child: Row(
                    children: const [
                      Text(
                        'Apply Coupon',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 5.0, right: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          decoration: _enable
                              ? BoxDecoration(
                                  color: Theme.of(context).backgroundColor)
                              : const BoxDecoration(color: Color(0xFFF1F2F3)),
                          child: GestureDetector(
                            onTap: _showCouponList ? () {} : null,
                            child: TextField(
                              controller: couponController,
                              enabled: _enable && !_loading,
                              onChanged: (value) {
                                setState(() {
                                  isPopup = false;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: _enable
                                      ? 'Enter coupon code'
                                      : cartModel.couponObj?.code,
                                  //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                                  contentPadding: const EdgeInsets.all(2)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 35),
                            backgroundColor: couponController.text == ''
                                ? const Color(0xFFFF8277)
                                : const Color(0xFFFF8277),
                          ),
                          onPressed: !cartModel.calculatingDiscount
                              ? () async {
                                  if (!widget.isApplyCouponSuccess) {
                                    await applyTextCoupon(
                                            couponController.text, cartModel)
                                        .then((value) {
                                      setState(() {});
                                    });

                                    cartModel.isCouponApplied = true;
                                    cartModel.notifyListeners();
                                    // if (user.errorMsg ==
                                    //     'Your coupon code is invalid') {
                                    //   Fluttertoast.showToast(
                                    //       msg: user.errorMsg,
                                    //       toastLength: Toast.LENGTH_SHORT,
                                    //       gravity: ToastGravity.BOTTOM,
                                    //       timeInSecForIosWeb: 1,
                                    //       backgroundColor: Colors.grey[600],
                                    //       textColor: Colors.white);
                                    // }

                                  } else {
                                    unawaited(removeCoupon(cartModel));
                                  }
                                }
                              : null,
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto'),
                          ))
                    ],
                  ),
                ),
                isPopup
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text:
                                    'Sorry, this coupon does not exist. Try one of the coupons below.',
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
                    : const SizedBox(),
                SizedBox(
                    height: 350,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        itemCount: widget.couponList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Your desired background color
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 10),
                                  ]),
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.discount_outlined,
                                          color: Color(0xFFFF8277)),
                                    ],
                                  ),
                                  title: Text(
                                    widget.couponList[index] ?? '',
                                    style: const TextStyle(
                                        color: Color.fromRGBO(51, 51, 51, 1),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Gilmer'),
                                  ),
                                  subtitle: Text(
                                    couponDescription[index],
                                    style: const TextStyle(
                                        color: Color.fromRGBO(114, 114, 114, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Gilmer'),
                                  ),
                                  trailing: TextButton(
                                      child: const Text(
                                        'Apply',
                                        style:
                                            TextStyle(color: Color(0xFFFF8277)),
                                      ),
                                      onPressed: () async {
                                        setState(() {});
                                        selectedIndex = index;
                                        if (index == 0) {
                                          await createDiscount(
                                                  couponCode: widget
                                                          .couponList[index] ??
                                                      '',
                                                  priceRuleId: '1224921284856')
                                              .then((value) async {
                                            await checkCoupon(
                                                widget.couponList[index] ?? '',
                                                cartModel);
                                            setEndDate = true;
                                            // cartModel.isCouponApplied = true;
                                            // cartModel.notifyListeners();
                                            // firstTimeCoupon = true;
                                          });
                                          Navigator.of(context).pop();
                                        } else if (index == 3) {
                                          await checkCoupon(
                                              'WELCOMEAPP25', cartModel);
                                          // cartModel.isCouponApplied = true;
                                          // cartModel.notifyListeners();
                                          couponController.text =
                                              widget.couponList[index];
                                          Navigator.of(context).pop();
                                        } else {
                                          initialTotalPrice =
                                              cartModel.checkout?.totalPrice ??
                                                  0.0;
                                          await checkCoupon(
                                              widget.couponList[index] ?? '',
                                              cartModel);
                                          // cartModel.isCouponApplied = true;
                                          // cartModel.notifyListeners();
                                          // firstTimeCoupon = true;

                                          Navigator.of(context).pop();
                                        }
                                      })),
                            ),
                          );
                        }))
              ],
            ),
    );
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

  checkCoupon(String couponCode, CartModel cartModel) {
    if (couponCode.isEmpty) {
      showError(S.of(Get.context!).pleaseFillCode);
      return;
    }
    // Navigator.pop(Get.context!);
    cartModel.setLoadingDiscount();

    Services().widget.applyCoupon(
      Get.context!,
      coupons: coupons,
      code: couponCode,
      success: (Discount discount) async {
        cartModel.isCouponApplied = true;

        cartModel.notifyListeners();
        try {
          await cartModel.updateDiscount(discount: discount);
        } on Exception catch (e) {
          Future.delayed(const Duration(milliseconds: 400), () {
            cartModel.setLoadedDiscount();
            cartModel.notifyListeners();
            log('now it works after 400');
          });
        }
        Future.delayed(const Duration(milliseconds: 400), () {
          cartModel.setLoadedDiscount();
          cartModel.notifyListeners();

          log('now it works after 400');
        });
      },
      error: (String errMess) {
        if (cartModel.couponObj != null) {
          removeCoupon(cartModel);
        }
        Future.delayed(const Duration(milliseconds: 900), () {
          cartModel.setLoadedDiscount();
        });
        var user = Provider.of<UserModel>(Get.context!, listen: false);
        user.errorMsg = errMess;
        // showError(errMess);
      },
    );
  }

  Future applyTextCoupon(String couponCode, CartModel cartModel) async {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
    }

    await Services().widget.applyCoupon(
      context,
      coupons: coupons,
      code: couponCode,
      success: (Discount discount) async {
        await cartModel.updateDiscount(discount: discount);

        Navigator.of(context).pop();
      },
      error: (String errMess) {
        isPopup = true;
        if (cartModel.couponObj != null) {
          removeCoupon(cartModel);
        }
        cartModel.setLoadedDiscount();
        var user = Provider.of<UserModel>(context, listen: false);
        user.errorMsg = errMess;
        // Navigator.of(context).pop();
        showError(errMess);
      },
    );
    var isFalse;
    return isFalse;
  }

  Future<void> removeCoupon(CartModel cartModel) async {
    await Services().widget.removeCoupon(context);
    cartModel.resetCoupon();
    cartModel.discountAmount = 0.0;
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
}
