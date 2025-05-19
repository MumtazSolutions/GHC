import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/config/models/general_setting_item.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/app_model.dart';
import '../models/category/category_model.dart';
import '../models/category/local_cat_model.dart';
import '../models/entities/back_drop_arguments.dart';
import '../models/entities/category.dart';
import '../models/user_model.dart';
import '../modules/dynamic_layout/config/app_config.dart';
import '../modules/dynamic_layout/helper/helper.dart';
import '../routes/flux_navigate.dart';
import '../screens/referral/referral_homescreen.dart';
import '../screens/referral/referral_provider.dart';
import '../services/audio/audio_manager.dart';
import '../services/dependency_injection.dart';
import '../services/service_config.dart';
import '../services/services.dart';
import '../widgets/common/flux_image.dart';
import '../widgets/common/webview.dart';
import '../widgets/general/general_banner_widget.dart';
import '../widgets/general/general_blog_category_widget.dart';
import '../widgets/general/general_blog_widget.dart';
import '../widgets/general/general_button_widget.dart';
import '../widgets/general/general_category_widget.dart';
import '../widgets/general/general_post_widget.dart';
import '../widgets/general/general_product_widget.dart';
import '../widgets/general/general_title_widget.dart';
import '../widgets/general/general_web_widget.dart';
import 'maintab_delegate.dart';

class SideBarMenu extends StatefulWidget {
  const SideBarMenu();

  @override
  MenuBarState createState() => MenuBarState();
}

class MenuBarState extends State<SideBarMenu> {
  bool get isEcommercePlatform =>
      !ServerConfig().isListingType || !ServerConfig().isWordPress;

  DrawerMenuConfig get drawer =>
      Provider.of<AppModel>(context, listen: false).appConfig?.drawer ??
      kDefaultDrawer;

  void pushNavigation(String name) {
    eventBus.fire(const EventCloseNativeDrawer());
    MainTabControlDelegate.getInstance().changeTab(name.replaceFirst('/', ''));
  }

  final LocalStorage storage = LocalStorage('localStorage_app');

  @override
  Widget build(BuildContext context) {
    printLog('[AppState] Load Menu');

    return SafeArea(
      top: drawer.safeArea,
      right: false,
      bottom: false,
      left: false,
      child: Padding(
        key: drawer.key != null ? Key(drawer.key as String) : UniqueKey(),
        padding: EdgeInsets.only(
            bottom:
                injector<AudioManager>().isStickyAudioWidgetActive ? 46 : 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (drawer.logo != null) ...[
                Container(
                  color: drawer.logoConfig.backgroundColor != null
                      ? HexColor(drawer.logoConfig.backgroundColor)
                      : null,
                  padding: EdgeInsets.only(
                    bottom: drawer.logoConfig.marginBottom.toDouble(),
                    top: drawer.logoConfig.marginTop.toDouble(),
                    left: drawer.logoConfig.marginLeft.toDouble(),
                    right: drawer.logoConfig.marginRight.toDouble(),
                  ),
                  child: FluxImage(
                    width: drawer.logoConfig.useMaxWidth
                        ? MediaQuery.of(context).size.width
                        : drawer.logoConfig.width?.toDouble(),
                    fit: Helper.boxFit(drawer.logoConfig.boxFit),
                    height: drawer.logoConfig.height.toDouble(),
                    imageUrl: drawer.logo as String,
                  ),
                ),
                const Divider(),
              ],
              ...List.generate(
                drawer.items?.length ?? 0,
                (index) {
                  return drawerItem(
                    drawer.items![index],
                    drawer.subDrawerItem ?? {},
                    textColor: drawer.textColor != null
                        ? HexColor(drawer.textColor)
                        : null,
                    iconColor: drawer.iconColor != null
                        ? HexColor(drawer.iconColor)
                        : null,
                  );
                },
              ),
              Layout.isDisplayDesktop(context)
                  ? const SizedBox(height: 300)
                  : const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(
    DrawerItemsConfig drawerItemConfig,
    Map<String, GeneralSettingItem> subDrawerItem, {
    Color? iconColor,
    Color? textColor,
  }) {
    // final isTablet = Tools.isTablet(MediaQuery.of(context));

    if (drawerItemConfig.show == false) return const SizedBox();
    var value = drawerItemConfig.type;
    var textStyle = TextStyle(
      color: textColor ?? Theme.of(context).textTheme.bodyText1?.color,
    );

    switch (value) {
      case 'home':
        {
          return ListTile(
            leading: Icon(
              isEcommercePlatform ? Icons.home : Icons.shopping_basket,
              size: 20,
              color: iconColor,
            ),
            title: Text(
              isEcommercePlatform ? S.of(context).home : S.of(context).shop,
              style: textStyle,
            ),
            onTap: () {
              pushNavigation(RouteList.home);
            },
          );
        }
      case 'categories':
        {
          return ListTile(
            leading: Icon(
              Icons.category,
              size: 20,
              color: iconColor,
            ),
            title: Text(
              S.of(context).categories,
              style: textStyle,
            ),
            onTap: () => pushNavigation(
              !Provider.of<AppModel>(context, listen: false).isMultivendor
                  ? RouteList.category
                  : RouteList.vendorCategory,
            ),
          );
        }
      case 'cart':
        {
          if ((!Services().widget.enableShoppingCart(null)) ||
              ServerConfig().isListingType) {
            return const SizedBox();
          }
          return ListTile(
              leading: Icon(
                Icons.shopping_cart,
                size: 20,
                color: iconColor,
              ),
              title: Text(
                S.of(context).cart,
                style: textStyle,
              ),
              onTap: () => {
                    pushNavigation(RouteList.cart),
                  });
        }
      case 'profile':
        {
          return ListTile(
              leading: Icon(
                Icons.person,
                size: 20,
                color: iconColor,
              ),
              title: Text(
                S.of(context).settings,
                style: textStyle,
              ),
              onTap: () => {
                    pushNavigation(RouteList.profile),
                  });
        }
      case 'web':
        {
          return ListTile(
            leading: Icon(
              Icons.web,
              size: 20,
              color: iconColor,
            ),
            title: Text(
              S.of(context).webView,
              style: textStyle,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebView(
                    url: 'https://inspireui.com',
                    title: S.of(context).webView,
                  ),
                ),
              );
            },
          );
        }
      case 'tracker':
        {
          return ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Track your progress'),
              onTap: () => {
                    pushNavigation(RouteList.progress),
                  });
        }
      case 'referral':
        {
          return ListTile(
              leading: Icon(
                Icons.wallet,
                size: 20,
                color: iconColor,
              ),
              title: const Text('My Wallet'),
              // trailing: Container(
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(30),
              //       color: Colors.black),
              //   // padding: EdgeInsets.all(8.0),
              //   height: 30,
              //   width: 70,
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       SizedBox(
              //         width: 20, // Set the desired width
              //         height: 20, // Set the desired height
              //         child: Image.asset(
              //           'assets/images/moonIcon.png',
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.only(left: 4.0),
              //         child: Consumer<ReferralProvider>(
              //             builder: (context, value, child) {
              //           return Text(
              //             value.referralBalModel?.body?.balance.toString() ??
              //                 '0',
              //             style: const TextStyle(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w400,
              //                 fontSize: 14),
              //           );
              //         }),
              //       )
              //     ],
              //   ),
              // ),
              onTap: () {
                // if (Provider.of<UserModel>(context, listen: false).loggedIn ==
                //     true) {
                //   Get.to(const ReferralHomeScreen());
                // } else {
                //   storage.clear();
                //   pushNavigation(RouteList.login);
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebView(
                      url: 'https://ghc.health/pages/rewards',
                      title: 'My Wallet',
                    ),
                  ),
                );
              });
        }
      case 'support':
        {
          return ListTile(
            leading: Icon(
              Icons.headset_mic_outlined,
              size: 20,
              color: iconColor,
            ),
            title: const Text('Customer Support'),
            onTap: () {
              pushNavigation(RouteList.support);
            },
          );
        }
      case 'blog':
        {
          return ListTile(
              leading: Icon(
                CupertinoIcons.news_solid,
                size: 20,
                color: iconColor,
              ),
              title: Text(
                S.of(context).blog,
                style: textStyle,
              ),
              onTap: () => {
                    pushNavigation(RouteList.listBlog),
                  });
        }
      case 'login':
        {
          return ListenableProvider.value(
            value: Provider.of<UserModel>(context, listen: false),
            child: Consumer<UserModel>(builder: (context, userModel, _) {
              final loggedIn = userModel.loggedIn;
              return ListTile(
                leading: Icon(Icons.exit_to_app, size: 20, color: iconColor),
                title: loggedIn
                    ? Text(S.of(context).logout, style: textStyle)
                    : Text(S.of(context).login, style: textStyle),
                onTap: () {
                  if (loggedIn) {
                    Get.defaultDialog(
                      radius: 5,
                      title: 'Are you sure?',
                      titlePadding: const EdgeInsets.only(top: 20),
                      contentPadding: const EdgeInsets.all(20),
                      middleText: 'do you want to logout?',
                      textConfirm: 'Yes',
                      textCancel: 'No',
                      cancelTextColor: Theme.of(context).primaryColor,
                      confirmTextColor: Theme.of(context).primaryColor,
                      buttonColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                        Provider.of<UserModel>(context, listen: false).logout();
                        if (Services().widget.isRequiredLogin) {}
                        pushNavigation(RouteList.home);
                      },
                      onCancel: () {},
                    );
                  } else {
                    storage.clear();
                    pushNavigation(RouteList.login);
                  }
                },
              );
            }),
          );
        }
      case 'category':
        {
          var categories = Provider.of<CategoryModel>(context, listen: false);
          var widgets = <Widget>[];
          categories.categories?.where((item) {
            return item.parent == '0';
          }).toList();
          if (categories.categories != null) {
            var list = categories.categories
                ?.where((item) => item.parent == '0')
                .toList();
            list!.removeWhere((element) =>
                element.name == 'Hidden Items' ||
                element.name == 'Salary Day' ||
                element.name == 'OneRupee' ||
                element.name == 'Best products' ||
                element.name == 'Hidden Items [hidden]' ||
                element.name == 'Free Gifts' ||
                element.name == 'Hidden Sale products' ||
                element.name == 'BOGO' ||
                element.name == 'Buy 2 at 699/-' ||
                element.name == 'products' ||
                element.name == 'buy2get2' ||
                element.name == 'Best Sellers' ||
                element.name == 'Best Products' ||
                element.name == 'New Arrivals' ||
                element.name == 'Anniversary 300' ||
                element.name == 'Ann300 products' ||
                element.name == '60%off combos' ||
                element.name == 'kits' ||
                element.name == 'ANN300 collection' ||
                element.name == 'dreamy60_combos' ||
                element.name == 'Anniversary 300' ||
                element.name == 'single products');
            if (localCategories?.isEmpty == true) {
              localCategories = List.from(list
                  .map((e) => LocalCatModel(name: e.name, id: e.id))
                  .toList());
            }
            for (var i = 0; i < (list.length); i++) {
              var currentCategory = list[i];

              var childCategories = categories.categories
                  ?.where((o) => o.parent == currentCategory.id)
                  .toList();
              if (currentCategory.name.toString().toUpperCase() == 'SEE ALL') {
                currentCategory.name = localCategories
                    ?.firstWhere((item) => currentCategory.id == item.id)
                    .name;
              }
              widgets.add(Container(
                color: i.isOdd
                    ? null
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),

                /// Check to add only parent link category
                child: childCategories?.isEmpty == true
                    ? InkWell(
                        onTap: () => navigateToBackDrop(currentCategory),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 20,
                            bottom: 12,
                            left: 16,
                            top: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                currentCategory.name?.toUpperCase() ?? '',
                                style: textStyle,
                              )),
                              const SizedBox(width: 24),
                              currentCategory.totalProduct == null
                                  ? const Icon(Icons.chevron_right)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        S.of(context).nItems(
                                            currentCategory.totalProduct ?? 0),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      )
                    : ExpansionTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 0.0, top: 0),
                          child: Text(
                            currentCategory.name?.toUpperCase() ?? '',
                            style: textStyle.copyWith(fontSize: 14),
                          ),
                        ),
                        textColor: Theme.of(context).primaryColor,
                        iconColor: Theme.of(context).primaryColor,
                        children: getChildren(categories.categories ?? [],
                            currentCategory, childCategories!) as List<Widget>,
                      ),
              ));
            }
          }
          return buildListCategory(textStyle: textStyle, widgets: widgets);
        }
      default:
        {
          var item = subDrawerItem[value];
          if (value?.contains('web') ?? false) {
            return GeneralWebWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
          if (value?.contains('post') ?? false) {
            return GeneralPostWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
          if (value?.contains('title') ?? false) {
            return GeneralTitleWidget(item: item);
          }
          if (value?.contains('button') ?? false) {
            return GeneralButtonWidget(item: item);
          }
          if (value?.contains('product') ?? false) {
            return GeneralProductWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
          if (value?.contains('category') ?? false) {
            return GeneralCategoryWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
          if (value?.contains('banner') ?? false) {
            return GeneralBannerWidget(
              item: item,
            );
          }
          if (value?.contains('blogCategory') ?? false) {
            return GeneralBlogCategoryWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
          if (value?.contains('blog') ?? false) {
            return GeneralBlogWidget(
              item: item,
              useTile: true,
              iconColor: iconColor,
              textStyle: textStyle,
            );
          }
        }

        return const SizedBox();
    }
  }

  Widget buildListCategory({TextStyle? textStyle, List<Widget>? widgets}) {
    return ExpansionTile(
      initiallyExpanded: true,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      tilePadding: const EdgeInsets.only(left: 16, right: 8),
      title: Text(
        'SHOP BY CATEGORY',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textStyle?.color ??
              Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ),
      children: widgets ?? [],
    );
  }

  List getChildren(
    List<Category> categories,
    Category currentCategory,
    List<Category> childCategories, {
    double paddingOffset = 0.0,
  }) {
    var list = <Widget>[];
    final totalProduct = currentCategory.totalProduct;
    list.add(
      ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 20 + paddingOffset),
          child: Text(S.of(context).seeAll),
        ),
        trailing: ((totalProduct != null && totalProduct > 0))
            ? Text(
                S.of(context).nItems(totalProduct),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              )
            : null,
        onTap: () => navigateToBackDrop(currentCategory),
      ),
    );
    for (var i in childCategories) {
      var newChildren = categories.where((cat) => cat.parent == i.id).toList();
      if (newChildren.isNotEmpty) {
        list.add(
          ExpansionTile(
            title: Padding(
              padding: EdgeInsets.only(left: 20.0 + paddingOffset),
              child: Text(
                i.name!.toUpperCase(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            children: getChildren(
              categories,
              i,
              newChildren,
              paddingOffset: paddingOffset + 10,
            ) as List<Widget>,
          ),
        );
      } else {
        final totalProduct = i.totalProduct;
        list.add(
          ListTile(
            title: Padding(
              padding: EdgeInsets.only(left: 20 + paddingOffset),
              child: Text(i.name!),
            ),
            trailing: (totalProduct != null && totalProduct > 0)
                ? Text(
                    S.of(context).nItems(i.totalProduct!),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  )
                : null,
            onTap: () => navigateToBackDrop(i),
          ),
        );
      }
    }
    return list;
  }

  void navigateToBackDrop(Category category) {
    FluxNavigate.pushNamed(
      RouteList.backdrop,
      arguments: BackDropArguments(
        cateId: category.id,
        cateName: category.name,
      ),
    );
  }
}
