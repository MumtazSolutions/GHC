import 'package:flutter/material.dart';
import './progress_step.dart';

class ProgressStepper extends StatelessWidget {
  final int? currentIndex;
  ProgressStepper({this.currentIndex});

  Widget _stepper () {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _steps(),
      ),
    );
  }

  List<Widget> _steps() {
    List<Widget>? _progressSteps = List<Widget>.generate(6, (index) {
      if (index == 5) {
        return ProgressStep(isCurrentStep: index + 1 == currentIndex, stepNumber: index, isActive: index< currentIndex!, currentStepNumber: currentIndex!);
      } else {
        return Expanded(
          child: ProgressStep(isCurrentStep: index + 1 == currentIndex, stepNumber: index, isActive: index< currentIndex!, currentStepNumber: currentIndex!)
        );
      }
    });
    return _progressSteps;
  }
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Container(
        height: 120,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Monthly Progress', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).accentColor,
                ), textAlign: TextAlign.start),
            const SizedBox(height:10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: _stepper(),
              )
            )
          ],
        ),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor,
            spreadRadius: 1.5),
        ],
        ),
      ));
  }
  
}