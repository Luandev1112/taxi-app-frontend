import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geolocs;
import 'package:tagyourtaxi_driver/pages/NavigatorPages/editprofile.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/history.dart';
import 'package:tagyourtaxi_driver/pages/NavigatorPages/makecomplaint.dart';
import 'package:tagyourtaxi_driver/pages/login/get_started.dart';
import 'package:tagyourtaxi_driver/pages/login/login.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/map_page.dart';
import 'package:tagyourtaxi_driver/pages/onTripPage/review_page.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/referral_code.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/service_area.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/upload_docs.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_color.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_make.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_model.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_number.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_type.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tagyourtaxi_driver/pages/vehicleInformations/vehicle_year.dart';
import '../pages/vehicleInformations/upload_docs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'geohash.dart';
import 'package:url_launcher/url_launcher.dart';

//languages code
dynamic phcode;
dynamic platform;
dynamic fcm;
dynamic pref;
String isActive = '';
double duration = 0.0;
AudioCache audioPlayer = AudioCache();
AudioPlayer audioPlayers = AudioPlayer();
String audio = 'audio/notification_sound.mp3';
bool internet = true;

//base url
String url = 'base url';
String mqttUrl = 'mqtt url';
int mqttPort = 1883;
String mapkey = 'map key';
 String mapStyle = '';

getDetailsOfDevice() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if(connectivityResult == ConnectivityResult.none){
    internet = false;
  }else{
    internet = true;
  }
  try {
    rootBundle.loadString('assets/map_style.json').then((value) {
      mapStyle = value;});
    var token = await FirebaseMessaging.instance.getToken();
    fcm = token;
    pref = await SharedPreferences.getInstance();
    
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//validate email already exist

validateEmail() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/driver/validate-mobile'),
           
            body: {'email': email});
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'success';
      } else {
        result = 'failed';
      }
    } else {
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//language code
var choosenLanguage = '';
var languageDirection = '';

List languagesCode = [
  {'name': 'Amharic', 'code': 'am'},
  {'name': 'Arabic', 'code': 'ar'},
  {'name': 'Basque', 'code': 'eu'},
  {'name': 'Bengali', 'code': 'bn'},
  {'name': 'English (UK)', 'code': 'en-GB'},
  {'name': 'Portuguese (Brazil)', 'code': 'pt-BR'},
  {'name': 'Bulgarian', 'code': 'bg'},
  {'name': 'Catalan', 'code': 'ca'},
  {'name': 'Cherokee', 'code': 'chr'},
  {'name': 'Croatian', 'code': 'hr'},
  {'name': 'Czech', 'code': 'cs'},
  {'name': 'Danish', 'code': 'da'},
  {'name': 'Dutch', 'code': 'nl'},
  {'name': 'English (US)', 'code': 'en'},
  {'name': 'Estonian', 'code': 'et'},
  {'name': 'Filipino', 'code': 'fil'},
  {'name': 'Finnish', 'code': 'fi'},
  {'name': 'French', 'code': 'fr'},
  {'name': 'German', 'code': 'de'},
  {'name': 'Greek', 'code': 'el'},
  {'name': 'Gujarati', 'code': 'gu'},
  {'name': 'Hebrew', 'code': 'iw'},
  {'name': 'Hindi', 'code': 'hi'},
  {'name': 'Hungarian', 'code': 'hu'},
  {'name': 'Icelandic', 'code': 'is'},
  {'name': 'Indonesian', 'code': 'id'},
  {'name': 'Italian', 'code': 'it'},
  {'name': 'Japanese', 'code': 'ja'},
  {'name': 'Kannada', 'code': 'kn'},
  {'name': 'Korean', 'code': 'ko'},
  {'name': 'Latvian', 'code': 'lv'},
  {'name': 'Lithuanian', 'code': 'lt'},
  {'name': 'Malay', 'code': 'ms'},
  {'name': 'Malayalam', 'code': 'ml'},
  {'name': 'Marathi', 'code': 'mr'},
  {'name': 'Norwegian', 'code': 'no'},
  {'name': 'Polish', 'code': 'pl'},
  {
    'name': 'Portuguese (Portugal)',
    'code': 'pt' //pt-PT
  },
  {'name': 'Romanian', 'code': 'ro'},
  {'name': 'Russian', 'code': 'ru'},
  {'name': 'Serbian', 'code': 'sr'},
  {
    'name': 'Chinese (PRC)',
    'code': 'zh' //zh-CN
  },
  {'name': 'Slovak', 'code': 'sk'},
  {'name': 'Slovenian', 'code': 'sl'},
  {'name': 'Spanish', 'code': 'es'},
  {'name': 'Swahili', 'code': 'sw'},
  {'name': 'Swedish', 'code': 'sv'},
  {'name': 'Tamil', 'code': 'ta'},
  {'name': 'Telugu', 'code': 'te'},
  {'name': 'Thai', 'code': 'th'},
  {'name': 'Chinese (Taiwan)', 'code': 'zh-TW'},
  {'name': 'Turkish', 'code': 'tr'},
  {'name': 'Urdu', 'code': 'ur'},
  {'name': 'Ukrainian', 'code': 'uk'},
  {'name': 'Vietnamese', 'code': 'vi'},
  {'name': 'Welsh', 'code': 'cy'},
];

//upload docs

uploadDocs() async {
  dynamic result;

  try {
    var response = http.MultipartRequest(
        'POST', Uri.parse(url + 'api/v1/driver/upload/documents'));
    response.headers
        .addAll({'Authorization': 'Bearer ' + bearerToken[0].token});
    response.files
        .add(await http.MultipartFile.fromPath('document', imageFile));
    response.fields['expiry_date'] = expDate.toString().substring(0, 19);
    response.fields['identify_number'] = docIdNumber;
    response.fields['document_id'] = docsId.toString();
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = val['message'];
    } else {
      result = val['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//getting country code

List countries = [];
getCountryCode() async {
  dynamic result;
  try {
    final response = await http.get(Uri.parse(url + 'api/v1/countries'));

    if (response.statusCode == 200) {
      countries = jsonDecode(response.body)['data'];
      phcode = (countries
              .where((element) =>
                  element['code'] ==
                  WidgetsBinding.instance!.window.locale.countryCode)
              .isNotEmpty)
          ? countries.indexWhere((element) =>
              element['code'] ==
              WidgetsBinding.instance!.window.locale.countryCode)
          : 0;
      result = 'success';
    } else {
      result = 'error';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}



//login firebase

String userUid = '';
var verId = '';
int? resendTokenId;
bool phoneAuthCheck = false;
dynamic credentials;

phoneAuth(String phone) async {
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        credentials = credential;
        valueNotifierHome.incrementNotifier();
      },
      forceResendingToken: resendTokenId,
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          debugPrint('The provided phone number is not valid.');
        } 
      },
      codeSent: (String verificationId, int? resendToken) async {
        verId = verificationId;
        resendTokenId = resendToken;
       
       
      },
      codeAutoRetrievalTimeout: (String verificationId) {
      
      },
    );
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get local bearer token

getLocalData() async {
  dynamic result;
  bearerToken.clear;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if(connectivityResult == ConnectivityResult.none){
    internet = false;
  }else{
    internet = true;
  }
  try {
    
    if (pref.containsKey('choosenLanguage')) {
      choosenLanguage = pref.getString('choosenLanguage');
      languageDirection = pref.getString('languageDirection');

      if (choosenLanguage.isNotEmpty) {
        if (pref.containsKey('Bearer')) {
          var tokens = pref.getString('Bearer');
          if (tokens != null) {
            bearerToken.add(BearerClass(type: 'Bearer', token: tokens));

            var responce = await getUserDetails();
            if (responce == true) {
              result = '3';
            } else if(responce == false) {
              result = '2';
            }
          } else {
            result = '2';
          }
        } else {
          result = '2';
        }
      } else {
        result = '1';
      }
    } else {
      result = '1';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get service locations

List serviceLocations = [];

getServiceLocation() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse(url + 'api/v1/servicelocation'),
    );

    if (response.statusCode == 200) {
      serviceLocations = jsonDecode(response.body)['data'];
      res = 'success';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle type

List vehicleType = [];

getvehicleType() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse(url + 'api/v1/types/' + myServiceId),
    );

    if (response.statusCode == 200) {
      vehicleType = jsonDecode(response.body)['data'];
      res = 'success';
    }
  } catch (e) {
    if (e is SocketException) {
      res = 'no internet';
      internet = false;
    }
  }

  return res;
}

//get vehicle make

List vehicleMake = [];

getVehicleMake() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse(url + 'api/v1/common/car/makes'),
    );

    if (response.statusCode == 200) {
      vehicleMake = jsonDecode(response.body)['data'];
      res = 'success';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//get vehicle model

List vehicleModel = [];

getVehicleModel() async {
  dynamic res;
  try {
    final response = await http.get(
      Uri.parse(url + 'api/v1/common/car/models/' + vehicleMakeId.toString()),
    );

    if (response.statusCode == 200) {
      vehicleModel = jsonDecode(response.body)['data'];
      res = 'success';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      res = 'no internet';
    }
  }
  return res;
}

//register driver

List<BearerClass> bearerToken = <BearerClass>[];

registerDriver() async {
  bearerToken.clear();
  dynamic result;
  try {
    final response = await http.post(Uri.parse(url + 'api/v1/driver/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "mobile": phnumber,
          "email": email,
          "device_token": fcm,
          "terms_condition": true,
          "country": countries[phcode]['dial_code'],
          "service_location_id": myServiceId,
          "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
          "is_company_driver": false,
          "vehicle_type": myVehicleId,
          "car_make": vehicleMakeId,
          "car_model": vehicleModelId,
          "car_color": vehicleColor,
          "car_number": vehicleNumber,
          "vehicle_year" : modelYear
        }));

    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);

      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      pref.setString('Bearer', bearerToken[0].token);
      await getUserDetails();
      result = 'true';
    } else {
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//update referral code

updateReferral() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/update/driver/referral'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({"refferal_code": referralCode}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        result = 'true';
      } else {
        result = 'false';
      }
    } else {
      result = 'false';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get documents needed

List documentsNeeded = [];
bool enableDocumentSubmit = false;

getDocumentsNeeded() async {
  dynamic result;
  try {
    final response = await http
        .get(Uri.parse(url + 'api/v1/driver/documents/needed'), headers: {
      'Authorization': 'Bearer ' + bearerToken[0].token,
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      documentsNeeded = jsonDecode(response.body)['data'];
      enableDocumentSubmit = jsonDecode(response.body)['enable_submit_button'];
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//call firebase otp

otpCall() async {
  dynamic result;
  try {
    var otp = await FirebaseDatabase.instance.ref().child('call_FB_OTP').get();
    result = otp;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no Internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

// verify user already exist

verifyUser(String number) async {
  dynamic val;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/driver/validate-mobile-for-login'),
        body: {"mobile": number});

    if (response.statusCode == 200) {
      val = jsonDecode(response.body)['success'];
      if (val == true) {
        var check = await driverLogin();
        if (check == true) {
          var uCheck = await getUserDetails();
          val = uCheck;
        } else {
          val = false;
        }
      } else {
        val = false;
      }
    } else {
      val = false;
    }
  } catch (e) {
    if (e is SocketException) {
      val = 'no internet';
      internet = false;
    }
  }
  return val;
}

//driver login
driverLogin() async {
  bearerToken.clear();
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/driver/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "mobile": phnumber,
          'device_token': fcm,
          "login_by": (platform == TargetPlatform.android) ? 'android' : 'ios',
        }));
    if (response.statusCode == 200) {
      var jsonVal = jsonDecode(response.body);
      bearerToken.add(BearerClass(
          type: jsonVal['token_type'].toString(),
          token: jsonVal['access_token'].toString()));
      result = true;
      pref.setString('Bearer', bearerToken[0].token);
    } else {
      
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String, dynamic> userDetails = {};

//user current state
getUserDetails() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + bearerToken[0].token
      },
    );
    if (response.statusCode == 200) {
      
      userDetails = jsonDecode(response.body)['data'];

      sosData = userDetails['sos']['data'];

      if (userDetails['onTripRequest'] != null) {
        driverReq = userDetails['onTripRequest']['data'];
        
        if(driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0 && arrivedTimer == null){
          waitingBeforeStart();
        }
        else if(driverReq['is_completed'] == 0 && driverReq['is_trip_start'] == 1 && rideTimer == null){
          waitingAfterStart();
        }
        

        if (driverReq['accepted_at'] != null) {
          getCurrentMessages();
        }
        valueNotifierHome.incrementNotifier();
      } else if (userDetails['metaRequest'] != null) {
        driverReq = userDetails['metaRequest']['data'];

        if(duration == 0 || duration == 0.0){
          duration = 30;
        sound();
        }

        valueNotifierHome.incrementNotifier();
      } else {
        driverReq = {};
      }
      if (userDetails['active'] == false) {
        isActive = 'false';
      } else {
        isActive = 'true';
      }
      result = true;
    } else {
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

class BearerClass {
  final String type;
  final String token;
  BearerClass({required this.type, required this.token});

  BearerClass.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        token = json['token'];

  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

Map<String, dynamic> driverReq = {};
var client = MqttServerClient.withPort(mqttUrl, '', mqttPort);
bool userReject = false;

//mqtt for documents approvals
mqttForDocuments() async {
  client.setProtocolV311();
  client.logging(on: true);
  client.keepAlivePeriod = 120;
  client.autoReconnect = true;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    debugPrint(e.toString());
    // Raised by the client when connection fails.
    client.disconnect();
  }

  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    debugPrint('connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    
    client.disconnect();
  }

  void onconnected() {
    debugPrint('connected');
  }

  client.subscribe(
      'approval_status_' + userDetails['id'].toString(), MqttQos.atLeastOnce);
  client.subscribe(
      'create_request_' + userDetails['id'].toString(), MqttQos.atLeastOnce);
  client.subscribe(
      'request_handler_' + userDetails['id'].toString(), MqttQos.atLeastOnce);
  client.subscribe(
      'new_message_' + userDetails['id'].toString(), MqttQos.atLeastOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
    
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

    
    final pt =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    if (c[0].topic == 'approval_status_' + userDetails['id'].toString()) {
      Map<String, dynamic> val =
          Map<String, dynamic>.from(jsonDecode(pt)['data']);
      if (userDetails['approve'] == val['approve']) {
        userDetails['declined_reason'] = val['declined_reason'];
        
        valueNotifierHome.incrementNotifier();
      } else if (userDetails['approve'] != val['approve'] &&
          val['approve'] == true) {
        userDetails['approve'] = val['approve'];
        userDetails['declined_reason'] = val['declined_reason'];
        audioPlayer.play(audio);
        valueNotifierHome.incrementNotifier();
      } else if (userDetails['approve'] != val['approve'] &&
          val['approve'] == false) {
        userDetails['declined_reason'] = val['declined_reason'];
        userDetails['approve'] = val['approve'];
        audioPlayer.play(audio);
        valueNotifierHome.incrementNotifier();
      } else {}
    } else if (c[0].topic ==
        'request_handler_' + userDetails['id'].toString()) {
        await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).update({'is_cancelled':true});
      driverReq = {};
      getUserDetails();
      if (jsonDecode(pt)['message'] != 'driver_cancelled_trip') {
        userReject = true;
         audioPlayer.play(audio);
      }
      getStartOtp = false;

      audioPlayers.stop();
      audioPlayers.dispose();
      valueNotifierHome.incrementNotifier();
    } else if (c[0].topic == 'create_request_' + userDetails['id'].toString()) {
      Map<String, dynamic> val =
          Map<String, dynamic>.from(jsonDecode(pt)['result']['data']);
          
      
      driverReq = val;
      valueNotifierHome.incrementNotifier();
      duration = 30;
      sound();
    } else if (c[0].topic == 'new_message_' + userDetails['id'].toString()) {
      if (jsonDecode(pt)["success_message"] == "new_message") {
        chatList = jsonDecode(pt)['data'];
        audioPlayer.play(audio);
        valueNotifierHome.incrementNotifier();
      } else {
        audioPlayer.play(audio);
      }
    }
  });
  

  client.onConnected = onconnected;
}

class ValueNotifying {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifier = ValueNotifying();

class ValueNotifyingHome {
  ValueNotifier value = ValueNotifier(0);

  void incrementNotifier() {
    value.value++;
  }
}

ValueNotifying valueNotifierHome = ValueNotifying();

//driver online offline status
driverStatus() async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/driver/online-offline'),
        headers: {'Authorization': 'Bearer ' + bearerToken[0].token});
    if (response.statusCode == 200) {
      userDetails = jsonDecode(response.body)['data'];
      result = true;
      if (userDetails['active'] == false) {
        userInactive();
      }
    } else {
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//update driver location in firebase

currentPositionUpdate() async {
  bool serviceEnabled;
  PermissionStatus permission;
  Location locs = Location();
  GeoHasher geo = GeoHasher();

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    
    
    if (userDetails.isNotEmpty) {
      serviceEnabled = await locs.serviceEnabled();
    permission = await locs.hasPermission();
      if (userDetails['active'] == true &&
          serviceEnabled == true &&
          permission == PermissionStatus.granted) {
        if (await locs.isBackgroundModeEnabled() == false) {
          await locs.enableBackgroundMode(enable: true);
          locs.changeNotificationOptions(iconName: '@mipmap/ic_launcher');
        }
        if (client.connectionStatus!.state != MqttConnectionState.connected ||
            client.connectionStatus == null) {
          mqttForDocuments();
        }
        var pos = await Location.instance.getLocation();
        
        // Test if location services are enabled.

        center = LatLng(double.parse(pos.latitude.toString()),
            double.parse(pos.longitude.toString()));
        heading = pos.heading;
        valueNotifierHome.incrementNotifier();
        final _position = FirebaseDatabase.instance.ref();

        try {
          _position.child('drivers/' + userDetails['id'].toString()).update({
            'bearing': pos.heading,
            'id': userDetails['id'],
            'g': geo.encode(double.parse(pos.longitude.toString()),
                double.parse(pos.latitude.toString())),
            'is_active': userDetails['active'] == true ? 1 : 0,
            'is_available': userDetails['available'],
            'l': {'0': pos.latitude, '1': pos.longitude},
            'mobile': userDetails['mobile'],
            'name': userDetails['name'],
            'updated_at': ServerValue.timestamp,
            'vehicle_number': userDetails['car_number'],
            'vehicle_type_name': userDetails['car_make_name'],
            'vehicle_type': userDetails['vehicle_type_id']
          });
          if (driverReq.isNotEmpty) {
            if (driverReq['accepted_at'] != null &&
                driverReq['is_completed'] == 0) {
              requestDetailsUpdate(
                  double.parse(pos.heading.toString()),
                  double.parse(pos.latitude.toString()),
                  double.parse(pos.longitude.toString()));
            }
          }
          valueNotifierHome.incrementNotifier();
        } catch (e) {
          if (e is SocketException) {
            internet = false;
            valueNotifierHome.incrementNotifier();
          }
        }
      } else if (userDetails['active'] == false &&
          serviceEnabled == true &&
          permission != PermissionStatus.denied) {
        var pos = await geolocs.Geolocator.getCurrentPosition();
        valueNotifierHome.incrementNotifier();
        center = LatLng(double.parse(pos.latitude.toString()),
            double.parse(pos.longitude.toString()));
      } 
    } 
  });
}

//add request details in firebase realtime database

List latlngArray = [];
dynamic lastLat;
dynamic lastLong;
dynamic totalDistance;

requestDetailsUpdate(
  double bearing,
  double lat,
  double lng,
) async {
  final _data = FirebaseDatabase.instance.ref();
  if (driverReq['is_trip_start'] == 1 && driverReq['is_completed'] == 0) {
    if(totalDistance == null){var _dist =  await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('distance').get();
    var _array =  await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('lat_lng_array').get();
    
        if(_dist.value != null){
        totalDistance = _dist.value;
        }
        if(_array.value != null){
          latlngArray = jsonDecode(jsonEncode(_array.value));
          lastLat = latlngArray[latlngArray.length - 1]['lat'];
          lastLong = latlngArray[latlngArray.length - 1]['lng'];
        }}
    if (latlngArray.isEmpty) {
      latlngArray.add({'lat': lat, 'lng': lng});
      lastLat = lat;
      lastLong = lng;
    } else {
      var distance = await calculateDistance(lastLat, lastLong, lat, lng);
      if (distance >= 10.0) {
        latlngArray.add({'lat': lat, 'lng': lng});
        lastLat = lat;
        lastLong = lng;

        if (totalDistance == null) {
        
          totalDistance = distance / 1000;
        
        } else {
          totalDistance = ((totalDistance * 1000) + distance) / 1000;
        }
      }
    }
  }

  try {
    _data.child('requests/' + driverReq['id']).update({
      'bearing': bearing,
      'distance': (totalDistance == null) ? 0.0 : totalDistance,
      'id': userDetails['id'],
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': (driverReq['is_completed'] == 0) ? false : true,
      'lat': lat,
      'lng': lng,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': (driverReq['is_driver_arrived'] == 0) ? "0" : "1",
      'trip_start': (driverReq['is_trip_start'] == 0) ? "0" : "1",
    });
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//calculate distance

calculateDistance(lat1, lon1, lat2, lon2) {
 

  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}

userInactive() {
  final _position = FirebaseDatabase.instance.ref();
  _position.child('drivers/' + userDetails['id'].toString()).update({
    'is_active': 0,
  });
}

calculateIdleDistance(lat1, lon1, lat2, lon2) {
  

  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var val = (12742 * asin(sqrt(a))) * 1000;
  return val;
}



//driver request accept

requestAccept() async {
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 1}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'success') {
        
        audioPlayers.stop();
        audioPlayers.dispose();
        
        await getUserDetails();
        FirebaseDatabase.instance.ref().child('drivers/' + userDetails['id']).update({
          'is_available':false
        });
        duration = 0;
        valueNotifierHome.incrementNotifier();
      }
    } else {}
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//driver request reject

requestReject() async {
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/respond'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'is_accept': 0}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'success') {
        audioPlayers.stop();
        audioPlayers.dispose(); 
        await getUserDetails();
        // audioPlayers.stop();
        valueNotifierHome.incrementNotifier();
      }
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//sound

sound() async {
  
    audioPlayers = await audioPlayer.loop('audio/request_sound.mp3');

  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (duration > 0.0 && driverReq['accepted_at'] == null  && driverReq.isNotEmpty) {
      duration--;
      valueNotifierHome.incrementNotifier();
    } else if (driverReq['accepted_at'] == null && duration <= 0.0) {
      timer.cancel();
      audioPlayers.stop();
      audioPlayers.dispose();
      Future.delayed(const Duration(seconds: 2), () {
        requestReject();
      });
      duration = 0;
    }  else {
      audioPlayers.stop();
      audioPlayers.dispose();
      timer.cancel();
      duration = 0;
    }
  });
}

//driver arrived

driverArrived() async {
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/arrived'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id']}));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['message'] == 'driver_arrived') {
        waitingBeforeTime = 0;
        waitingTime = 0;
        await getUserDetails();
        valueNotifierHome.incrementNotifier();
      }
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
}

//opening google map

openMap(lat, lng) async {
  try {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//trip start with otp

tripStart() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng'],
          'ride_otp': driverOtp
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//trip start without otp

tripStartDispatcher() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/started'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'pick_lat': driverReq['pick_lat'],
          'pick_lng': driverReq['pick_lng']
        }));
    if (response.statusCode == 200) {
      result = 'success';
      await getUserDetails();
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}


geoCoding(double lat, double lng) async {
  dynamic result;
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$mapkey'));

    if (response.statusCode == 200) {
      var val = jsonDecode(response.body);
      result = val['results'][0]['formatted_address'];
    } else {
      result = '';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    } 
  }
  return result;
}

//ending trip

endTrip() async {
  try {
    
    await requestDetailsUpdate(heading, center.latitude, center.longitude);
    var dropAddress = await geoCoding(center.latitude, center.longitude);
    var db = await FirebaseDatabase.instance
        .ref()
        .child('requests/' + driverReq['id'] + '/distance')
        .get();
 
    double dist =
        double.parse(double.parse(db.value.toString()).toStringAsFixed(2));
    
    final _data = FirebaseDatabase.instance.ref();
    _data.child('requests/' + driverReq['id']).update({
      'bearing': heading,
      'id': userDetails['id'],
      'is_cancelled': (driverReq['is_cancelled'] == 0) ? false : true,
      'is_completed': true,
      'lat': center.latitude,
      'lng': center.longitude,
      'lat_lng_array': latlngArray,
      'request_id': driverReq['id'],
      'trip_arrived': "1",
      'trip_start': "1",
    });
    
    var response = await http.post(Uri.parse(url + 'api/v1/request/end'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'distance': dist,
          'before_arrival_waiting_time': 0,
          'after_arrival_waiting_time': 0,
          'drop_lat': center.latitude,
          'drop_lng': center.longitude,
          'drop_address': dropAddress,
          'before_trip_start_waiting_time': (waitingBeforeTime != null && waitingBeforeTime > 60) ? (waitingBeforeTime / 60).toInt() : 0,
          'after_trip_start_waiting_time': (waitingAfterTime != null && waitingAfterTime > 60) ? (waitingAfterTime / 60).toInt() : 0

        }));
    if (response.statusCode == 200) {
     
      totalDistance = null;
      lastLat = null;
      lastLong = null;
      waitingTime = null;
      waitingBeforeTime = null;
      waitingAfterTime = null;
      latlngArray.clear();
      polyList.clear();
      chatList.clear();
      driverOtp = '';
      waitingAfterTime = null;
      waitingBeforeTime = null;
      waitingTime = null;
      await getUserDetails();

      valueNotifierHome.incrementNotifier();
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

dynamic heading;

//get polylines

List<LatLng> polyList = [];

getPolylines() async {
  polyList.clear();
  String pickLat = driverReq['pick_lat'].toString();
  String pickLng = driverReq['pick_lng'].toString();
  String dropLat = driverReq['drop_lat'].toString();
  String dropLng = driverReq['drop_lng'].toString();
  try {
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?destination=$pickLat%2C$pickLng&origin=$dropLat%2C$dropLng&avoid=ferries|indoor&transit_mode=bus&mode=driving&key=$mapkey'));

    var steps =
        jsonDecode(response.body)['routes'][0]['overview_polyline']['points'];

    decodeEncodedPolyline(steps);
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }

  return polyList;
}

//polyline decode

Set<Polyline> polyline = {};

List<PointLatLng> decodeEncodedPolyline(String encoded) {
  polyline.clear();
  List<PointLatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    polyList.add(p);
  }
  polyline.add(Polyline(
    polylineId:const PolylineId('1'),
    visible: true,
    color: const Color(0xffFD9898),
    width: 4,
    points: polyList,
  ));
  valueNotifierHome.incrementNotifier();
  return poly;
}

/// Note instead of using the class,
/// you can use Google LatLng() by importing it from their library.
class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
  // ignore: unnecessary_null_comparison
      : assert(latitude != null),
        // ignore: unnecessary_null_comparison
        assert(longitude != null),
        
        // ignore: unnecessary_this, prefer_initializing_formals
        this.latitude = latitude,
        // ignore: unnecessary_this, prefer_initializing_formals
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

//add user rating

userRating() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/rating'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'request_id': driverReq['id'],
          'rating': review,
          'comment': feedback
        }));
    if (response.statusCode == 200) {
      await getUserDetails();
      result = true;
    } else {
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//making call to user

makingPhoneCall(phnumber) async {
  var mobileCall = 'tel:' + phnumber;
  if (await canLaunch(mobileCall)) {
    await launch(mobileCall);
  } else {
    throw 'Could not launch $mobileCall';
  }
}

//request cancel by driver

cancelRequestDriver(reason) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/request/cancel/by-driver'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'request_id': driverReq['id'], 'custom_reason': reason}));

    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).update({'is_cancelled':true});
        result = true;
        await getUserDetails();
        valueNotifierHome.incrementNotifier();
      } else {
        result = false;
      }
    } else {
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//sos data
List sosData = [];

getSosData(lat, lng) async {
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/common/sos/list/$lat/$lng'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      sosData = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//get current ride messages

List chatList = [];

getCurrentMessages() async {
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/request/chat-history/' + driverReq['id']),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['success'] == true) {
        chatList = jsonDecode(response.body)['data'];
        valueNotifierHome.incrementNotifier();
      }
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//send chat

sendMessage(chat) async {
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/request/send'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'request_id': driverReq['id'], 'message': chat}));
    if (response.statusCode == 200) {
      getCurrentMessages();
    } 
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//message seen

messageSeen() async {
  var response = await http.post(Uri.parse(url + 'api/v1/request/seen'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({'request_id': driverReq['id']}));
  if (response.statusCode == 200) {
    getCurrentMessages();
  } 
}

//cancellation reason
List cancelReasonsList = [];
cancelReason(reason) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/common/cancallation/reasons?arrived=$reason'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      cancelReasonsList = jsonDecode(response.body)['data'];
      result = true;
    } else {
      result = false;
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//open url in browser

openBrowser(browseUrl) async {
  try {
    if (await canLaunch(browseUrl)) {
      await launch(browseUrl);
    } else {
      throw 'Could not launch $browseUrl';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
    }
  }
}

//update driver vehicle

updateVehicle() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/user/driver-profile'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "service_location_id": myServiceId,
              "is_company_driver": false,
              "vehicle_type": myVehicleId,
              "car_make": vehicleMakeId,
              "car_model": vehicleModelId,
              "car_color": vehicleColor,
              "car_number": vehicleNumber,
              "vehicle_year":modelYear
            }));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//edit user profile

updateProfile(name, email) async {
  dynamic result;
  try {
    var response =  http.MultipartRequest(
      'POST',
      Uri.parse(url + 'api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ' + bearerToken[0].token});
    response.files.add(
        await http.MultipartFile.fromPath('profile_picture', proImageFile));
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

updateProfileWithoutImage(name, email) async {
  dynamic result;
  try {
    var response =  http.MultipartRequest(
      'POST',
      Uri.parse(url + 'api/v1/user/driver-profile'),
    );
    response.headers
        .addAll({'Authorization': 'Bearer ' + bearerToken[0].token});
    response.fields['email'] = email;
    response.fields['name'] = name;
    var request = await response.send();
    var respon = await http.Response.fromStream(request);
    final val = jsonDecode(respon.body);
    if (request.statusCode == 200) {
      result = 'success';
      if (val['success'] == true) {
        await getUserDetails();
      }
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
    }
  }
  return result;
}

//get faq
List faqData = [];

getFaqData(lat, lng) async {
  dynamic result;
  try {
    var response = await http
        .get(Uri.parse(url + 'api/v1/common/faq/list/$lat/$lng'), headers: {
      'Authorization': 'Bearer ' + bearerToken[0].token,
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      faqData = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
    return result;
  }
}

//request history
List myHistory = [];
Map<String, dynamic> myHistoryPage = {};

getHistory(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse(url + 'api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ' + bearerToken[0].token});
    if (response.statusCode == 200) {
      myHistory = jsonDecode(response.body)['data'];
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getHistoryPages(id) async {
  dynamic result;

  try {
    var response = await http.get(Uri.parse(url + 'api/v1/request/history?$id'),
        headers: {'Authorization': 'Bearer ' + bearerToken[0].token});
    if (response.statusCode == 200) {
      List list = jsonDecode(response.body)['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        myHistory.add(element);
      });
      myHistoryPage = jsonDecode(response.body)['meta'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';

      internet = false;
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//get wallet history

Map<String, dynamic> walletBalance = {};
List walletHistory = [];
Map<String, dynamic> walletPages = {};

getWalletHistory() async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse(url + 'api/v1/payment/wallet/history'),
        headers: {'Authorization': 'Bearer ' + bearerToken[0].token});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      walletHistory = walletBalance['wallet_history']['data'];
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

getWalletHistoryPage(page) async {
  dynamic result;
  try {
    var response = await http.get(
        Uri.parse(url + 'api/v1/payment/wallet/history?page=$page'),
        headers: {'Authorization': 'Bearer ' + bearerToken[0].token});
    if (response.statusCode == 200) {
      walletBalance = jsonDecode(response.body);
      List list = walletBalance['wallet_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      list.forEach((element) {
        walletHistory.add(element);
      });
      walletPages = walletBalance['wallet_history']['meta']['pagination'];
      result = 'success';
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
      valueNotifierHome.incrementNotifier();
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
      valueNotifierHome.incrementNotifier();
    }
  }
  return result;
}

//add sos

addSos(name, number) async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/common/sos/store'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'name': name, 'number': number}));

    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//remove sos

deleteSos(id) async {
  dynamic result;
  try {
    var response = await http
        .post(Uri.parse(url + 'api/v1/common/sos/delete/' + id), headers: {
      'Authorization': 'Bearer ' + bearerToken[0].token,
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      await getUserDetails();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//get user referral

Map<String, dynamic> myReferralCode = {};
getReferral() async {
  dynamic result;
  try {
    var response =
        await http.get(Uri.parse(url + 'api/v1/get/referral'), headers: {
      'Authorization': 'Bearer ' + bearerToken[0].token,
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      result = 'success';
      myReferralCode = jsonDecode(response.body)['data'];
      valueNotifierHome.incrementNotifier();
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//stripe payment

Map<String, dynamic> stripeToken = {};

getStripePayment(money) async {
  dynamic results;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/payment/stripe/intent'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      results = 'success';
      stripeToken = jsonDecode(response.body)['data'];
    } else {
      results = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

//stripe add money


addMoneyStripe(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/payment/stripe/add/money'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//paystack payment
Map<String,dynamic> paystackCode = {};


getPaystackPayment(money)async{
  dynamic results;
  paystackCode.clear();
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/payment/paystack/initialize'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({'amount': money}));
    if (response.statusCode == 200) {
      results = 'success';
      paystackCode = jsonDecode(response.body)['data'];
    } else {
      results = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      results = 'no internet';
      internet = false;
    }
  }
  return results;
}

addMoneyPaystack(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/payment/paystack/add-money'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      paystackCode.clear();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//flutterwave

addMoneyFlutterwave(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/payment/flutter-wave/add-money'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      paystackCode.clear();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//razorpay

addMoneyRazorpay(amount, nonce) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/payment/razerpay/add-money'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(
            {'amount': amount, 'payment_nonce': nonce, 'payment_id': nonce}));
    if (response.statusCode == 200) {
      await getWalletHistory();
      paystackCode.clear();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//braintree

dynamic brainTreeToken;

getBrianTreeToken()async{
  brainTreeToken = null;
  dynamic result;
  try{
    var response =await http.get(Uri.parse(url + 'api/v1/payment/braintree/client/token'),
   headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            );
  if(response.statusCode == 200){
    if(jsonDecode(response.body)['success'] == true){
      brainTreeToken = jsonDecode(response.body)['data']['client_token'];
      result = 'success';
    }else{
      result = 'failure';
    }
    
    
  }else{
    result = 'failure';
  }
  }catch(e){
    if(e is SocketException){
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//cashfree

Map<String,dynamic> cftToken = {};

getCfToken(money, currency)async{
  cftToken.clear();
  cfSuccessList.clear();
  dynamic result;
  try{
    var response =await http.post(Uri.parse(url + 'api/v1/payment/cashfree/generate-cftoken'),
   headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
  body: jsonEncode({
    'order_amount' : money,
    'order_currency': currency
  })
            );
  if(response.statusCode == 200){
    if(jsonDecode(response.body)['status'] == 'OK'){
      cftToken = jsonDecode(response.body);
      result = 'success';
    }else{
      result = 'failure';
    }
    
  }else{
    result = 'failure';
  }
  }catch(e){
    if(e is SocketException){
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

Map<String,dynamic> cfSuccessList = {};

cashFreePaymentSuccess()async{
  dynamic result;
  try{
    var response = await http.post(Uri.parse(url + 'api/v1/payment/cashfree/add-money-to-wallet-webhooks'),
    headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
    body: jsonEncode({
      'orderId' : cfSuccessList['orderId'],
      'orderAmount':cfSuccessList['orderAmount'],
      'referenceId':cfSuccessList['referenceId'],
      'txStatus':cfSuccessList['txStatus'],
      'paymentMode':cfSuccessList['paymentMode'],
      'txMsg':cfSuccessList['txMsg'],
      'txTime':cfSuccessList['txTime'],
      'signature':cfSuccessList['signature']
    })
    );
    if(response.statusCode == 200){
      if(jsonDecode(response.body)['success'] == true){
        result = 'success';
        await getWalletHistory();
        await getUserDetails();
      }else{
        result = 'failure';
      }
    }else{
      result = 'failure';
    }
  }catch(e){
    if(e is SocketException){
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//user logout

userLogout() async {
  dynamic result;
  try {
    var response = await http.post(Uri.parse(url + 'api/v1/logout'), headers: {
      'Authorization': 'Bearer ' + bearerToken[0].token,
      'Content-Type': 'application/json'
    });
    if (response.statusCode == 200) {
      pref.remove('Bearer');
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//check internet connection

checkInternetConnection()async {
  
  Connectivity().onConnectivityChanged.listen((connectionState) {
    if (connectionState == ConnectivityResult.none) {
      internet = false;
      client.disconnect();
      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    } else {
      internet = true;
      if(client.connectionStatus!.state != ConnectionState.active && client.connectionStatus == null && userDetails.isNotEmpty){
        mqttForDocuments();
      }
      valueNotifierHome.incrementNotifier();
      valueNotifierHome.incrementNotifier();
    }
  });
}

//internet true
internetTrue() {
  internet = true;
  valueNotifierHome.incrementNotifier();
}

//driver earnings

Map<String, dynamic> driverTodayEarnings = {};
Map<String, dynamic> driverWeeklyEarnings = {};
Map<String, dynamic> weekDays = {};
Map<String, dynamic> driverReportEarnings = {};

driverTodayEarning() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/driver/today-earnings'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverTodayEarnings = jsonDecode(response.body)['data'];
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverWeeklyEarning() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/driver/weekly-earnings'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      driverWeeklyEarnings = jsonDecode(response.body)['data'];
      weekDays = jsonDecode(response.body)['data']['week_days'];
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

driverEarningReport(fromdate, todate) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/driver/earnings-report/$fromdate/$todate'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      driverReportEarnings = jsonDecode(response.body)['data'];
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw request

requestWithdraw(amount) async {
  dynamic result;
  try {
    var response = await http.post(
        Uri.parse(url + 'api/v1/payment/wallet/request-for-withdrawal'),
        headers: {
          'Authorization': 'Bearer ' + bearerToken[0].token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'requested_amount': amount}));
    if (response.statusCode == 200) {
      await getWithdrawList();
      result = 'success';
    } else {
      result = jsonDecode(response.body)['message'];
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//withdraw list

Map<String, dynamic> withDrawList = {};
List withDrawHistory = [];
Map<String, dynamic> withDrawHistoryPages = {};

getWithdrawList() async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/payment/wallet/withdrawal-requests'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      withDrawHistory = jsonDecode(response.body)['withdrawal_history']['data'];
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

getWithdrawListPages(page) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/payment/wallet/withdrawal-requests?page=$page'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      withDrawList = jsonDecode(response.body);
      List val = jsonDecode(response.body)['withdrawal_history']['data'];
      // ignore: avoid_function_literals_in_foreach_calls
      val.forEach((element) {
        withDrawHistory.add(element);
      });
      withDrawHistoryPages =
          jsonDecode(response.body)['withdrawal_history']['meta']['pagination'];
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//get bank info
Map<String, dynamic> bankData = {};

getBankInfo() async {
  bankData.clear();
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/user/get-bank-info'),
      headers: {
        'Authorization': 'Bearer ' + bearerToken[0].token,
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      result = 'success';
      bankData = jsonDecode(response.body)['data'];
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

addBankData(accName, accNo, bankCode, bankName) async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/user/update-bank-info'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'account_name': accName,
              'account_no': accNo,
              'bank_code': bankCode,
              'bank_name': bankName
            }));

    if (response.statusCode == 200) {
      await getBankInfo();
      result = 'success';
    } else {
      result = 'failure';
    }
  } catch (e) {
    if (e is SocketException) {
      result = 'no internet';
      internet = false;
    }
  }
  return result;
}

//sos admin notification

notifyAdmin() async {
  var db = FirebaseDatabase.instance.ref();
  dynamic result;
  try {
    await db.child('SOS/' + driverReq['id']).update({
      "is_driver": "1",
      "is_user": "0",
      "req_id": driverReq['id'],
      "serv_loc_id": driverReq['service_location_id'],
      "updated_at": ServerValue.timestamp
    });
    result = true;
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = false;
    }
  }
  return result;
}



//make complaint

List generalComplaintList = [];
getGeneralComplaint(type) async {
  dynamic result;
  try {
    var response = await http.get(
      Uri.parse(url + 'api/v1/common/complaint-titles?complaint_type=$type'),
      headers: {'Authorization': 'Bearer ' + bearerToken[0].token},
    );
    if (response.statusCode == 200) {

      generalComplaintList = jsonDecode(response.body)['data'];
      result = 'success';
    } else {
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeGeneralComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
            }));
    if (response.statusCode == 200) {
     
      result = 'success';
    } else {
      
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

makeRequestComplaint() async {
  dynamic result;
  try {
    var response =
        await http.post(Uri.parse(url + 'api/v1/common/make-complaint'),
            headers: {
              'Authorization': 'Bearer ' + bearerToken[0].token,
              'Content-Type': 'application/json'
            },
            body: jsonEncode({
              'complaint_title_id': generalComplaintList[complaintType]['id'],
              'description': complaintDesc,
              'request_id': myHistory[selectedHistory]['id']
            }));
    if (response.statusCode == 200) {
      
      result = 'success';
    } else {
      
      result = 'failed';
    }
  } catch (e) {
    if (e is SocketException) {
      internet = false;
      result = 'no internet';
    }
  }
  return result;
}

//waiting time

//waiting before start
dynamic waitingTime;
dynamic waitingBeforeTime;
dynamic waitingAfterTime;
dynamic arrivedTimer;
dynamic rideTimer;
waitingBeforeStart()async{
  var _bWaitingTime = await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('waiting_time_before_start').get();
  var _waitingTime = await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('total_waiting_time').get();
  if(_bWaitingTime.value != null){
    waitingBeforeTime = _bWaitingTime.value;
  }else{
    waitingBeforeTime = 0;
  }
  if(_waitingTime.value != null){
    waitingTime = _waitingTime.value;
  }else{
    waitingTime = 0;
  }
  await Future.delayed(const Duration(seconds: 10),(){

  });
  
 arrivedTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
    if(driverReq['is_driver_arrived'] == 1 && driverReq['is_trip_start'] == 0){
    waitingBeforeTime++;
    waitingTime++;
    if(waitingTime%60 == 0){
    FirebaseDatabase.instance.ref().child('requests/' + driverReq['id']).update(
     {
       'waiting_time_before_start' : waitingBeforeTime,
       'total_waiting_time':waitingTime
     }
    );}
    valueNotifierHome.incrementNotifier();
    
    }else{
    timer.cancel();
    arrivedTimer = null;
  }
  });
  
}

dynamic positionStream;
dynamic currentRidePosition;

dynamic startTimer;


waitingAfterStart()async{
  var _bWaitingTime = await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('waiting_time_before_start').get();
  var _waitingTime = await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('total_waiting_time').get();
  var _aWaitingTime = await FirebaseDatabase.instance.ref().child('requests/' +  driverReq['id']).child('waiting_time_after_start').get();
  if(_bWaitingTime.value != null && waitingBeforeTime == null){
    waitingBeforeTime = _bWaitingTime.value;
  }
  if(_waitingTime.value != null && waitingTime == null){
    waitingTime = _waitingTime.value;
  }
  if(_aWaitingTime.value != null){
    waitingAfterTime = _aWaitingTime.value;
  }else{
    waitingAfterTime = 0;
  }
 await Future.delayed(const Duration(seconds: 10),(){

  });
  rideTimer = Timer.periodic(const Duration(seconds: 60), (timer) async { 
  
    if(currentRidePosition == null && driverReq['is_completed'] == 0 && driverReq['is_trip_start'] == 1){
   
      currentRidePosition = center;
    }else if(currentRidePosition != null && driverReq['is_completed'] == 0 && driverReq['is_trip_start'] == 1){
      var dist = await calculateIdleDistance(currentRidePosition.latitude, currentRidePosition.longitude, center.latitude, center.longitude);
      if(dist < 150){
        waitingAfterTime = waitingAfterTime + 60;
        waitingTime = waitingTime + 60;
        if(waitingTime%60 == 0){
         FirebaseDatabase.instance.ref().child('requests/' + driverReq['id']).update(
     {
       'waiting_time_after_start' : waitingAfterTime,
       'total_waiting_time':waitingTime
     }
    );
      }
        valueNotifierHome.incrementNotifier();
      
      }else{
       
        currentRidePosition = center;
      }
    }
    else{
      timer.cancel();
      rideTimer = null;
    }
  });
}
