import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:google_fonts/google_fonts.dart';
import 'package:tagyourtaxi_driver/functions/functions.dart';
import 'package:tagyourtaxi_driver/functions/geohash.dart';
import 'package:tagyourtaxi_driver/pages/chatPage/chat_page.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/invoice.dart';
import 'package:tagyourtaxi_driver/pages/loadingPage/loading.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/navDrawer/nav_drawer.dart';
import 'package:tagyourtaxi_driver/pages/noInternet/nointernet.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/docs_onprocess.dart';
import 'package:tagyourtaxi_driver/styles/styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:tagyourtaxi_driver/translation/translation.dart';
import 'package:tagyourtaxi_driver/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class Maps extends StatefulWidget {
  const Maps({Key? key}) : super(key: key);

  @override
  _MapsState createState() => _MapsState();
}

dynamic center;

List<Marker> myMarkers = [];
// Set<Marker> _markers = {};
Set<Circle> circles = {};

dynamic _timer;
String cancelReasonText = '';
bool notifyCompleted = false;
bool logout = false;
bool getStartOtp = false;
String driverOtp = '';

class _MapsState extends State<Maps> with WidgetsBindingObserver {
  bool sosLoaded = false;
  bool cancelRequest = false;
  bool _pickAnimateDone = false;
  bool _dropAnimateDone = false;
  late bool serviceEnabled;
  late PermissionStatus permission;
  Location location = Location();
  String state = '';
  GoogleMapController? _controller;
 
  String _cancelReason = '';
   bool _locationDenied = false;
  int gettingPerm = 0;
  bool _errorOtp = false;
  dynamic loc;
  String _otp1 = '';
  String _otp2 = '';
  String _otp3 = '';
  String _otp4 = '';
  bool showSos = false;
  bool _showWaitingInfo = false;
  bool _isLoading = false;
  bool _reqCancelled = false;
  dynamic pinLocationIcon;
  dynamic userLocationIcon;

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

  
    getLocs();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if(_controller != null){_controller!.setMapStyle(mapStyle);
      valueNotifierHome.incrementNotifier();}
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  reqCancel() {
    _reqCancelled = true;

    Future.delayed(const Duration(seconds: 2), () {
      _reqCancelled = false;
      userReject = false;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

//getting permission and current location
  getLocs() async {
    permission = await location.hasPermission();
    serviceEnabled = await location.serviceEnabled();

    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.deniedForever || serviceEnabled == false) {
           gettingPerm++;
        if(gettingPerm >= 2){
          setState(() {
            _locationDenied = true;
          });
        }
      setState(() {
        state = '2';
        
        _isLoading = false;
      });
    } else if (permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited) {
     
      final Uint8List markerIcon =
          await getBytesFromAsset('assets/images/top-taxi.png', 40);
      if (center == null) {
        var locs = await geolocator.Geolocator.getLastKnownPosition();
        if(locs != null){
          center = LatLng(locs.latitude, locs.longitude);
          heading = locs.heading;
        }else{
        loc = await geolocator.Geolocator.getCurrentPosition(desiredAccuracy: geolocator.LocationAccuracy.low);
        center = LatLng(double.parse(loc.latitude.toString()),
            double.parse(loc.longitude.toString()));
        heading = loc.heading;
        }
      }
      setState(() {
        pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);

       

        
        if (myMarkers.isEmpty) {
          myMarkers = [
            Marker(
              markerId: const MarkerId('1'),
              rotation: heading,
              position: center,
              icon: pinLocationIcon,
              anchor:const Offset(0.5,0.5)
            )
          ];
        }
      });
      setState(() {
        state = '3';
        _isLoading = false;
      });
    }
  }



  int _bottom = 0;

  GeoHasher geo = GeoHasher();

  @override
  Widget build(BuildContext context) {
    GlobalKey iconKey = GlobalKey();
    GlobalKey iconDropKey = GlobalKey();

    var media = MediaQuery.of(context).size;
    

    final markerDropWidget = RepaintBoundary(
        key: iconDropKey,
        child: Column(
          children: [
            Container(
              width: media.width * 0.5,
              height: media.width * 0.12,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: page),
              child: Row(
                children: [
                  Container(
                    height: media.width * 0.12,
                    width: media.width * 0.12,
                    decoration: BoxDecoration(
                        borderRadius: (languageDirection == 'ltr')
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10))
                            : const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                        color: const Color(0xff222222)),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.star,
                      color: Color(0xffE60000),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.only(
                        left: media.width * 0.02, right: media.width * 0.02),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languages[choosenLanguage]['text_droppoint'],
                          style: GoogleFonts.roboto(
                              fontSize: media.width * twelve,
                              fontWeight: FontWeight.bold),
                        ),
                        (driverReq.isNotEmpty &&
                                driverReq['drop_address'] != null)
                            ? Text(
                                driverReq['drop_address'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: GoogleFonts.roboto(
                                    fontSize: media.width * twelve),
                              )
                            : Container(),
                      ],
                    ),
                  ))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: AssetImage('assets/images/droploc.png'),
                      fit: BoxFit.contain)),
              height: media.width * 0.05,
              width: media.width * 0.05,
            )
          ],
        ));

    Future<BitmapDescriptor> getCustomIcon(GlobalKey iconKeys) async {
      Future<Uint8List> _capturePng(GlobalKey iconKeys) async {
        dynamic pngBytes;
       
        try {
          RenderRepaintBoundary boundary = iconKeys.currentContext!
              .findRenderObject() as RenderRepaintBoundary;
          ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          pngBytes = byteData!.buffer.asUint8List();
          return pngBytes;
        } catch (e) {
          debugPrint(e.toString());
        }
        return pngBytes;
      }

      Uint8List imageData = await _capturePng(iconKeys);
    
      return BitmapDescriptor.fromBytes(imageData);
    }

    addDropMarker() async {
      BitmapDescriptor testIcon = await getCustomIcon(iconDropKey);
      setState(() {
        myMarkers.add(Marker(
            markerId: const MarkerId('3'),
            icon: testIcon,
            position: LatLng(driverReq['drop_lat'], driverReq['drop_lng'])));
      });
      if (polyline
          .where((element) => element.polylineId == const PolylineId('1'))
          .isEmpty) {
        getPolylines();
      }
    }

    addMarker() async {
      if (driverReq.isNotEmpty) {
        BitmapDescriptor testIcon = await getCustomIcon(iconKey);
        setState(() {
          myMarkers.add(Marker(
              markerId: const MarkerId('2'),
              icon: testIcon,
              position: LatLng(driverReq['pick_lat'], driverReq['pick_lng'])));
        });
      }
    }

    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            if (myMarkers
                    .where((element) => element.markerId == const MarkerId('1'))
                    .isNotEmpty &&
                pinLocationIcon != null) {
              var lst = myMarkers.firstWhere(
                  (element) => element.markerId == const MarkerId('1'));
              var ind = myMarkers.indexOf(lst);
              myMarkers[ind] = Marker(
                  markerId: const MarkerId('1'),
                  position: center,
                  rotation: heading,
                  icon: pinLocationIcon,
                  anchor:const Offset(0.5,0.5)
                  );
                  if( driverReq.isEmpty || driverReq['is_trip_start'] == 1){_controller
                  ?.animateCamera(CameraUpdate.newLatLng(center));}
            } else if (myMarkers
                    .where((element) => element.markerId == const MarkerId('1'))
                    .isEmpty &&
                pinLocationIcon != null) {
              myMarkers.add(Marker(
                markerId: const MarkerId('1'),
                rotation: heading,
                position: center,
                icon: pinLocationIcon,
                anchor:const Offset(0.5,0.5)
              ));
            }
            if (driverReq.isNotEmpty) {
              if (driverReq['is_trip_start'] != 1) {
                if (myMarkers
                    .where((element) => element.markerId == const MarkerId('2'))
                    .isEmpty) {
                  Future.delayed(const Duration(seconds: 2), () {
                    addMarker();
                  });
                }

                if (_pickAnimateDone != true) {
                  
                  _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(driverReq['pick_lat'], driverReq['pick_lng']), 11.0));
                  _pickAnimateDone = true;
                }
              } else if (driverReq['is_trip_start'] == 1 &&
                  driverReq['is_completed'] == 0) {
                if (myMarkers
                    .where((element) => element.markerId == const MarkerId('3'))
                    .isEmpty) {
                  addDropMarker();
                }
                if (myMarkers
                    .where((element) => element.markerId == const MarkerId('2'))
                    .isEmpty) {
                  addMarker();
                }

                if (_dropAnimateDone == false) {
                  _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(driverReq['drop_lat'], driverReq['drop_lng']), 11.0));
                  _dropAnimateDone = true;
                }
              } else if (driverReq['is_completed'] == 1 &&
                  driverReq['requestBill'] != null) {
                WidgetsBinding.instance?.addPostFrameCallback((_) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Invoice()),
                      (route) => false);
                });
                _pickAnimateDone = false;
                _dropAnimateDone = false;
                myMarkers.removeWhere(
                    (element) => element.markerId == const MarkerId('2'));
                myMarkers.removeWhere(
                    (element) => element.markerId == const MarkerId('3'));
                polyline.removeWhere(
                    (element) => element.polylineId == const PolylineId('1'));
              }
            } else {
              if (myMarkers
                  .where((element) => element.markerId == const MarkerId('2'))
                  .isNotEmpty) {
                myMarkers.removeWhere(
                    (element) => element.markerId == const MarkerId('2'));
                if (userReject == true) {
                  reqCancel();
                }

                _pickAnimateDone = false;
              }
            }
            if (userDetails['approve'] == false) {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DocsProcess()),
                    (route) => false);
              });
            }
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                drawer:const NavDrawer(),
                body: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Container(
                        color: page,
                        height: media.height * 1,
                        width: media.width * 1,
                        child: Column(
                            mainAxisAlignment: (state == '1' || state == '2')
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            children: [
                              (state == '1')
                                  ? Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 0.6,
                                      height: media.width * 0.3,
                                      decoration: BoxDecoration(
                                          color: page,
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 5,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            languages[choosenLanguage]
                                                ['text_enable_location'],
                                            style: GoogleFonts.roboto(
                                                fontSize: media.width * sixteen,
                                                color: textColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  state = '';
                                                });
                                                getLocs();
                                              },
                                              child: Text(
                                                languages[choosenLanguage]
                                                    ['text_ok'],
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        media.width * twenty,
                                                    color: buttonColor),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : (state == '2')
                                      ? Container(
                                          height: media.height * 1,
                                          width: media.width * 1,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: media.height * 0.31,
                                                child: Image.asset(
                                                  'assets/images/allow_location_permission.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_trustedtaxi'],
                                                style: GoogleFonts.roboto(
                                                    fontSize:
                                                        media.width * eighteen,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.025,
                                              ),
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_allowpermission1'],
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * fourteen,
                                                ),
                                              ),
                                              Text(
                                                languages[choosenLanguage]
                                                    ['text_allowpermission2'],
                                                style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * fourteen,
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.05,
                                              ),
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    media.width * 0.05,
                                                    0,
                                                    media.width * 0.05,
                                                    0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.075,
                                                        child: const Icon(Icons
                                                            .location_on_outlined)),
                                                    SizedBox(
                                                      width:
                                                          media.width * 0.025,
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.8,
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_loc_permission'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.width * 0.02,
                                              ),
                                              Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    media.width * 0.05,
                                                    0,
                                                    media.width * 0.05,
                                                    0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.075,
                                                        child: const Icon(Icons
                                                            .location_on_outlined)),
                                                    SizedBox(
                                                      width:
                                                          media.width * 0.025,
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.8,
                                                      child: Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_background_permission'],
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  child: Button(
                                                      onTap: () async {
                                                        if (serviceEnabled ==
                                                            false) {
                                                          await location
                                                              .requestService();
                                                        }
                                                        if (permission ==
                                                                PermissionStatus
                                                                    .denied ||
                                                            permission ==
                                                                PermissionStatus
                                                                    .deniedForever) {
                                                          await [perm.Permission.location, perm.Permission.locationAlways].request();
                                                        }
                                                        setState(() {
                                                          _isLoading = true;
                                                        });
                                                        getLocs();
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_allow']))
                                            ],
                                          ),
                                        )
                                      : (state == '3')
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  
                                                    height: media.height * 1,
                                                    width: media.width * 1,
                                                    //google maps
                                                    child: GoogleMap(
                                                      onMapCreated:
                                                          _onMapCreated,
                                                      initialCameraPosition:
                                                          CameraPosition(
                                                        target: center,
                                                        zoom: 11.0,
                                                      ),
                                                      markers: Set<Marker>.from(
                                                          myMarkers),
                                                      polylines: polyline,
                                                      
                                                      minMaxZoomPreference:
                                                          const MinMaxZoomPreference(
                                                              0.0, 20.0),
                                                      myLocationButtonEnabled:
                                                          false,
                                                      compassEnabled: false,

                                                      buildingsEnabled: false,
                                                      zoomControlsEnabled:
                                                          false,
                                                    )),

                                                //driver status
                                                Positioned(
                                                    top: MediaQuery.of(context)
                                                            .padding
                                                            .top +
                                                        25,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.05,
                                                              media.width *
                                                                  0.025,
                                                              media.width *
                                                                  0.05,
                                                              media.width *
                                                                  0.025),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                blurRadius: 2,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 2)
                                                          ],
                                                          color: page),
                                                      //driver status display
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 10,
                                                            width: 10,
                                                            decoration:
                                                                BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                          blurRadius:
                                                                              2,
                                                                          color: Colors.black.withOpacity(
                                                                              0.2),
                                                                          spreadRadius:
                                                                              2)
                                                                    ],
                                                                    color: (driverReq
                                                                            .isEmpty)
                                                                        ? (userDetails['active'] ==
                                                                                false)
                                                                            ? const Color(
                                                                                0xff666666)
                                                                            : const Color(
                                                                                0xff319900)
                                                                        : (driverReq['accepted_at'] != null &&
                                                                                driverReq['arrived_at'] == null)
                                                                            ? const Color(0xff2E67D5)
                                                                            : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 0)
                                                                                ? const Color(0xff319900)
                                                                                : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] != null)
                                                                                    ? const Color(0xffFF0000)
                                                                                    : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                        ? const Color(0xff666666)
                                                                                        : const Color(0xff319900)),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.02,
                                                          ),
                                                          Text(
                                                            (driverReq.isEmpty)
                                                                ? (userDetails['active'] ==
                                                                        false)
                                                                    ? languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_youareoffline']
                                                                    : languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_youareonline']
                                                                : (driverReq[
                                                                                'accepted_at'] !=
                                                                            null &&
                                                                        driverReq['arrived_at'] ==
                                                                            null)
                                                                    ? languages[
                                                                            choosenLanguage]
                                                                        [
                                                                        'text_arriving']
                                                                    : (driverReq['accepted_at'] != null &&
                                                                            driverReq['arrived_at'] !=
                                                                                null &&
                                                                            driverReq['is_trip_start'] ==
                                                                                0)
                                                                        ? languages[choosenLanguage]
                                                                            [
                                                                            'text_arrived']
                                                                        : (driverReq['accepted_at'] != null &&
                                                                                driverReq['arrived_at'] != null &&
                                                                                driverReq['is_trip_start'] != null)
                                                                            ? languages[choosenLanguage]['text_onride']
                                                                            : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                ? languages[choosenLanguage]['text_youareoffline']
                                                                                : languages[choosenLanguage]['text_youareonline'],
                                                            style: GoogleFonts.roboto(
                                                                fontSize: media.width * twelve,
                                                                color: (driverReq.isEmpty)
                                                                    ? (userDetails['active'] == false)
                                                                        ? const Color(0xff666666)
                                                                        : const Color(0xff319900)
                                                                    : (driverReq['accepted_at'] != null && driverReq['arrived_at'] == null)
                                                                        ? const Color(0xff2E67D5)
                                                                        : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 0)
                                                                            ? const Color(0xff319900)
                                                                            : (driverReq['accepted_at'] != null && driverReq['arrived_at'] != null && driverReq['is_trip_start'] == 1)
                                                                                ? const Color(0xffFF0000)
                                                                                : (driverReq['accepted'] == null && userDetails['active'] == false)
                                                                                    ? const Color(0xff666666)
                                                                                    : const Color(0xff319900)),
                                                          )
                                                        ],
                                                      ),
                                                    )),
                                                //menu bar
                                                Positioned(
                                                    top: MediaQuery.of(context)
                                                            .padding
                                                            .top +
                                                        12.5,
                                                    child: SizedBox(
                                                      width: media.width * 0.9,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.1,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      blurRadius:
                                                                          2,
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          2)
                                                                ],
                                                                color: page,
                                                                borderRadius: BorderRadius
                                                                    .circular(media
                                                                            .width *
                                                                        0.02)),
                                                            child: StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    Scaffold.of(
                                                                            context)
                                                                        .openDrawer();
                                                                  },
                                                                  child: const Icon(
                                                                      Icons
                                                                          .menu));
                                                            }),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                //online or offline button
                                                (userDetails['low_balance'] ==
                                                        false)
                                                    ? Positioned(
                                                        bottom: 25,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            setState(() {
                                                              _isLoading = true;
                                                            });
                                                            
                                                                await driverStatus();
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.only(
                                                                left: media
                                                                        .width *
                                                                    0.01,
                                                                right: media
                                                                        .width *
                                                                    0.01),
                                                            height:
                                                                media.width *
                                                                    0.08,
                                                            width: media.width *
                                                                0.267,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      media.width *
                                                                          0.04),
                                                              color: (userDetails[
                                                                          'active'] ==
                                                                      false)
                                                                  ? offline
                                                                  : online,
                                                            ),
                                                            child: (userDetails[
                                                                        'active'] ==
                                                                    false)
                                                                ? Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Container(),
                                                                      Text(
                                                                        'OFF DUTY',
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize: media.width *
                                                                                twelve,
                                                                            color:
                                                                                onlineOfflineText),
                                                                      ),
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.all(media.width *
                                                                                0.01),
                                                                        height: media.width *
                                                                            0.07,
                                                                        width: media.width *
                                                                            0.07,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: onlineOfflineText),
                                                                        child: Image.asset(
                                                                            'assets/images/offline.png'),
                                                                      )
                                                                    ],
                                                                  )
                                                                : Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.all(media.width *
                                                                                0.01),
                                                                        height: media.width *
                                                                            0.07,
                                                                        width: media.width *
                                                                            0.07,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: onlineOfflineText),
                                                                        child: Image.asset(
                                                                            'assets/images/online.png'),
                                                                      ),
                                                                      Text(
                                                                        'ON DUTY',
                                                                        style: GoogleFonts.roboto(
                                                                            fontSize: media.width *
                                                                                twelve,
                                                                            color:
                                                                                onlineOfflineText),
                                                                      ),
                                                                      Container(),
                                                                    ],
                                                                  ),
                                                          ),
                                                        ))
                                                    : (userDetails.isNotEmpty && userDetails['low_balance'] ==
                                                        true) ?
                                                    //low balance
                                                    Positioned(
                                                        bottom: 0,
                                                        child: Container(
                                                          color: buttonColor,
                                                          width:
                                                              media.width * 1,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.05),
                                                          child: Text(
                                                            languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_low_balance'],
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ) : Container(),

                                                //request popup accept or reject
                                                Positioned(
                                                    bottom: 20,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        (driverReq.isNotEmpty &&
                                                                driverReq[
                                                                        'is_trip_start'] ==
                                                                    1)
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    showSos =
                                                                        true;
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: media
                                                                          .width *
                                                                      0.1,
                                                                  width: media
                                                                          .width *
                                                                      0.1,
                                                                  decoration: BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            blurRadius:
                                                                                2,
                                                                            color:
                                                                                Colors.black.withOpacity(0.2),
                                                                            spreadRadius: 2)
                                                                      ],
                                                                      color:
                                                                          buttonColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(media.width *
                                                                              0.02)),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    'SOS',
                                                                    style: GoogleFonts.roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                fourteen,
                                                                        color:
                                                                            page),
                                                                  ),
                                                                ))
                                                            : Container(),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        (driverReq.isNotEmpty &&
                                                                driverReq[
                                                                        'accepted_at'] !=
                                                                    null)
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  (driverReq['is_trip_start'] ==
                                                                          1)
                                                                      ? openMap(
                                                                          driverReq[
                                                                              'drop_lat'],
                                                                          driverReq[
                                                                              'drop_lng'])
                                                                      : openMap(
                                                                          driverReq[
                                                                              'pick_lat'],
                                                                          driverReq[
                                                                              'pick_lng']);
                                                                },
                                                                child:
                                                                    Container(
                                                                        height: media.width *
                                                                            0.1,
                                                                        width: media.width *
                                                                            0.1,
                                                                        decoration: BoxDecoration(
                                                                            boxShadow: [
                                                                              BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2)
                                                                            ],
                                                                            color:
                                                                                page,
                                                                            borderRadius: BorderRadius.circular(media.width *
                                                                                0.02)),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child: Image.asset(
                                                                            'assets/images/locationFind.png',
                                                                            width: media.width *
                                                                                0.06,
                                                                            color:
                                                                                Colors.black
                                                                            
                                                                            )),
                                                              )
                                                            : Container(),
                                                        const SizedBox(
                                                            height: 20),
                                                        //animate to current location button
                                                        InkWell(
                                                          onTap: () async {
                                                            _controller?.animateCamera(
                                                                CameraUpdate
                                                                    .newLatLngZoom(
                                                                        center,
                                                                        18.0));
                                                          },
                                                          child: Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.1,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      blurRadius:
                                                                          2,
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.2),
                                                                      spreadRadius:
                                                                          2)
                                                                ],
                                                                color: page,
                                                                borderRadius: BorderRadius
                                                                    .circular(media
                                                                            .width *
                                                                        0.02)),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                                Icons
                                                                    .my_location_sharp,
                                                                size: media
                                                                        .width *
                                                                    0.06),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.25),
                                                        (driverReq.isNotEmpty)
                                                            ? (driverReq['accepted_at'] ==
                                                                    null)
                                                                ? Column(
                                                                  children: [
                                                                    (driverReq['is_later'] == 1) ?
                                                                    Container(
                                                                      alignment:Alignment.center,
                                                                      margin: EdgeInsets.only(bottom: media.width*0.025),
                                                                      padding: EdgeInsets.all(media.width*0.025),
                                                                      decoration:BoxDecoration(
                                                                        color: buttonColor,
                                                                        borderRadius: BorderRadius.circular(6)
                                                                      ),
                                                                      width: media.width*0.9,
                                                                      child: Text(languages[choosenLanguage]['text_rideLaterTime'] + " " + driverReq['cv_trip_start_time'],
                                                                      style: GoogleFonts.roboto(
                                                                        fontSize: media.width*sixteen,
                                                                        color: Colors.white
                                                                      ),
                                                                      ),
                                                                    ) : Container(),
                                                                    Container(
                                                                        padding:
                                                                           const  EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                        width: media
                                                                                .width *
                                                                            0.9,
                                                                        
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            color: page,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                  blurRadius: 2,
                                                                                  color: Colors.black.withOpacity(0.2),
                                                                                  spreadRadius: 2)
                                                                            ]),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment
                                                                                  .start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment
                                                                                  .spaceBetween,
                                                                          children: [
                                                                            AnimatedContainer(
                                                                              duration:
                                                                                  const Duration(milliseconds: 100),
                                                                              height:
                                                                                  10,
                                                                              width:
                                                                                  (media.width * 0.9 / 30) * (30 - duration),
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.green,
                                                                                  borderRadius: (languageDirection == 'ltr')
                                                                                      ? BorderRadius.only(
                                                                                          topLeft: const Radius.circular(100),
                                                                                          topRight: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                                        )
                                                                                      : BorderRadius.only(
                                                                                          topRight: const Radius.circular(100),
                                                                                          topLeft: (duration <= 2.0) ? const Radius.circular(100) : const Radius.circular(0),
                                                                                        )),
                                                                            ),
                                                                            Container(
                                                                              padding: EdgeInsets.fromLTRB(
                                                                                  media.width * 0.05,
                                                                                  media.width * 0.02,
                                                                                  media.width * 0.05,
                                                                                  media.width * 0.05),
                                                                              child:
                                                                                  Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        height: media.width * 0.25,
                                                                                        width: media.width * 0.25,
                                                                                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                                      ),
                                                                                      SizedBox(width: media.width * 0.05),
                                                                                      SizedBox(
                                                                                        height: media.width * 0.2,
                                                                                        child: Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                          children: [
                                                                                            Text(
                                                                                              driverReq['userDetail']['data']['name'],
                                                                                              style: GoogleFonts.roboto(fontSize: media.width * eighteen, color: textColor),
                                                                                            ),
                                                                                            Row(
                                                                                              children: [
                                                                                                //payment image
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.06,
                                                                                                  child: (driverReq['payment_opt'] == 1)
                                                                                                      ? Image.asset(
                                                                                                          'assets/images/cash.png',
                                                                                                          fit: BoxFit.contain,
                                                                                                        )
                                                                                                      : (driverReq['payment_opt'] == 2)
                                                                                                          ? Image.asset(
                                                                                                              'assets/images/wallet.png',
                                                                                                              fit: BoxFit.contain,
                                                                                                            )
                                                                                                          : (driverReq['payment_opt'] == 0)
                                                                                                              ? Image.asset(
                                                                                                                  'assets/images/card.png',
                                                                                                                  fit: BoxFit.contain,
                                                                                                                )
                                                                                                              : Container(),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.03,
                                                                                                ),
                                                                                                Text(
                                                                                                  driverReq['payment_type_string'].toString(),
                                                                                                  style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                                ),
                                                                                                SizedBox(width: media.width * 0.03),
                                                                                                (driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null) ?
                                                                                                Text(
                                                                                                  userDetails['currency_symbol'] + driverReq['request_eta_amount'].toStringAsFixed(2),
                                                                                                  style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                                ) : Container()
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Text(
                                                                                          duration.toString().split('.')[0],
                                                                                          style: GoogleFonts.roboto(fontSize: media.width * twenty, fontWeight: FontWeight.bold),
                                                                                          textAlign: TextAlign.end,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.02,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Image.asset(
                                                                                        'assets/images/picklocation.png',
                                                                                        width: media.width * 0.075,
                                                                                      ),
                                                                                      SizedBox(width: media.width * 0.05),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            languages[choosenLanguage]['text_pickpoint'],
                                                                                            style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7)),
                                                                                          ),
                                                                                          SizedBox(height: media.width * 0.02),
                                                                                          SizedBox(
                                                                                            width: media.width * 0.6,
                                                                                           
                                                                                            child: Text(
                                                                                              driverReq['pick_address'],
                                                                                              style: GoogleFonts.roboto(
                                                                                                fontSize: media.width * twelve,
                                                                                              ),
                                                                                              maxLines: 2,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.04,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.location_on_outlined,
                                                                                        size: media.width * 0.075,
                                                                                        color: Colors.red,
                                                                                      ),
                                                                                      SizedBox(width: media.width * 0.05),
                                                                                      Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                          SizedBox(
                                                                                            height: media.width * 0.02,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: media.width * 0.6,
                                                                                            height: media.width * 0.1,
                                                                                            child: Text(
                                                                                              driverReq['drop_address'],
                                                                                              style: GoogleFonts.roboto(
                                                                                                fontSize: media.width * twelve,
                                                                                              ),
                                                                                              maxLines: 2,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.04,
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Button(
                                                                                          borcolor: buttonColor,
                                                                                          textcolor: buttonColor,
                                                                                          width: media.width * 0.38,
                                                                                          color: page,
                                                                                          onTap: () async {
                                                                                            setState(() {
                                                                                              _isLoading = true;
                                                                                            });
                                                                                            //reject request
                                                                                            await requestReject();
                                                                                            setState(() {
                                                                                              _isLoading = false;
                                                                                            });
                                                                                          },
                                                                                          text: languages[choosenLanguage]['text_decline']),
                                                                                      Button(
                                                                                        onTap: () async {
                                                                                          setState(() {
                                                                                            _isLoading = true;
                                                                                          });
                                                                                          await requestAccept();
                                                                                          setState(() {
                                                                                            _isLoading = false;
                                                                                          });
                                                                                        },
                                                                                        text: languages[choosenLanguage]['text_accept'],
                                                                                        width: media.width * 0.38,
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ],
                                                                )
                                                                : (driverReq[
                                                                            'accepted_at'] !=
                                                                        null)
                                                                    ? SizedBox(
                                                                        width: media.width *
                                                                            0.9,
                                                                        height: media.width *
                                                                            0.7,
                                                                      )
                                                                    : Container(
                                                                        width: media.width *
                                                                            0.9)
                                                            : Container(
                                                                width: media
                                                                        .width *
                                                                    0.9,
                                                              ),
                                                      ],
                                                    )),

                                                //on ride bottom sheet
                                                (driverReq['accepted_at'] !=
                                                        null)
                                                    ? Positioned(
                                                        bottom: 0,
                                                        child: GestureDetector(
                                                          onPanUpdate: (val) {
                                                            if (val.delta.dy >
                                                                0) {
                                                              setState(() {
                                                                _bottom = 0;
                                                              });
                                                            }
                                                            if (val.delta.dy <
                                                                0) {
                                                              setState(() {
                                                                _bottom = 1;
                                                              });
                                                            }
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.05),
                                                            width:
                                                                media.width * 1,
                                                            decoration: BoxDecoration(
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10)),
                                                                color: page),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.02,
                                                                  width: media
                                                                          .width *
                                                                      0.2,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(media.width *
                                                                            0.01),
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: media
                                                                          .width *
                                                                      0.025,
                                                                ),
                                                                Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                media.width * 0.25,
                                                                            width:
                                                                                media.width * 0.25,
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.red,
                                                                                shape: BoxShape.circle,
                                                                                image: DecorationImage(image: NetworkImage(driverReq['userDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                          ),
                                                                          SizedBox(
                                                                              width: media.width * 0.05),
                                                                          SizedBox(
                                                                            width:
                                                                                media.width * 0.3,
                                                                            height:
                                                                                media.width * 0.2,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                SizedBox(
                                                                                  width:
                                                                                media.width * 0.3,
                                                                                  child: Text(
                                                                                    driverReq['userDetail']['data']['name'],
                                                                                    style: GoogleFonts.roboto(fontSize: media.width * eighteen, color: textColor),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Icon(
                                                                                      Icons.star,
                                                                                      color: buttonColor,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: media.width * 0.01,
                                                                                    ),
                                                                                    Text(
                                                                                      driverReq['userDetail']['data']['rating'].toString(),
                                                                                      style: GoogleFonts.roboto(fontSize: media.width * sixteen, color: textColor),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                (driverReq['accepted_at'] == null && driverReq['show_request_eta_amount'] == true && driverReq['request_eta_amount'] != null )
                                                                                    ? Text(
                                                                                        userDetails['currency_symbol'] + driverReq['request_eta_amount'].toString(),
                                                                                        style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                      )
                                                                                    : (driverReq['is_driver_arrived'] == 1 && waitingTime != null) ? 
                                                                                    (waitingTime/60 >= 1) ?
                                                                                    Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(width: media.width*0.25,
                                                                                            alignment:Alignment.center,
                                                                                              child: Text(
                                                                                                  languages[choosenLanguage]['text_waiting_time'],
                                                                                                  style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: buttonColor),
                                                                                                ),
                                                                                            ),
                                                                                            SizedBox(width: media.width*0.01,),
                                                                                                InkWell(
                                                                                                  onTap: (){
                                                                                                    setState(() {
                                                                                                      _showWaitingInfo = true;
                                                                                                    });
                                                                                                  },
                                                                                                  child: Icon(Icons.info_outline,
                                                                                                  size: media.width*0.04,),
                                                                                                )
                                                                                          ],
                                                                                        ),
                                                                                          SizedBox(height: media.width*0.02,),
                                                                                           Container(
                                                                                             width: media.width*0.3,
                                                                                        alignment:Alignment.center,
                                                                                             child: Text(
                                                                                           (waitingTime/60).toInt().toString() + ' mins',
                                                                                              style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor),
                                                                                          ),
                                                                                           ),
                                                                                      ],
                                                                                    )
                                                                                    : Container() : Container(),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: media.width *
                                                                            0.05,
                                                                      ),
                                                                      (_bottom !=
                                                                              0)
                                                                          ? AnimatedContainer(
                                                                              duration: const Duration(milliseconds: 200),
                                                                              height: media.height * 0.4,
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  children: [
                                                                                    Container(
                                                                                      padding: EdgeInsets.all(media.width * 0.05),
                                                                                      decoration: BoxDecoration(boxShadow: [
                                                                                        BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.2), spreadRadius: 2),
                                                                                      ], color: page, borderRadius: BorderRadius.circular(10)),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Image.asset(
                                                                                            'assets/images/picklocation.png',
                                                                                            width: media.width * 0.075,
                                                                                          ),
                                                                                          SizedBox(width: media.width * 0.05),
                                                                                          Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                languages[choosenLanguage]['text_pickpoint'],
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7)),
                                                                                              ),
                                                                                              SizedBox(height: media.width * 0.02),
                                                                                              SizedBox(
                                                                                                width: media.width * 0.6,
                                                                                                child: Text(
                                                                                                  driverReq['pick_address'],
                                                                                                  style: GoogleFonts.roboto(
                                                                                                    fontSize: media.width * twelve,
                                                                                                  ),
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: media.width * 0.05),
                                                                                    Container(
                                                                                      padding: EdgeInsets.all(media.width * 0.05),
                                                                                      decoration: BoxDecoration(boxShadow: [
                                                                                        BoxShadow(blurRadius: 2, color: Colors.black.withOpacity(0.2), spreadRadius: 2),
                                                                                      ], color: page, borderRadius: BorderRadius.circular(10)),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Icon(Icons.location_on_outlined, color: Colors.red, size: media.width * 0.075),
                                                                                          SizedBox(width: media.width * 0.05),
                                                                                          Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                              SizedBox(
                                                                                                height: media.width * 0.02,
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: media.width * 0.6,
                                                                                                height: media.width * 0.1,
                                                                                                child: Text(
                                                                                                  driverReq['drop_address'],
                                                                                                  style: GoogleFonts.roboto(
                                                                                                    fontSize: media.width * twelve,
                                                                                                  ),
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                    ]),
                                                                (driverReq['is_trip_start'] ==
                                                                        0)
                                                                    ? Column(
                                                                        children: [
                                                                          (_bottom == 0)
                                                                              ? Row(
                                                                                  children: [
                                                                                    Icon(Icons.location_on_outlined, color: Colors.red, size: media.width * 0.075),
                                                                                    SizedBox(width: media.width * 0.05),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(languages[choosenLanguage]['text_pickpoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                        SizedBox(
                                                                                          height: media.width * 0.02,
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: media.width * 0.6,
                                                                                          height: media.width * 0.05,
                                                                                          child: Text(
                                                                                            driverReq['pick_address'],
                                                                                            style: GoogleFonts.roboto(
                                                                                              fontSize: media.width * twelve,
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: media.width * 0.02,
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              : Container(),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  InkWell(
                                                                                      onTap: () {
                                                                                        makingPhoneCall(driverReq['userDetail']['data']['mobile']);
                                                                                      },
                                                                                      child: Image.asset(
                                                                                        'assets/images/Call.png',
                                                                                        width: media.width * 0.06,
                                                                                      )),
                                                                                  Text(
                                                                                    languages[choosenLanguage]['text_call'],
                                                                                    style: GoogleFonts.roboto(
                                                                                      fontSize: media.width * twelve,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                              (driverReq['if_dispatch'] == true) ? Container() :
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
                                                                                },
                                                                                child: Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Image.asset(
                                                                                          'assets/images/message-square.png',
                                                                                          width: media.width * 0.06,
                                                                                        ),
                                                                                        (chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).isNotEmpty)
                                                                                            ? Text(
                                                                                                chatList.where((element) => element['from_type'] == 1 && element['seen'] == 0).length.toString(),
                                                                                                style: GoogleFonts.roboto(fontSize: media.width * twelve, color: const Color(0xffFF0000)),
                                                                                              )
                                                                                            : Container()
                                                                                      ],
                                                                                    ),
                                                                                    Text(
                                                                                      languages[choosenLanguage]['text_chat'],
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: media.width * twelve,
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () async {
                                                                                      setState(() {
                                                                                        _isLoading = true;
                                                                                      });
                                                                                      var val = await cancelReason((driverReq['is_driver_arrived'] == 0) ? 'before' : 'after');
                                                                                      if (val == true) {
                                                                                        setState(() {
                                                                                          cancelRequest = true;
                                                                                        });
                                                                                      }
                                                                                      setState(() {
                                                                                        _isLoading = false;
                                                                                      });
                                                                                    },
                                                                                    child: Image.asset(
                                                                                      'assets/images/cancel.png',
                                                                                      width: media.width * 0.06,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    languages[choosenLanguage]['text_cancel'],
                                                                                    style: GoogleFonts.roboto(
                                                                                      fontSize: media.width * twelve,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : (_bottom ==
                                                                                0 &&
                                                                            driverReq['is_trip_start'] ==
                                                                                1)
                                                                        ? Row(
                                                                            children: [
                                                                              Icon(Icons.location_on_outlined, color: Colors.red, size: media.width * 0.075),
                                                                              SizedBox(width: media.width * 0.05),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(languages[choosenLanguage]['text_droppoint'], style: GoogleFonts.roboto(fontSize: media.width * twelve, color: textColor.withOpacity(0.7))),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.02,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: media.width * 0.6,
                                                                                    height: media.width * 0.05,
                                                                                    child: Text(
                                                                                      driverReq['drop_address'],
                                                                                      style: GoogleFonts.roboto(
                                                                                        fontSize: media.width * twelve,
                                                                                      ),
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          )
                                                                        : Container(),
                                                                SizedBox(
                                                                  height: media
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                Button(
                                                                    onTap:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        _isLoading =
                                                                            true;
                                                                      });
                                                                      if ((driverReq[
                                                                              'is_driver_arrived'] ==
                                                                          0)) {
                                                                        await driverArrived();
                                                                      } else if (driverReq['is_driver_arrived'] ==
                                                                              1 &&
                                                                          driverReq['is_trip_start'] ==
                                                                              0) {
                                                                        if (driverReq['show_otp_feature'] ==
                                                                            true) {
                                                                          setState(
                                                                              () {
                                                                            getStartOtp =
                                                                                true;
                                                                          });
                                                                        } else {
                                                                          await tripStartDispatcher();
                                                                        }
                                                                      } else {
                                                                        driverOtp = '';
                                                                        await endTrip();
                                                                      }

                                                                      _isLoading =
                                                                          false;
                                                                    },
                                                                    text: (driverReq['is_driver_arrived'] ==
                                                                            0)
                                                                        ? languages[choosenLanguage]
                                                                            [
                                                                            'text_arrived']
                                                                        : (driverReq['is_driver_arrived'] == 1 &&
                                                                                driverReq['is_trip_start'] == 0)
                                                                            ? languages[choosenLanguage]['text_startride']
                                                                            : languages[choosenLanguage]['text_endtrip'])
                                                              ],
                                                            ),
                                                          ),
                                                        ))
                                                    : Container(),
                                                //user cancelled request popup
                                                (_reqCancelled == true)
                                                    ? Positioned(
                                                        bottom:
                                                            media.height * 0.5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.05),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: page,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    blurRadius:
                                                                        2,
                                                                    spreadRadius:
                                                                        2)
                                                              ]),
                                                          child:Text(
                                                              languages[choosenLanguage]['text_user_cancelled_request']),
                                                        ))
                                                    : Container(),

                                              
                                              ],
                                            )
                                          : Container(),
                            ]),
                      ),
                      (_locationDenied == true) ?
                      Positioned(child: Container(
                        height: media.height*1,
                        width: media.width*1,
                        color: Colors.transparent.withOpacity(0.6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(media.width*0.05),
                              width: media.width*0.9,
                              decoration:BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: page,
                                boxShadow: [BoxShadow(blurRadius: 2.0,spreadRadius: 2.0,color: Colors.black.withOpacity(0.2))]
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: media.width*0.8,
                                    child: Text(languages[choosenLanguage]['text_open_loc_settings'],
                                    style: GoogleFonts.roboto(
                                      fontSize:media.width*sixteen,
                                      color: textColor,
                                      fontWeight:FontWeight.w600
                                    ),
                                    )),
                                    SizedBox(height:media.width*0.05),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: ()async{
                                            await perm.openAppSettings();
                                            
                                            
                                          },
                                          child: Text(languages[choosenLanguage]['text_open_settings'],
                                          style: GoogleFonts.roboto(
                                      fontSize:media.width*sixteen,
                                      color: buttonColor,
                                      fontWeight:FontWeight.w600
                                    ),
                                          )),
                                        InkWell(
                                          onTap: ()async{
                                            setState(() {
                                              _locationDenied = false;
                                              _isLoading = true;
                                            });
                                            
                                            getLocs();
                                          },
                                          child: Text(languages[choosenLanguage]['text_done'],
                                          style: GoogleFonts.roboto(
                                      fontSize:media.width*sixteen,
                                      color: buttonColor,
                                      fontWeight:FontWeight.w600
                                    ),
                                          ))
                                      ],
                                    )
                                ],
                              ),
                            )
                          ],
                        ),
                      )) : Container(),
                      //enter otp
                      (getStartOtp == true && driverReq.isNotEmpty)
                          ? Positioned(
                              top: 0,
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: media.width * 0.8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                getStartOtp = false;
                                              });
                                            },
                                            child: Container(
                                              height: media.height * 0.05,
                                              width: media.height * 0.05,
                                              decoration: BoxDecoration(
                                                color: page,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.cancel,
                                                  color: buttonColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: media.width * 0.025),
                                    Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 0.8,
                                      height: media.width * 0.7,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: page,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 2)
                                          ]),
                                      child: Column(
                                        children: [
                                          Text(
                                            languages[choosenLanguage]
                                                ['text_driver_otp'],
                                            style: GoogleFonts.roboto(
                                                fontSize:
                                                    media.width * eighteen,
                                                fontWeight: FontWeight.bold,
                                                color: textColor),
                                          ),
                                          SizedBox(height: media.width * 0.05),
                                          Text(
                                            languages[choosenLanguage]
                                                ['text_enterdriverotp'],
                                            style: GoogleFonts.roboto(
                                              fontSize: media.width * twelve,
                                              color: textColor.withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                width: media.width * 0.12,
                                                color: page,
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    if (val.length == 1) {
                                                      setState(() {
                                                        _otp1 = val;
                                                        driverOtp = _otp1 +
                                                            _otp2 +
                                                            _otp3 +
                                                            _otp4;
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      });
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 1,
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                      counterText: '',
                                                      border: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 1.5,
                                                              style: BorderStyle
                                                                  .solid))),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: media.width * 0.12,
                                                color: page,
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    if (val.length == 1) {
                                                      setState(() {
                                                        _otp2 = val;
                                                        driverOtp = _otp1 +
                                                            _otp2 +
                                                            _otp3 +
                                                            _otp4;
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      });
                                                    } else {
                                                      setState(() {
                                                        FocusScope.of(context)
                                                            .previousFocus();
                                                      });
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 1,
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                      counterText: '',
                                                      border: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 1.5,
                                                              style: BorderStyle
                                                                  .solid))),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: media.width * 0.12,
                                                color: page,
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    if (val.length == 1) {
                                                      setState(() {
                                                        _otp3 = val;
                                                        driverOtp = _otp1 +
                                                            _otp2 +
                                                            _otp3 +
                                                            _otp4;
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      });
                                                    } else {
                                                      setState(() {
                                                        FocusScope.of(context)
                                                            .previousFocus();
                                                      });
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 1,
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                      counterText: '',
                                                      border: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 1.5,
                                                              style: BorderStyle
                                                                  .solid))),
                                                ),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: media.width * 0.12,
                                                color: page,
                                                child: TextFormField(
                                                  onChanged: (val) {
                                                    if (val.length == 1) {
                                                      setState(() {
                                                        _otp4 = val;
                                                        driverOtp = _otp1 +
                                                            _otp2 +
                                                            _otp3 +
                                                            _otp4;
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      });
                                                    } else {
                                                      setState(() {
                                                        FocusScope.of(context)
                                                            .previousFocus();
                                                      });
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLength: 1,
                                                  textAlign: TextAlign.center,
                                                  decoration: const InputDecoration(
                                                      counterText: '',
                                                      border: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  Colors.black,
                                                              width: 1.5,
                                                              style: BorderStyle
                                                                  .solid))),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: media.width * 0.04,
                                          ),
                                          (_errorOtp == true)
                                              ? Text(
                                                  'Please Enter Valid Otp',
                                                  style: GoogleFonts.roboto(
                                                      color: Colors.red,
                                                      fontSize:
                                                          media.width * twelve),
                                                )
                                              : Container(),
                                          SizedBox(height: media.width * 0.02),
                                          Button(
                                            onTap: () async {
                                              if (driverOtp.length != 4) {
                                                setState(() {});
                                              } else {
                                                setState(() {
                                                  _errorOtp = false;
                                                  _isLoading = true;
                                                });
                                                var val = await tripStart();
                                                if (val != 'success') {
                                                  setState(() {
                                                    _errorOtp = true;
                                                    _isLoading = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _isLoading = false;
                                                    getStartOtp = false;
                                                  });
                                                }
                                              }
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_confirm'],
                                            color: (driverOtp.length != 4)
                                                ? Colors.grey
                                                : buttonColor,
                                              borcolor: (driverOtp.length != 4)
                                                ? Colors.grey
                                                : buttonColor,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),

                      //popup for cancel request
                      (cancelRequest == true && driverReq.isNotEmpty)
                          ? Positioned(
                              child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 0.9,
                                    decoration: BoxDecoration(
                                        color: page,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Column(children: [
                                      Container(
                                        height: media.width * 0.18,
                                        width: media.width * 0.18,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xffFEF2F2)),
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: media.width * 0.14,
                                          width: media.width * 0.14,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xffFF0000)),
                                          child: const Center(
                                            child: Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: cancelReasonsList
                                            .asMap()
                                            .map((i, value) {
                                              return MapEntry(
                                                  i,
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _cancelReason =
                                                            cancelReasonsList[i]
                                                                ['reason'];
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.01),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.height *
                                                                    0.05,
                                                            width: media.width *
                                                                0.05,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black,
                                                                    width:
                                                                        1.2)),
                                                            alignment: Alignment
                                                                .center,
                                                            child: (_cancelReason ==
                                                                    cancelReasonsList[
                                                                            i][
                                                                        'reason'])
                                                                ? Container(
                                                                    height: media
                                                                            .width *
                                                                        0.03,
                                                                    width: media
                                                                            .width *
                                                                        0.03,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.05,
                                                          ),
                                                          SizedBox(
                                                            width: media.width*0.65,
                                                            child: Text(
                                                                cancelReasonsList[
                                                                    i]['reason'],
                                                                    
                                                                    ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ));
                                            })
                                            .values
                                            .toList(),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _cancelReason = 'others';
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              media.width * 0.01),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: media.height * 0.05,
                                                width: media.width * 0.05,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.black,
                                                        width: 1.2)),
                                                alignment: Alignment.center,
                                                child: (_cancelReason ==
                                                        'others')
                                                    ? Container(
                                                        height:
                                                            media.width * 0.03,
                                                        width:
                                                            media.width * 0.03,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    : Container(),
                                              ),
                                              SizedBox(
                                                width: media.width * 0.05,
                                              ),
                                              Text(languages[choosenLanguage]
                                                  ['text_others'])
                                            ],
                                          ),
                                        ),
                                      ),
                                      (_cancelReason == 'others')
                                          ? Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0,
                                                  media.width * 0.025,
                                                  0,
                                                  media.width * 0.025),
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              
                                              width: media.width * 0.9,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: languages[
                                                            choosenLanguage][
                                                        'text_cancelRideReason'],
                                                    hintStyle:
                                                        GoogleFonts.roboto(
                                                            fontSize:
                                                                media.width *
                                                                    twelve)),
                                                maxLines: 4,
                                                minLines: 2,
                                                onChanged: (val) {
                                                  setState(() {
                                                    cancelReasonText = val;
                                                  });
                                                },
                                              ),
                                            )
                                          : Container(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Button(
                                              color: page,
                                              textcolor: buttonColor,
                                              width: media.width * 0.39,
                                              onTap: () async {
                                                client.disconnect();
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                if (_cancelReason != '') {
                                                  if (_cancelReason ==
                                                      'others') {
                                                    await cancelRequestDriver(
                                                        cancelReasonText);
                                                    setState(() {
                                                      cancelRequest = false;
                                                    });
                                                  } else {
                                                    await cancelRequestDriver(
                                                        _cancelReason);
                                                    setState(() {
                                                      cancelRequest = false;
                                                    });
                                                  }
                                                }
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_cancel']),
                                          Button(
                                              width: media.width * 0.39,
                                              onTap: () {
                                                setState(() {
                                                  cancelRequest = false;
                                                });
                                              },
                                              text: languages[choosenLanguage]
                                                  ['tex_dontcancel'])
                                        ],
                                      )
                                    ]),
                                  ),
                                ],
                              ),
                            ))
                          : Container(),

                      //loader
                      (state == '')
                          ? const Positioned(top: 0, child: Loading())
                          : Container(),

                      //logout popup
                      (logout == true)
                          ? Positioned(
                              top: 0,
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: media.width * 0.9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              height: media.height * 0.1,
                                              width: media.width * 0.1,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: page),
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      logout = false;
                                                    });
                                                  },
                                                  child: const Icon(Icons
                                                      .cancel_outlined))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: page),
                                      child: Column(
                                        children: [
                                          Text(
                                            languages[choosenLanguage]
                                                ['text_confirmlogout'],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                                fontSize: media.width * sixteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Button(
                                              onTap: () async {
                                                setState(() {
                                                  logout = false;
                                                 
                                                });
                                                var result = await userLogout();
                                                if (result == 'success') {
                                                  setState(() {
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Login()),
                                                        (route) => false);
                                                    userDetails.clear();
                                                  });
                                                } else {
                                                  setState(() {
                                                    
                                                    logout = true;
                                                  });
                                                }
                                                
                                              
                                              },
                                              text: languages[choosenLanguage]
                                                  ['text_confirm'])
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ))
                          : Container(),

                           //waiting time popup
                      (_showWaitingInfo == true)
                          ? Positioned(
                              top: 0,
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: media.width * 0.9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              height: media.height * 0.1,
                                              width: media.width * 0.1,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: page),
                                              child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _showWaitingInfo = false;
                                                    });
                                                  },
                                                  child: const Icon(Icons
                                                      .cancel_outlined))),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: page),
                                      child: Column(
                                        children: [
                                          Text(
                                            languages[choosenLanguage]['text_waiting_time_1'],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                                fontSize: media.width * sixteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(languages[choosenLanguage]['text_waiting_time_2'],style: GoogleFonts.roboto(
                                                fontSize: media.width * fourteen,
                                                color: textColor) ),
                                              Text(driverReq['free_waiting_time_in_mins_before_trip_start'].toString() + ' mins',style: GoogleFonts.roboto(
                                                fontSize: media.width * fourteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                          SizedBox(height: media.width*0.05,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(languages[choosenLanguage]['text_waiting_time_3'],style: GoogleFonts.roboto(
                                                fontSize: media.width * fourteen,
                                                color: textColor) ),
                                              Text(driverReq['free_waiting_time_in_mins_after_trip_start'].toString()  + ' mins',
                                              style: GoogleFonts.roboto(
                                                fontSize: media.width * fourteen,
                                                color: textColor,
                                                fontWeight: FontWeight.w600)
                                              ),
                                            ],
                                          ),

                                        ],
                                      ),
                                    )
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
                                    getUserDetails();
                                  });
                                },
                              ))
                          : Container(),

                      //sos popup
                      (showSos == true)
                          ? Positioned(
                              top: 0,
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.6),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: media.width * 0.7,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  notifyCompleted = false;
                                                  showSos = false;
                                                });
                                              },
                                              child: Container(
                                                height: media.width * 0.1,
                                                width: media.width * 0.1,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: page),
                                                child: const Icon(
                                                    Icons.cancel_outlined),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.all(media.width * 0.05),
                                        height: media.height * 0.5,
                                        width: media.width * 0.7,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: page),
                                        child: SingleChildScrollView(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      notifyCompleted = false;
                                                    });
                                                    var val =
                                                        await notifyAdmin();
                                                    if (val == true) {
                                                      setState(() {
                                                        notifyCompleted = true;
                                                      });
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        media.width * 0.05),
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
                                                                  'text_notifyadmin'],
                                                              style: GoogleFonts.roboto(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            (notifyCompleted ==
                                                                    true)
                                                                ? Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: media.width *
                                                                            0.01),
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_notifysuccess'],
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontSize:
                                                                            media.width *
                                                                                twelve,
                                                                        color: const Color(
                                                                            0xff319900),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                        const Icon(Icons
                                                            .notification_add)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                (sosData.isNotEmpty)
                                                    ? Column(
                                                        children: sosData
                                                            .asMap()
                                                            .map((i, value) {
                                                              return MapEntry(
                                                                  i,
                                                                  InkWell(
                                                                    onTap: () {
                                                                      makingPhoneCall(sosData[i]
                                                                              [
                                                                              'number']
                                                                          .toString()
                                                                          .replaceAll(
                                                                              ' ',
                                                                              ''));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      padding: EdgeInsets.all(
                                                                          media.width *
                                                                              0.05),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                width: media.width * 0.4,
                                                                                child: Text(
                                                                                  sosData[i]['name'],
                                                                                  style: GoogleFonts.roboto(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                height: media.width * 0.01,
                                                                              ),
                                                                              Text(
                                                                                sosData[i]['number'],
                                                                                style: GoogleFonts.roboto(
                                                                                  fontSize: media.width * twelve,
                                                                                  color: textColor,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          const Icon(
                                                                              Icons.call)
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ));
                                                            })
                                                            .values
                                                            .toList(),
                                                      )
                                                    : Container(
                                                        width:
                                                            media.width * 0.7,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_noDataFound'],
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  media.width *
                                                                      eighteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor),
                                                        ),
                                                      )
                                              ],
                                            )),
                                      )
                                    ]),
                              ))
                          : Container(),

                      //loader
                      (_isLoading == true)
                          ? const Positioned(top: 0, child: Loading())
                          : Container(),
                      //pickup marker
                      Positioned(
                        top: media.height * 1.5,
                        left: 100,
                        child: RepaintBoundary(
                            key: iconKey,
                            child: Column(
                              children: [
                                Container(
                                  width: media.width * 0.5,
                                  height: media.width * 0.12,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: page),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: media.width * 0.12,
                                        width: media.width * 0.12,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                (languageDirection == 'ltr')
                                                    ? const BorderRadius.only(
                                                        topLeft:
                                                            Radius
                                                                .circular(10),
                                                        bottomLeft:
                                                            Radius
                                                                .circular(10))
                                                    : const BorderRadius.only(
                                                        topRight: Radius
                                                            .circular(10),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10)),
                                            color: const Color(0xff222222)),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.star,
                                          color: Color(0xff319900),
                                        ),
                                      ),
                                      Expanded(
                                          child: Container(
                                        padding: EdgeInsets.only(
                                            left: media.width * 0.02,
                                            right: media.width * 0.02),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              languages[choosenLanguage]
                                                  ['text_pickpoint'],
                                              style: GoogleFonts.roboto(
                                                  fontSize:
                                                      media.width * twelve,
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                            (driverReq.isNotEmpty &&
                                                    driverReq[
                                                            'pick_address'] !=
                                                        null)
                                                ? Text(
                                                    driverReq['pick_address'],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.fade,
                                                    softWrap: false,
                                                    style: GoogleFonts.roboto(
                                                        fontSize:
                                                            media.width *
                                                                twelve),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/userloc.png'),
                                          fit: BoxFit.contain)),
                                  height: media.width * 0.05,
                                  width: media.width * 0.05,
                                )
                              ],
                            )),
                      ),

                      //drop marker
                      Positioned(
                        top: media.height * 2.5,
                        left: 100,
                        child: markerDropWidget,
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
