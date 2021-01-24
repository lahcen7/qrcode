import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';



class ScanPage extends StatefulWidget {
  @override
  ScanPageState createState() {
    return new ScanPageState();
  }
}

class ScanPageState extends State<ScanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String result = "a";
  bool resultScanned = false;
  TapGestureRecognizer _flutterTapRecognizer;



  // DRAWER CODE
    Offset _offset = Offset(0,0);
  GlobalKey globalKey = GlobalKey();
  List<double> limits = [];

  bool isMenuOpen = false;

  getPosition(duration){
    RenderBox renderBox = globalKey.currentContext.findRenderObject();
    final position = renderBox.localToGlobal(Offset.zero);
    double start = position.dy - 20;
    double contLimit = position.dy + renderBox.size.height - 20;
    double step = (contLimit-start)/5;
    limits = [];
    for (double x = start; x <= contLimit; x = x + step) {
      limits.add(x);
    }
    setState(() {
      limits = limits;
    });

  }

  double getSize(int x){
    double size  = (_offset.dy > limits[x] && _offset.dy < limits[x + 1]) ? 25 : 20;
    return size;
  }
  // DRAWER CODE END 
  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "CAMERA permission denied!";
        });
      } else {
        setState(() {
          result = "$ex Error occurred.";
        });
      }
    } on FormatException {
      setState(() {
        result = "Nothing scanned!";
      });
    } catch (ex) {
      setState(() {
        result = "$ex Error occured.";
      });
    }
  }

  @override
  void initState() {
     limits= [0, 0, 0, 0, 0, 0];
    WidgetsBinding.instance.addPostFrameCallback(getPosition);

    super.initState();
    _flutterTapRecognizer = new TapGestureRecognizer()
      ..onTap = () => _openUrl(result);
  }

  @override
  void dispose() {
    _flutterTapRecognizer.dispose();
    super.dispose();
  }

  void _openUrl(String url) async {
    // Close the about dialog.
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => ScanPage(),
        ),
        (Route route) => route == null);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Problem launching $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DynamicTheme>(context);
    Size mediaQuery = MediaQuery.of(context).size;
    double sidebarSize = mediaQuery.width * 0.65;
    double menuContainerHeight = mediaQuery.height/2;

    if (result != "a") {
      Clipboard.setData(
        ClipboardData(text: result),
      );
      setState(() {
        resultScanned = true;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Result copied to clipboard.'),
        ),
      );
    } else {
      // setState(() {
      //   resultScanned = false;
      // });
    }
    return SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(255, 65, 108, 1.0),
                    Color.fromRGBO(255, 75, 73, 1.0)
                  ])
              ),
              width: mediaQuery.width,
              child: Stack(
                children: <Widget>[
                  Center(
            child: Text(
              "Press scan to scan barcodes or QR codes.",
              style: new TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                fontFamily: "IBM Plex Sans",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          resultScanned
              ? AlertDialog(
                  title: const Text('Result'),
                  content: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: result,
                          recognizer: _flutterTapRecognizer,
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ScanPage(),
                            ),
                            (Route route) => route == null);
                      },
                      textColor: Theme.of(context).primaryColor,
                      child: const Text('Okay, got it!'),
                    ),
                  ],
                )
              : Container(),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 1500),
                    left: isMenuOpen?0: -sidebarSize+20,
                    top: 0,
                    curve: Curves.elasticOut,
                    child: SizedBox(
                      width: sidebarSize,
                      child: GestureDetector(
                        onPanUpdate: (details){
                          if(details.localPosition.dx <=sidebarSize){
                            setState(() {
                              _offset = details.localPosition;
                            });
                          }

                          if(details.localPosition.dx>sidebarSize-20 && details.delta.distanceSquared>2){
                            setState(() {
                              isMenuOpen = true;
                            });
                          }

                        },
                        onPanEnd: (details){
                           setState(() {
                             _offset = Offset(0,0);
                           });
                        },
                        child: Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size(sidebarSize, mediaQuery.height),
                              painter: DrawerPainter(offset: _offset),
                            ),
                            Container(
                              height: mediaQuery.height,
                              width: sidebarSize,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Container(
                                    height: mediaQuery.height*0.25,
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          Image.asset("assets/dp_default.png",width: sidebarSize/2,),
                                          Text("LACHGAR LAHCEN",style: TextStyle(color: Colors.black45),),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(thickness: 1,),
                                  Container(
                                    key: globalKey,
                                    width: double.infinity,
                                    height: menuContainerHeight,
                                    child: Column(
                                      children: <Widget>[
                                        MyButton(
                                          text: "Profile",
                                          iconData: Icons.person,
                                          textSize: getSize(0),
                                          height: (menuContainerHeight)/5,
                                        ),
                                        MyButton(
                                          text: "Payments",
                                          iconData: Icons.payment,
                                          textSize: getSize(1),
                                          height: (menuContainerHeight)/5,),
                                        MyButton(
                                          text: "Notifications",
                                          iconData: Icons.notifications,
                                          textSize: getSize(2),
                                          height: (mediaQuery.height/2)/5,),
                                        MyButton(
                                          text: "Settings",
                                          iconData: Icons.settings,
                                          textSize: getSize(3),
                                          height: (menuContainerHeight)/5,),
                                        MyButton(
                                          text: "My Files",
                                          iconData: Icons.attach_file,
                                          textSize: getSize(4),
                                          height: (menuContainerHeight)/5,),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 400),
                              right: (isMenuOpen)?10:sidebarSize,
                              bottom: 30,
                              child: IconButton(
                                enableFeedback: true,
                                icon: Icon(Icons.keyboard_backspace,color: Colors.black45,size: 30,),
                                onPressed: (){
                                  this.setState(() {
                                    isMenuOpen = false;
                                  });
                                },),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
        )); 
  }
}

// REFACTORED
class MyButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final double textSize;
  final double height;

  MyButton({this.text, this.iconData, this.textSize,this.height});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialButton(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(
            iconData,
            color: Colors.black45,
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: TextStyle(color: Colors.black45, fontSize: textSize),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}

// REFACTRORED
class DrawerPainter extends CustomPainter{

  final Offset offset;

  DrawerPainter({this.offset});

  double getControlPointX(double width){
    if(offset.dx == 0){
      return width;
    } else {
      return offset.dx>width?offset.dx:width+75;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    Path path = Path();
    path.moveTo(-size.width, 0);
    path.lineTo(size.width, 0);
    path.quadraticBezierTo(getControlPointX(size.width), offset.dy, size.width, size.height);
    path.lineTo(-size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
