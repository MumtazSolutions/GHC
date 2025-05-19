import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../models/progress/progress_tracking_model.dart';

class NoUserScreen extends StatefulWidget {
  const NoUserScreen({Key? key}) : super(key: key);

  @override
  State<NoUserScreen> createState() => _NoUserScreenState();
}

class _NoUserScreenState extends State<NoUserScreen> {
  @override
  Widget build(BuildContext context) {
    var headerText = 'Community';

    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title:
              Consumer<ProgressTrackingVM>(builder: (context, progress, child) {
            return Text(
              headerText,
              style: const TextStyle(
                color: Colors.black,
              ),
            );
          }),
          backgroundColor: Theme.of(context).backgroundColor,
        ),
        body: Center(
          child: SizedBox(
            height: 400,
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.not_interested_outlined,
                      size: 120, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 20),
                  const Text('Login to join our Mars Wellness Community!!'),
                  const SizedBox(height: 100),
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.of(
                        Get.context!,
                      ).pushNamed(RouteList.login);
                      return;
                    },
                    isExtended: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    icon: const Icon(Icons.account_box_rounded, size: 20),
                    label: const Text('Login'),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
