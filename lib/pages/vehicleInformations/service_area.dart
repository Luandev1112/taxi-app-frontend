import 'package:flutter/material.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_type.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';
import '../../functions/functions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../loadingPage/loading.dart';
import '../../styles/styles.dart';

class ServiceArea extends StatefulWidget {
  const ServiceArea({Key? key}) : super(key: key);

  @override
  _ServiceAreaState createState() => _ServiceAreaState();
}

dynamic myServiceLocation;
dynamic myServiceId;

class _ServiceAreaState extends State<ServiceArea> {
  bool _loaded = false;

  @override
  void initState() {
    getServiceLoc();
    super.initState();
  }

//get service loc data
  getServiceLoc() async {
    myServiceId = '';
    myServiceLocation = '';
    await getServiceLocation();
    setState(() {
      _loaded = true;
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
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: media.width * 0.08,
                  right: media.width * 0.08,
                  top: media.width * 0.05 + MediaQuery.of(context).padding.top),
              color: page,
              height: media.height * 1,
              width: media.width * 1,
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.bottomLeft,
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
                        languages[choosenLanguage]['text_service_location'],
                        style: GoogleFonts.roboto(
                            fontSize: media.width * twenty,
                            color: textColor,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(height: 10),
                  (_loaded != false && serviceLocations.isNotEmpty)
                      ? Expanded(
                          child: SingleChildScrollView(
                          child: Column(
                            children: serviceLocations
                                .asMap()
                                .map((i, value) => MapEntry(
                                    i,
                                    Container(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      width: media.width * 1,
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            myServiceId =
                                                serviceLocations[i]['id'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              serviceLocations[i]['name'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * twenty,
                                                  color: textColor),
                                            ),
                                            (myServiceId ==
                                                    serviceLocations[i]['id'])
                                                ? Icon(
                                                    Icons.done,
                                                    color: buttonColor,
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    )))
                                .values
                                .toList(),
                          ),
                        ))
                      : Container(),
                  (myServiceId != '')
                      ? Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Button(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const VehicleType()));
                              },
                              text: languages[choosenLanguage]['text_next']),
                        )
                      : Container()
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
                        });
                      },
                    ))
                : Container(),

                //loader
            (_loaded == false)
                ? const Positioned(top: 0, child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
