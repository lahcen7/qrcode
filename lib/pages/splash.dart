import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import './scan.dart';

class splashScreen extends StatefulWidget {
  final int secends;
  // final dynamic afterPage;
  splashScreen(this.secends);
  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  var show = false;

  @override
  void initState() {
  
    // TODO: implement initState
    super.initState();
    setTimer();
    show = true;
  }
  setTimer() async{
    var sec = Duration(seconds: widget.secends);
    
    return Timer(sec, ()=>{
      Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => ScanPage())
      )
    }
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Container(
      child: Center(
    
        child:FlareActor('assets/qr_code.flr',
              animation: show ? "show":"loading",) 
              ),
        decoration:  new BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255,33, 147, 176),
                    Color.fromARGB(255,109, 213, 237)
                  ],
                )),
    ),
    );
  }
}