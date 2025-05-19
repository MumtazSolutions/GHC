import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../common/sizeConfig.dart';
import 'earning_screen.dart';
import 'referral_provider.dart';
import 'voucher_screen.dart';

class HistoryScreen extends StatefulWidget {
  int index;
  HistoryScreen({Key? key, required this.index}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  double pendingMoons = 0.0;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    controller?.index = widget.index;
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    for (var i = 0;
        i <
            int.parse(
                referralVm.referralBalModel?.body?.ledger?.length.toString() ??
                    '0');
        i++) {
      if (referralVm.referralBalModel?.body?.ledger?[i].status == 'pending' &&
          referralVm.referralBalModel?.body?.ledger?[i].type == 'credit') {
        pendingMoons = pendingMoons +
            double.parse(referralVm.referralBalModel?.body?.ledger?[i].value
                    .toString() ??
                '');
        print(
            'this is my earning list ${referralVm.referralBalModel?.body?.ledger?[i]}');
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    return SafeArea(
      child: Scaffold(
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
              onPressed: Get.back,
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
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
                      // Image.asset(
                      //   'assets/images/walletIcon.png',
                      // ),
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
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              height: 20,
            ),

            referralVm.referralBalModel?.body?.ledger
                            ?.any((element) => element.status == 'pending') ==
                        true &&
                    pendingMoons > 0.0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    margin:
                        const EdgeInsets.only(left: 1, right: 1, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      //only give boxshadow to the all edges
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset:
                              const Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/greenCircles.png',
                              scale: 3,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: '$pendingMoons moons',
                                    style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Color(0xff108F57),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: const [
                                  TextSpan(
                                    text: ' are on your way!',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Color(0xff333333),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ])),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 35.0),
                          child: Text(
                            '${pendingMoons.toString()} Moons will be credited once your \norder/referee’s order gets delivered.',
                            style: const TextStyle(
                              height: 1.2,
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Color(0xff726868),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),

            const Text(
              'History',
              style: TextStyle(
                color: Color(0xff333333),
                fontFamily: 'Roboto',
                fontSize: 30,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //make a tab bar of 2 tabs where i can swtich between 2
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffEBEBEB),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller?.animateTo(0);
                      setState(() {});
                    },
                    child: Container(
                      width: Get.width * 0.44,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: controller?.index == 0
                            ? Colors.black
                            : Colors.transparent,
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Earning',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: controller?.index == 0
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller?.animateTo(1);
                      setState(() {});
                    },
                    child: Container(
                      width: Get.width * 0.44,
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: controller?.index == 1
                              ? Colors.black
                              : Colors.transparent),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'My Vouchers',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: controller?.index == 1
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
                child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    children: const [
                  Tab(
                    child: EarningScreen(),
                  ),
                  Tab(
                    child: VoucherScreen(),
                  ),
                ]))
          ]),
        ),
      ),
    );
  }
}
