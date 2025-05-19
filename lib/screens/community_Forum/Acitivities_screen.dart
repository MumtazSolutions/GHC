import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(

      height: Get.height * 0.4,
      margin: const EdgeInsets.only( left: 12, right: 12, bottom: 12),
      padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
       borderRadius: BorderRadius.circular(20)
        ),
      child : ListView.builder(
          itemCount: 1,
          itemBuilder: (context , index){
        return Row(
          children: [
          Container(
          height: 40,
          width: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle  ,
                color: Colors.pink.withOpacity(0.3)
            ),
            child: Center(child: Text('S', style: TextStyle(
                color: Colors.pink.withOpacity(0.6),
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),)),
          ),
        ),
          ]
        );
      }),

    );
  }
}
