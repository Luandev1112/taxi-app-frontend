import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/review_page.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class Invoice extends StatefulWidget {
  const Invoice({Key? key}) : super(key: key);

  @override
  _InvoiceState createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              media.width * 0.05,
              MediaQuery.of(context).padding.top + media.width * 0.05,
              media.width * 0.05,
              media.width * 0.05),
          height: media.height * 1,
          width: media.width * 1,
          color: page,
          //invoice data
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        languages[choosenLanguage]['text_tripsummary'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * sixteen,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: media.height * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: media.width * 0.13,
                            width: media.width * 0.13,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: NetworkImage(driverReq['userDetail']
                                        ['data']['profile_picture']),
                                    fit: BoxFit.contain)),
                          ),
                          SizedBox(
                            width: media.width * 0.05,
                          ),
                          Text(
                            driverReq['userDetail']['data']['name'],
                            style: GoogleFonts.roboto(
                              fontSize: media.width * eighteen,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.height * 0.05,
                      ),
                      SizedBox(
                        width: media.width * 0.72,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_reference'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * twelve,
                                          color: const Color(0xff898989)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                    Text(
                                      driverReq['request_number'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * fourteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_rideType'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * twelve,
                                          color: const Color(0xff898989)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                    Text(
                                      (driverReq['is_rental'] == false)
                                          ? 'Regular'
                                          : 'Rental',
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * fourteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.height * 0.02,
                            ),
                            Container(
                              height: 2,
                              color: const Color(0xffAAAAAA),
                            ),
                            SizedBox(
                              height: media.height * 0.02,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_distance'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * twelve,
                                          color: const Color(0xff898989)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                    Text(
                                      driverReq['total_distance'] +
                                          ' ' +
                                          driverReq['unit'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * fourteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      languages[choosenLanguage]
                                          ['text_duration'],
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * twelve,
                                          color: const Color(0xff898989)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.02,
                                    ),
                                    Text(
                                      driverReq['total_time'].toString() +
                                          ' mins',
                                      style: GoogleFonts.roboto(
                                          fontSize: media.width * fourteen,
                                          color: textColor),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info),
                          SizedBox(
                            width: media.width * 0.04,
                          ),
                          Text(
                            languages[choosenLanguage]['text_tripfare'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * fourteen,
                                color: textColor),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_baseprice'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['base_price']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                       SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_distprice'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']
                                        ['distance_price']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_timeprice'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['time_price']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                           languages[choosenLanguage]['text_waiting_price'] + ' (' + driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] + ' ' + driverReq['requestBill']['data']['waiting_charge_per_min'].toString() + ' x '  + driverReq['requestBill']['data']['calculated_waiting_time'].toString() + ' mins' + ')',
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['waiting_charge']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                      (driverReq['requestBill']['data']['cancellation_fee'] !=
                              0)
                          ? SizedBox(
                              height: media.height * 0.02,
                            )
                          : Container(),
                      (driverReq['requestBill']['data']['cancellation_fee'] !=
                              0)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]['text_cancelfee'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twelve,
                                      color: textColor),
                                ),
                                Text(
                                  driverReq['requestBill']['data']
                                          ['requested_currency_symbol'] +
                                      ' ' +
                                      driverReq['requestBill']['data']
                                              ['cancellation_fee']
                                          .toString(),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twelve,
                                      color: textColor),
                                ),
                              ],
                            )
                          : Container(),
                      (driverReq['requestBill']['data']['airport_surge_fee'] !=
                              0)
                          ? SizedBox(
                              height: media.height * 0.02,
                            )
                          : Container(),
                      (driverReq['requestBill']['data']['airport_surge_fee'] !=
                              0)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languages[choosenLanguage]['text_surge_fee'],
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twelve,
                                      color: textColor),
                                ),
                                Text(
                                  driverReq['requestBill']['data']
                                          ['requested_currency_symbol'] +
                                      ' ' +
                                      driverReq['requestBill']['data']
                                              ['airport_surge_fee']
                                          .toString(),
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * twelve,
                                      color: textColor),
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_convfee'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']
                                        ['admin_commision']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                      (driverReq['requestBill']['data']
                                        ['promo_discount'] != null) ?
                      SizedBox(
                        height: media.height * 0.02,
                      ) : Container(),
                      (driverReq['requestBill']['data']
                                        ['promo_discount'] != null) ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_discount'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: Colors.red),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']
                                        ['promo_discount']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: Colors.red),
                          ),
                        ],
                      ) : Container(),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_taxes'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['service_tax']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                     
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Container(
                        height: 1.5,
                        color: const Color(0xffE0E0E0),
                      ),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages[choosenLanguage]['text_totalfare'],
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['total_amount']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twelve,
                                color: textColor),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: media.height * 0.02,
                      ),
                      Container(
                        height: 1.5,
                        color: const Color(0xffE0E0E0),
                      ),
                      SizedBox(
                        height: media.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (driverReq['payment_opt'] == '1')
                                ? languages[choosenLanguage]['text_cash']
                                : (driverReq['payment_opt'] == '2')
                                    ? languages[choosenLanguage]['text_wallet']
                                    : 'Card',
                            style: GoogleFonts.roboto(
                                fontSize: media.width * sixteen,
                                color: buttonColor),
                          ),
                          Text(
                            driverReq['requestBill']['data']
                                    ['requested_currency_symbol'] +
                                ' ' +
                                driverReq['requestBill']['data']['total_amount']
                                    .toString(),
                            style: GoogleFonts.roboto(
                                fontSize: media.width * twentysix,
                                color: textColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Button(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Review()));
                  },
                  text: languages[choosenLanguage]['text_confirm'])
            ],
          ),
        ),
      ),
    );
  }
}
