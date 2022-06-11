import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/referral_code.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';

class VehicleColor extends StatefulWidget {
  const VehicleColor({Key? key}) : super(key: key);

  @override
  _VehicleColorState createState() => _VehicleColorState();
}

dynamic vehicleColor;

class _VehicleColorState extends State<VehicleColor> {
  bool _isLoading = false;
  TextEditingController controller = TextEditingController();

  String uploadError = '';

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Directionality(
      textDirection:
          (languageDirection == 'rtl') ? TextDirection.rtl : TextDirection.ltr,
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
                            languages[choosenLanguage]['text_vehicle_color'],
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
                            ['Text_enter_vehicle_color'],
                        textController: controller,
                        onTap: (val) {
                          setState(() {
                            
                            vehicleColor = controller.text;
                          });
                        },
                      ),
                      (uploadError != '')
                          ? Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Text(
                                uploadError,
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * sixteen,
                                    color: Colors.red),
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 40,
                      ),
                      (controller.text.isNotEmpty)
                          ? Button(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  _isLoading = true;
                                });
                                if (userDetails.isEmpty) {
                                  var reg = await registerDriver();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if (reg == 'true') {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>const Referral()),
                                        (route) => false);
                                    serviceLocations.clear();
                                    vehicleMake.clear();
                                    vehicleModel.clear();
                                    vehicleType.clear();
                                  }
                                } else {
                                  var update = await updateVehicle();
                                  if (update == 'success') {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>const Maps()),
                                        (route) => false);
                                    serviceLocations.clear();
                                    vehicleMake.clear();
                                    vehicleModel.clear();
                                    vehicleType.clear();
                                  }
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              text: languages[choosenLanguage]['text_next'])
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
                      });
                    },
                  ))
              : Container(),

              //loader
          (_isLoading == true)
              ? const Positioned(top: 0, child: Loading())
              : Container()
        ],
      ),
    ));
  }
}
