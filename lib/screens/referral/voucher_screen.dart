import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fstore/screens/referral/Model/referralBal_model.dart';
import 'package:fstore/screens/referral/referral_provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({Key? key}) : super(key: key);

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  List<Ledger?> earningList = [];
  var voucherAmount;
  @override
  void initState() {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);

    for (var i = 0;
        i <
            int.parse(
                referralVm.referralBalModel?.body?.ledger?.length.toString() ??
                    '0');
        i++) {
      if ((referralVm.referralBalModel?.body?.ledger?[i].status == 'redeemed' &&
              referralVm.referralBalModel?.body?.ledger?[i].type == 'debit') ||
          (referralVm.referralBalModel?.body?.ledger?[i].status == 'pending' &&
              referralVm.referralBalModel?.body?.ledger?[i].type == 'debit')) {
        earningList.add(referralVm.referralBalModel?.body?.ledger?[i]);

        print(
            'this is my earning list ${referralVm.referralBalModel?.body?.ledger?[i]}');
      }
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child: referralVm.referralBalModel?.body?.ledger
                        ?.any((element) => element.status == 'rewarded') ==
                    false &&
                referralVm.referralBalModel?.body?.ledger
                        ?.any((element) => element.status == 'redeemed') ==
                    false
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/noReferralEarning.png',
                      scale: 3,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      'You have no Vouchers yet.',
                      style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff777777)),
                    ),
                  ],
                ),
              )
            : earningList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/noReferralEarning.png',
                          scale: 3,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        const Text(
                          'You have no Vouchers yet.',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff777777)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: earningList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30, // Set the desired width
                                  height: 30, // Set the desired height
                                  child: Image.asset(
                                    'assets/images/amazon.png',
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    earningList[index]?.status == 'pending'
                                        ? const Text('Amazon voucher coming your way')
                                        : SizedBox(
                                            width: Get.width * 0.65,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                DottedBorder(
                                                  borderType: BorderType.RRect,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                                  color:
                                                      const Color(0xffC4C4C4),
                                                  dashPattern: const [4, 4],
                                                  radius:
                                                      const Radius.circular(3),
                                                  child: Text(
                                                    earningList[index]?.voucherCode.toString() ?? '',
                                                    style: const TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 12),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(
                                                        ClipboardData(
                                                            text: earningList[
                                                                        index]
                                                                    ?.voucherCode
                                                                    .toString() ??
                                                                ''));
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Copied to Clipboard')));
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Row(
                                                      children: const [
                                                        Icon(
                                                          Icons.copy,
                                                          color: Colors.white,
                                                          size: 10,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          'Copy code',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xffFFFFFF),
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    earningList[index]?.status == 'pending'
                                        ? const Text(
                                            'Voucher code will be sent to your registered \naccount within 24 hrs',
                                            style: TextStyle(
                                                fontFamily:
                                                    'HarmoniaSansW01-Regular',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Color(0xffEE9A24)),
                                          )
                                        : Text(
                                            'Amazon Voucher worth Rs${((double.parse(earningList[index]?.value.toString() ?? '')) * 0.4).toInt()}',
                                            style: const TextStyle(
                                                fontFamily:
                                                    'HarmoniaSansW01-Regular',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Color(0xffEE9A24)),
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          const WidgetSpan(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right: 10.0, bottom: 2.0),
                                              child: Icon(
                                                Icons.calendar_today_rounded,
                                                size: 10,
                                                color: Color(0xff726868),
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                              style: const TextStyle(
                                                color: Color(0xff726868),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              text:
                                                  'Redeemed ${earningList[index]?.value.toString() ?? ''} Moons on ${DateFormat("dd MMM yyyy").format(DateTime.parse(earningList[index]?.createdAt.toString() ?? ''))} '),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                          ],
                        ),
                      );
                    }),
      ),
    );
  }
}

// class MyClipper extends CustomClipper<Path> {
//   final double space;
//
//   MyClipper(this.space);
//
//   @override
//   Path getClip(Size size) {
//     final path = Path();
//     final halfHeight = size.height / 2;
//     final halfSpace = space / 2;
//     final curveHeight = size.height / 4;
//     path.lineTo(size.width - halfSpace, 0);
//     path.lineTo(size.width - halfSpace, halfHeight - curveHeight);
//     path.quadraticBezierTo(size.width, halfHeight, size.width - halfSpace, halfHeight + curveHeight);
//     path.lineTo(size.width - halfSpace, size.height);
//     path.lineTo(0, size.height);
//     path.lineTo(0, 0);
//     path.close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }

