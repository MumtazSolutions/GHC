import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools/price_tools.dart';
import '../../../models/app_model.dart';
import '../../../models/index.dart' show Product, ProductWishListModel;

class HeartButton extends StatelessWidget {
  final Product product;
  final double? size;
  final Color? color;

  const HeartButton({Key? key, required this.product, this.size, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? regularPrice = 0.0;
    final currency = Provider.of<AppModel>(context, listen: false).currencyCode;
    var salePercent = 0;
    return ChangeNotifierProvider.value(
      value: Provider.of<ProductWishListModel>(context, listen: false),
      child: Consumer<ProductWishListModel>(
        builder: (BuildContext context, ProductWishListModel model, _) {
          final isExist =
              model.products.indexWhere((item) => item.id == product.id) != -1;
          if (!isExist) {
            return IconButton(
              onPressed: () {
                if (product.regularPrice != null &&
                    product.regularPrice!.isNotEmpty &&
                    product.regularPrice != '0.0') {
                  regularPrice =
                      (double.tryParse(product.regularPrice.toString()));
                }

                /// Calculate the Sale price
                var isSale = (product.onSale ?? false) &&
                    PriceTools.getPriceProductValue(product, currency,
                            onSale: true) !=
                        PriceTools.getPriceProductValue(product, currency,
                            onSale: false);
                if (isSale && regularPrice != 0) {
                  salePercent =
                      (double.parse(product.salePrice!) - regularPrice!) *
                          100 ~/
                          regularPrice!;
                }
                Provider.of<ProductWishListModel>(context, listen: false)
                    .addToWishlist(product);
              },
              icon: CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.5),
                child: Icon(
                  CupertinoIcons.heart,
                  color: Colors.white,
                  size: size ?? 16.0,
                ),
              ),
            );
          }

          return IconButton(
            onPressed: () {
              Provider.of<ProductWishListModel>(context, listen: false)
                  .removeToWishlist(product);
            },
            icon: CircleAvatar(
              backgroundColor: Colors.pink.withOpacity(0.1),
              child: Icon(CupertinoIcons.heart_fill,
                  color: Colors.pink, size: size ?? 16.0),
            ),
          );
        },
      ),
    );
  }
}
