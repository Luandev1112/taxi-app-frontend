import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';
import './login.dart';
import '../vehicleInformations/service_area.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({Key? key}) : super(key: key);

  @override
  _GetStartedState createState() => _GetStartedState();
}

String name = ''; //name of user
String email = ''; // email of user

class _GetStartedState extends State<GetStarted> {
  bool _loading = false;
  var verifyEmailError = '';

  TextEditingController emailText =
      TextEditingController(); //email textediting controller
  TextEditingController nameText =
      TextEditingController(); //name textediting controller

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: media.width * 0.08,
                  right: media.width * 0.08,
                  top: media.width * 0.05 + MediaQuery.of(context).padding.top),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  Container(

                      // height: media.height * 0.12,
                      width: media.width * 1,
                      color: topBar,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back)),
                        ],
                      )),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: media.height * 0.04,
                      ),
                      SizedBox(
                        width: media.width * 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              languages[choosenLanguage]['text_get_started'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * twentyeight,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.height * 0.012,
                      ),
                      Text(
                        languages[choosenLanguage]['text_fill_form'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * sixteen,
                            color: textColor.withOpacity(0.3)),
                      ),
                      SizedBox(height: media.height * 0.04),

                      // name input field
                      InputField(
                        icon: Icons.person_outline_rounded,
                        text: languages[choosenLanguage]['text_name'],
                        onTap: (val) {
                          setState(() {
                            name = nameText.text;
                          });
                        },
                        textController: nameText,
                      ),
                      SizedBox(
                        height: media.height * 0.012,
                      ),
                      // email input field
                      InputField(
                        icon: Icons.email_outlined,
                        text: languages[choosenLanguage]['text_email'],
                        onTap: (val) {
                          setState(() {
                            email = emailText.text;
                          });
                        },
                        textController: emailText,
                        color: (verifyEmailError == '') ? null : Colors.red,
                      ),
                      SizedBox(
                        height: media.height * 0.012,
                      ),

                      Container(
                        decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: underline))),
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    countries[phcode]['dial_code'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: textColor),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  const Icon(Icons.keyboard_arrow_down)
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              phnumber,
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  letterSpacing: 2),
                            )
                          ],
                        ),
                      ),
                      //email already exist error
                      (verifyEmailError != '')
                          ? Container(
                              margin: EdgeInsets.only(top: media.height * 0.03),
                              alignment: Alignment.center,
                              child: Text(
                                verifyEmailError,
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: Colors.red),
                              ),
                            )
                          : Container(),

                      SizedBox(
                        height: media.height * 0.065,
                      ),
                      (nameText.text.isNotEmpty && emailText.text.isNotEmpty)
                          ? Container(
                              width: media.width * 1,
                              alignment: Alignment.center,
                              child: Button(
                                  onTap: () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    setState(() {
                                      verifyEmailError = '';
                                      _loading = true;
                                    });
                                    var result = await validateEmail();
                                    setState(() {
                                      _loading = false;
                                    });
                                    if (result == 'success') {
                                      setState(() {
                                        verifyEmailError = '';
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                 const ServiceArea()));
                                    } else {
                                      setState(() {
                                        verifyEmailError = result.toString();
                                      });
                                      debugPrint('failed');
                                    }
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_next']))
                          : Container()
                    ],
                  )),
                ],
              ),
            ),

            //internet not connected
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      },
                    ))
                : Container(),

            //loader
            (_loading == true)
                ? const Positioned(top: 0, child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
