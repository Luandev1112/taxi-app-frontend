import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/bankdetails.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class Withdraw extends StatefulWidget {
  const Withdraw({Key? key}) : super(key: key);

  @override
  _WithdrawState createState() => _WithdrawState();
}

dynamic withDrawMoney;
bool addBank = false;

class _WithdrawState extends State<Withdraw> {
  TextEditingController addMoneyController = TextEditingController();
  bool _isLoading = true;
  bool _addPayment = false;
  bool _showError = false;
  dynamic _error;

  @override
  void initState() {
    getWithdrawel();

    super.initState();
  }

//get withdrawed money list
  getWithdrawel() async {
    await getWithdrawList();
    setState(() {
      _isLoading = false;
      addBank = false;
    });
  }

  _errorClear() async {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _showError = false;
        _error = null;
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
                            languages[choosenLanguage]['text_withdraw'],
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
                    (withDrawList.isNotEmpty)
                        ? Column(children: [
                            Text(
                              languages[choosenLanguage]
                                  ['text_availablebalance'],
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * twelve,
                                  color: textColor),
                            ),
                            SizedBox(
                              height: media.width * 0.01,
                            ),
                            Text(
                              walletBalance['currency_symbol'] +
                                  withDrawList['wallet_balance'].toString(),
                              style: GoogleFonts.roboto(
                                  fontSize: media.width * fourty,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            SizedBox(
                              width: media.width * 0.9,
                              child: Text(
                                languages[choosenLanguage]
                                    ['text_withdrawHistory'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * twenty,
                                    fontWeight: FontWeight.w600,
                                    color: textColor),
                              ),
                            )
                          ])
                        : Container(),
                    SizedBox(
                      height: media.width * 0.1,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: (withDrawList.isNotEmpty)
                          ? SizedBox(
                              width: media.width * 0.9,
                              child: Column(
                                children: [
                                  (withDrawHistory.isNotEmpty)
                                      ? Column(
                                          children: withDrawHistory
                                              .asMap()
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          bottom: media.width *
                                                              0.025),
                                                      width: media.width * 0.9,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_withdrawReqAt'],
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        hintColor),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                withDrawHistory[
                                                                            i][
                                                                        'created_at']
                                                                    .toString(),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                withDrawHistory[
                                                                            i][
                                                                        'status']
                                                                    .toString(),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        buttonColor),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              Text(
                                                                withDrawHistory[
                                                                            i][
                                                                        'requested_currency'] +
                                                                    ' ' +
                                                                    withDrawHistory[i]
                                                                            [
                                                                            'requested_amount']
                                                                        .toString(),
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        textColor),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ));
                                              })
                                              .values
                                              .toList(),
                                        )
                                      : (_isLoading == false &&
                                              withDrawHistory.isEmpty)
                                          ? Text(
                                              languages[choosenLanguage]
                                                  ['text_noDataFound'])
                                          : Container(),
                                  (withDrawHistoryPages.isNotEmpty)
                                      ? (withDrawHistoryPages['current_page'] <
                                              withDrawHistoryPages[
                                                  'total_pages'])
                                          ? InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  _isLoading = true;
                                                });

                                             
                                                    await getWithdrawListPages(
                                                        (withDrawHistoryPages[
                                                                    'current_page'] +
                                                                1)
                                                            .toString());

                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.025),
                                                margin: EdgeInsets.only(
                                                    bottom: media.width * 0.05),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: page,
                                                    border: Border.all(
                                                        color: borderLines,
                                                        width: 1.2)),
                                                child: Text(
                                                  languages[choosenLanguage]
                                                      ['text_loadmore'],
                                                  style: GoogleFonts.roboto(
                                                      fontSize:
                                                          media.width * sixteen,
                                                      color: textColor),
                                                ),
                                              ),
                                            )
                                          : Container()
                                      : Container()
                                ],
                              ),
                            )
                          : Container(),
                    )),
                    SizedBox(
                      height: media.width * 0.05,
                    ),
                    Button(
                        onTap: () {
                          setState(() {
                            _addPayment = true;
                          });
                        },
                        text: languages[choosenLanguage]['text_withdraw'])
                  ],
                ),
              ),
              (_addPayment == true)
                  ? Positioned(
                      bottom: 0,
                      child: Container(
                        height: media.height * 1,
                        width: media.width * 1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: media.width * 0.05),
                              width: media.width * 0.9,
                              padding: EdgeInsets.all(media.width * 0.025),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: borderLines, width: 1.2),
                                  color: page),
                              child: Column(children: [
                                Container(
                                  height: media.width * 0.128,
                                 
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: borderLines, width: 1.2),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: media.width * 0.1,
                                          height: media.width * 0.128,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  (languageDirection == 'ltr')
                                                      ? const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  12),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  12),
                                                        )
                                                      : const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  12),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  12),
                                                        ),
                                              color: const Color(0xffF0F0F0)),
                                          alignment: Alignment.center,
                                          child: Text(
                                            walletBalance['currency_symbol'],
                                            style: GoogleFonts.roboto(
                                                fontSize: media.width * fifteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600),
                                          )),
                                      SizedBox(
                                        width: media.width * 0.05,
                                      ),
                                      Container(
                                        height: media.width * 0.128,
                                        width: media.width * 0.6,
                                        alignment: Alignment.center,
                                        child: TextField(
                                          controller: addMoneyController,
                                          onChanged: (val) {
                                            setState(() {
                                              if (double.parse(withDrawList[
                                                          'wallet_balance']
                                                      .toString()) >=
                                                  double.parse(val)) {
                                               
                                                withDrawMoney =
                                                    double.parse(val);
                                              } else {
                                                addMoneyController.text = withDrawList[
                                                        'wallet_balance']
                                                    .toString();
                                                withDrawMoney = withDrawList[
                                                    'wallet_balance'];
                                              }
                                              
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: languages[choosenLanguage]
                                                ['text_enteramount'],
                                            hintStyle: GoogleFonts.roboto(
                                                fontSize: media.width * twelve,
                                                color: hintColor),
                                          ),
                                          maxLines: 1,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (withDrawList['wallet_balance'] >=
                                              100.0) {
                                            addMoneyController.text = '100';
                                            withDrawMoney = 100;
                                          } else {
                                            addMoneyController.text =
                                                withDrawList['wallet_balance']
                                                    .toString();
                                            withDrawMoney =
                                                withDrawList['wallet_balance'];
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: media.width * 0.11,
                                        width: media.width * 0.17,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: borderLines, width: 1.2),
                                            color: page,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          walletBalance['currency_symbol'] +
                                              '100',
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: media.width * 0.05,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (withDrawList['wallet_balance'] >=
                                              500.0) {
                                            addMoneyController.text = '500';
                                            withDrawMoney = 500;
                                          } else {
                                            addMoneyController.text =
                                                withDrawList['wallet_balance']
                                                    .toString();
                                            withDrawMoney =
                                                withDrawList['wallet_balance'];
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: media.width * 0.11,
                                        width: media.width * 0.17,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: borderLines, width: 1.2),
                                            color: page,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          walletBalance['currency_symbol'] +
                                              '500',
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: media.width * 0.05,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (withDrawList['wallet_balance'] >=
                                              1000.0) {
                                            addMoneyController.text = '1000';
                                            withDrawMoney = 1000;
                                          } else {
                                            addMoneyController.text =
                                                withDrawList['wallet_balance']
                                                    .toString();
                                            withDrawMoney =
                                                withDrawList['wallet_balance'];
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: media.width * 0.11,
                                        width: media.width * 0.17,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: borderLines, width: 1.2),
                                            color: page,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        alignment: Alignment.center,
                                        child: Text(
                                          walletBalance['currency_symbol'] +
                                              '1000',
                                          style: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: textColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: media.width * 0.1,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Button(
                                      onTap: () async {
                                        setState(() {
                                          _addPayment = false;
                                          withDrawMoney = null;
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          addMoneyController.clear();
                                        });
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_cancel'],
                                      width: media.width * 0.4,
                                    ),
                                    Button(
                                      onTap: () async {
                                        
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await getBankInfo();
                                        if (bankData.isNotEmpty) {
                                          setState(() {
                                            _addPayment = false;
                                          });
                                          //withdraw request
                                          var val = await requestWithdraw(
                                              withDrawMoney);
                                          if (val != 'success' &&
                                              val != 'no internet') {
                                            setState(() {
                                              _error = val;
                                              _showError = true;
                                            });
                                            _errorClear();
                                          }
                                        } else {
                                          addBank = true;
                                          setState(() {
                                            _isLoading = false;
                                          });

                                          var nav = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const BankDetails()));
                                          if (nav) {
                                            setState(() {
                                              addMoneyController.text = withDrawMoney;
                                              addBank = false;
                                            });
                                          }
                                        }
                                        setState(() {
                                          addMoneyController.clear();
                                          withDrawMoney = null;
                                          _isLoading = false;
                                        });
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_withdraw'],
                                      width: media.width * 0.4,
                                    ),
                                  ],
                                )
                              ]),
                            ),
                          ],
                        ),
                      ))
                  : Container(),

                  //no internet
              (internet == false)
                  ? Positioned(
                      top: 0,
                      child: NoInternet(
                        onTap: () {
                          setState(() {
                            internetTrue();

                            _isLoading = true;
                          });
                        },
                      ))
                  : Container(),

              //show error
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
                                  _error,
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * sixteen,
                                      color: textColor),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ]),
                      ))
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
