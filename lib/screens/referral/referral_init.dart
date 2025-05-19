import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/common_widgets.dart';
import '../../common/constants.dart';
import '../../common/sizeConfig.dart';
import '../../common/tools/navigate_tools.dart';
import '../../routes/flux_navigate.dart';
import 'referral_tnc.dart';

bool fromReferral = false;

class ReferralInit extends StatefulWidget {
  const ReferralInit({super.key});

  @override
  State<ReferralInit> createState() => _ReferralInitState();
}

class _ReferralInitState extends State<ReferralInit> {
  bool _showContent1 = false;
  bool _showContent2 = false;
  bool _showContent3 = false;
  List accordianModel = [];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
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
                }),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 18.0,
                          right: 18.0,
                          bottom: 10.0,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('assets/images/GiftWellness.jpg'),
                            Positioned(
                              top: 150,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  fixedSize: const Size.fromWidth(185),
                                ),
                                onPressed: () async {
                                  if (kDebugMode) {
                                    print('Refer a friend clicked');
                                  }
                                  fromReferral = true;
                                  await FluxNavigate.pushNamed(RouteList.login);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.share,
                                      size: 18,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Refer a friend',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 185,
                              right: 10,
                              child: TextButton(
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('Read T&C clicked');
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: const EdgeInsets.all(0),
                                          scrollable: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          content: const ReferralTnC(),
                                        );
                                      });
                                },
                                child: Row(
                                  children: const [
                                    Text(
                                      '*',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 2, 55, 39),
                                      ),
                                    ),
                                    Text(
                                      'Read T&C',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 2, 55, 39),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Text(
                        'Login to view your',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff333333),
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      sBox(h: 0.5),
                      const Text(
                        'Moons',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff21785D),
                          fontFamily: 'Roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      sBox(h: 0.6),
                      GestureDetector(
                        onTap: () async {
                          fromReferral = true;
                          await FluxNavigate.pushNamed(RouteList.login);
                        },
                        child: Image.asset(
                          'assets/images/moonsLogoutUser.png',
                          fit: BoxFit.cover,
                        ),
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
                        children: List.generate(accordianModel.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                accordianModel[index]['isContentShow'] =
                                    !accordianModel[index]['isContentShow'];
                              });
                            },
                            child: accordian(
                                title: accordianModel[index]['title'],
                                description: accordianModel[index]['content'],
                                showContent: accordianModel[index]
                                    ['isContentShow'],
                                onTap: () {
                                  setState(() {
                                    accordianModel[index]['isContentShow'] =
                                        !accordianModel[index]['isContentShow'];
                                  });
                                }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
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
                text: '$word ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Set the text color to black
                ),
              ),
            );
          } else {
            textSpans.add(
              TextSpan(
                text: '$word ',
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
            text: '$line\n',
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
