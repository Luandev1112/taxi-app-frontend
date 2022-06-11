import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class DocsProcess extends StatefulWidget {
  const DocsProcess({Key? key}) : super(key: key);

  @override
  _DocsProcessState createState() => _DocsProcessState();
}

class _DocsProcessState extends State<DocsProcess> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              if (userDetails['approve'] == true) {
                Future.delayed(const Duration(milliseconds: 0), () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Maps()),
                      (route) => false);
                });
              }
              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: media.width * 0.08,
                        right: media.width * 0.08,
                        top: 20,
                        bottom: 20),
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        (userDetails['approve'] == false &&
                                userDetails['declined_reason'] == null)
                            ? Column(
                                children: [
                                  Container(
                                    height: media.width * 0.4,
                                    width: media.width * 0.4,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: verifyPendingBck),
                                    alignment: Alignment.center,
                                    child: Container(
                                      height: media.width * 0.3,
                                      width: media.width * 0.3,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: verifyPending),
                                      child: Icon(
                                        Icons.access_time_rounded,
                                        color: buttonText,
                                        size: media.width * 0.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    languages[choosenLanguage]
                                        ['text_approval_waiting'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: textColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: media.height * 0.02),
                                  Text(
                                    languages[choosenLanguage]
                                        ['text_send_approval'],
                                    style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : (userDetails['approve'] == false &&
                                    userDetails['declined_reason'] != null)
                                ? Column(
                                    children: [
                                      Container(
                                        height: media.width * 0.4,
                                        width: media.width * 0.4,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: verifyPendingBck),
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: media.width * 0.3,
                                          width: media.width * 0.3,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: verifyDeclined),
                                          child: Icon(
                                            Icons.access_time_rounded,
                                            color: buttonText,
                                            size: media.width * 0.1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_document_suspended'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * twenty,
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: media.height * 0.02),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_document_rejected'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: media.height * 0.02),
                                      Text(
                                        (userDetails['declined_error'] != null)
                                            ? userDetails['declined_reason']
                                                .toString()
                                            : '',
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  )
                                : Container(),

                        //button
                        Button(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Docs(
                                            fromPage: '1',
                                          )));
                            },
                            text: languages[choosenLanguage]['text_edit_docs'])
                      ],
                    ),
                  ),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(
                            onTap: () {
                              setState(() {
                                internetTrue();

                                getUserDetails();
                              });
                            },
                          ))
                      : Container(),
                ],
              );
            }),
      ),
    );
  }
}
