import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/config.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Support'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
              fontFamily: 'Futura Bk',
              fontSize: 20,
              color: Color.fromRGBO(15, 19, 22, 0.79)),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'We\'re  happy to help you! You can reach out to us by:',
                style: TextStyle(
                  color: Color(0XFF5B5757),
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0XFFE8FAF4),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: double.infinity,
                padding: const EdgeInsets.only(right: 8, left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          height: 25,
                          width: 25,
                          'assets/icons/brands/Gmail.svg',
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0XFF177D5D),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        var uri = Uri.parse(
                            'mailto:support@ghc.health?subject=&body=');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Could not launch $uri';
                        }
                      },
                      child: const Text(
                        'support@ghc.health',
                        style: TextStyle(
                          color: Color(0XFF8A9196),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0XFFE8FAF4),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.only(right: 8, left: 14),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          height: 25,
                          width: 25,
                          'assets/icons/brands/Phone.svg',
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0XFF177D5D),
                          ),
                        )
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        var uri = Uri.parse('tel:+9140-48211222');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          throw 'Could not launch $uri';
                        }
                      },
                      child: const Text(
                        '040-48211222',
                        style: TextStyle(
                          color: Color(0XFF8A9196),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0XFFE8FAF4),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: double.infinity,
                padding: const EdgeInsets.only(right: 8, left: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          height: 25,
                          width: 25,
                          'assets/icons/brands/Whatsapp.svg',
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Whatsapp',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0XFF177D5D),
                          ),
                        )
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        var url = Configurations.customerSupportUrl;
                        launchUrl(Uri.parse(url));
                      },
                      child: const Text(
                        'Chat with us',
                        style: TextStyle(
                          color: Color(0XFF8A9196),
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
