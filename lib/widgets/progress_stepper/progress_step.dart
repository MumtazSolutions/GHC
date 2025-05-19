

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressStep extends StatelessWidget {

  final int? stepNumber;
  final bool? isCurrentStep;
  final int? currentStepNumber;
  final bool? isActive;

  ProgressStep({this.stepNumber, this.isCurrentStep, this.currentStepNumber, this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Container(
            height: isCurrentStep!? 32: 22,
            width: isCurrentStep!? 32: 22,
            child: Center( 
              child: Text('${stepNumber! + 1}', 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isCurrentStep!? 14: 10
                )
              ) 
            ),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isActive! ? Theme.of(context).primaryColor: Colors.grey,
                  offset: const Offset(
                    0.0,
                    0.0,
                  ),
                  blurRadius: isCurrentStep!? 10.0 : 1.0,
                  spreadRadius: isCurrentStep!? 5.0 :  1.0,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ),
              ],
              color: isActive!? Theme.of(context).primaryColor: Colors.grey[400],
              shape: BoxShape.circle),
          ),
          if (stepNumber != 5)
            Expanded(
              child: Container(
                height: 2,
                color: stepNumber! < currentStepNumber! -1? Theme.of(context).primaryColor: Colors.grey[400]
              )
            )
          
        ],
      ),
    );
  }
  
}