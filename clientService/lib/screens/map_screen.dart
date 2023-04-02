import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_food/bloc/location_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:yandex_geocoder/yandex_geocoder.dart' hide Point, GeoObject;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  static const String id = "map_screen";


  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController pinAddressController = TextEditingController();

  String _addressDelivery = "";

  final YandexGeocoder geocoder =
      YandexGeocoder(apiKey: 'd8fc9c55-89f0-4977-983f-1800f00c6c58');

  late YandexMapController controller;

  final mapKey = GlobalKey();
  final pinKey = GlobalKey();

  Point _pointUser = const Point(latitude: 0, longitude: 0);

  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 1.0);

  @override
  void initState() {
    context.read<LocationCubit>().getLocation();
    super.initState();
  }

  PlacemarkMapObject _buildMeMarker(context) {
    return PlacemarkMapObject(
      mapId: const MapObjectId('inner_placemark'),
      point: Point(
        latitude: _pointUser.latitude,
        longitude: _pointUser.longitude,
      ),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: BitmapDescriptor.fromAssetImage('lib/assets/user.png'),
        ),
      ),
    );
  }

  Future<GeocodeResponse> _getAddressGeoCoder(String addressDelivery) async {
    return await geocoder.getGeocode(
      GeocodeRequest(
        geocode: AddressGeocode(
          address: _addressDelivery,
        ),
        ll: SearchAreaLL(
            latitude: _pointUser.latitude, longitude: _pointUser.longitude),
      ),
    );
  }

  Future<void> _changeCameraPosition(Point point) async {
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: point,
          zoom: 17,
        ),
      ),
      animation: animation,
    );
  }

  Future<void> _checkSavedUserPosAndMove(Point point) async {
    final prefs = await SharedPreferences.getInstance();
    final double? lat = prefs.getDouble('latDelivery');
    final double? long = prefs.getDouble('longDelivery');
    if (lat != null && long != null) {
      final point = Point(latitude: lat, longitude: long);
      _changeCameraPosition(point);
    } else {
      _changeCameraPosition(point);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFe41f26),
            actions: [
              IconButton(
                onPressed: () async {
                  // open the window with search-system
                  _addressDelivery = await showSearch(
                        context: context,
                        delegate: SearchAddress(),
                      ) ??
                      "";

                  if (_addressDelivery.isEmpty) return;

                  final latLongInstance =
                      await _getAddressGeoCoder(_addressDelivery);
                  final latLongString =
                      latLongInstance.firstPoint!.pos!.split(" ").reversed;
                  final latLongDouble =
                      latLongString.map(double.parse).toList();
                  final point = Point(latitude: latLongDouble[0], longitude: latLongDouble[1]);
                  _changeCameraPosition(point);
                },
                icon: const Icon(Icons.search),
              )
            ],
          ),
          body: SafeArea(
            child: BlocListener<LocationCubit, LocationState>(
              listener: (context, state) {
                if (state is LocationLoading) {
                  const Center(child: CircularProgressIndicator());
                }
                if (state is LocationError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red.withOpacity(0.6),
                    ),
                  );
                }
                if (state is LocationLoaded) {
                  _pointUser = Point(
                      latitude: state.latitude, longitude: state.longitude);
                  _checkSavedUserPosAndMove(_pointUser);
                }
              },
              child: BlocBuilder<LocationCubit, LocationState>(
                buildWhen: (previousState, state) => (previousState != state),
                builder: (context, state) {
                  return YandexMap(
                    key: mapKey,
                    onMapCreated:
                        (YandexMapController yandexMapController) async {
                      controller = yandexMapController;
                    },
                    mapObjects: [
                      _buildMeMarker(context),
                    ],
                    onCameraPositionChanged: (
                      CameraPosition cameraPosition,
                      CameraUpdateReason reason,
                      bool finished,
                    ) async {
                      if (finished) {
                        var address = await geocoder.getGeocode(GeocodeRequest(
                          geocode: PointGeocode(
                              latitude: cameraPosition.target.latitude,
                              longitude: cameraPosition.target.longitude),
                        ));
                        String formattedAddress =
                            '${address.firstAddress!.components![5].name}, ${address.firstAddress!.components![6].name}';
                        pinAddressController.text = formattedAddress;

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble(
                            'latDelivery', cameraPosition.target.latitude);
                        await prefs.setDouble(
                            'longDelivery', cameraPosition.target.longitude);
                        await prefs.setString(
                              'addressDelivery', formattedAddress);
                      } else {
                        pinAddressController.text = "Waiting...";
                      }
                    },
                  );
                },
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFe41f26),
            onPressed: () {
              _changeCameraPosition(_pointUser);
            },
            child: const Icon(Icons.gps_fixed),
          ),
        ),
        Container(
          key: pinKey,
          height: 50,
          width: 30,
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage("lib/assets/pin.png"),
            fit: BoxFit.cover,
          )),
        ),
        Positioned(
          width: MediaQuery.of(context).size.width / 1.2,
          top: 100,
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: pinAddressController,
              readOnly: true,
              maxLines: null,
              decoration: const InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                border: InputBorder.none,
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w500,
                fontSize: 25,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SearchAddress extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    var superThemeData = super.appBarTheme(context);
    return superThemeData.copyWith(
      textTheme: superThemeData.textTheme.copyWith(
        headline6: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, "");
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    return FutureBuilder(
        future: _suggest(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Center(child: CircularProgressIndicator()),
              ],
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No Results Found.",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else {
            var results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return ListTile(
                  title: Text(
                    result,
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    close(context, result);
                  },
                );
              },
            );
          }
        });
  }

  Future<List<String>> _suggest() async {
    final resultWithSession = YandexSuggest.getSuggestions(
        text: query,
        boundingBox: const BoundingBox(
            northEast: Point(latitude: 50.666676, longitude: 107.636975),
            southWest: Point(latitude: 50.547626, longitude: 107.506926)),
        suggestOptions: const SuggestOptions(
            suggestType: SuggestType.geo,
            suggestWords: true,
            userPosition: Point(latitude: 50.588588, longitude: 107.597061)));

    final List<SuggestSessionResult> results = [await resultWithSession.result];
    final list = <String>[];

    if (results.isEmpty) {
      list.add('Nothing found');
    }

    for (var r in results) {
      r.items!.asMap().forEach((i, item) {
        if (item.tags[0] == 'street' || item.tags[0] == 'house') {
          list.add('${item.displayText}');
        }
      });
    }
    return list;
  }
}
