import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/pages/language/languages.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/upload_docs.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  String dot = '.';
 

  var demopage = TextEditingController();

  @override
  void initState() {
    getLanguageDone();

    super.initState();
  }

//get language json and data saved in local (bearer token , choosen language) and find users current status
  getLanguageDone() async {
      await getDetailsOfDevice();
      if(internet == true){
      var val = await getLocalData();
      
      //if user is login and check waiting for approval status and send accordingly
      if (val == '3') {
        if (userDetails['uploaded_document'] == false) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Docs()));
        } else if (userDetails['uploaded_document'] == true &&
            userDetails['approve'] == false) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DocsProcess(),
              ));
          mqttForDocuments();
        } else if (userDetails['uploaded_document'] == true &&
            userDetails['approve'] == true) {
          
          
            //status approved
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Maps()),
                (route) => false);
          mqttForDocuments();
        }
      }
      //if user is not login in this device
      else if (val == '2') {
        Future.delayed(const Duration(seconds: 2), (){
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Login()));
        });
        
      }
      
       else {
        //user installing first time and didnt yet choosen language
       
          Future.delayed(const Duration(seconds: 2), (){
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Languages()));
              });
        
      }}else{
        setState(() {
          
        });
      }
    
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: media.height * 1,
              width: media.width * 1,
              decoration: BoxDecoration(
                color: page,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(media.width * 0.01),
                    width: media.width * 0.429,
                    height: media.width * 0.429,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain)),
                  ),
                ],
              ),
            ),
            
            //internet is not connected
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        //try again
                        setState(() {
                          internetTrue();
                          getLanguageDone();
                        });
                      },
                    ))
                : Container(),
           
          ],
        ),
      ),
    );
  }
}
