import 'package:flutter/material.dart';
import 'package:fstore/screens/referral/Model/referralBal_model.dart';
import 'package:fstore/screens/referral/referral_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({Key? key}) : super(key: key);

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  List<Ledger?> earningList = [];

  @override
  void initState() {
    var referralVm = Provider.of<ReferralProvider>(context, listen: false);
    for (var i = 0;
        i <
            int.parse(
                referralVm.referralBalModel?.body?.ledger?.length.toString() ??
                    '0');
        i++) {
      if ((referralVm.referralBalModel?.body?.ledger?[i].status == 'rewarded' &&
              referralVm.referralBalModel?.body?.ledger?[i].type == 'credit') ||
          (referralVm.referralBalModel?.body?.ledger?[i].status == 'redeemed' &&
              referralVm.referralBalModel?.body?.ledger?[i].type == 'credit')) {
        earningList.add(referralVm.referralBalModel?.body?.ledger?[i]);
        print(
            'this is my earning list ${referralVm.referralBalModel?.body?.ledger?[i].status}');
      }
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('this is my List ${earningList.length}}');
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        child:
            Consumer<ReferralProvider>(builder: (context, referralVm, child) {
          if (referralVm.referralBalModel?.body?.ledger
                      ?.any((element) => element.status == 'rewarded') ==
                  false &&
              referralVm.referralBalModel?.body?.ledger
                      ?.any((element) => element.status == 'redeemed') ==
                  false) {
            return Center(
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
                    'You have no Earnings yet.',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff777777)),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
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
                              width: 20, // Set the desired width
                              height: 20, // Set the desired height
                              child: Image.asset(
                                'assets/images/moonIcon.png',
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  int.parse(earningList[index]
                                                  ?.ledgerCategory
                                                  .toString() ??
                                              '0') ==
                                          1
                                      ? 'Earned ${earningList[index]?.value.toString() ?? ''} Moons on referral order'
                                      : 'Earned ${earningList[index]?.value.toString() ?? ''} Moons on your order #${earningList[index]?.order.toString()}',
                                  style: const TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff333333)),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Color(0xff726868),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    children: [
                                      const WidgetSpan(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: 10.0, bottom: 2.0),
                                          child: Icon(
                                            Icons.calendar_today_outlined,
                                            size: 10,
                                            color: Color(0xff726868),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                          text:
                                              DateFormat('dd MMM yyyy').format(DateTime.parse(earningList[index]?.createdAt.toString() ?? ''))),
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
                });
          }
        }),
      ),
    );
  }
}
