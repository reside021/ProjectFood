import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {

  LocationCubit() : super (const LocationInitial());

  Future<void> getLocation() async {

    // Get latitude and longitude

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      emit(const LocationError(message: "Location services are disabled."));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        emit(const LocationError(message: "Location permissions are denied."));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      emit(const LocationError(message: "Location permissions are permanently denied, we cannot request permissions."));
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position =  await Geolocator.getCurrentPosition();
     emit(LocationLoaded(latitude: position.latitude, longitude: position.longitude));

  }

}