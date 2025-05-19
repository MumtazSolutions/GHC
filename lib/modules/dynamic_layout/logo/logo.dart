import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inspireui/icons/icon_picker.dart' deferred as defer_icon;
import 'package:inspireui/inspireui.dart' show DeferredWidget;
import 'package:provider/provider.dart';

import '../../../common/common_widgets.dart';
import '../../../models/user_model.dart';
import '../../../screens/referral/referral_homescreen.dart';
import '../../../screens/referral/referral_init.dart';
import '../../../screens/referral/referral_provider.dart';
import '../../../widgets/common/flux_image.dart';
import '../config/logo_config.dart';

const double kSizeLogo = 50;

class LogoIcon extends StatelessWidget {
  final LogoConfig config;
  final Function onTap;
  final MenuIcon? menuIcon;

  const LogoIcon({
    Key? key,
    required this.config,
    required this.onTap,
    this.menuIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      key: const Key('drawerMenu'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          config.iconRadius,
        ),
      ),
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      fillColor: config.iconBackground != null
          ? config.iconBackground!.withOpacity(config.iconOpacity)
          : Theme.of(context).backgroundColor.withOpacity(config.iconOpacity),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      onPressed: () => onTap.call(),
      child: menuIcon != null
          ? DeferredWidget(
              defer_icon.loadLibrary,
              () => Icon(
                defer_icon.iconPicker(
                  menuIcon!.name!,
                  menuIcon!.fontFamily ?? 'CupertinoIcons',
                ),
                color: config.iconColor ??
                    Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                size: config.iconSize,
              ),
            )
          : Icon(
              Icons.blur_on,
              color: config.iconColor ??
                  Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              size: config.iconSize,
            ),
    );
  }
}

class Logo extends StatefulWidget {
  final onSearch;
  final onCheckout;
  final onTapDrawerMenu;
  final onTapNotifications;
  final String? logo;
  final LogoConfig config;
  final int totalCart;
  final int notificationCount;

  const Logo({
    Key? key,
    required this.config,
    required this.onSearch,
    required this.onCheckout,
    required this.onTapDrawerMenu,
    required this.onTapNotifications,
    this.logo,
    this.totalCart = 0,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  void initState() {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false);
    if (user.user != null) {
      var shopifyId = utf8.decode(base64.decode((user.user?.id).toString()));
      var userIdUrl = shopifyId.toString().split('/');
      var shopifyUserId = userIdUrl[4].trim();
      print('this is customer id $shopifyUserId');
      Future.delayed(Duration.zero).then((value) async {
        await referralVm.getReferralBal(customerID: shopifyUserId);
      });
    }

    super.initState();
  }

  Widget renderLogo() {
    if (widget.config.image != null) {
      if (widget.config.image!.contains('http')) {
        return SizedBox(
          height: kSizeLogo - 10,
          child: FluxImage(
            imageUrl: widget.config.image!,
            height: kSizeLogo,
            fit: BoxFit.contain,
          ),
        );
      }
      return Image.asset(
        widget.config.image!,
        height: kSizeLogo,
      );
    }

    /// render from config to support dark/light theme
    if (widget.logo != null) {
      return FluxImage(imageUrl: widget.logo!, height: kSizeLogo);
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Container(
          constraints: const BoxConstraints(minHeight: 40.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              Expanded(
                child: (widget.config.showMenu ?? false)
                    ? LogoIcon(
                        menuIcon: widget.config.menuIcon,
                        onTap: widget.onTapDrawerMenu,
                        config: widget.config,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 0, maxHeight: 34),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (widget.config.showLogo) Center(child: renderLogo()),
                        if (widget.config.name?.isNotEmpty ?? false) ...[
                          const SizedBox(width: 1),
                          Text(
                            widget.config.name!,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.config.showSearch)
                Expanded(
                  child: LogoIcon(
                    menuIcon:
                        widget.config.searchIcon ?? MenuIcon(name: 'search'),
                    onTap: widget.onSearch,
                    config: widget.config,
                  ),
                ),
              sBox(w: 3.0),
              // if (Provider.of<UserModel>(context, listen: false).loggedIn ==
              //     true)
              //   Container(
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(30),
              //         color: Colors.black),
              //     // padding: EdgeInsets.all(8.0),
              //     height: 30,
              //     width: 70,
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         GestureDetector(
              //           onTap: () {
              //             Get.to(Consumer<UserModel>(
              //               builder: (context, value, child) {
              //                 if (value.user == null ||
              //                     value.user?.loggedIn == false) {
              //                   return const ReferralInit();
              //                 }
              //                 return const ReferralHomeScreen();
              //               },
              //             ));
              //           },
              //           child: Image.asset(
              //             'assets/images/walletIcon.png',
              //           ),
              //         ),
              //         Consumer<ReferralProvider>(
              //             builder: (context, value, child) {
              //           return Padding(
              //             padding: const EdgeInsets.only(left: 4.0),
              //             child: Text(
              //               value.referralBalModel?.body?.balance.toString() ??
              //                   '',
              //               style: const TextStyle(
              //                   color: Colors.white,
              //                   fontWeight: FontWeight.w400,
              //                   fontSize: 14),
              //             ),
              //           );
              //         })
              //       ],
              //     ),
              //   ),
              if (widget.config.showCart)
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      LogoIcon(
                        menuIcon:
                            widget.config.cartIcon ?? MenuIcon(name: 'bag'),
                        onTap: widget.onCheckout,
                        config: widget.config,
                      ),
                      if (widget.totalCart > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              widget.totalCart.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              if (widget.config.showNotification)
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      LogoIcon(
                        menuIcon: widget.config.notificationIcon ??
                            MenuIcon(name: 'bell'),
                        onTap: widget.onTapNotifications,
                        config: widget.config,
                      ),
                      if (widget.notificationCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              widget.notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              if (!widget.config.showSearch &&
                  !widget.config.showCart &&
                  !widget.config.showNotification)
                const Spacer(),
            ],
          ),
        );
      },
    );
  }
}
