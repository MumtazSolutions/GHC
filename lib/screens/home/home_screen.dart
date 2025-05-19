import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fstore/menu/maintab_delegate.dart';
import 'package:fstore/pushNotification_handler.dart';
import 'package:inspireui/widgets/smart_engagement_banner/index.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/app_model.dart';
import '../../modules/dynamic_layout/index.dart';
import '../../routes/flux_navigate.dart';
import '../../services/index.dart';
import '../../widgets/home/index.dart';
import '../../widgets/home/wrap_status_bar.dart';
import '../base_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseScreen<HomeScreen> {
  // @override
  // bool get wantKeepAlive => true;

  @override
  void dispose() {
    printLog('[Home] dispose');
    super.dispose();
  }

  void pushNavigation(String name) {
    eventBus.fire(const EventCloseNativeDrawer());
    MainTabControlDelegate.getInstance().changeTab(name.replaceFirst('/', ''));
  }

  @override
  void initState() {
    printLog('[Home] initState');
    super.initState();
    debugPrint('screenName in home screen $screenName');
    if (screenName == 'Hair' ||
        screenName == 'Beard' ||
        screenName == 'weight' ||
        screenName == 'skin' ||
        screenName == 'water' ||
        screenName == 'sleep') {
      Future.delayed(const Duration(milliseconds: 2500)).then((value) {
        pushNavigation(RouteList.progress);
      });
    } else if (screenName == 'cart') {
      Future.delayed(const Duration(milliseconds: 2500)).then((value) {
        pushNavigation(RouteList.cart);
      });
    } else if (screenName.contains('product')) {
      var productDeeplink = screenName.split('-');
      var productId = 'gid://shopify/Product/${productDeeplink[1]}';
      var encodedProduct = utf8.encode(productId.toString());
      var encodedProductId = base64.encode(encodedProduct);
      Future.delayed(const Duration(milliseconds: 2500)).then((value) async {
        var product = await Services().api.getProduct(encodedProductId);
        var bytes = utf8.encode(product?.categoryId ?? '');
        var base64Str = base64.encode(bytes);
        product?.categoryId = base64Str;
        await FluxNavigate.pushNamed(
          RouteList.productDetail,
          arguments: product,
        );
      });
    }
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    /// init dynamic link
    if (!kIsWeb) {
      Services().firebase.initDynamicLinkService(context);
    }
  }

  final popupBannerLastUpdatedTime = injector<SharedPreferences>()
          .getInt(LocalStorageKey.popupBannerLastUpdatedTime) ??
      0;

  void afterClosePopup(int updatedTime) {
    injector<SharedPreferences>().setInt(
      LocalStorageKey.popupBannerLastUpdatedTime,
      updatedTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    printLog('[Home] build');
    return Selector<AppModel, Tuple2<AppConfig?, String>>(
      selector: (_, model) => Tuple2(model.appConfig, model.langCode),
      builder: (_, value, child) {
        var appConfig = value.item1;
        var langCode = value.item2;

        if (appConfig == null) {
          return kLoadingWidget(context);
        }

        var isStickyHeader = appConfig.settings.stickyHeader;
        final horizontalLayoutList =
            List.from(appConfig.jsonData['HorizonLayout']);
        final isShowAppbar = horizontalLayoutList.isNotEmpty &&
            horizontalLayoutList.first['layout'] == 'logo';

        final bannerConfig = appConfig.settings.smartEngagementBannerConfig;

        final isShowPopupBanner =
            (popupBannerLastUpdatedTime != bannerConfig.popup.updatedTime) ||
                bannerConfig.popup.alwaysShowUponOpen;

        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Stack(
            children: <Widget>[
              if (appConfig.background != null)
                isStickyHeader
                    ? SafeArea(
                        child: HomeBackground(config: appConfig.background),
                      )
                    : HomeBackground(config: appConfig.background),
              HomeLayout(
                isPinAppBar: isStickyHeader,
                isShowAppbar: isShowAppbar,
                showNewAppBar:
                    appConfig.appBar?.shouldShowOn(RouteList.home) ?? false,
                configs: appConfig.jsonData,
                key: Key(langCode),
              ),
              SmartEngagementBanner(
                context: App.fluxStoreNavigatorKey.currentContext!,
                config: bannerConfig,
                enablePopup: isShowPopupBanner,
                afterClosePopup: () {
                  afterClosePopup(bannerConfig.popup.updatedTime);
                },
                childWidget: (data) {
                  return DynamicLayout(config: data);
                },
              ),
              const WrapStatusBar(),
            ],
          ),
        );
      },
    );
  }
}
