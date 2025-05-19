import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inspireui/inspireui.dart' show AutoHideKeyboard, printLog;
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../common/tools/flash.dart';
import '../../env.dart';
import '../../generated/l10n.dart';
import '../../menu/index.dart' show MainTabControlDelegate;
import '../../models/cart/checkout_shopify.dart';
import '../../models/entities/address.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, UserModel;
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/product/cart_item.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../checkout/checkout_screen.dart';
import 'widgets/empty_cart.dart';
import 'widgets/shopping_cart_sumary.dart';

bool bogo = false;

// Move createShoppingCartRows is outside MyCart to reuse for POS
List<Widget> createShoppingCartRows(CartModel model, BuildContext context) {
  // ignore: curly_braces_in_flow_control_structures
  model.productsInCart.forEach((key, value) async {
    var productId = Product.cleanProductID(key);
    var productCheck = await Services().api.getProduct(productId);
    var product = model.getProductById(productId);

    // remove product if its out of stock
    if (productCheck?.inStock != true) {
      model.removeItemFromCart(key);
    }

    var cartQty = model.productsInCart[key];
    var availQty = productCheck?.stockQuantity;

    // minus product quantity if not available. CODE GOES BELOW
    if (availQty != null && cartQty! > availQty) {
      model.updateQuantity(product!, key, availQty);
    }
  });
  // final currencyRate = Provider.of<AppModel>(context).currencyRate;
  // final currency = Provider.of<AppModel>(context).currency;
  // final defaultCurrency = kAdvanceConfig.defaultCurrency;
  var productList = [];
  productList.add(model.productsInCart);

  return model.productsInCart.keys.map(
    (key) {
      print((model.getTotal()! - model.getShippingCost()!).round().runtimeType);
      var productId = Product.cleanProductID(key);
      var product = model.getProductById(productId);
      var productList = [];
      productList.add(product?.name);

      for (var i = 0;
          i < int.parse(product?.tags.length.toString() ?? '0');
          i++) {
        print(product?.tags[i].id);
        if (product?.tags[i].id == 'bogo' || product?.tags[i].id == 'buy1getany1' ) {}
      }

      if (product != null) {
        return ShoppingCartRow(
          product: product,
          addonsOptions: model.productAddonsOptionsInCart[key],
          variation: model.getProductVariationById(key),
          quantity: model.productsInCart[key],
          options: model.productsMetaDataInCart[key],
          onRemove: () {
            model.removeItemFromCart(
              key,
            );
            for (var i = 0;
                i < int.parse(product?.tags.length.toString() ?? '0');
                i++) {
              print(product?.tags[i].id);
              if (product?.tags[i].id == 'bogo' || product?.tags[i].id == 'buy1getany1') {
                bogo = false;
              }
            }
          },
          onChangeQuantity: (val) {
            var message = model.updateQuantity(product, key, val);
            if (message.isNotEmpty) {
              final snackBar = SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 1),
              );
              Future.delayed(
                const Duration(milliseconds: 300),
                () => ScaffoldMessenger.of(context).showSnackBar(snackBar),
              );
            }
          },
        );
      }
      return const SizedBox();
    },
  ).toList();
}

class MyCart extends StatefulWidget {
  final bool? isModal;
  final bool? isBuyNow;
  final bool hasNewAppBar;
  final ScrollController? scrollController;

  const MyCart({
    this.isModal,
    this.isBuyNow = false,
    this.hasNewAppBar = false,
    this.scrollController,
  });

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  final services = Services();
  String errMsg = '';
  var recordNumber;

  CartModel get cartModel => Provider.of<CartModel>(context, listen: false);

  void _loginWithResult(BuildContext context) async {
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => LoginScreen(
    //       fromCart: true,
    //     ),
    //     fullscreenDialog: kIsWeb,
    //   ),
    // );
    await FluxNavigate.pushNamed(
      RouteList.login,
    ).then((value) async {
      var cartModel = Provider.of<CartModel>(context, listen: false);
      var checkout = await Services()
          .api
          .checkoutLinkUser(cartModel.checkout?.id, cartModel.user?.cookie);
      // final newCheckout = await (checkoutLinkUser(checkoutId, token));
      CheckoutCart.fromJsonShopify(checkout ?? {});
      final user = Provider.of<UserModel>(context, listen: false).user;
      if (user != null && user.name != null) {
        Tools.showSnackBar(ScaffoldMessenger.of(context),
            '${S.of(context).welcome} ${user.name} !');
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<CartModel>(context, listen: false);
    model.productsInCart.keys.map(
      (key) {
        print(
            (model.getTotal()! - model.getShippingCost()!).round().runtimeType);
        var productId = Product.cleanProductID(key);
        var product = model.getProductById(productId);
        var productList = [];
        productList.add(product?.name);

        for (var i = 0;
            i < int.parse(product?.tags.length.toString() ?? '0');
            i++) {
          print(product?.tags[i].id);
          if (product?.tags[i].id == 'bogo' || product?.tags[i].id == 'buy1getany1') {
            bogo = true;
            print('this is bogo');
          }
        }

        if (product != null) {
          return ShoppingCartRow(
            product: product,
            addonsOptions: model.productAddonsOptionsInCart[key],
            variation: model.getProductVariationById(key),
            quantity: model.productsInCart[key],
            options: model.productsMetaDataInCart[key],
            onRemove: () {
              model.removeItemFromCart(
                key,
              );
            },
            onChangeQuantity: (val) {
              var message = model.updateQuantity(product, key, val);
              if (message.isNotEmpty) {
                final snackBar = SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 1),
                );
                Future.delayed(
                  const Duration(milliseconds: 300),
                  () => ScaffoldMessenger.of(context).showSnackBar(snackBar),
                );
              }
            },
          );
        }
      },
    ).toList();
    printLog('[Cart] build');

    final localTheme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    var layoutType = Provider.of<AppModel>(context).productDetailLayout;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final canPop = parentRoute?.canPop ?? false;

    return Consumer2<UserModel, CartModel>(
        builder: (context, userVm, cartModel, _) {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(left: 90, right: 70),
          child: Selector<CartModel, bool>(
            selector: (_, cartModel) => cartModel.calculatingDiscount,
            builder: (context, calculatingDiscount, child) {
              return TextButton(
                onPressed: calculatingDiscount
                    ? null
                    : () {
                        if (userVm.canCheckout ||
                            cartModel.totalCartQuantity <= 0) {
                          if (kAdvanceConfig.alwaysShowTabBar) {
                            setState(() {
                              enterPincode = false;
                            });
                            MainTabControlDelegate.getInstance()
                                .changeTab(RouteList.cart, allowPush: false);
                            // return;
                          }
                          onCheckout(cartModel);
                        }
                        if (userVm.canCheckout == false) {
                          userVm.enterPincode = true;
                          userVm.notifyListeners();
                          setState(() {});
                        }
                      },
                style: TextButton.styleFrom(
                  backgroundColor: cartModel.totalCartQuantity <= 0
                      ? const Color(0xFFFF8277)
                      : userVm.canCheckout
                          ? const Color(0xFFFF8277)
                          : const Color(0xFFE5E5E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: userVm.canCheckout ? 4 : 0,
                ),
                child: child!,
              );
            },
            child: Selector<CartModel, int>(
              selector: (_, carModel) => cartModel.totalCartQuantity,
              builder: (context, totalCartQuantity, child) {
                // if (totalCartQuantity == 0) {
                //   return const SizedBox();
                // }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      totalCartQuantity > 0
                          ? (isLoading
                              ? Text(S.of(context).loading.toUpperCase())
                              : (Provider.of<UserModel>(context, listen: false)
                                          .user !=
                                      null
                                  ? Text(
                                      S.of(context).checkout.toUpperCase(),
                                      style: TextStyle(
                                          color: userVm.canCheckout
                                              ? Colors.white
                                              : const Color(0xFFC0C0C0),
                                          fontSize: 16.0,
                                          fontFamily: 'Roboto'),
                                    )
                                  : const Text('LOGIN TO CHECKOUT')))
                          : Text(
                              S.of(context).startShopping.toUpperCase(),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        body: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            MediaQuery.removePadding(
              context: context,
              removeTop: widget.hasNewAppBar && widget.isModal != true,
              child: SliverAppBar(
                pinned: true,
                centerTitle: false,
                leading: widget.isModal == true
                    ? CloseButton(
                        onPressed: () {
                          if (widget.isBuyNow!) {
                            Navigator.of(context).pop();
                            return;
                          }

                          if (Navigator.of(context).canPop() &&
                              layoutType != 'simpleType') {
                            Navigator.of(context).pop();
                          } else {
                            ExpandingBottomSheet.of(context, isNullOk: true)
                                ?.close();
                          }
                        },
                      )
                    : canPop
                        ? const BackButton()
                        : null,
                backgroundColor: Theme.of(context).backgroundColor,
                title: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    S.of(context).myCart,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Selector<CartModel, int>(
                selector: (_, cartModel) => cartModel.totalCartQuantity,
                builder: (context, totalCartQuantity, child) {
                  return AutoHideKeyboard(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: Column(
                            children: [
                              if (totalCartQuantity > 0)
                                Container(
                                  // decoration: BoxDecoration(
                                  //     color: Theme.of(context).primaryColorLight),
                                  padding: const EdgeInsets.only(
                                    right: 15.0,
                                    top: 4.0,
                                  ),
                                  child: SizedBox(
                                    width: screenSize.width,
                                    child: SizedBox(
                                      width: screenSize.width /
                                          (2 /
                                              (screenSize.height /
                                                  screenSize.width)),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 25.0),
                                          Text(
                                            S.of(context).total.toUpperCase(),
                                            style: localTheme
                                                .textTheme.subtitle1!
                                                .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '$totalCartQuantity ${S.of(context).items}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Tools.isRTL(context)
                                                  ? Alignment.centerLeft
                                                  : Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  if (totalCartQuantity > 0) {
                                                    showDialog(
                                                      context: context,
                                                      useRootNavigator: false,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          content: Text(S
                                                              .of(context)
                                                              .confirmClearTheCart),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(S
                                                                  .of(context)
                                                                  .keep),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                cartModel
                                                                    .clearCart();
                                                              },
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .clear,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  S
                                                      .of(context)
                                                      .clearCart
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (totalCartQuantity > 0)
                                const Divider(
                                  height: 1,
                                  // indent: 25,
                                ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(height: 16.0),
                                  if (totalCartQuantity > 0)
                                    Column(
                                      children: createShoppingCartRows(
                                          cartModel, context),
                                    ),
                                  const ShoppingCartSummary(),
                                  if (totalCartQuantity == 0) EmptyCart(),
                                  if (errMsg.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Text(
                                        errMsg,
                                        style:
                                            const TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  const SizedBox(height: 4.0),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }

  void onCheckout(CartModel model) {
    var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    var message;

    if (isLoading) return;

    if (kCartDetail['minAllowTotalCartValue'] != null) {
      if (kCartDetail['minAllowTotalCartValue'].toString().isNotEmpty) {
        var totalValue = model.getSubTotal() ?? 0;
        var minValue = PriceTools.getCurrencyFormatted(
            kCartDetail['minAllowTotalCartValue'], currencyRate,
            currency: currency);
        if (totalValue < kCartDetail['minAllowTotalCartValue'] &&
            model.totalCartQuantity > 0) {
          message = '${S.of(context).totalCartValue} $minValue';
        }
      }
    }

    if (kVendorConfig.disableMultiVendorCheckout &&
        ServerConfig().isVendorType()) {
      if (!model.isDisableMultiVendorCheckoutValid(
          model.productsInCart, model.getProductById)) {
        message = S.of(context).youCanOnlyOrderSingleStore;
      }
    }

    if (message != null) {
      FlashHelper.errorMessage(context, message: message);

      return;
    }

    if (model.totalCartQuantity == 0) {
      if (widget.isModal == true) {
        try {
          ExpandingBottomSheet.of(context)!.close();
        } catch (e) {
          Navigator.of(context).pushNamed(RouteList.dashboard);
        }
      } else {
        final modalRoute = ModalRoute.of(context);
        if (modalRoute?.canPop ?? false) {
          Navigator.of(context).pop();
        }
        MainTabControlDelegate.getInstance().changeTab(RouteList.home);
      }
    } else if (isLoggedIn && kPaymentConfig.guestCheckout) {
      doCheckout();
    } else {
      _loginWithResult(context);
    }
  }

  void setCouponEndDate(String discountCode) async {
    var headers = {'Content-Type': 'application/json'};
    var request =
        http.Request('PATCH', Uri.parse('${apiUrl}discountCodes/setEndDate'));
    request.body = json.encode({'discountCode': discountCode});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> doCheckout() async {
    showLoading();
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user == null) {
      await Navigator.of(context).pushNamed(RouteList.login);
      return;
    }
    // if (setEndDate == true) {
    //   await setCouponEndDate(cartModel.couponObj!.code ?? '');
    //   setEndDate = false;
    // }

    await Services().widget.doCheckout(
      context,
      success: () async {
        hideLoading('');
        // var user = Provider.of<UserModel>(context, listen: false).user;
        // Address address =
        //     Address(country: kPaymentConfig.defaultCountryISOCode);
        cartModel.productsInCart.keys.map(
          (key) {
            // var productId = Product.cleanProductID(key);
            // Product? product = cartModel.getProductById(productId);
            // var quantity = cartModel.productsInCart[key] ?? 0;
          },
        ).toList();
        await FluxNavigate.pushNamed(
          RouteList.checkout,
          arguments: CheckoutArgument(isModal: widget.isModal),
          forceRootNavigator: true,
        );
      },
      error: (message) async {
        if (message ==
            Exception('Token expired. Please logout then login again')
                .toString()) {
          setState(() {
            isLoading = false;
          });
          //logout
          final userModel = Provider.of<UserModel>(context, listen: false);
          await userModel.logout();
          await Services().firebase.signOut();

          _loginWithResult(context);
        } else {
          hideLoading(message);
          Future.delayed(const Duration(seconds: 3), () {
            setState(() => errMsg = '');
          });
        }
      },
      loading: (isLoading) {
        setState(() {
          this.isLoading = isLoading;
        });
      },
    );
  }

  void showLoading() {
    setState(() {
      isLoading = true;
      errMsg = '';
    });
  }

  void hideLoading(error) {
    setState(() {
      isLoading = false;
      errMsg = error;
    });
  }
}
