import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../routes/flux_navigate.dart';

class ReferralTnC extends StatelessWidget {
  const ReferralTnC({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset(
          'assets/images/ReferralTnC.png',
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.grey,
            ),
          ),
        ),
        Positioned(
          bottom: 6,
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 125, 93),
                foregroundColor: Colors.white,
                fixedSize: const Size.fromWidth(140)),
            onPressed: () async {
              await FluxNavigate.pushNamed(RouteList.login);
            },
            child: const Text('Log In'),
          ),
        ),
      ],
    );
  }
}
