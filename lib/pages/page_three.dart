import 'package:flare_test/my_controller.dart';
import 'package:flare_test/tracking_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/services.dart';

class OnePunchInputPage extends StatefulWidget {
  @override
  _OnePunchInputPageState createState() => _OnePunchInputPageState();
}

class _OnePunchInputPageState extends State<OnePunchInputPage> {
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
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.0, 1.0],
            colors: [
              Color.fromRGBO(170, 207, 211, 1.0),
              Color.fromRGBO(93, 142, 155, 1.0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: 400,
                height: 400,
                child: FlareActor(
                  "assets/one_punch.flr",
                  controller: myController,
                  animation: null,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 50, right: 50),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                child: Form(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TrackingTextInput(
                          label: "账号",
                          hint: "你的账号是什么?",
                          onCaretMoved: (Offset caret) {
                            myController.lookAt(caret);
                          },
                          onEditingComplete: () {
                            myController.hasFocus = false;
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          },
                        ),
                        TrackingTextInput(
                          label: "密码",
                          hint: "试一试 onepunch",
                          isObscured: true,
                          onCaretMoved: (Offset caret) {
//                          myController.coverEyes(caret != null);
                            myController.lookAt(caret);
                          },
                          onTextChanged: (String value) {
                            myController.setPassword(value);
                          },
                          onEditingComplete: () {
                            myController.hasFocus = false;
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          },
                        ),
                        Container(
                          width: 300,
                          height: 50.0,
                          margin: EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color.fromRGBO(170, 207, 211, 1.0),
                                  Color.fromRGBO(93, 142, 155, 1.0),
                                ],
                              )),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                                onTap: () {
                                  myController.submitPassword();
                                },
                                child: Center(
                                  child: Text("登 录",
                                      style: TextStyle(
                                          fontFamily: "RobotoMedium",
                                          fontSize: 16,
                                          color: Colors.white)),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
