import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //controller for chat text
  TextEditingController chatText = TextEditingController();

  //controller for scrolling chats
  ScrollController controller = ScrollController();
  bool _sendingMessage = false;
  @override
  void initState() {
    getCurrentMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Material(
        // rtl and ltr
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
            body: ValueListenableBuilder(
                valueListenable: valueNotifierHome.value,
                builder: (context, value, child) {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    controller.animateTo(controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  });
                  //api call for message seen
                  messageSeen();

                  return Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            media.width * 0.05,
                            MediaQuery.of(context).padding.top +
                                media.width * 0.05,
                            media.width * 0.05,
                            media.width * 0.05),
                        height: media.height * 1,
                        width: media.width * 1,
                        color: page,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: media.width * 0.9,
                                  height: media.width * 0.1,
                                  alignment: Alignment.center,
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_chatwithdriver'],
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * twenty,
                                        color: textColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Positioned(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Container(
                                      height: media.width * 0.1,
                                      width: media.width * 0.1,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 2)
                                          ],
                                          color: page),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                                child: SingleChildScrollView(
                              controller: controller,
                              child: Column(
                                children: chatList
                                    .asMap()
                                    .map((i, value) {
                                      return MapEntry(
                                          i,
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: media.width * 0.025),
                                            width: media.width * 0.9,
                                            alignment:
                                                (chatList[i]['from_type'] == 2)
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                            child: Column(
                                              crossAxisAlignment: (chatList[i]
                                                          ['from_type'] ==
                                                      2)
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: media.width * 0.5,
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.04),
                                                  decoration: BoxDecoration(
                                                      borderRadius: (chatList[i]['from_type'] == 2)
                                                          ? const BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                      24),
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                      24),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                      24))
                                                          : const BorderRadius.only(
                                                              topRight:
                                                                  Radius.circular(
                                                                      24),
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                      24),
                                                              bottomRight:
                                                                  Radius.circular(24)),
                                                      color: (chatList[i]['from_type'] == 2) ? const Color(0xff000000).withOpacity(0.15) : const Color(0xff222222)),
                                                  child: Text(
                                                    chatList[i]['message'],
                                                    style: GoogleFonts.roboto(
                                                        fontSize: media.width *
                                                            fourteen,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.015,
                                                ),
                                                Text(chatList[i]
                                                    ['converted_created_at'])
                                              ],
                                            ),
                                          ));
                                    })
                                    .values
                                    .toList(),
                              ),
                            )),
                            Container(
                              margin: EdgeInsets.only(top: media.width * 0.025),
                              padding: EdgeInsets.fromLTRB(
                                  media.width * 0.025,
                                  media.width * 0.01,
                                  media.width * 0.025,
                                  media.width * 0.01),
                              
                              width: media.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: borderLines, width: 1.2),
                                  color: page),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: media.width * 0.7,
                                    child: TextField(
                                      controller: chatText,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: languages[choosenLanguage]
                                              ['text_entermessage'],
                                          hintStyle: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: hintColor)),
                                      minLines: 1,
                                      onChanged: (val) {},
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      setState(() {
                                        _sendingMessage = true;
                                      });

                                      //api call for send message
                                      await sendMessage(chatText.text);
                                      chatText.clear();
                                      setState(() {
                                        _sendingMessage = false;
                                      });
                                    },
                                    child: SizedBox(
                                      
                                      child: RotatedBox(
                                          quarterTurns:
                                              (languageDirection == 'rtl')
                                                  ? 2
                                                  : 0,
                                          child: Image.asset(
                                            'assets/images/send.png',
                                            fit: BoxFit.contain,
                                            width: media.width * 0.075,
                                          )),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // loader
                      (_sendingMessage == true)
                          ? const Positioned(top: 0, child: Loading())
                          : Container()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
