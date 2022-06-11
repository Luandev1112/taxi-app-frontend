import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/withdraw.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({Key? key}) : super(key: key);

  @override
  _BankDetailsState createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
//text controller for editing bank details
  TextEditingController holderName = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankCode = TextEditingController();

  bool _isLoading = true;
  bool _showError = false;
  bool _edit = false;

  @override
  void initState() {
    getBankDetails();
    super.initState();
  }

  getBankDetails() async {
    await getBankInfo();
    setState(() {
      _isLoading = false;
    });
  }

//showing error
  _errorClear() async {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showError = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                height: media.height * 1,
                width: media.width * 1,
                color: page,
                padding: EdgeInsets.all(media.width * 0.05),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: media.width * 0.05),
                          width: media.width * 1,
                          alignment: Alignment.center,
                          child: Text(
                            languages[choosenLanguage]['text_bankDetails'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twenty,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ),
                        Positioned(
                            child: InkWell(
                                onTap: () {
                                  
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.arrow_back)))
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      child: (bankData.isEmpty || _edit == true)
                          ? Column(
                              children: [
                                TextField(
                                  controller: holderName,
                                  decoration: InputDecoration(
                                      labelText: languages[choosenLanguage]
                                          ['text_accoutHolderName'],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gapPadding: 1),
                                      isDense: true),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                TextField(
                                  controller: accountNumber,
                                  decoration: InputDecoration(
                                      labelText: languages[choosenLanguage]
                                          ['text_accountNumber'],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gapPadding: 1),
                                      isDense: true),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                TextField(
                                  controller: bankName,
                                  decoration: InputDecoration(
                                      labelText: languages[choosenLanguage]
                                          ['text_bankName'],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gapPadding: 1),
                                      isDense: true),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                TextField(
                                  controller: bankCode,
                                  decoration: InputDecoration(
                                      labelText: languages[choosenLanguage]
                                          ['text_bankCode'],
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          gapPadding: 1),
                                      isDense: true),
                                ),
                                SizedBox(
                                  height: media.width * 0.1,
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(media.width * 0.025),
                                  width: media.width * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: page,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 2,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 2),
                                      ]),
                                  child: Column(
                                    children: [
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_accoutHolderName'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['account_name'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_bankName'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['bank_name'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_accountNumber'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['account_no'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Text(
                                        languages[choosenLanguage]
                                            ['text_bankCode'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: hintColor),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.025,
                                      ),
                                      Text(
                                        bankData['bank_code'],
                                        style: GoogleFonts.roboto(
                                            fontSize: media.width * sixteen,
                                            color: textColor),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                              ],
                            ),
                    )),
                    (_edit == true || bankData.isEmpty)
                        ? Row(
                            mainAxisAlignment: (bankData.isEmpty)
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.spaceBetween,
                            children: [
                              (bankData.isNotEmpty)
                                  ? Button(
                                      onTap: () {
                                        setState(() {
                                          _edit = false;
                                        });
                                      },
                                      width: media.width * 0.4,
                                      text: languages[choosenLanguage]
                                          ['text_cancel'])
                                  : Container(),
                              Button(
                                  onTap: () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (holderName.text.isNotEmpty &&
                                        accountNumber.text.isNotEmpty &&
                                        bankCode.text.isNotEmpty &&
                                        bankName.text.isNotEmpty) {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var val = await addBankData(
                                          holderName.text,
                                          accountNumber.text,
                                          bankCode.text,
                                          bankName.text);
                                      if (val == 'failure') {
                                        setState(() {
                                          _showError = true;
                                          _errorClear();
                                        });
                                      } else if (val == 'success') {
                                        setState(() {
                                          _edit = false;
                                        });
                                        if (addBank == true) {
                                          Navigator.pop(context, true);
                                        }
                                      }
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  width: (bankData.isEmpty)
                                      ? null
                                      : media.width * 0.4,
                                  text: languages[choosenLanguage]
                                      ['text_confirm']),
                            ],
                          )
                        : Button(
                            onTap: () {
                              setState(() {
                                accountNumber.text =
                                    bankData['account_no'].toString();
                                bankName.text = bankData['bank_name'];
                                bankCode.text = bankData['bank_code'];
                                holderName.text = bankData['account_name'];
                                _edit = true;
                              });
                            },
                            text: languages[choosenLanguage]['text_edit'])
                  ],
                ),
              ),
              (_showError == true)
                  ? Positioned(
                      top: 0,
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: media.width * 0.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: page,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 2)
                                    ]),
                                padding: EdgeInsets.all(media.width * 0.05),
                                child: Text(
                                  languages[choosenLanguage]
                                      ['text_somethingwentwrong'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      color: textColor),
                                ),
                              )
                            ]),
                      ))
                  : Container(),

              //no internet
              (internet == false)
                  ? Positioned(
                      top: 0,
                      child: NoInternet(onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      }))
                  : Container(),

              //loader
              (_isLoading == true)
                  ? const Positioned(top: 0, child: Loading())
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
