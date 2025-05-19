import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:country_pickers/country.dart' as picker_country;
import 'package:country_pickers/country_pickers.dart' as picker;
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:fstore/app.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../env.dart';

import '../../../common/config.dart';
import '../../../common/config/models/address_field_config.dart';
import '../../../common/constants.dart';
import '../../../common/tools/flash.dart';
import '../../../common/tools/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/booking/booking_model.dart';
import '../../../models/index.dart'
    show
        Address,
        AppModel,
        CartModel,
        Country,
        Order,
        PaymentMethodModel,
        TaxModel,
        UserModel;
import '../../../models/tera_wallet/wallet_model.dart';
import '../../../modules/native_payment/credit_card/credit_card_payment.dart';
import '../../../services/index.dart';
import '../../../widgets/common/common_safe_area.dart';
import '../../../widgets/common/flux_image.dart';
import '../../../widgets/common/place_picker.dart';
import '../../cart/widgets/shopping_cart_sumary.dart';
import '../choose_address_screen.dart';

part 'shipping_address_extension.dart';

class ShippingAddress extends StatefulWidget {
  final Function? onNext;

  const ShippingAddress({this.onNext});

  @override
  State<ShippingAddress> createState() => _ShippingAddressState();
}

class _ShippingAddressState extends State<ShippingAddress> {
  final _formKey = GlobalKey<FormState>();

  final Map<int, AddressFieldType> _fieldPosition = {};

  final Map<int, AddressFieldConfig> _configs = {};

  final Map<AddressFieldType, TextEditingController> _textControllers = {
    AddressFieldType.firstName: TextEditingController(),
    AddressFieldType.lastName: TextEditingController(),
    AddressFieldType.phoneNumber: TextEditingController(),
    AddressFieldType.email: TextEditingController(),
    AddressFieldType.country: TextEditingController(),
    AddressFieldType.state: TextEditingController(),
    AddressFieldType.city: TextEditingController(),
    AddressFieldType.apartment: TextEditingController(),
    AddressFieldType.block: TextEditingController(),
    AddressFieldType.street: TextEditingController(),
    AddressFieldType.zipCode: TextEditingController(),
  };

  final Map<AddressFieldType, FocusNode> _focusNodes = {
    AddressFieldType.firstName: FocusNode(),
    AddressFieldType.lastName: FocusNode(),
    AddressFieldType.phoneNumber: FocusNode(),
    AddressFieldType.email: FocusNode(),
    AddressFieldType.state: FocusNode(),
    AddressFieldType.city: FocusNode(),
    AddressFieldType.apartment: FocusNode(),
    AddressFieldType.block: FocusNode(),
    AddressFieldType.street: FocusNode(),
    AddressFieldType.zipCode: FocusNode(),
  };

  Address? address;
  List<Country>? countries = [];
  List<dynamic> states = [];

  String? selectedId;
  bool isPaying = false;

  final LocalStorage storage = LocalStorage('localStorage_app');

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// Init field positions.
    for (var config in Configurations.addressFields) {
      final index = _fieldPosition.values.length;
      _configs[index] = config;
      _fieldPosition[index] = config.type;
    }
    var model = Provider.of<PaymentMethodModel>(context, listen: false);
    var cartModel = Provider.of<CartModel>(context, listen: false);
    var walletModel = Provider.of<WalletModel>(context, listen: false);

    var ignoreWallet = false;
    final isWalletExisted =
        model.paymentMethods.firstWhereOrNull((e) => e.id == 'wallet') != null;
    if (isWalletExisted) {
      final total = (cartModel.getTotal() ?? 0) + cartModel.walletAmount;
      ignoreWallet = total > walletModel.balance;
    }

    if (selectedId == null && model.paymentMethods.isNotEmpty) {
      selectedId = model.paymentMethods.firstWhereOrNull((item) {
        if (ignoreWallet) {
          return item.id != 'wallet' && item.enabled!;
        } else {
          return item.enabled!;
        }
      })?.id;
    }
    Future.delayed(Duration.zero, () async {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      final langCode = Provider.of<AppModel>(context, listen: false).langCode;
      await Provider.of<PaymentMethodModel>(context, listen: false)
          .getPaymentMethods(
              cartModel: cartModel,
              shippingMethod: cartModel.shippingMethod,
              token: userModel.user != null ? userModel.user!.cookie : null,
              langCode: langCode);
      if (kPaymentConfig.enableReview != true) {
        await Provider.of<TaxModel>(context, listen: false)
            .getTaxes(Provider.of<CartModel>(context, listen: false),
                (taxesTotal, taxes) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          Provider.of<CartModel>(context, listen: false).taxes = taxes;
          setState(() {});
        });
      }
    });

    /// Pre-fill the address fields.
    WidgetsBinding.instance.endOfFrame.then(
      (_) async {
        /// Load saved addresses.
        final addressValue =
            await Provider.of<CartModel>(context, listen: false).getAddress();
        if (addressValue != null) {
          updateAddress(addressValue);
        } else {
          var user = Provider.of<UserModel>(context, listen: false).user;
          setState(() {
            address = Address(country: kPaymentConfig.defaultCountryISOCode);
            if (kPaymentConfig.defaultStateISOCode != null) {
              address!.state = kPaymentConfig.defaultStateISOCode;
            }
            _textControllers[AddressFieldType.country]?.text =
                address!.country!;
            _textControllers[AddressFieldType.state]?.text = address!.state!;
            if (user != null) {
              address!.firstName = user.firstName;
              address!.lastName = user.lastName;
              address!.email = user.email;
              address!.zipCode = storage.getItem('pinCode').toString();
              loadUserInfoFromAddress(address);
            }
          });
        }

        /// Init default fields.
        for (var field in _configs.values) {
          if ([
            AddressFieldType.searchAddress,
            AddressFieldType.selectAddress,
            AddressFieldType.country,
            AddressFieldType.state,
          ].contains(field.type)) {
            /// Not support default value.
            continue;
          }

          /// Replace current value with default value.
          /// Force to use default value for non-editable field.
          if (field.defaultValue.isNotEmpty && !field.editable) {
            _textControllers[field.type]?.text = field.defaultValue;
          }

          /// When the field is editable, replacing only when it's empty.
          if (field.defaultValue.isNotEmpty &&
              field.editable &&
              (_textControllers[field.type]?.text.isEmpty ?? false)) {
            _textControllers[field.type]?.text = field.defaultValue;
          }
        }

        /// Load country list.
        countries = await Services().widget.loadCountries();
        var country = countries!.firstWhereOrNull((element) =>
            element.id == address?.country || element.code == address?.country);
        if (country == null) {
          if (countries!.isNotEmpty) {
            country = countries![0];
            address!.country = countries![0].code;
          } else {
            country = Country.fromConfig(address!.country, null, null, []);
          }
        } else {
          address!.country = country.code;
          address!.countryId = country.id;
        }
        _textControllers[AddressFieldType.country]?.text = country.code!;
        refresh();

        /// Load states.
        states = await Services().widget.loadStates(country);
        refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var countryName = S.of(context).country;
    final currentCountry =
        _textControllers[AddressFieldType.country]?.text ?? '';
    if (currentCountry.isNotEmpty) {
      try {
        countryName =
            picker.CountryPickerUtils.getCountryByIsoCode(currentCountry).name;
      } catch (e) {
        countryName = S.of(context).country;
      }
    }

    if (address == null) {
      return SizedBox(height: 100, child: kLoadingWidget(context));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 50.0,
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      _fieldPosition.length,
                      (index) {
                        final isVisible = _configs[index]?.visible ?? true;
                        if (!isVisible) {
                          return const SizedBox();
                        }

                        final currentFieldType =
                            _fieldPosition[index] ?? AddressFieldType.unknown;

                        if (currentFieldType == AddressFieldType.country) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                S.of(context).country,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey),
                              ),
                              (countries!.length == 1)
                                  ? Text(
                                      picker.CountryPickerUtils
                                              .getCountryByIsoCode(
                                                  countries![0].code!)
                                          .name,
                                      style: const TextStyle(fontSize: 18),
                                    )
                                  : GestureDetector(
                                      onTap: _openCountryPickerDialog,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(countryName,
                                                      style: const TextStyle(
                                                          fontSize: 17.0)),
                                                ),
                                                const Icon(
                                                    Icons.arrow_drop_down)
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                            height: 1,
                                            color: kGrey900,
                                          )
                                        ],
                                      ),
                                    ),
                            ],
                          );
                        }

                        if (currentFieldType == AddressFieldType.state &&
                            states.isNotEmpty) {
                          return renderStateInput();
                        }

                        if (currentFieldType ==
                            AddressFieldType.searchAddress) {
                          if (kPaymentConfig.allowSearchingAddress &&
                              kGoogleApiKey.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ButtonTheme(
                                      height: 60,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          backgroundColor: Theme.of(context)
                                              .primaryColorLight,
                                          elevation: 0.0,
                                        ),
                                        onPressed: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PlacePicker(
                                                kIsWeb
                                                    ? kGoogleApiKey.web
                                                    : isIos
                                                        ? kGoogleApiKey.ios
                                                        : kGoogleApiKey.android,
                                              ),
                                            ),
                                          );

                                          if (result is LocationResult) {
                                            address!.country = result.country;
                                            address!.street = result.street;
                                            address!.state = result.state;
                                            address!.city = result.city;
                                            address!.zipCode = result.zip;
                                            if (result.latLng?.latitude !=
                                                    null &&
                                                result.latLng?.latitude !=
                                                    null) {
                                              address!.mapUrl =
                                                  'https://maps.google.com/maps?q=${result.latLng?.latitude},${result.latLng?.longitude}&output=embed';
                                              address!.latitude = result
                                                  .latLng?.latitude
                                                  .toString();
                                              address!.longitude = result
                                                  .latLng?.longitude
                                                  .toString();
                                            }

                                            loadAddressFields(address);
                                            final c = Country(
                                                id: result.country,
                                                name: result.country);
                                            states = await Services()
                                                .widget
                                                .loadStates(c);
                                            setState(() {});
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Icon(
                                              CupertinoIcons
                                                  .arrow_up_right_diamond,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(S
                                                .of(context)
                                                .searchingAddress
                                                .toUpperCase()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox();
                        }

                        if (currentFieldType ==
                            AddressFieldType.selectAddress) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ButtonTheme(
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  backgroundColor:
                                      Theme.of(context).primaryColorLight,
                                  elevation: 0.0,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChooseAddressScreen(updateAddress),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      CupertinoIcons.person_crop_square,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 10.0),
                                    Text(
                                      S.of(context).selectAddress.toUpperCase(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final currentFieldController =
                            _textControllers[currentFieldType];
                        final currentFieldFocusNode =
                            _focusNodes[currentFieldType];

                        var hasNext = false;
                        var nextFieldIndex = index + 1;
                        late var nextFieldType;
                        late var nextFieldFocus;
                        while (nextFieldIndex < _fieldPosition.length) {
                          nextFieldType = _fieldPosition[nextFieldIndex];
                          nextFieldFocus = _focusNodes[nextFieldType];
                          if (nextFieldType == AddressFieldType.country ||
                              (nextFieldType == AddressFieldType.state &&
                                  states.isNotEmpty)) {
                            hasNext = false;
                            break;
                          }
                          if (nextFieldFocus != null) {
                            hasNext = true;
                            break;
                          }
                          nextFieldIndex++;
                        }

                        if (currentFieldType == AddressFieldType.phoneNumber &&
                            kPhoneNumberConfig.enablePhoneNumberValidation) {
                          return InternationalPhoneNumberInput(
                            /// Auto focus first field if it's empty.
                            autoFocus: index == 0 &&
                                (currentFieldController?.text.isEmpty ?? false),
                            textFieldController: currentFieldController,
                            focusNode: currentFieldFocusNode,
                            isReadOnly: isFieldReadOnly(index),
                            autofillHints: currentFieldType.autofillHint != null
                                ? ['${currentFieldType.autofillHint}']
                                : null,
                            inputDecoration: InputDecoration(
                              labelText: getFieldLabel(currentFieldType),
                            ),
                            keyboardType: getKeyboardType(currentFieldType),
                            keyboardAction: hasNext
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (hasNext) {
                                nextFieldFocus?.requestFocus();
                              }
                            },
                            onSaved: (value) {
                              onTextFieldSaved(
                                value.phoneNumber,
                                currentFieldType,
                              );
                            },
                            onInputChanged: (PhoneNumber number) {},
                            onInputValidated: (value) => {},
                            spaceBetweenSelectorAndTextField: 0,
                            selectorConfig: SelectorConfig(
                              enable: kPhoneNumberConfig.useInternationalFormat,
                              showFlags: kPhoneNumberConfig.showCountryFlag,
                              selectorType: kPhoneNumberConfig.selectorType,
                              setSelectorButtonAsPrefixIcon:
                                  kPhoneNumberConfig.selectorFlagAsPrefixIcon,
                              leadingPadding: 0,
                              trailingSpace: false,
                            ),
                            selectorTextStyle:
                                Theme.of(context).textTheme.subtitle1,
                            ignoreBlank: !(_configs[index]?.required ?? true),
                            initialValue: PhoneNumber(
                              dialCode: kPhoneNumberConfig.dialCodeDefault,
                              isoCode: kPhoneNumberConfig.countryCodeDefault,
                              phoneNumber: currentFieldController?.text,
                            ),
                            formatInput: kPhoneNumberConfig.formatInput,
                            countries: kPhoneNumberConfig.customCountryList,
                          );
                        }

                        return TextFormField(
                          /// Auto focus first field if it's empty.
                          autofocus: index == 0 &&
                              (currentFieldController?.text.isEmpty ?? false),
                          autocorrect: false,
                          controller: currentFieldController,
                          focusNode: currentFieldFocusNode,
                          readOnly: isFieldReadOnly(index),
                          autofillHints: currentFieldType.autofillHint != null
                              ? ['${currentFieldType.autofillHint}']
                              : null,
                          decoration: InputDecoration(
                            labelText: getFieldLabel(currentFieldType),
                          ),
                          keyboardType: getKeyboardType(currentFieldType),
                          textCapitalization: TextCapitalization.words,
                          textInputAction: hasNext
                              ? TextInputAction.next
                              : TextInputAction.done,
                          validator: (val) {
                            final config = _configs[index];
                            if (config == null) {
                              return null;
                            }
                            return validateField(val, config, currentFieldType);
                          },
                          onFieldSubmitted: (_) {
                            if (hasNext) {
                              nextFieldFocus?.requestFocus();
                            }
                          },
                          onSaved: (value) => onTextFieldSaved(
                            value,
                            currentFieldType,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildBottom(onTap: () {
          var cartModel = Provider.of<CartModel>(context, listen: false);

          var paymentMethodModel =
              Provider.of<PaymentMethodModel>(context, listen: false);
          var model = Provider.of<CartModel>(context, listen: false);
          if (paymentMethodModel.message?.isNotEmpty ?? false) {
          } else {
            if (_formKey.currentState!.validate()) {
              placeOrder(paymentMethodModel, model);
              _formKey.currentState!.save();
              Provider.of<CartModel>(context, listen: false)
                  .setAddress(address);
              _loadShipping(beforehand: false);
            }

            setCouponEndDate(String discountCode) async {
              var headers = {'Content-Type': 'application/json'};
              var request = http.Request(
                  'PATCH', Uri.parse(apiUrl + 'discountCodes/setEndDate'));
              request.body = json.encode({'discountCode': discountCode});
              request.headers.addAll(headers);

              http.StreamedResponse response = await request.send();

              if (response.statusCode == 200) {
                print(await response.stream.bytesToString());
              } else {
                print(response.reasonPhrase);
              }
            }

            if (setEndDate == true) {
              setCouponEndDate(cartModel.couponObj!.code ?? '');
              setEndDate = false;
              // firstTimeCoupon = false;
            }
          }
        })
      ],
    );
  }

  void showSnackbar() {
    Tools.showSnackBar(
        ScaffoldMessenger.of(context), S.of(context).orderStatusProcessing);
  }

  Order? newOrder;
  bool isLoading = false;
  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  Future<void> createOrderOnWebsite(
      {paid = false,
      bacs = false,
      cod = false,
      transactionId = '',
      required Function(Order?) onFinish}) async {
    setLoading(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      bacs: bacs,
      transactionId: transactionId,
      onLoading: setLoading,
      success: onFinish,
      error: (message) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), message);
      },
    );
    setLoading.call(false);
  }

  void onFinish(order) async {
    setState(() {
      newOrder = order;
    });
    Provider.of<CartModel>(context, listen: false).clearCart();
    unawaited(context.read<WalletModel>().refreshWallet());
    await Services().widget.updateOrderAfterCheckout(context, order);
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
          onFinish(order);
        });
  }

  Future<bool>? createBooking(BookingModel? bookingInfo) async {
    return Services().api.createBooking(bookingInfo)!;
  }

  void placeOrder(PaymentMethodModel paymentMethodModel, CartModel cartModel) {
    var model = Provider.of<PaymentMethodModel>(context, listen: false);
    var walletModel = Provider.of<WalletModel>(context, listen: false);
    var ignoreWallet = false;
    setLoading(true);
    isPaying = true;
    final isWalletExisted =
        model.paymentMethods.firstWhereOrNull((e) => e.id == 'wallet') != null;
    if (isWalletExisted) {
      final total = (cartModel.getTotal() ?? 0) + cartModel.walletAmount;
      ignoreWallet = total > walletModel.balance;
    }
    if (selectedId == null && model.paymentMethods.isNotEmpty) {
      selectedId = model.paymentMethods.firstWhereOrNull((item) {
        if (ignoreWallet) {
          return item.id != 'wallet' && item.enabled!;
        } else {
          return item.enabled!;
        }
      })?.id;
    }
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
                  setLoading.call(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    setLoading.call(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );

        return;
      }

      /// Use WebView Payment per frameworks
      Services().widget.placeOrder(
        context,
        cartModel: cartModel,
        onLoading: setLoading,
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
            onFinish(order);
          }
          setLoading.call(false);
          isPaying = false;
        },
        error: (message) {
          setLoading.call(false);
          if (message != null) {
            Tools.showSnackBar(ScaffoldMessenger.of(context), message);
          }

          isPaying = false;
        },
      );
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
