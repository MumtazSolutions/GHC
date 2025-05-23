import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart' show RouteList, printLog;
import '../../../generated/l10n.dart';
import '../../../models/entities/back_drop_arguments.dart';
import '../../../models/entities/store_arguments.dart';
import '../../../routes/flux_navigate.dart';
import '../../../screens/blog/views/blog_detail_screen.dart';
import '../../../screens/referral/referral_homescreen.dart';
import '../../../services/index.dart';
import '../../../widgets/common/webview.dart';
import '../dynamic_link_service.dart';

class DynamicLinkServiceImpl extends DynamicLinkService {
  final _service = Services();

  @override
  void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      handleDynamicLink(dynamicLinkData.link.path, context);
    }).onError((e) {
      printLog('[firebase-dynamic-link] error: ${e.message}');
    });

    var initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final deepLink = initialLink.link;
      printLog('[firebase-dynamic-link] getInitialLink: $deepLink');
      await handleDynamicLink(deepLink.toString(), context);
    }
  }

  /// share product link that contains Dynamic link
  @override
  void shareProductLink({
    required String productUrl,
  }) async {
    var productParams = dynamicLinkParameters(url: productUrl);
    var firebaseDynamicLink = await generateFirebaseDynamicLink(productParams);
    printLog('[firebase-dynamic-link] $firebaseDynamicLink');
    await Share.share(
      firebaseDynamicLink.toString(),
    );
  }

  @override
  Future<String> generateProductCategoryUrl(dynamic productCategoryId) async {
    final cate = await _service.api
        .getProductCategoryById(categoryId: productCategoryId);
    var url;
    if (cate != null) {
      url = '${ServerConfig().url}/product-category/${cate.slug}';
    }
    return url;
  }

  @override
  Future<String> generateProductTagUrl(dynamic productTagId) async {
    final tag = await _service.api.getTagById(tagId: productTagId.toString());
    var url;
    if (tag != null) {
      url = '${ServerConfig().url}/product-tag/${tag.slug}';
    }
    return url;
  }

  @override
  Future<String> generateProductBrandUrl(dynamic brandCategoryId) async {
    final brand = await _service.api.getBrandById(brandCategoryId);
    var url;
    if (brand != null) {
      url = serverConfig['url'] + '/brand/' + brand.slug;
    }
    return url;
  }

  //Navigate to ProductDetail screen by entering productURL
  @override
  Future<void> handleDynamicLink(String url, BuildContext context) async {
    try {
      // _showLoading(context);

      //if the dynamic link contains referral, navigate the user to referral home screen
      if (url.contains('/referral')) {
        // await Get.to(const ReferralHomeScreen());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebView(
              url: 'https://ghc.health/pages/rewards',
              title: 'My Wallet',
            ),
          ),
        );
      } else if (url.contains('/product-category/')) {
        final category =
            await Services().api.getProductCategoryByPermalink(url);
        if (category != null) {
          await FluxNavigate.pushNamed(
            RouteList.backdrop,
            arguments: BackDropArguments(
              cateId: category.id,
              cateName: category.name,
            ),
          );
        }

        /// PRODUCT TAGS CASE
      } else if (url.contains('/product-tag/')) {
        final slug = Uri.tryParse(url)?.pathSegments.last;

        if (slug == null) throw '';

        final tag = await Services().api.getTagBySlug(slug);
        if (tag != null) {
          await FluxNavigate.pushNamed(
            RouteList.backdrop,
            arguments: BackDropArguments(
              tag: tag.id.toString(),
            ),
          );
        }

        /// VENDOR CASE
      } else if (url.contains('/store/')) {
        final vendor = await Services().api.getStoreByPermalink(url);
        if (vendor != null) {
          await FluxNavigate.pushNamed(
            RouteList.storeDetail,
            arguments: StoreDetailArgument(store: vendor),
          );
        }
      } else if (url.contains('/brand/')) {
        final slug = Uri.tryParse(url)?.pathSegments.last;

        if (slug == null) throw '';

        final brand = await Services().api.getBrandBySlug(slug);
        if (brand != null) {
          await FluxNavigate.pushNamed(
            RouteList.backdrop,
            arguments: BackDropArguments(
              brandId: brand.id,
              brandName: brand.name,
              brandImg: brand.image,
            ),
          );
        }
      } else {
        var blog = await Services().api.getBlogByPermalink(url);
        if (blog != null) {
          await FluxNavigate.pushNamed(
            RouteList.detailBlog,
            arguments: BlogDetailArguments(blog: blog),
          );
        }
      }
    } catch (err) {
      _showErrorMessage(context);
    }
  }

  DynamicLinkParameters dynamicLinkParameters({required String url}) {
    return DynamicLinkParameters(
      uriPrefix: firebaseDynamicLinkConfig['uriPrefix'],
      link: Uri.parse(url),
      androidParameters: AndroidParameters(
        packageName: firebaseDynamicLinkConfig['androidPackageName'],
        minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'],
      ),
      iosParameters: IOSParameters(
        bundleId: firebaseDynamicLinkConfig['iOSBundleId'],
        minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'],
        appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'],
      ),
    );
  }

  Future<Uri> generateFirebaseDynamicLink(DynamicLinkParameters params) async {
    var dynamicLinks = FirebaseDynamicLinks.instance;

    if (firebaseDynamicLinkConfig['shortDynamicLinkEnable'] ?? false) {
      var shortDynamicLink = await dynamicLinks.buildShortLink(params);
      return shortDynamicLink.shortUrl;
    } else {
      return await dynamicLinks.buildLink(params);
    }
  }

  static void _showLoading(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.current.loadingLink),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void _showErrorMessage(context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.current.canNotLoadThisLink),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'DISMISS',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
