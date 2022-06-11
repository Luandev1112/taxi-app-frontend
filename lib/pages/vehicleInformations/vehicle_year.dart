import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_number.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class VehicleYear extends StatefulWidget {
  const VehicleYear({Key? key}) : super(key: key);

  @override
  _VehicleYearState createState() => _VehicleYearState();
}

dynamic modelYear;

class _VehicleYearState extends State<VehicleYear> {
  String dateError = '';

  TextEditingController controller = TextEditingController();

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
                  height: media.height * 1,
                  width: media.width * 1,
                  color: page,
                  child: Column(children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: media.width * 0.08,
                          right: media.width * 0.08,
                          top: media.width * 0.05 +
                              MediaQuery.of(context).padding.top),
                      color: page,
                      height: media.height * 1,
                      width: media.width * 1,
                      child: Column(
                        children: [
                          Container(
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
                          SizedBox(
                            height: media.height * 0.04,
                          ),
                          SizedBox(
                              width: media.width * 1,
                              child: Text(
                                languages[choosenLanguage]
                                    ['text_vehicle_model_year'],
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * twenty,
                                    color: textColor,
                                    fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          InputField(
                            text: languages[choosenLanguage]
                                ['text_enter_vehicle_model_year'],
                            textController: controller,
                            onTap: (val) {
                              setState(() {
                                modelYear = controller.text;
                              });
                              if (controller.text.length == 4 &&
                                  int.parse(modelYear) <=
                                      int.parse(
                                          DateTime.now().year.toString())) {
                                setState(() {
                                  dateError = '';
                                });
                                FocusManager.instance.primaryFocus?.unfocus();
                              } else if (controller.text.length == 4 &&
                                  int.parse(modelYear) >
                                      int.parse(
                                          DateTime.now().year.toString())) {
                                setState(() {
                                  dateError = 'Please Enter Valid Date';
                                });
                              }
                            },
                            color: (dateError == '') ? null : Colors.red,
                            inputType: TextInputType.number,
                            maxLength: 4,
                          ),
                          (dateError != '')
                              ? Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    dateError,
                                    style: GoogleFonts.roboto(
                                        fontSize: media.width * sixteen,
                                        color: Colors.red),
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 40,
                          ),
                          (controller.text.length == 4)
                              ? (int.parse(modelYear) <=
                                      int.parse(DateTime.now().year.toString()))
                                  ? Button(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const VehicleNumber()));
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_next'])
                                  : Container()
                              : Container()
                        ],
                      ),
                    ),
                  ])),

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
          )),
    );
  }
}
