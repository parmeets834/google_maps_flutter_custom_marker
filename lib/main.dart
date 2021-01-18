import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_places/flutter_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Provider/LocationProvider.dart';
import 'Widget/GpsPermissionFragment.dart';
import 'Widget/LoadingFragment.dart';
import 'package:provider/provider.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';
import 'dart:math';
/*
* This app need to update min sdk version to 24 in order to run map api
*
* */
/*void main() => runApp(MyApp());*/

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (ctx) => LocationProvider())
  ],
  child:MyApp())
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 10.151926040649414);
  Set<Marker> _markers = {};
  GlobalKey<AutoCompleteTextFieldState<String>> key  = new GlobalKey();


 _getpalcesWidget()  {


   return Container(
     height :100,
     width: 100,
     child: RaisedButton(
       onPressed: () async {
         final place = await FlutterPlaces.show(
           context: context,
           apiKey: "AIzaSyBvD73khNYpYFjm8RA5b_iKfZO8RPYJpyA",
           modeType: ModeType.OVERLAY,
         );

       },
       child: Text('Overlay'),
     ),
   );


 }

  @override
  Widget build(BuildContext context) {
    final provider= Provider.of<LocationProvider>(context, listen: false);






    return new Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, value,child) {

           return FutureBuilder<CameraPosition>(
               future: value.initlocationLoad(),
               builder: (context, AsyncSnapshot<CameraPosition> snapshot) {
                 return Stack(
                   children: [

                     (){
                       if(snapshot.data==null) {  // on start its returns null snapshot data. When future done its future builder block called again
                        return LoadingFragment();
                       }
                       else if(snapshot.data!=null) {
                            _markers.add(Marker(
                             markerId: MarkerId("1234"),
                             position: LatLng(provider.locationData.latitude,provider.locationData.longitude),
                             icon: pinLocationIcon));

                         return GoogleMap(mapType: MapType.normal,
                           initialCameraPosition: provider.currentPosition,
                           markers: _markers,
                           onMapCreated: (GoogleMapController controller) {
                             _controller.complete(controller);
                           },
                         );
                       }

                     }(),
                     // generate Input Text Box code here
                       (){
                     //dchfdhydfhh
                         if(snapshot.data!=null){
                           return Positioned(
                             top: 50,
                             right: 15,
                             left: 15,
                             child: Container(
                                 height: 50,
                                 width: double.infinity,
                                 decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(3.0),
                                     color: Colors.white,
                                     boxShadow: [
                                       BoxShadow(color: Colors.grey,
                                           offset: Offset(1,5),
                                           blurRadius: 10,
                                           spreadRadius: 3

                                       )

                                     ]
                                 ),

                         child: SimpleAutoCompleteTextField(
                           key: key,
                           decoration: InputDecoration(
                             icon: Container(
                               margin: EdgeInsets.only(left: 20,bottom: 10),
                               width: 10,
                               height: 10,
                               child: Icon(
                                 Icons.local_taxi,
                                 color: Colors.black,
                               ),
                             ),
                             hintText: "destination?",
                             border: InputBorder.none,
                             contentPadding: EdgeInsets.only(left: 15.0),
                           ),
                           controller:provider.autocompleteTextController,
                           suggestions: provider.placeSuggestions,
                           textChanged: (text){
                             provider.updateSuggestions(text,key);
                           },
                           clearOnSubmit: true,
                           textSubmitted: provider.onTextInputSubmit,
                         ),
                             ),
                           );
                         }else{
                            return Container();
                         }

                          }()



                   ],
                 );
               }
           );
         }

      ),
/*      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),*/
    );




  }


  Widget _loadScreenFragement() {
    Size size=    MediaQuery.of(context).size;
    return Container(
        height:size.height,
        width:size.width,
        color: Colors.amber,
        child:Center(child:CircularProgressIndicator()));

  }
  LatLng pinPosition = LatLng(28.6442197, 77.2157713);

  // these are the minimum required values to set
  // the camera position
  var pinLocationIcon;

  Future<void> _goToTheLake() async {
    final CameraPosition _kLake = CameraPosition(
        bearing: 90.8334901395799,
        target: pinPosition,
        tilt: 0,
        zoom: 25.151926040649414);

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)), 'flags/bic.png')
        .then((onValue) {
      pinLocationIcon = onValue;

      _markers.add(Marker(
          markerId: MarkerId("1234"),
          position: pinPosition,
          icon: pinLocationIcon));
      setState(() {});
    });
  }



}
