import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InvalidProgressDateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          'Invalid Progress Date',
          style: TextStyle(
            color: Theme.of(context).accentColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Theme.of(context).accentColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Container(
          height: 400,
          child: Center(
            child: Column(
              children: [
                Icon(Icons.image_not_supported_outlined,
                    size: 120, color: Theme.of(context).primaryColor),
                SizedBox(height: 20),
                Text('This week\'s picture has already been taken.')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
