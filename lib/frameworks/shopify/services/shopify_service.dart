import 'dart:async';
import 'dart:convert' as convert;

import 'package:collection/collection.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../common/config.dart' show kAdvanceConfig;
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/cart/cart_model_shopify.dart';
import '../../../models/entities/index.dart';
import '../../../models/index.dart'
    show
        Address,
        CartModel,
        Category,
        CheckoutCart,
        CreditCardModel,
        Order,
        PaymentMethod,
        PaymentSettings,
        PaymentSettingsModel,
        Product,
        ProductModel,
        ProductVariation,
        Review,
        ShippingMethod,
        User;
import '../../../models/vendor/store_model.dart' as store_model;
import '../../../services/base_services.dart';
import 'shopify_query.dart';
import 'shopify_storage.dart';

const _apiVersion = '2024-04';

class ShopifyService extends BaseServices {
  ShopifyService({
    required String domain,
    String? blogDomain,
    required String accessToken,
  })  : client = _getClient(
          accessToken: accessToken,
          domain: domain,
          version: _apiVersion,
        ),
        super(domain: domain, blogDomain: blogDomain);

  final GraphQLClient client;

  ShopifyStorage shopifyStorage = ShopifyStorage();

  @override
  String get languageCode => super.languageCode.toUpperCase();

  final _cacheCursorWithCategories = <String, String?>{};
  final _cacheCursorWithSearch = <String, String?>{};

  static GraphQLClient _getClient({
    required String accessToken,
    required String domain,
    String? version,
  }) {
    var httpLink;
    if (version == null) {
      httpLink = HttpLink('$domain/api/graphql');
    } else {
      httpLink = HttpLink('$domain/api/$version/graphql.json');
    }
    final authLink = AuthLink(
      headerKey: 'X-Shopify-Storefront-Access-Token',
      getToken: () async => accessToken,
    );
    return GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }

  Future<List<Category>> getCategoriesByCursor({
    List<Category>? categories,
    String? cursor,
    langCode,
  }) async {
    try {
      const nRepositories = 50;
      var variables = <String, dynamic>{'nRepositories': nRepositories};
      if (cursor != null) {
        variables['cursor'] = cursor;
      }
      variables['langCode'] = langCode?.toString().toUpperCase();
      final options = QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(ShopifyQuery.readCollections),
        variables: variables,
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = categories ?? <Category>[];

      for (var item in result.data!['collections']['edges']) {
        var category = item['node'];

        list.add(Category.fromJsonShopify(category));
      }
      if (result.data?['shop']?['collections']?['pageInfo']?['hasNextPage'] ??
          false) {
        var lastCategory = result.data!['shop']['collections']['edges'].last;
        String? cursor = lastCategory['cursor'];
        if (cursor != null) {
          printLog('::::getCategories shopify by cursor $cursor');
          return await getCategoriesByCursor(
            categories: list,
            cursor: cursor,
            langCode: langCode,
          );
        }
      }
      return list;
    } catch (e) {
      return categories ?? [];
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      printLog('::::request category');
      var categories = await getCategoriesByCursor(langCode: lang);
      return categories;
    } catch (e) {
      printLog('::::getCategories shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Category>> getSubCategories({
    String? langCode,
    dynamic page,
    int limit = 25,
    required String? parentId,
  }) async {
    final cursor = page;
    try {
      const nRepositories = 50;
      var variables = <String, dynamic>{'nRepositories': nRepositories};
      if (cursor != null) {
        variables['cursor'] = cursor;
      }
      final options = QueryOptions(
        document: gql(ShopifyQuery.getCollections),
        variables: variables,
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Category>[];

      String? lastCursor;
      for (var item in result.data!['collections']['edges']) {
        var category = item['node'];
        lastCursor = item['cursor'];
        list.add(Category.fromJsonShopify(category));
      }

      return PagingResponse(data: list, cursor: lastCursor);
    } catch (e) {
      return const PagingResponse(data: <Category>[]);
    }
  }

  @override
  Future<PagingResponse<Product>> getProductsByCategoryId(
    String categoryId, {
    String? langCode,
    dynamic page,
    int limit = 25,
  }) async {
    try {
      final currentCursor = page;
      printLog(
          '::::request fetchProductsByCategory with cursor $currentCursor');
      const nRepositories = 50;
      var variables = <String, dynamic>{
        'nRepositories': nRepositories,
        'categoryId': categoryId,
        'pageSize': limit,
        'query': '',
        'sortKey': 'RELEVANCE',
        'reverse': false,
        'cursor': currentCursor != '' ? currentCursor : null,
      };
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProductByCollection),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: variables,
      );
      final result = await client.query(options);
      var list = <Product>[];
      var lastCursor = '';

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var node = result.data?['node'];

      if (node != null) {
        var productResp = node['products'];
        var edges = productResp['edges'];

        printLog(
            'fetchProductsByCategory with products length ${edges.length}');

        if (edges.length != 0) {
          var lastItem = edges.last;
          lastCursor = lastItem['cursor'];
        }

        for (var item in result.data!['node']['products']['edges']) {
          var product = item['node'];
          product['categoryId'] = categoryId;

          /// Hide out of stock.
          if ((kAdvanceConfig.hideOutOfStock) &&
              product['availableForSale'] == false) {
            continue;
          }
          list.add(Product.fromShopify(product));
        }
      }

      return PagingResponse(data: list, cursor: lastCursor);
    } catch (e) {
      return const PagingResponse(data: []);
    }
  }

  @override
  Future<List<Product>?> fetchProductsLayout(
      {required config,
      lang,
      ProductModel? productModel,
      userId,
      bool refreshCache = false}) async {
    try {
      var list = <Product>[];
      if (config['layout'] == 'imageBanner' ||
          config['layout'] == 'circleCategory') {
        return list;
      }

      return await fetchProductsByCategory(
          categoryId: config['category'].toString(),
          orderBy: config['orderby'].toString(),
          productModel: productModel,
          lang: lang,
          page: config.containsKey('page') ? config['page'] : 1,
          limit: config['limit']);
    } catch (e) {
      printLog('::::fetchProductsLayout shopify error');
      printLog(e.toString());
      return null;
    }
  }

  @override
  // get sort key to filter product
  String getOrderByKey(orderBy) {
    // if (onSale == true) return 'BEST_SELLING';

    if (orderBy == 'price') return 'PRICE';

    if (orderBy == 'date') return 'CREATED';

    if (orderBy == 'title') return 'TITLE';

    return 'COLLECTION_DEFAULT';
  }

  String getProductSortKey(orderBy) {
    // if (onSale == true) return 'BEST_SELLING';

    if (orderBy == 'price') return 'PRICE';

    if (orderBy == 'date') return 'UPDATED_AT';

    if (orderBy == 'title') return 'TITLE';

    return 'RELEVANCE';
  }

  @override
  bool getOrderDirection(order) {
    if (order == 'desc') return true;
    return false;
  }

  @override
  Future<List<Product>?> fetchProductsByCategory({
    categoryId,
    tagId,
    page = 1,
    minPrice,
    maxPrice,
    orderBy,
    lang,
    order,
    attribute,
    attributeTerm,
    featured,
    onSale,
    ProductModel? productModel,
    listingLocation,
    userId,
    nextCursor,
    String? include,
    String? search,
    limit,
  }) async {
    String? currentCursor;

    if (tagId != null) {
      search = (search?.isNotEmpty ?? false)
          ? '$search AND tag:$tagId'
          : 'tag:$tagId';
    }

    if (search == null && categoryId == null) {
      return <Product>[];
    }

    final sortKey = getOrderByKey(orderBy);
    final reverse = getOrderDirection(order);

    try {
      var list = <Product>[];

      /// change category id
      if (page == 1) {
        _cacheCursorWithCategories['$categoryId'] = null;
        _cacheCursorWithSearch['$search'] = null;
      }

      currentCursor = _cacheCursorWithCategories['$categoryId'];
      const nRepositories = 50;
      var variables = <String, dynamic>{
        'nRepositories': nRepositories,
        'categoryId': categoryId,
        'pageSize': limit ?? apiPageSize,
        'query': search ?? '',
        'sortKey': sortKey,
        'reverse': reverse,
        'langCode': lang?.toString().toUpperCase(),
        'cursor': currentCursor != '' ? currentCursor : null,
      };
      printLog(
          '::::request fetchProductsByCategory with category id $categoryId --- search $search');

      if (search != null && search.isNotEmpty) {
        currentCursor = _cacheCursorWithSearch[search];
        printLog(
            '::::request fetchProductsByCategory with cursor $currentCursor');

        final result = await searchProducts(
          name: search,
          lang: lang,
          page: currentCursor,
          sortKey: orderBy,
          reverse: reverse,
        );
        _cacheCursorWithSearch[search] = result.cursor;
        return result.data;
      }

      printLog(
          '::::request fetchProductsByCategory with cursor $currentCursor');
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProductByCollection),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: variables,
      );
      final result = await client.query(options);

      if (result.hasException) {
        throw (result.exception.toString());
      }

      var node = result.data?['node'];

      if (node != null) {
        var productResp = node['products'];
        var edges = productResp['edges'];

        printLog(
            'fetchProductsByCategory with products length ${edges.length}');

        if (edges.length != 0) {
          var lastItem = edges.last;
          var lastCursor = lastItem['cursor'];
          _cacheCursorWithCategories['$categoryId'] = lastCursor;
        }

        for (var item in result.data!['node']['products']['edges']) {
          var product = item['node'];
          product['categoryId'] = categoryId;

          /// Hide out of stock.
          if ((kAdvanceConfig.hideOutOfStock) &&
              product['availableForSale'] == false) {
            continue;
          }
          if (product['tags'].contains('hidden') == false) {
            list.add(Product.fromShopify(product));
          }
        }
      }

      return list;
    } catch (e) {
      printError('::::fetchProductsByCategory shopify error $e');
      printError(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId,
      {int page = 1, int perPage = 10}) async {
    var list = <Review>[];

    return list;
  }

  Future<Address?> updateShippingAddress(
      {Address? address, String? checkoutId}) async {
    try {
      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingAddress),
        variables: {'shippingAddress': address, 'cartId': checkoutId},
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      printLog('updateShippingAddress $result');

      return null;
    } catch (e) {
      printLog('::::updateShippingAddress shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    CartModel? cartModel,
    String? token,
    String? checkoutId,
    store_model.Store? store,
    String? langCode,
  }) async {
    try {
      final list = <ShippingMethod>[];
      final address = cartModel!.address!;
      final buyerIdentity = {
        'email': cartModel.address?.email,
        'phone': cartModel.address?.phoneNumber,
        'deliveryAddressPreferences': [
          {
            'deliveryAddress': {
              'address1': cartModel.address?.apartment,
              'address2': cartModel.address?.block,
              'city': cartModel.address?.city,
              'province': cartModel.address?.state,
              'country': cartModel.address?.country,
              'zip': cartModel.address?.zipCode,
              'firstName': cartModel.address?.firstName,
              'lastName': cartModel.address?.lastName,
              'phone': cartModel.address?.phoneNumber,
            }
          }
        ]
      };

      printLog('getShippingMethods with checkoutId $checkoutId');

      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingAddress),
        variables: {
          'cartId': checkoutId,
          'buyerIdentity': buyerIdentity,
        },
      );

      final result = await client.mutate(options);

      await Future.delayed(const Duration(seconds: 15));

      if (result.hasException) {
        printLog(result.exception.toString());
        throw ('So sorry, we do not support shipping to your address.');
      }

      final cart = result.data?['cartDeliveryAddressesAdd']?['cart'];
      final addresses = cart?['delivery']?['addresses'] ?? [];

      for (var item in addresses) {
        final shippingMethod = ShippingMethod.fromShopifyJson(item);
        list.add(shippingMethod);
      }

      printLog(
          '::::getShippingMethods ${list.map((e) => e.toString()).join(', ')}');
      return list;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future updateShippingLine(
      String checkoutId, String shippingRateHandle) async {
    try {
      final options = MutationOptions(
        document: gql(ShopifyQuery.updateShippingLine),
        variables: {
          'checkoutId': checkoutId,
          'shippingRateHandle': shippingRateHandle
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var checkout = result.data!['checkoutShippingLineUpdate']['checkout'];

      return checkout;
    } catch (e) {
      printLog('::::getShippingMethods shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
      ShippingMethod? shippingMethod,
      String? token,
      String? langCode}) async {
    try {
      var list = <PaymentMethod>[];

      list.add(PaymentMethod.fromJson({
        'id': '0',
        'title': 'Checkout Free',
        'description': '',
        'enabled': true,
      }));

      list.add(PaymentMethod.fromJson({
        'id': '1',
        'title': 'Checkout Credit card',
        'description': '',
        'enabled': true,
      }));

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Product>> searchProducts({
    name,
    categoryId = '',
    categoryName = '',
    tag = '',
    attribute = '',
    attributeId = '',
    page,
    lang,
    listingLocation,
    userId,
    String? sortKey,
    bool reverse = false,
  }) async {
    try {
      printLog('::::request searchProducts');
      const pageSize = 25;
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getProductByName),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'query': '$name $categoryName',
          if (page != null) 'cursor': page,
          'pageSize': pageSize,
          'sortKey': getProductSortKey(sortKey),
          'reverse': reverse,
          'langCode': lang?.toString().toUpperCase(),
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        throw (result.exception.toString());
      }

      var list = <Product>[];
      String? lastCursor;
      for (var item in result.data?['products']['edges']) {
        lastCursor = item['cursor'];

        /// Hide out of stock.
        if ((kAdvanceConfig.hideOutOfStock) &&
            item['node']?['availableForSale'] == false) {
          continue;
        }
        if (item['node']['tags'].contains('hidden') == false) {
          list.add(Product.fromShopify(item['node']));
        }
      }

      printLog(list);

      return PagingResponse(data: list, cursor: lastCursor);
    } catch (e) {
      printLog('::::searchProducts shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
  }) async {
    try {
      printLog('::::request createUser');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.createCustomer),
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {
              'firstName': firstName,
              'lastName': lastName,
              'email': username,
              'password': password
            }
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final listError =
          List.from(result.data?['customerCreate']?['userErrors'] ?? []);
      if (listError.isNotEmpty) {
        final message = listError.map((e) => e['message']).join(', ');
        throw Exception('$message!');
      }

      printLog('createUser ${result.data}');

      var userInfo = result.data!['customerCreate']['customer'];
      final token =
          await createAccessToken(username: username, password: password);
      var user = User.fromShopifyJson(userInfo, token);

      return user;
    } catch (e) {
      printLog('::::createUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User?> getUserInfo(cookie) async {
    try {
      printLog('::::request getUserInfo');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.getCustomerInfo),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'accessToken': cookie
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      var user = User.fromShopifyJson(result.data?['customer'] ?? {}, cookie);
      print('userId: ${user.id}');
      if (user.cookie == null) return null;
      return user;
    } catch (e) {
      printLog('::::getUserInfo shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String? token) async {
    try {
      printLog('::::request updateUser');

      const nRepositories = 50;
      json.removeWhere((key, value) => key == 'deviceToken');
      final options = QueryOptions(
          document: gql(ShopifyQuery.customerUpdate),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'customerAccessToken': token,
            'customer': json,
          });

      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      // When update password, full user info will get null
      final userData = result.data?['customerUpdate']['customer'];
      final newToken =
          result.data?['customerUpdate']['customerAccessToken']?['accessToken'];
      final user = User.fromShopifyJson(userData, newToken);
      return user.toJson();
    } catch (e) {
      printLog('::::updateUser shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<String?> createAccessToken({username, password}) async {
    try {
      printLog('::::request createAccessToken');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.createCustomerToken),
          fetchPolicy: FetchPolicy.networkOnly,
          variables: <String, dynamic>{
            'nRepositories': nRepositories,
            'input': {'email': username, 'password': password}
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json =
          result.data!['customerAccessTokenCreate']['customerAccessToken'];
      printLog("json['accessToken'] ${json['accessToken']}");

      return json['accessToken'];
    } catch (e) {
      printLog('::::createAccessToken shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<User?> login({username, password}) async {
    try {
      printLog('::::request login');

      var accessToken =
          await createAccessToken(username: username, password: password);
      var userInfo = await getUserInfo(accessToken);

      printLog('login $userInfo');

      return userInfo;
    } catch (e) {
      printLog('::::login shopify error');
      printLog(e.toString());
      throw Exception(
          'Please check your username or password and try again. If the problem persists, please contact support!');
    }
  }

  @override
  Future<Product> getProduct(id, {lang, cursor}) async {
    /// Private id is id has been encrypted by Shopify, which is get via api
    final isPrivateId = int.tryParse(id) == null;
    if (isPrivateId) {
      return getProductByPrivateId(id);
    }
    printLog('::::request getProduct $id');

    /// Normal id is id the user can see on the admin site, which is not encrypt
    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductById),
      variables: <String, dynamic>{'nRepositories': nRepositories, 'id': id},
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }
    List? listData = result.data?['products']?['edges'];
    if (listData != null && listData.isNotEmpty) {
      final productData = listData.first['node'];
      return Product.fromShopify(productData);
    }
    return Product();
  }

  Future<Product> getProductByPrivateId(id) async {
    printLog('::::request getProductByPrivateId $id');

    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductByPrivateId),
      variables: <String, dynamic>{'nRepositories': nRepositories, 'id': id},
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }
    return Product.fromShopify(result.data!['node']);
  }

  Future<Map<String, dynamic>?> updateCartBuyerIdentity({
    required String cartId,
    required String customerAccessToken,
  }) async {
    print("this is cartId: $cartId");
    print("this is accesstoken: $customerAccessToken");
    final options = MutationOptions(
      document: gql(ShopifyQuery.updateCartBuyerIdentity),
      variables: {
        'cartId': cartId,
        'buyerIdentityInput': {
          'customerAccessToken': customerAccessToken,
        },
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }

    final cart = result.data?['cartBuyerIdentityUpdate']?['cart'];
    return cart;
  }

  Future<CheckoutCart> addItemsToCart(CartModelShopify cartModel) async {
    final cookie = cartModel.user?.cookie;
    try {
      if (cookie == null) throw 'You need to login to checkout';

      var lineItems = <Map<String, dynamic>>[];

      for (var productId in cartModel.productVariationInCart.keys) {
        var variant = cartModel.productVariationInCart[productId]!;
        var quantity = cartModel.productsInCart[productId];

        lineItems.add({
          'merchandiseId': variant.id,
          'quantity': quantity,
        });
      }

      final options = MutationOptions(
        document: gql(ShopifyQuery.createCart),
        variables: {
          'cartInput': {
            'lines': lineItems,
            if (cartModel.address != null)
              'buyerIdentity': {
                'customerAccessToken': cookie,
                'email': cartModel.address!.email
              }
          },
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final cart = result.data!['cartCreate']['cart'];
      // NEW: update buyer identity
      await updateCartBuyerIdentity(
        cartId: cart['id'],
        customerAccessToken: cookie,
      );

      return CheckoutCart.fromJsonShopifyCart(cart);
    } catch (e) {
      printLog('::::addItemsToCart shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<CheckoutCart> updateItemsToCart(
      CartModelShopify cartModel, String? cookie) async {
    try {
      if (cookie == null) throw S.current.youNeedToLoginCheckout;

      final cartId = cartModel.checkout?.id;
      if (cartId == null) throw 'Cart ID is null';

      final List<Map<String, dynamic>> updatedLines = [];

      cartModel.productsInCart.forEach((key, quantity) {
        final variant = cartModel.productVariationInCart[key];
        if (variant != null && variant.id != null) {
          final lineItemId = cartModel.cartLines[variant.id];
          if (lineItemId != null) {
            updatedLines.add({
              'id': lineItemId,
              'quantity': quantity,
              'merchandiseId': variant.id,
            });
          } else {
            printLog('❗ Line item ID not found for variant: ${variant.id}');
          }
        }
      });

      final options = MutationOptions(
        document: gql(ShopifyQuery.cartLinesUpdate),
        variables: {
          'cartId': cartId,
          'lines': updatedLines,
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final cart = result.data?['cartLinesUpdate']?['cart'];
      if (cart == null) throw 'Update failed: cart is null';

      return CheckoutCart.fromJsonShopifyCart(cart);
    } catch (e) {
      printLog('::::updateItemsToCart shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<CheckoutCart> applyCoupon(
    CartModel cartModel,
    String discountCode,
  ) async {
    try {
      printLog('applyCoupon ${cartModel.productsInCart}');
      printLog('Applying discount code: $discountCode');

      final options = MutationOptions(
        document: gql(ShopifyQuery.applyCoupon),
        variables: {
          'cartId': cartModel.checkout!.id,
          'discountCodes': [discountCode],
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final cart = result.data?['cartDiscountCodesUpdate']?['cart'];
      if (cart == null) {
        throw Exception('Cart is null after applying discount code.');
      }

      return CheckoutCart.fromJsonShopifyCart(cart);
    } catch (e) {
      printLog('::::applyCoupon shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<CheckoutCart> removeCoupon(String? cartId) async {
    try {
      if (cartId == null) throw Exception('Cart ID cannot be null.');

      final options = MutationOptions(
        document: gql(ShopifyQuery.applyCoupon), // reuse the same mutation
        variables: {
          'cartId': cartId,
          'discountCodes': [], // 👈 empty list to remove coupons
        },
      );

      final result = await client.mutate(options);

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }

      final cart = result.data?['cartDiscountCodesUpdate']?['cart'];

      if (cart == null) {
        throw Exception('Cart is null after removing coupon.');
      }

      return CheckoutCart.fromJsonShopifyCart(cart);
    } catch (e) {
      printLog('::::removeCoupon shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  Future<void> updateCartAttributes({
    required String cartId,
    String? note,
    DateTime? deliveryDate,
  }) async {
    final deliveryInfo = <Map<String, String>>[];

    if (note?.isNotEmpty == true) {
      deliveryInfo.add({'key': 'Note', 'value': note!});
    }

    if (deliveryDate != null) {
      final dateFormat = DateFormat(DateTimeFormatConstants.ddMMMMyyyy);
      final dayFormat = DateFormat(DateTimeFormatConstants.weekday);
      final timeFormat = DateFormat(DateTimeFormatConstants.timeHHmmFormatEN);

      deliveryInfo.addAll([
        {'key': 'Delivery Date', 'value': dateFormat.format(deliveryDate)},
        {'key': 'Delivery Day', 'value': dayFormat.format(deliveryDate)},
        {'key': 'Delivery Time', 'value': timeFormat.format(deliveryDate)},
      ]);
    }

    final options = MutationOptions(
      document: gql(ShopifyQuery.updateCartAttribute),
      variables: {
        'cartId': cartId,
        'attributes': deliveryInfo,
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw Exception(result.exception.toString());
    }
  }

  // payment settings from shop
  @override
  Future<PaymentSettings> getPaymentSettings() async {
    try {
      printLog('::::request paymentSettings');

      const nRepositories = 50;
      final options = QueryOptions(
          document: gql(ShopifyQuery.getPaymentSettings),
          variables: const <String, dynamic>{
            'nRepositories': nRepositories,
          });

      final result = await client.query(options);

      printLog('result ${result.data}');

      if (result.hasException) {
        printLog(result.exception.toString());
        throw Exception(result.exception.toString());
      }
      var json = result.data!['shop']['paymentSettings'];

      printLog('paymentSettings $json');

      return PaymentSettings.fromShopifyJson(json);
    } catch (e) {
      printLog('::::paymentSettings shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<PaymentSettings> addCreditCard(
      PaymentSettingsModel paymentSettingsModel,
      CreditCardModel creditCardModel) async {
    try {
      var response = await httpPost(
          paymentSettingsModel.getCardVaultUrl()!.toUri()!,
          body: convert.jsonEncode(creditCardModel),
          headers: {'content-type': 'application/json'});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return PaymentSettings.fromVaultIdShopifyJson(body['data']);
      } else {
        List? error = body['error'];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception('Login fail');
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future checkoutWithCreditCard(String? vaultId, CartModel cartModel,
      Address address, PaymentSettingsModel paymentSettingsModel) async {
    try {
      try {
        var uuid = const Uuid();
        var paymentAmount = {
          'amount': cartModel.getTotal(),
          'currencyCode': cartModel.getCurrency()
        };

        final options = MutationOptions(
          document: gql(ShopifyQuery.checkoutWithCreditCard),
          variables: {
            'checkoutId': cartModel.checkout!.id,
            'payment': {
              'paymentAmount': paymentAmount,
              'idempotencyKey': uuid.v1(),
              'billingAddress': address.toShopifyJson()['address'],
              'vaultId': vaultId,
              'test': true
            }
          },
        );

        final result = await client.mutate(options);

        if (result.hasException) {
          printLog(result.exception.toString());
          throw Exception(result.exception.toString());
        }

        var checkout =
            result.data!['checkoutCompleteWithCreditCardV2']['checkout'];

        return CheckoutCart.fromJsonShopify(checkout);
      } catch (e) {
        printLog('::::applyCoupon shopify error');
        printLog(e.toString());
        rethrow;
      }
    } catch (e) {
      printLog('::::checkoutWithCreditCard shopify error');
      printLog(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>?> getProductVariations(Product product,
      {String? lang = 'en'}) async {
    try {
      return product.variations;
    } catch (e) {
      printLog('::::getProductVariations shopify error');
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Blog>>? getBlogs(dynamic cursor) async {
    /// That means override blog from WordPress
    if (super.blogApi.url != domain) {
      return (await super.getBlogs(cursor)) ?? const PagingResponse();
    }
    try {
      printLog('::::request blogs');

      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getArticle),
        fetchPolicy: FetchPolicy.networkOnly,
        variables: {
          'nRepositories': nRepositories,
          'pageSize': 12,
          'langCode': languageCode,
          if (cursor != null && cursor is! num) 'cursor': cursor,
        },
      );
      final response = await client.query(options);

      if (response.hasException) {
        printLog(response.exception.toString());
      }

      final data = <Blog>[];
      String? lastCursor;
      for (var item in response.data!['articles']['edges']) {
        final blog = item['node'];
        lastCursor = item['cursor'];
        data.add(Blog.fromShopifyJson(blog));
      }

      return PagingResponse(
        data: data,
        cursor: lastCursor,
      );

      // printLog(list);
    } catch (e) {
      printLog('::::fetchBlogLayout shopify error');
      printLog(e.toString());
      return const PagingResponse();
    }
  }

  @override
  Future<PagingResponse<Order>> getMyOrders({
    User? user,
    dynamic cursor,
    String? cartId,
  }) async {
    try {
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getOrder),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'customerAccessToken': user!.cookie,
          if (cursor != null) 'cursor': cursor,
          'pageSize': 50
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      var list = <Order>[];
      String? lastCursor;

      for (var item in result.data!['customer']['orders']['edges']) {
        lastCursor = item['cursor'];
        var order = item['node'];
        list.add(Order.fromJson(order));
      }
      return PagingResponse(
        cursor: lastCursor,
        data: list,
      );
    } catch (e) {
      printLog('::::getMyOrders shopify error');
      printLog(e.toString());
      return const PagingResponse();
    }
  }

  @override
  Future<String> submitForgotPassword({
    String? forgotPwLink,
    Map<String, dynamic>? data,
  }) async {
    final options = MutationOptions(
      document: gql(ShopifyQuery.resetPassword),
      variables: {
        'email': data!['email'],
      },
    );

    final result = await client.mutate(options);

    if (result.hasException) {
      printLog(result.exception.toString());
      throw (result.exception?.graphqlErrors.firstOrNull?.message ??
          S.current.somethingWrong);
    }

    final List? errors = result.data!['customerRecover']['customerUserErrors'];
    const errorCode = 'UNIDENTIFIED_CUSTOMER';
    if (errors?.isNotEmpty ?? false) {
      if (errors!.any((element) => element['code'] == errorCode)) {
        throw Exception(errorCode);
      }
    }

    return '';
  }

  @override
  Future<Product?> getProductByPermalink(String productPermalink) async {
    final handle =
        productPermalink.substring(productPermalink.lastIndexOf('/') + 1);
    printLog('::::request getProduct $productPermalink');

    const nRepositories = 50;
    final options = QueryOptions(
      document: gql(ShopifyQuery.getProductByHandle),
      variables: <String, dynamic>{
        'nRepositories': nRepositories,
        'handle': handle
      },
    );
    final result = await client.query(options);

    if (result.hasException) {
      printLog(result.exception.toString());
    }

    final productData = result.data?['productByHandle'];
    return Product.fromShopify(productData);
  }

  Future<Order?> getLatestOrder({required String cookie}) async {
    try {
      const nRepositories = 50;
      final options = QueryOptions(
        document: gql(ShopifyQuery.getOrder),
        variables: <String, dynamic>{
          'nRepositories': nRepositories,
          'customerAccessToken': cookie,
          'pageSize': 1
        },
      );
      final result = await client.query(options);

      if (result.hasException) {
        printLog(result.exception.toString());
      }

      for (var item in result.data!['customer']['orders']['edges']) {
        var order = item['node'];
        return Order.fromJson(order);
      }
    } catch (e) {
      printLog('::::getLatestOrder shopify error');
      printLog(e.toString());
      return null;
    }
    return null;
  }

  @override
  Future logout(String? token) async {}
}
