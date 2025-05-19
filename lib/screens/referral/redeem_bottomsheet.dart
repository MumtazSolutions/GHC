import 'package:flutter/material.dart';
import 'package:fstore/screens/referral/referral_provider.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../common/common_widgets.dart';
import '../../models/user_model.dart';
import 'history_screen.dart';

class RedeemBottomSheet extends StatefulWidget {
  const RedeemBottomSheet({Key? key}) : super(key: key);

  @override
  State<RedeemBottomSheet> createState() => _RedeemBottomSheetState();
}

class _RedeemBottomSheetState extends State<RedeemBottomSheet> {
  int counter = 500;
  double progressPercentage = 0.0;
  bool minimumCounter = false;
  bool maximumCounter = false;
  List<String> coins = ['500', '1000', '1500'];
  LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFFFB8746), Color(0xFFFFC63F)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralProvider>(builder: (context, referralVm, child) {
      return Container(
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 3,
                width: 59,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0xffC4C4C4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                'Redeem Moons',
                style: TextStyle(
                  color: Color(0xff333333),
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              RichText(
                  text: TextSpan(
                      text: 'Wallet: ',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          color: Color(0xffA6A6A6),
                          fontSize: 14),
                      children: [
                    TextSpan(
                      text: referralVm.referralBalModel?.body?.balance
                              .toString() ??
                          '',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff5F9E71)),
                    )
                  ]))
            ]),
            const SizedBox(height: 20),
            //Make a container with plus and minus button in center there will be coins which will be added or subtracted
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 55,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(width: 1, color: const Color(0xffCFCFCF)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (counter > 500) {
                          counter = counter - 500;
                          maximumCounter = false;
                        } else {
                          maximumCounter = false;
                          minimumCounter = true;
                        }
                      });
                      print(
                          'this is my miminum counter amnd maximum counter $minimumCounter and $maximumCounter');
                    },
                    icon: const Icon(
                      Icons.remove,
                      size: 30,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 20, // Set the desired width
                        height: 20, // Set the desired height
                        child: Image.asset(
                          'assets/images/moonIcon.png',
                        ),
                      ),
                      sBox(w: 1),
                      Text(
                        '$counter',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: Color(0xff333333),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      print('this is vaue in counter $counter');

                      var balance = int.tryParse(referralVm
                                  .referralBalModel?.body?.balance
                                  ?.toString() ??
                              '') ??
                          0;
                      setState(() {
                        if (balance > counter) {
                          if (balance - counter >= 500) {
                            minimumCounter = false;
                            counter += 500;
                          } else {
                            minimumCounter = false;
                            maximumCounter = true;
                          }
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            minimumCounter || maximumCounter
                ? Align(
                    alignment: Alignment.center,
                    child: Text(
                      maximumCounter == false
                          ? 'Enter minimum value of 500'
                          : 'Enter a value less than the current balance',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.red),
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
            const Text(
              'You can only redeem in multiples of 500',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffA6A6A6)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(coins.length, (index) {
                return GestureDetector(
                  onTap: () {
                    var balance = int.tryParse(referralVm
                                .referralBalModel?.body?.balance
                                ?.toString() ??
                            '') ??
                        0;
                    var selectedCoin = int.tryParse(coins[index]) ?? 0;

                    if (balance >= selectedCoin) {
                      maximumCounter = false;
                      counter = selectedCoin;
                    } else {
                      maximumCounter = true;
                    }
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    height: 26,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xffEBEFF0),
                    ),
                    child: Center(
                        child: Text(
                      coins[index],
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xff333333)),
                    )),
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 40,
            ),
            RichText(
                text: TextSpan(
                    text:
                        'Refer ${((getNextNearest500(int.parse(referralVm.referralBalModel?.body?.balance.toString() ?? '')) - (getLowerNearest100(int.parse(referralVm.referralBalModel?.body?.balance.toString() ?? '')))) / 100).toInt()} more friends to reach ',
                    style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        color: Color(0xff333333),
                        fontSize: 12),
                    children: [
                  TextSpan(
                    text:
                        '${(getNextNearest500(int.parse(referralVm.referralBalModel?.body?.balance.toString() ?? '')))} Moons',
                    style: const TextStyle(color: Color(0xff108F57)),
                  )
                ])),

            const SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        LinearPercentIndicator(
                          barRadius: const Radius.circular(8),
                          linearGradient: gradient,
                          width: Get.width * 0.88,
                          lineHeight: 14.0,
                          percent: progressBar(((getNextNearest500(int.parse(
                                      referralVm.referralBalModel?.body?.balance
                                              .toString() ??
                                          '0')) -
                                  (getLowerNearest100(int.parse(referralVm
                                          .referralBalModel?.body?.balance
                                          .toString() ??
                                      '0')))) /
                              100)),
                          backgroundColor: const Color(0xffD1D1D1),
                        ),
                        Image.asset(
                          'assets/images/moonIcon.png',
                          scale: 14,
                        )
                      ],
                    ),
                  ],
                ),
                Transform(
                    transform: Matrix4.translationValues(
                        progressBar(((getNextNearest500(int.parse(referralVm
                                            .referralBalModel?.body?.balance
                                            .toString() ??
                                        '')) -
                                    (getLowerNearest100(int.parse(referralVm
                                            .referralBalModel?.body?.balance
                                            .toString() ??
                                        '')))) /
                                100)) *
                            300,
                        -3,
                        0),
                    child: Image.asset(
                      'assets/images/rocket.png',
                      scale: 2,
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50), // Background color
              ),
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // Prevent users from dismissing the dialog
                  builder: (BuildContext context) {
                    return Center(
                      child:
                          CircularProgressIndicator(), // Display a loading indicator
                    );
                  },
                );

                var intUserPhone;
                var referralVm =
                    Provider.of<ReferralProvider>(context, listen: false);
                var user = Provider.of<UserModel>(context, listen: false).user;
                referralVm.userPhone == ''
                    ? intUserPhone = 0
                    : intUserPhone = int.parse(referralVm.userPhone);

                await referralVm
                    .redeemMoons(
                  customerId: referralVm.shopifyUserId,
                  moons: counter,
                  brand: 'mars',
                  PhoneNumber: intUserPhone,
                  email: user?.email ?? '',
                  name: user?.firstName ?? '',
                )
                    .then((value) async {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the loading indicator dialog
                  showDialog(
                    context: context,
                    builder: _buildPopupDialog,
                  );
                });
              },
              child: const Text(
                'Redeem Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(0xffFFFFFF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  int getNextNearest500(int number) {
    int remainder = number % 500;
    int nextNearest500 = number + (500 - remainder);
    return nextNearest500;
  }

  int getLowerNearest100(int number) {
    int remainder = number % 100;
    int lowerNearest100 = number - remainder;
    return lowerNearest100;
  }

  progressBar(double progressPercentage) {
    if (progressPercentage == 0.0 || progressPercentage == 5.0) {
      return 0.0;
    } else if (progressPercentage == 1.0) {
      return 0.2;
    } else if (progressPercentage == 2.0) {
      return 0.4;
    } else if (progressPercentage == 3.0) {
      return 0.6;
    } else if (progressPercentage == 4.0) {
      return 0.8;
    }
  }
}

Widget _buildPopupDialog(BuildContext context) {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: contentBox(context),
  );
}

Widget contentBox(context) {
  return Stack(
    children: <Widget>[
      Container(
        padding:
            const EdgeInsets.only(left: 20, top: 55, right: 20, bottom: 20),
        margin: const EdgeInsets.only(top: 45),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Congratulations!',
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xff333333)),
            ),
            sBox(h: 1.5),
            const Text(
              'Your redemption request for 500 moons has been successfully submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xff333333)),
            ),
            sBox(h: 2.5),
            const Text(
              'Your Amazon voucher code will be generated and sent to your registered phone number/email.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Color(0xff777777)),
            ),
            sBox(h: 3),
            Center(
              child: SizedBox(
                height: 34,
                width: 147,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff333333)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(HistoryScreen(index: 1));
                  },
                  child: const Text('My Vouchers'),
                ),
              ),
            ),
            sBox(h: 1.5),
          ],
        ),
      ),
      Positioned(
        left: 20,
        right: 20,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 45,
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(45)),
              child: Image.asset('assets/images/gift.png')),
        ),
      ),
    ],
  );
}
