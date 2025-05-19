import 'cart_base.dart';
import 'cart_model_shopify.dart';

export 'cart_base.dart';

class CartInject {
  static final CartInject _instance = CartInject._internal();

  factory CartInject() => _instance;

  CartInject._internal();

  /// init default CartModel
  CartModel model = CartModelShopify();

  void init(config) {
    switch (config['type']) {
      case 'shopify':
        model = CartModelShopify();
        break;
    }
    model.initData();
  }
}
