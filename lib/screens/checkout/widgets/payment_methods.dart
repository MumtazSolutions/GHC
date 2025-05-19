// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

// import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/booking/booking_model.dart';
import '../../../models/entities/product.dart';
import '../../../models/index.dart'
    show AppModel, CartModel, Order, PaymentMethodModel, TaxModel, UserModel;
import '../../../models/tera_wallet/wallet_model.dart';
import '../../../modules/native_payment/credit_card/index.dart';
import '../../../modules/native_payment/flutterwave/services.dart';
import '../../../modules/native_payment/mercado_pago/index.dart';
import '../../../modules/native_payment/paypal/index.dart';
import '../../../modules/native_payment/paystack/services.dart';
import '../../../modules/native_payment/paytm/services.dart';
import '../../../services/index.dart';
import '../../../widgets/product/cart_item.dart';
import '../../cart/my_cart_screen.dart';

class PaymentMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onFinish;
  final Function(bool)? onLoading;

  const PaymentMethods({this.onBack, this.onFinish, this.onLoading});

  @override
  State<PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String? selectedId;
  bool isPaying = false;
  TextEditingController note = TextEditingController();
  var quantity;
  var productN;
  Product? product;

  @override
  void initState() {
    super.initState();
    note.text = Provider.of<CartModel>(context, listen: false).notes ?? '';
    for (var i = 0;
        i < int.parse(product?.tags.length.toString() ?? '0');
        i++) {
      print(product?.tags[i].id);
      if (product?.tags[i].id == 'bogo' || product?.tags[i].id == 'buy1getany1') {
        bogo = false;
      }
    }

    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      final langCode = Provider.of<AppModel>(context, listen: false).langCode;
      Provider.of<PaymentMethodModel>(context, listen: false).getPaymentMethods(
          cartModel: cartModel,
          shippingMethod: cartModel.shippingMethod,
          token: userModel.user != null ? userModel.user!.cookie : null,
          langCode: langCode);

      if (kPaymentConfig.enableReview != true) {
        Provider.of<TaxModel>(context, listen: false)
            .getTaxes(Provider.of<CartModel>(context, listen: false),
                (taxesTotal, taxes) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          Provider.of<CartModel>(context, listen: false).taxes = taxes;
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);

    return ListenableProvider.value(
      value: paymentMethodModel,
      child: Consumer<CartModel>(builder: (context, model, child) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ...getProducts(model, context),
                      // Text(S.of(context).paymentMethods,
                      //     style: const TextStyle(fontSize: 16)),
                      // const SizedBox(height: 5),
                      // Text(
                      //   S.of(context).chooseYourPaymentMethod,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Theme.of(context)
                      //         .colorScheme
                      //         .secondary
                      //         .withOpacity(0.6),
                      //   ),
                      // ),

                      Services().widget.renderPayByWallet(context),
                      const SizedBox(height: 20),
                      Consumer2<PaymentMethodModel, WalletModel>(
                          builder: (context, model, walletModel, child) {
                        if (model.isLoading) {
                          return SizedBox(
                              height: 100, child: kLoadingWidget(context));
                        }

                        if (model.message != null) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                                child: Text(model.message!,
                                    style:
                                        const TextStyle(color: kErrorRed))),
                          );
                        }

                        var ignoreWallet = false;
                        final isWalletExisted = model.paymentMethods
                                .firstWhereOrNull((e) => e.id == 'wallet') !=
                            null;
                        if (isWalletExisted) {
                          final total = (cartModel.getTotal() ?? 0) +
                              cartModel.walletAmount;
                          ignoreWallet = total > walletModel.balance;
                        }

                        if (selectedId == null &&
                            model.paymentMethods.isNotEmpty) {
                          selectedId =
                              model.paymentMethods.firstWhereOrNull((item) {
                            if (ignoreWallet) {
                              return item.id != 'wallet' && item.enabled!;
                            } else {
                              return item.enabled!;
                            }
                          })?.id;
                        }

                        return const SizedBox();
                      }),

                      // const ShoppingCartSummary(showPrice: false),
                      const SizedBox(height: 20),

                      Services().widget.renderTaxes(taxModel, context),
                      Services().widget.renderRewardInfo(context),
                      Services().widget.renderCheckoutWalletInfo(context),
                      Services().widget.renderCODExtraFee(context),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 8, horizontal: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       Text(
                      //         S.of(context).total,
                      //         style: TextStyle(
                      //             fontSize: 16,
                      //             color:
                      //                 Theme.of(context).colorScheme.secondary),
                      //       ),
                      //       Text(
                      //         PriceTools.getCurrencyFormatted(
                      //             cartModel.getTotal(), currencyRate,
                      //             currency: cartModel.currencyCode)!,
                      //         style: TextStyle(
                      //           fontSize: 20,
                      //           color: Theme.of(context).colorScheme.secondary,
                      //           fontWeight: FontWeight.w600,
                      //           decoration: TextDecoration.underline,
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).subtotal,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                            ),
                            Text(
                              '₹' +
                                  (model.checkout?.subtotalPrice).toString(),
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),

                      Services().widget.renderShippingMethodInfo(context),
                      if (cartModel.getCoupon() != '')
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                S.of(context).discount,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.8),
                                ),
                              ),
                              Text(
                                cartModel.getCoupon(),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.8),
                                    ),
                              )
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              S.of(context).total,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                            ),
                            Text(
                              '₹' +
                                  (model.checkout?.subtotalPrice).toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            )
                          ],
                        ),
                      ),
                      // if (bogo)
                      //   Padding(
                      //     padding: const EdgeInsets.only(right: 17.0),
                      //     child: Align(
                      //       alignment: Alignment.centerRight,
                      //       child: Text(
                      //           "*BOGO offer Applied",
                      //           style: TextStyle(
                      //               color: Colors.red, fontSize: 13)),
                      //     ),
                      //   ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          'Your Note',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextField(
                            maxLines: 5,
                            controller: note,
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                                hintText: S.of(context).writeYourNote,
                                hintStyle: const TextStyle(fontSize: 12),
                                border: InputBorder.none),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<PaymentMethodModel>(builder: (context, model, child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildBottom(model, cartModel),
                );
              })
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottom(
      PaymentMethodModel paymentMethodModel, CartModel cartModel) {
    return kPaymentConfig.enableShipping ||
            kPaymentConfig.enableAddress ||
            kPaymentConfig.enableReview
        ? Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 85),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: ButtonTheme(
              height: 45,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                ),
                onPressed: () {
                  if (paymentMethodModel.message?.isNotEmpty ?? false) {
                  } else {
                    if (isPaying || selectedId == null) {
                      showSnackbar();
                    } else {
                      placeOrder(paymentMethodModel, cartModel);
                      // WebEngagePlugin.trackEvent('Checkout created', {
                      //   'abandoned checkout url': "", 'buyer_accepts_marketing': , 'cart token': , 'Created At': , 'currency':cartModel.getCurrency(), 'customer accepts marketing': address!.state, 'customer created at': address!.city, 'customer email': , 'customer first name': address!.block, 'customer last name': address!.street, 'customer phone': address!.zipCode,'customer updated at':,
                      //   'default address city':,'default address country':,'default address country code':,'default address province':,
                      //   'default address province code':,'default address zip':,'email':,'line_items':,'location id':,
                      //   'name':,'order id':,'orders count':,'phone':,'productIds':,'source name':,'total price':,'total spent':,'Updated At':});

                    }
                  }
                },
                icon: const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 20,
                ),
                label: Text(S.of(context).placeMyOrder.toUpperCase()),
              ),
            ),
          )
        : const SizedBox();
  }

  List<Widget> getProducts(CartModel model, BuildContext context) {
    var subTotalAmount = 0.0;
    return model.productsInCart.keys.map(
      (key) {
        print(model.checkout?.subtotalPrice.runtimeType);
        var productId = Product.cleanProductID(key);
        product = model.getProductById(productId);

        productN = product?.name;
        quantity = model.productsInCart[key] ?? 0;
        return ShoppingCartRow(
          addonsOptions: model.productAddonsOptionsInCart[key],
          product: model.getProductById(productId),
          variation: model.getProductVariationById(key),
          quantity: model.productsInCart[key],
          options: model.productsMetaDataInCart[key],
        );
      },
    ).toList();
  }

  void showSnackbar() {
    Tools.showSnackBar(
        ScaffoldMessenger.of(context), S.of(context).orderStatusProcessing);
  }

  void placeOrder(PaymentMethodModel paymentMethodModel, CartModel cartModel) {
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;

    widget.onLoading!(true);
    isPaying = true;
    if (paymentMethodModel.paymentMethods.isNotEmpty) {
      final paymentMethod = paymentMethodModel.paymentMethods
          .firstWhere((item) => item.id == selectedId);
      var isSubscriptionProduct = cartModel.item.values.firstWhere(
              (element) =>
                  element?.type == 'variable-subscription' ||
                  element?.type == 'subscription',
              orElse: () => null) !=
          null;
      Provider.of<CartModel>(context, listen: false)
          .setPaymentMethod(paymentMethod);

      /// Use Credit card. For Shopify only.
      if (!isSubscriptionProduct &&
          kPaymentConfig.enableCreditCard &&
          ServerConfig().isShopify) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading?.call(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading?.call(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );

        return;
      }

      /// Use Native payment

      /// Direct bank transfer (BACS)

      if (!isSubscriptionProduct && paymentMethod.id!.contains('bacs')) {
        widget.onLoading?.call(false);
        isPaying = false;

        showModalBottomSheet(
            context: context,
            builder: (sContext) => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              S.of(context).cancel,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        paymentMethod.description!,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      const Expanded(child: SizedBox(height: 10)),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onLoading!(true);
                          isPaying = true;
                          Services().widget.placeOrder(
                            context,
                            cartModel: cartModel,
                            onLoading: widget.onLoading,
                            paymentMethod: paymentMethod,
                            success: (Order order) async {
                              for (var item in order.lineItems) {
                                var product =
                                    cartModel.getProductById(item.productId!);
                                if (product?.bookingInfo != null) {
                                  product!.bookingInfo!.idOrder = order.id;
                                  var booking =
                                      await createBooking(product.bookingInfo)!;

                                  Tools.showSnackBar(
                                      ScaffoldMessenger.of(context),
                                      booking
                                          ? 'Booking success!'
                                          : 'Booking error!');
                                }
                              }
                              widget.onFinish!(order);
                              widget.onLoading?.call(false);
                              isPaying = false;
                            },
                            error: (message) {
                              widget.onLoading?.call(false);
                              if (message != null) {
                                Tools.showSnackBar(
                                    ScaffoldMessenger.of(context), message);
                              }
                              isPaying = false;
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          S.of(context).ok,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ));

        return;
      }

      /// PayPal Payment
      if (!isSubscriptionProduct &&
          isNotBlank(kPaypalConfig['paymentMethodId']) &&
          paymentMethod.id!.contains(kPaypalConfig['paymentMethodId']) &&
          kPaypalConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading?.call(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true, transactionId: number).then((value) {
                    widget.onLoading?.call(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
        return;
      }

      /// MercadoPago payment
      if (!isSubscriptionProduct &&
          isNotBlank(kMercadoPagoConfig['paymentMethodId']) &&
          paymentMethod.id!.contains(kMercadoPagoConfig['paymentMethodId']) &&
          kMercadoPagoConfig['enabled'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MercadoPagoPayment(
              onFinish: (number, paid) {
                if (number == null) {
                  widget.onLoading?.call(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: paid).then((value) {
                    widget.onLoading?.call(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
        return;
      }

      /// RazorPay payment
      /// Check below link for parameters:
      /// https://razorpay.com/docs/payment-gateway/web-integration/standard/#step-2-pass-order-id-and-other-options
      if (!isSubscriptionProduct &&
          paymentMethod.id!.contains(kRazorpayConfig['paymentMethodId']) &&
          kRazorpayConfig['enabled'] == true) {
        Services().api.createRazorpayOrder({
          'amount': (PriceTools.getPriceValueByCurrency(cartModel.getTotal()!,
                      cartModel.currencyCode!, currencyRate) *
                  100)
              .toInt()
              .toString(),
          'currency': cartModel.currencyCode,
        }).catchError((e) {
          widget.onLoading?.call(false);
          Tools.showSnackBar(ScaffoldMessenger.of(context), e);
          isPaying = false;
        });
        return;
      }

      /// PayTm payment.
      /// Check below link for parameters:
      /// https://developer.paytm.com/docs/all-in-one-sdk/hybrid-apps/flutter/
      final availablePayTm = kPayTmConfig['paymentMethodId'] != null &&
          (kPayTmConfig['enabled'] ?? false) &&
          paymentMethod.id!.contains(kPayTmConfig['paymentMethodId']);
      if (!isSubscriptionProduct && availablePayTm) {
        createOrderOnWebsite(
            paid: false,
            onFinish: (Order? order) async {
              if (order != null) {
                final paytmServices = PayTmServices(
                  amount: cartModel.getTotal()!.toString(),
                  orderId: order.id!,
                  email: cartModel.address?.email,
                );
                try {
                  await paytmServices.openPayment();
                  widget.onFinish!(order);
                } catch (e) {
                  Tools.showSnackBar(
                      ScaffoldMessenger.of(context), e.toString());
                  isPaying = false;
                }
              }
            });
        return;
      }

      /// PayStack payment.
      final availablePayStack = kPayStackConfig['paymentMethodId'] != null &&
          (kPayStackConfig['enabled'] ?? false) &&
          paymentMethod.id!.contains(kPayStackConfig['paymentMethodId']);
      if (!isSubscriptionProduct && availablePayStack) {
        createOrderOnWebsite(
            paid: false,
            onFinish: (Order? order) async {
              if (order != null) {
                final payStackServices = PayStackServices(
                  amount: cartModel.getTotal()!.toString(),
                  orderId: order.id!,
                  email: cartModel.address?.email,
                );
                try {
                  await payStackServices.openPayment(
                      context, widget.onLoading!);
                  widget.onFinish!(order);
                } catch (e) {
                  Tools.showSnackBar(
                      ScaffoldMessenger.of(context), e.toString());
                  isPaying = false;
                }
              }
            });
        return;
      }

      /// Flutterwave payment.
      final availableFlutterwave =
          kFlutterwaveConfig['paymentMethodId'] != null &&
              (kFlutterwaveConfig['enabled'] ?? false) &&
              paymentMethod.id!.contains(kFlutterwaveConfig['paymentMethodId']);
      if (!isSubscriptionProduct && availableFlutterwave) {
        createOrderOnWebsite(
            paid: false,
            onFinish: (Order? order) async {
              if (order != null) {
                final flutterwaveServices = FlutterwaveServices(
                    amount: cartModel.getTotal()!.toString(),
                    orderId: order.id!,
                    email: cartModel.address?.email,
                    name: cartModel.address?.fullName,
                    phone: cartModel.address?.phoneNumber,
                    currency: cartModel.currencyCode,
                    paymentMethod: paymentMethod.title);
                try {
                  await flutterwaveServices.openPayment(
                      context, widget.onLoading!);
                  widget.onFinish!(order);
                } catch (e) {
                  Tools.showSnackBar(
                      ScaffoldMessenger.of(context), e.toString());
                  isPaying = false;
                }
              }
            });
        return;
      }

      /// Use WebView Payment per frameworks
      Services().widget.placeOrder(
        context,
        cartModel: cartModel,
        onLoading: widget.onLoading,
        paymentMethod: paymentMethod,
        success: (Order? order) async {
          if (order != null) {
            for (var item in order.lineItems) {
              var product = cartModel.getProductById(item.productId!);
              if (product?.bookingInfo != null) {
                product!.bookingInfo!.idOrder = order.id;
                var booking = await createBooking(product.bookingInfo)!;

                Tools.showSnackBar(ScaffoldMessenger.of(context),
                    booking ? 'Booking success!' : 'Booking error!');
              }
            }
            widget.onFinish!(order);
          }
          widget.onLoading?.call(false);
          isPaying = false;
        },
        error: (message) {
          widget.onLoading?.call(false);
          if (message != null) {
            Tools.showSnackBar(ScaffoldMessenger.of(context), message);
          }

          isPaying = false;
        },
      );
    }
  }

  Future<bool>? createBooking(BookingModel? bookingInfo) async {
    return Services().api.createBooking(bookingInfo)!;
  }

  Future<void> createOrder(
      {paid = false, bacs = false, cod = false, transactionId = ''}) async {
    await createOrderOnWebsite(
        paid: paid,
        bacs: bacs,
        cod: cod,
        transactionId: transactionId,
        onFinish: (Order? order) async {
          if (!transactionId.toString().isEmptyOrNull && order != null) {
            await Services()
                .api
                .updateOrderIdForRazorpay(transactionId, order.number);
          }
          widget.onFinish!(order);
        });
  }

  Future<void> createOrderOnWebsite(
      {paid = false,
      bacs = false,
      cod = false,
      transactionId = '',
      required Function(Order?) onFinish}) async {
    widget.onLoading!(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      bacs: bacs,
      transactionId: transactionId,
      onLoading: widget.onLoading,
      success: onFinish,
      error: (message) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), message);
      },
    );
    widget.onLoading?.call(false);
  }

  // @override
  // void handlePaymentSuccess(PaymentSuccessResponse response) {
  //   createOrder(paid: true, transactionId: response.paymentId).then((value) {
  //     widget.onLoading?.call(false);
  //     isPaying = false;
  //   });
  // }

  // @override
  // void handlePaymentFailure(PaymentFailureResponse response) {
  //   widget.onLoading?.call(false);
  //   isPaying = false;
  //   final body = convert.jsonDecode(response.message!);
  //   if (body['error'] != null &&
  //       body['error']['reason'] != 'payment_cancelled') {
  //     Tools.showSnackBar(
  //         ScaffoldMessenger.of(context), body['error']['description']);
  //   }
  //   printLog(response.message);
  // }
}
