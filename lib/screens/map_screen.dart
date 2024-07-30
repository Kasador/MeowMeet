import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../theme.dart';
import '../generated/l10n.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  String _mapStyle = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _getCurrentLocation();
  }

  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      if (mapController != null) {
        mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
        mapController?.setMapStyle(_mapStyle);
      }
    }).catchError((e) {
      print(e);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          localizations.map,
          style: TextStyle(color: AppTheme.backgroundColor),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 5.0,
              ),
            ),
    );
  }
}
