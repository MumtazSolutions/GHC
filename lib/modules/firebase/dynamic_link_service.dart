import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import '../../common/config.dart';

import '../../common/constants.dart';
import '../../common/firebase_services.dart';
import '../../services/services.dart';

class DynamicLinkService {
   DynamicLinkParameters defaultParameters() {
    return DynamicLinkParameters(
        uriPrefix: firebaseDynamicLinkConfig['uriPrefix'],
        link: Uri.parse(firebaseDynamicLinkConfig['link']),
        androidParameters: AndroidParameters(
          packageName: firebaseDynamicLinkConfig['androidPackageName'],
          minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'],
        ),
        iosParameters: IOSParameters(
          bundleId: firebaseDynamicLinkConfig['iOSBundleId'],
          minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'],
          appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'],
        ));

  }
  Future<Uri> generateFirebaseDynamicLink(DynamicLinkParameters params) async {
    final dynamicUrl = params.link;
   
    return dynamicUrl;
  }
     void initDynamicLinks(BuildContext context) async {
    final data = await FirebaseServices().dynamicLinks?.getInitialLink();

    await _handleDynamicLink(data!, context);

    FirebaseServices().dynamicLinks?.onLink;
  }
    static Future<void> _handleDynamicLink(
      PendingDynamicLinkData data, BuildContext context) async {
    try {
      final deepLink = data?.link;
      if (deepLink == null) {
        return;
      }
      var link = deepLink.toString();

      //deepLink URL will look like: https://mstore.io/?productId=26028/ware-backpack-in-burgundy-product-add-ons/
      if (link.contains('productId')) {
        //Permalink will always be in the same format, with ?productId config from permalink settings.
        var productId = link.split('/')[3].split('=')[1];
        final product = await Services().api.getProduct(productId);
        await Navigator.of(context).pushNamed(
          RouteList.productDetail,
          arguments: product,
        );
      }
    } catch (err) {
      printLog('[dynamic_link] error: ${err.toString()}');
    }
  }
  


  void shareProductLink({required String productUrl}) {}

  Future<void> handleDynamicLink(String url, BuildContext context) async {}
  Future<String> generateProductCategoryUrl(dynamic productCategoryId) =>
      Future.value('');
  Future<String> generateProductTagUrl(dynamic productTagId) =>
      Future.value('');
  Future<String> generateProductBrandUrl(dynamic brandCategoryId) =>
      Future.value('');

      
      
}
