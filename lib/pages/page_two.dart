import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_test/pages/page_three.dart';
import 'package:flutter/material.dart';
import 'package:circle_list/circle_list.dart';

import '../my_controller.dart';

class PageTwo extends StatefulWidget {
  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
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
    return Scaffold(
      appBar: AppBar(title: Text("一超多强"),),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
            return OnePunchInputPage();
          }));
        },
        child: Icon(Icons.keyboard_arrow_right),
      ),
      body: Center(
        child: CircleList(
          origin: Offset(0, 0),
          centerWidget: FlareActor(
            "assets/one_punch.flr",
            controller: myController,
          ),
          children: List.generate(10, (index) {
            return ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                child: Container(
                  color: Colors.blue,
                    width: 50,
                    height: 50,
                    child: Image.asset("assets/${index + 1}.png")));
          }),
          onDragUpdate: (update) {
            Offset point = Offset(update.point.dx * 2, update.point.dy * 2);
            myController.lookAt(point);
          },
        ),
      ),
    );
  }
}
