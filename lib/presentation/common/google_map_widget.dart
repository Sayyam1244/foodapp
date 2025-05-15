import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final Set<Marker>? markers;

  const GoogleMapWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
    this.markers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: zoom,
        ),
        markers: markers ??
            {
              Marker(
                markerId: const MarkerId('center'),
                position: LatLng(latitude, longitude),
              ),
            },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
