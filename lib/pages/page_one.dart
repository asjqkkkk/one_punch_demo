import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_test/my_controller.dart';
import 'package:flare_test/pages/page_three.dart';
import 'package:flare_test/pages/page_two.dart';
import 'package:flutter/material.dart';

class OnePunchPage extends StatefulWidget {
  @override
  _OnePunchPageState createState() => _OnePunchPageState();
}

class _OnePunchPageState extends State<OnePunchPage> {

  MyController myController;

  @override
  void initState() {
    super.initState();
    myController = MyController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (update){
        debugPrint("global:${update.globalPosition}");
        myController.lookAt(update.globalPosition);
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctx){
            return PageTwo();
          }));
        },child: Icon(Icons.keyboard_arrow_right),),
        body: Container(
          alignment: Alignment.center,
          child: Container(
            width: 400,
            height: 400,
            child: FlareActor(
              "assets/one_punch.flr",
              controller: myController,
            ),
          ),
        ),
      ),
    );
  }
}
