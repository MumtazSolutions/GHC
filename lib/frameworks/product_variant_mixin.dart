import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools/flash.dart';
import '../common/tools/tools.dart';
import '../generated/l10n.dart';
import '../models/cart/cart_base.dart';
import '../models/index.dart'
    show CartModel, Product, ProductModel, ProductVariation;
import '../models/user_model.dart';
import '../routes/flux_navigate.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/detail/widgets/index.dart' show ProductShortDescription;
import '../services/services.dart';
import '../widgets/common/webview.dart';
import '../widgets/product/widgets/quantity_selection.dart';

mixin ProductVariantMixin {
  ProductVariation? updateVariation(
    List<ProductVariation> variations,
    Map<String?, String?> mapAttribute,
  ) {
    final templateVariation =
        variations.isNotEmpty ? variations.first.attributes : null;
    final listAttributes = variations.map((e) => e.attributes);

    ProductVariation productVariation;
    var attributeString = '';

    /// Flat attribute
    /// Example attribute = { "color": "RED", "SIZE" : "S", "Height": "Short" }
    /// => "colorRedsizeSHeightShort"
    templateVariation?.forEach((element) {
      final key = element.name;
      final value = mapAttribute[key];
      attributeString += value != null ? '$key$value' : '';
    });

    /// Find attributeS contain attribute selected
    final validAttribute = listAttributes.lastWhereOrNull(
      (attributes) =>
          attributes.map((e) => e.toString()).join().contains(attributeString),
    );

    if (validAttribute == null) return null;

    /// Find ProductVariation contain attribute selected
    /// Compare address because use reference
    productVariation =
        variations.lastWhere((element) => element.attributes == validAttribute);

    for (var element in productVariation.attributes) {
      if (!mapAttribute.containsKey(element.name)) {
        mapAttribute[element.name!] = element.option!;
      }
    }
    return productVariation;
  }

  bool isPurchased(
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?> mapAttribute,
    bool isAvailable,
  ) {
    var inStock;
    // ignore: unnecessary_null_comparison
    if (productVariation != null) {
      inStock = productVariation.inStock!;
    } else {
      inStock = product.inStock!;
    }

    var allowBackorder = productVariation != null
        ? (productVariation.backordersAllowed ?? false)
        : product.backordersAllowed;

    var isValidAttribute = false;
    try {
      if (product.type == 'simple') {
        isValidAttribute = true;
      }
      if (product.attributes!.length == mapAttribute.length &&
          (product.attributes!.length == mapAttribute.length ||
              product.type != 'variable')) {
        isValidAttribute = true;
      }
    } catch (_) {}

    return (inStock || allowBackorder) && isValidAttribute && isAvailable;
  }

  List<Widget> makeProductTitleWidget(BuildContext context,
      ProductVariation? productVariation, Product product, bool isAvailable) {
    var listWidget = <Widget>[];

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    var stockQuantity =
        (kProductDetail.showStockQuantity) && product.stockQuantity != null
            ? '  (${product.stockQuantity}) '
            : '';
    if (Provider.of<ProductModel>(context, listen: false).selectedVariation !=
        null) {
      stockQuantity = (kProductDetail.showStockQuantity) &&
              Provider.of<ProductModel>(context, listen: false)
                      .selectedVariation!
                      .stockQuantity !=
                  null
          ? '  (${Provider.of<ProductModel>(context, listen: false).selectedVariation!.stockQuantity}) '
          : '';
    }

    if (isAvailable) {
      listWidget.add(
        const SizedBox(height: 5.0),
      );

      final sku = productVariation != null ? productVariation.sku : product.sku;

      listWidget.add(
        Row(
          children: <Widget>[
            if ((kProductDetail.showSku) && (sku?.isNotEmpty ?? false)) ...[
              Text(
                '${S.of(context).sku}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                sku ?? '',
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: inStock
                          ? Theme.of(context).primaryColor
                          : const Color(0xFFe74c3c),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      );

      for (int i = 0; i < product.tags.length; i++) {
        print(product.tags[i].id);
        if (product.tags[i].id == 'bogo' ||
            product.tags[i].id == 'buy1getany1') {
          listWidget.add(
            const SizedBox(height: 1.0),
          );
          listWidget.add(Image.asset('assets/images/bogoOffer.png'));
          listWidget.add(
            const SizedBox(height: 10.0),
          );
          listWidget.add(const Align(
            alignment: Alignment.centerLeft,
            child: Text(
                "*This offer cannot be clubbed with any other coupon codes",
                style: TextStyle(color: Colors.red, fontSize: 13)),
          ));

          listWidget.add(
            const SizedBox(height: 20.0),
          );
          break;
        }
      }

      listWidget.add(
        Row(
          children: <Widget>[
            if (kAdvanceConfig.showStockStatus) ...[
              Text(
                '${S.of(context).availability}: ',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              (productVariation != null
                      ? (productVariation.backordersAllowed ?? false)
                      : product.backordersAllowed)
                  ? Text(
                      S.of(context).backOrder,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: kStockColor.backorder,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : Text(
                      inStock
                          ? '${S.of(context).inStock}'
                          : S.of(context).outOfStock,
                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                            color: inStock
                                ? kStockColor.inStock
                                : kStockColor.outOfStock,
                            fontWeight: FontWeight.w600,
                          ),
                    )
            ],
          ],
        ),
      );

      if (productVariation?.description?.isNotEmpty ?? false) {
        listWidget.add(Services()
            .widget
            .renderProductDescription(context, productVariation!.description!));
      }
      if (product.shortDescription != null &&
          product.shortDescription!.isNotEmpty) {
        listWidget.add(
          ProductShortDescription(product),
        );
      }

      var isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;

      listWidget.add(Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
        child: Container(
          height: 48,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
              colors: [Color(0xff0B2041), Color(0xff0F345C)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20, // Set the desired width
                  height: 20, // Set the desired height
                  child: Image.asset(
                    'assets/images/moonIcon.png',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  isLoggedIn
                      ? 'Place an order to get 25% of your purchase\nvalue as Moons in your Wallet  '
                      : 'Log in and place an order to get 25% of your\npurchase value as Moons in your Wallet  ',
                  style: const TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: Color(0xffFFFFFF)),
                onPressed: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          padding:
                              const EdgeInsets.all(0), // Adjust padding as needed
                          width: 250,
                          height: 230,
                          child:
                              Image.asset('assets/images/introducingMoons.png'),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ));

      listWidget.add(
        const SizedBox(height: 15.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
      BuildContext context,
      ProductVariation? productVariation,
      Product product,
      Map<String?, String?>? mapAttribute,
      int maxQuantity,
      int quantity,
      Function addToCart,
      Function onChangeQuantity,
      bool isAvailable,
      {bool ignoreBuyOrOutOfStockButton = false}) {
    final theme = Theme.of(context);

    // ignore: unnecessary_null_comparison
    var inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;
    var allowBackorder = productVariation != null
        ? (productVariation.backordersAllowed ?? false)
        : product.backordersAllowed;

    final isExternal = product.type == 'external' ? true : false;
    final isVariationLoading =
        // ignore: unnecessary_null_comparison
        (product.isVariableProduct || product.type == 'configurable') &&
            productVariation == null &&
            mapAttribute == null;

    final buyOrOutOfStockButton = Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: isExternal
            ? ((inStock || allowBackorder) &&
                    mapAttribute != null &&
                    (product.attributes!.length == mapAttribute.length) &&
                    isAvailable)
                ? theme.primaryColor
                : theme.disabledColor
            : theme.primaryColor,
      ),
      child: Center(
        child: Text(
          ((((inStock || allowBackorder) && isAvailable) || isExternal) &&
                  !isVariationLoading
              ? S.of(context).buyNow
              : (isAvailable && !isVariationLoading
                      ? S.of(context).outOfStock
                      : isVariationLoading
                          ? S.of(context).loading
                          : S.of(context).unavailable)
                  .toUpperCase()),
          style: Theme.of(context).textTheme.button!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );

    if (!inStock && !isExternal && !allowBackorder) {
      return [
        ignoreBuyOrOutOfStockButton ? const SizedBox() : buyOrOutOfStockButton,
      ];
    }

    if ((product.isPurchased) && (product.isDownloadable ?? false)) {
      return [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async => await Tools.launchURL(product.files![0]!),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                      child: Text(
                    S.of(context).download,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ];
    }

    return [
      if (!isExternal && kProductDetail.showStockQuantity) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                '${S.of(context).selectTheQuantity}:',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Expanded(
              child: Container(
                height: 32.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: QuantitySelection(
                  height: 32.0,
                  expanded: true,
                  value: quantity,
                  color: theme.colorScheme.secondary,
                  limitSelectQuantity: maxQuantity,
                  onChanged: onChangeQuantity,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 10),

      /// Action Buttons: Buy Now, Add To Cart
      actionButton(
          ignoreBuyOrOutOfStockButton,
          isAvailable,
          addToCart,
          inStock,
          allowBackorder,
          buyOrOutOfStockButton,
          isExternal,
          isVariationLoading,
          product,
          quantity,
          productVariation,
          context)
    ];
  }

  /// Add to Cart & Buy Now function
  void addToCart(BuildContext context, Product product, int quantity,
      ProductVariation? productVariation, Map<String?, String?> mapAttribute,
      [bool buyNow = false, bool inStock = false]) {
    var productPriceInt = double.parse(product.price.toString()).round();
    print(productPriceInt.runtimeType);

    /// Out of stock || Variable product but not select any variant.
    if (!inStock || (product.isVariableProduct && mapAttribute.isEmpty)) {
      return;
    }

    final cartModel = Provider.of<CartModel>(context, listen: false);
    if (product.type == 'external') {
      openWebView(context, product);
      return;
    }

    final mapAttr = <String, String>{};
    for (var entry in mapAttribute.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key != null && value != null) {
        mapAttr[key] = value;
      }
    }

    productVariation =
        Provider.of<ProductModel>(context, listen: false).selectedVariation;
    var message = cartModel.addProductToCart(
        context: context,
        product: product,
        quantity: quantity,
        variation: productVariation!,
        options: mapAttr);

    if (message.isNotEmpty) {
      FlashHelper.errorMessage(context, message: message);
    } else {
      if (buyNow) {
        FluxNavigate.pushNamed(
          RouteList.cart,
          arguments: CartScreenArgument(isModal: true, isBuyNow: true),
        );
      }
      FlashHelper.message(
        context,
        title: product.name,
        message: S.of(context).addToCartSucessfully,
      );
    }
  }

  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: Center(
            child: Text(S.of(context).notFound),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebView(
          url: product.affiliateUrl,
          title: product.name,
        ),
      ),
    );
  }
}

Widget actionButton(
  bool ignoreBuyOrOutOfStockButton,
  bool isAvailable,
  Function addToCart,
  bool inStock,
  bool allowBackorder,
  Widget buyOrOutOfStockButton,
  bool isExternal,
  bool isVariationLoading,
  Product product,
  int quantity,
  ProductVariation? productVariation,
  BuildContext context,
) {
  return Row(
    children: <Widget>[
      if (!ignoreBuyOrOutOfStockButton)
        Expanded(
          child: GestureDetector(
            onTap: isAvailable
                ? () => addToCart(true, inStock || allowBackorder)
                : null,
            child: buyOrOutOfStockButton,
          ),
        ),
      if (!ignoreBuyOrOutOfStockButton) const SizedBox(width: 10),
      if (isAvailable &&
          (inStock || allowBackorder) &&
          !isExternal &&
          !isVariationLoading)
        Expanded(
          child: GestureDetector(
            onTap: () => addToCart(false, inStock || allowBackorder),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: const Color.fromRGBO(254, 130, 118, .7)
                  // color: Theme.of(context).primaryColorLight,// ghc 163[1]
                  ),
              child: Center(
                child: Text(
                  S.of(context).addToCart.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    // color: Theme.of(context).accentColor, //ghc-163[1] related
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
