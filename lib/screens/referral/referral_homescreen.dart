import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/common_widgets.dart';
import '../../common/sizeConfig.dart';
import '../../common/tools/navigate_tools.dart';
import '../../models/user_model.dart';
import 'history_screen.dart';
import 'redeem_bottomsheet.dart';
import 'referral_provider.dart';

class ReferralHomeScreen extends StatefulWidget {
  const ReferralHomeScreen({Key? key}) : super(key: key);

  @override
  State<ReferralHomeScreen> createState() => _ReferralHomeScreenState();
}

class _ReferralHomeScreenState extends State<ReferralHomeScreen> {
  bool _showContent1 = false;
  bool _showContent2 = false;
  bool _showContent3 = false;
  bool isCopied = false;
  bool phoneLength = false;

  bool phoneEdit = false;
  TextEditingController phoneController = TextEditingController();

  double? referralValue = 0.0;
  int? voucherValue = 0;

  List accordianModel = [];
  @override
  void initState() {
    super.initState();
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    var user = Provider.of<UserModel>(context, listen: false);
    var shopifyId = utf8.decode(base64.decode((user.user?.id).toString()));
    var userIdUrl = shopifyId.toString().split('/');
    referralVm.shopifyUserId = userIdUrl[4].trim();
    Future.delayed(Duration.zero).then((value) async {
      await referralVm.getReferralBal(customerID: referralVm.shopifyUserId);
    });
    accordianModel = [
      {
        'title': 'What are Moons?',
        'content':
            'By logging in, you can earn Moons by placing orders or referring others to Mars. The Moons you accumulate can be redeemed for Amazon gift vouchers.',
        'isContentShow': _showContent1,
      },
      {
        'title': 'How do I earn Moons?',
        'content':
            "Enjoy 25% cashback as Moons in your wallet when you make a purchase above ₹100.\nNote: The cashback will be rounded to the closest 100. If the cashback is 240, for example, you will be credited with 200 moons. You will be credited 300 moons if the cashback is 260.\n\nRefer your friends with your referral code. When they use your code to place an order, you'll earn 100 Moons.\n\nMoons will be credited to your wallet after the order is delivered.",
        'isContentShow': _showContent2,
      },
      {
        'title': 'How do I Redeem Moons?',
        'content':
            'After logging in, you can see your Moons in the Wallet. Redeem them for Amazon gift vouchers once you have a minimum of 500 Moons.',
        'isContentShow': _showContent3,
      },
    ];
  }

  @override
  void didChangeDependencies() {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    Future.delayed(Duration.zero).then((value) async {
      await referralVm.getUserPhone(customerId: referralVm.shopifyUserId);
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    phoneController.text = referralVm.userPhone.toString();

    return SafeArea(
      child: FutureBuilder(
          future:
              referralVm.createReferral(customerId: referralVm.shopifyUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                referralVm.referralBalModel?.body?.ledger?.forEach((element) {
                  if (element.status == 'pending' && element.type == 'credit') {
                    referralValue = referralValue! + element.value!;
                    if (mounted) {
                      referralVm.notifyListeners();
                    }
                  }
                  if (element.statusId == 3 && element.type == 'debit') {
                    voucherValue =
                        voucherValue! + int.parse(element.voucherValue!);
                    if (mounted) {
                      referralVm.notifyListeners();
                    }
                  }
                });
              });
              return Consumer<ReferralProvider>(
                  builder: (context, referralVm, child) {
                return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(50.0),
                      child: AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.white,
                        title: const Text(
                          'Moons',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_sharp,
                              color: Colors.black,
                              size: SizeConfig.blockSizeVertical! * 2,
                            ),
                            onPressed: (() {
                              NavigateTools.navigateHome(context);
                            })),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 10.0, right: 20.0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.black),
                              height: 30,
                              width: 70,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/walletIcon.png',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      referralVm.referralBalModel?.body?.balance
                                              .toString() ??
                                          '0',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Referral Code',
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            //make a dotted container
                            DottedBorder(
                              borderType: BorderType.RRect,
                              color: const Color(0xffC4C4C4),
                              radius: const Radius.circular(6),
                              dashPattern: const [4, 4],
                              strokeWidth: 1,
                              child: Container(
                                height: 44,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      referralVm.referralCodeModel?.body
                                              .referralCode
                                              .toString() ??
                                          '',
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        color: Color(0xff5F9E71),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: referralVm.referralCodeModel
                                                    ?.body.referralCode
                                                    .toString() ??
                                                ''));

                                        isCopied = true;
                                        referralVm.notifyListeners();
                                      },
                                      child: isCopied
                                          ? Container(
                                              height: 35,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                color: const Color(0xff5F9E71),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: const Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Copied',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ))
                                          : Container(
                                              width: 100,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.copy,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'Copy Code',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Share.share(
                                    "Hey,buddy!\n Here is my Mars by ghc referral code - ${referralVm.referralCodeModel?.body.referralCode ?? ''}.\n You get 25% off and free delivery on your next order.\n Let's celebrate Good health and Wellness.\n https://www.ghc.health/discount/${referralVm.referralCodeModel?.body.referralCode ?? ''}");
                              },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xff333333)),
                                  color: const Color(0xff333333),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      size: 14,
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Refer a Friend',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 14,
                                        color: Color(0xffFFFFFF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 2,
                                  color: const Color(0xffD1D1D1),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  'Or',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Color(0xffD1D1D1),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 80,
                                  height: 2,
                                  color: const Color(0xffD1D1D1),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            GestureDetector(
                              onTap: () {
                                NavigateTools.navigateHome(context);
                              },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xff333333)),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.shopping_bag,
                                      color: Color(0xff333333),
                                      size: 14,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: Color(0xff333333),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            referralVm.userPhone.toString().isEmpty == true ||
                                    phoneEdit == true
                                ? phoneNumber()
                                : editPhoneNumber(referralVm: referralVm),
                            const SizedBox(
                              height: 20,
                            ),
                            referralVm.referralBalModel?.body?.ledger
                                            ?.isEmpty ==
                                        true ||
                                    referralVm.referralBalModel?.body?.ledger ==
                                        null
                                ? wallet(referralVm: referralVm)
                                : referralVm.referralBalModel?.body?.balance ==
                                        0
                                    ? walletEdit(referralVm: referralVm)
                                    : walletRedeem(referralVm: referralVm),
                            const SizedBox(
                              height: 10,
                            ),
                            Image.asset(
                              'assets/images/moonsLoginUser.png',
                              width: double.infinity,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 18.0, left: 18.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'FAQ\'s',
                                  style: TextStyle(
                                    color: Color(0xff333333),
                                    fontFamily: 'Roboto',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children:
                                  List.generate(accordianModel.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    accordianModel[index]['isContentShow'] =
                                        !accordianModel[index]['isContentShow'];
                                    referralVm.notifyListeners();
                                  },
                                  child: accordian(
                                      title: accordianModel[index]['title'],
                                      description: accordianModel[index]
                                          ['content'],
                                      showContent: accordianModel[index]
                                          ['isContentShow'],
                                      onTap: () {
                                        accordianModel[index]['isContentShow'] =
                                            !accordianModel[index]
                                                ['isContentShow'];
                                        referralVm.notifyListeners();
                                      }),
                                );
                              }),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ));
              });
            }
          }),
    );
  }

  Widget wallet({required ReferralProvider referralVm}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xffE6F6F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xff333333)),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(HistoryScreen(
                        index: 0,
                      ));
                    },
                    child: const Text(
                      'History',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xff333333)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14, // Set the desired width
                    height: 14, // Set the desired height
                    child: Image.asset(
                      'assets/images/moonIcon.png',
                    ),
                  ),
                  sBox(w: 2),
                  const Text(
                    '0',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                        color: Color(0xff333333)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Moons',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          color: Color(0xff333333)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          RichText(
            text: TextSpan(
              text: 'Lifetime Earnings: ',
              style: const TextStyle(
                color: Color(0xff777777),
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: <TextSpan>[
                TextSpan(
                  text:
                      referralVm.referralBalModel?.body?.lifetime.toString() ??
                          '',
                  style: const TextStyle(
                    color: Color(0xff333333),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget walletRedeem({required ReferralProvider referralVm}) {
    return Container(
      height: 320,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xffE6F6F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wallet',
                  style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xff333333)),
                ),
                Row(
                  children: [
                    const Icon(
                      color: Color(0xff333333),
                      Icons.history,
                      size: 14,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(HistoryScreen(
                          index: 0,
                        ));
                      },
                      child: const Text(
                        'History',
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xff333333)),
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14, // Set the desired width
                      height: 14, // Set the desired height
                      child: Image.asset(
                        'assets/images/moonIcon.png',
                      ),
                    ),
                    sBox(w: 2),
                    Text(
                      referralVm.referralBalModel?.body?.balance.toString() ??
                          '',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Color(0xff333333)),
                    ),
                    const SizedBox(width: 5),
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Moons',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Roboto',
                            color: Color(0xff333333)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Lifetime Earnings: ',
                    style: const TextStyle(
                      color: Color(0xff777777),
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            '${referralVm.referralBalModel?.body?.lifetime.toString() ?? ''}',
                        style: const TextStyle(
                          color: Color(0xff333333),
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '5 Moons = ₹2',
                  style: TextStyle(
                    color: Color(0xff333333),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: List.generate(26, (index) {
                return Container(
                  margin: const EdgeInsets.only(right: 5),
                  height: 1,
                  width: 7,
                  color: const Color(0xff777777),
                );
              }),
            ),
            const SizedBox(
              height: 20,
            ),
            referralValue?.toStringAsFixed(0) != '0'
                ? SizedBox(
                    width: Get.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          child: Image.asset(
                            'assets/images/moonIcon.png',
                          ),
                        ),
                        sBox(w: 2),
                        Container(
                          width: 44,
                          height: 20,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              referralValue?.toStringAsFixed(0) ?? '',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text(
                            'Moons are on your way',
                            style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff333333)),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            sBox(h: 2),
            voucherValue?.toStringAsFixed(0) != '0'
                ? SizedBox(
                    width: Get.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20, // Set the desired width
                          height: 20, // Set the desired height
                          child: Image.asset(
                            'assets/images/lifetimeVouchers.png',
                          ),
                        ),
                        sBox(w: 2),
                        const Padding(
                          padding: EdgeInsets.only(left: 1.0),
                          child: Text(
                            'Amazon Vouchers earned',
                            style: TextStyle(
                              color: Color(0xff333333),
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        sBox(w: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              '₹$voucherValue',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff1DBA78)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                if (int.parse(
                        referralVm.referralBalModel?.body?.balance.toString() ??
                            '') <
                    500) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return moonDialog(referralVm);
                      });
                } else {
                  Get.bottomSheet(const RedeemBottomSheet());
                }
              },
              child: Container(
                height: 45,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xff333333)),
                  color: const Color(0xff333333),
                ),
                child: const Center(
                  child: Text(
                    'Redeem Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'HarmoniaSansW01-Regular',
                      fontSize: 14,
                      color: Color(0xffFFFFFF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget walletEdit({required ReferralProvider referralVm}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xffE6F6F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xff333333)),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(HistoryScreen(index: 0));
                    },
                    child: const Text(
                      'History',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xff333333)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14, // Set the desired width
                    height: 14, // Set the desired height
                    child: Image.asset(
                      'assets/images/moonIcon.png',
                    ),
                  ),
                  sBox(w: 2),
                  Text(
                    referralVm.referralBalModel?.body?.balance.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                        color: Color(0xff333333)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Moons',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          color: Color(0xff333333)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Lifetime Earnings: ',
                  style: const TextStyle(
                    color: Color(0xff777777),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${referralVm.referralBalModel?.body?.lifetime.toString() ?? ''}',
                      style: const TextStyle(
                        color: Color(0xff333333),
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '5 Moons = ₹2',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: List.generate(22, (index) {
              return Container(
                margin: const EdgeInsets.only(right: 5),
                height: 1,
                width: 10,
                color: Colors.black,
              );
            }),
          ),
          const SizedBox(
            height: 20,
          ),
          referralValue?.toStringAsFixed(0) != '0'
              ? SizedBox(
                  width: Get.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20, // Set the desired width
                        height: 20, // Set the desired height
                        child: Image.asset(
                          'assets/images/moonIcon.png',
                        ),
                      ),
                      sBox(w: 2),
                      Container(
                        width: 44,
                        height: 20,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            referralValue?.toStringAsFixed(0) ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.amber),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(
                          'Moons are on your way',
                          style: TextStyle(
                            color: Color(0xff333333),
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
          sBox(h: 2),
          voucherValue?.toStringAsFixed(0) != '0'
              ? SizedBox(
                  width: Get.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20, // Set the desired width
                        height: 20, // Set the desired height
                        child: Image.asset(
                          'assets/images/lifetimeVouchers.png',
                        ),
                      ),
                      sBox(w: 2),
                      const Padding(
                        padding: EdgeInsets.only(left: 1.0),
                        child: Text(
                          'Amazon Vouchers earned',
                          style: TextStyle(
                            color: Color(0xff333333),
                            fontFamily: 'Roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      sBox(w: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            '₹$voucherValue',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1DBA78)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget moonDialog(ReferralProvider referralVm) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/moonsAlert.png',
              scale: 2.5,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "You don't have enough Moons",
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xff333333)),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'You need minimum of 500 Moons to\n redeem',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xff777777)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Share.share(
                    "Hey,buddy!\n Here is my Mars by ghc referral code - ${referralVm.referralCodeModel?.body.referralCode ?? ''}.\n You get 25% off and free delivery on your next order.\n Let's celebrate Good health and Wellness.\n https://www.ghc.health/discount/${referralVm.referralCodeModel?.body.referralCode ?? ''}");
                Get.back();
              },
              child: Container(
                height: 44,
                width: 204,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xff333333)),
                  color: const Color(0xff333333),
                ),
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Refer and Earn 100 Moons',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget phoneNumber() {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xffFFF3D9),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Stay informed about all the updates related to your Moons wallet on',
                      style: TextStyle(
                          height: 1.4,
                          letterSpacing: 0.25,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Color(0xff333333),
                          fontSize: 12)),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SizedBox(
                        width: 12, // Set the desired width
                        height: 12, // Set the desired height
                        child: Image.asset(
                          'assets/images/whatsapp.png',
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                      text: 'Whatsapp/SMS',
                      style: TextStyle(
                          height: 1.4,
                          letterSpacing: 0.25,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Color(0xff333333),
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            //make a textfield with submit button inside
            Container(
              height: 44,
              padding: const EdgeInsets.only(left: 10, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              child: Consumer<ReferralProvider>(
                  builder: (context, referralVm, child) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          if (value.length == 10) {
                            referralVm.phoneLength = true;
                            referralVm.notifyListeners();
                          } else {
                            referralVm.phoneLength = false;
                            referralVm.notifyListeners();
                          }
                        },
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your Phone number',
                          hintStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff777777),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (phoneController.text.length < 10) {
                        } else {
                          var user =
                              Provider.of<UserModel>(context, listen: false);
                          var shopifyId = utf8.decode(
                              base64.decode((user.user?.id).toString()));
                          var userIdUrl = shopifyId.toString().split('/');
                          var shopifyUserId = userIdUrl[4].trim();
                          referralVm
                              .updatePhoneNumber(
                                  customerId: shopifyUserId,
                                  phoneNumber: phoneController.text)
                              .then((value) {
                            referralVm
                                .getUserPhone(customerId: shopifyUserId)
                                .then((value) {
                              phoneEdit = false;
                              referralVm.notifyListeners();
                            });
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: referralVm.phoneLength == false
                              ? Colors.grey.withOpacity(0.2)
                              : const Color(0xFFFF8277),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: referralVm.phoneLength == false
                                ? const Color(0xff777777)
                                : const Color(0xffFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget editPhoneNumber({required ReferralProvider referralVm}) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xffFFF3D9),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Stay informed about all the updates related to your Moons wallet on',
                      style: TextStyle(
                          height: 1.4,
                          letterSpacing: 0.25,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Color(0xff333333),
                          fontSize: 12)),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: SizedBox(
                        width: 12, // Set the desired width
                        height: 12, // Set the desired height
                        child: Image.asset(
                          'assets/images/whatsapp.png',
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                      text: 'Whatsapp/SMS',
                      style: TextStyle(
                          height: 1.4,
                          letterSpacing: 0.25,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Color(0xff333333),
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            //make a textfield with submit button inside
            Row(
              children: [
                const Text(
                  'Phone Number :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Consumer<ReferralProvider>(
                    builder: (context, referralVm, child) {
                  return Text(' ${referralVm.userPhone}');
                }),
                const SizedBox(
                  width: 40,
                ),
                GestureDetector(
                  onTap: () {
                    phoneEdit = true;
                    phoneController.text = referralVm.userPhone.toString();
                    referralVm.notifyListeners();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff333333),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card accordian({
    required String title,
    required String description,
    required bool showContent,
    required Function onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xffF4F4F4),
      elevation: 0,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, right: 5, top: 0),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black, // Set the text color to black
              ),
            ),
            trailing: IconButton(
              color: const Color(0xff333333),
              icon: Icon(
                showContent
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              onPressed: () {
                onTap();
              },
            ),
          ),
          if (showContent)
            Container(
              padding: const EdgeInsets.only(left: 2, right: 15, bottom: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < description.split('\n\n').length; i++)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 15),
                            if (i != description.split('\n\n').length - 1)
                              const Text(
                                '\u2022 ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Set the text color to black
                                ),
                              ),
                            Expanded(
                              child: RichText(
                                text: _buildDescriptionTextSpan(
                                    description.split('\n\n')[i]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TextSpan _buildDescriptionTextSpan(String paragraph) {
    final List<TextSpan> textSpans = [];

    final List<String> lines = paragraph.split('\n');

    for (var line in lines) {
      if (line.startsWith('Note:')) {
        final List<String> words = line.split(' ');

        for (var word in words) {
          if (word == 'Note:') {
            textSpans.add(
              TextSpan(
                text: word + ' ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set the text color to black
                ),
              ),
            );
          } else {
            textSpans.add(
              TextSpan(
                text: word + ' ',
                style: const TextStyle(
                  color: Colors.black, // Set the text color to black
                ),
              ),
            );
          }
        }
      } else {
        textSpans.add(
          TextSpan(
            text: line + '\n',
            style: const TextStyle(
              color: Colors.black, // Set the text color to black
            ),
          ),
        );
      }
    }

    return TextSpan(children: textSpans);
  }
}
