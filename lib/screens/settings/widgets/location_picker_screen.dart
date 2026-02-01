import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// WICHTIG: Passe diesen Import an deinen Projektnamen an, falls abweichend
import 'package:store_controller/l10n/generated/app_localizations.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  bool _loading = true;

  // Standard-Position (Dubai als Fallback)
  static const LatLng _defaultLocation = LatLng(25.2048, 55.2708);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      setState(() => _loading = false);
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permission denied');
      }

      if (permission == LocationPermission.deniedForever) throw Exception('Permission denied forever');

      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
        _controller?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Zugriff auf Übersetzungen
    final s = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.locationPickerTitle), // "Standort wählen"
        actions: [
          TextButton(
            onPressed: _selectedLocation == null
                ? null
                : () {
              Navigator.of(context).pop(_selectedLocation);
            },
            child: Text(
              s.saveLabel, // "Speichern"
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? _defaultLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _controller = controller,
            onTap: (pos) {
              setState(() => _selectedLocation = pos);
            },
            markers: _selectedLocation == null
                ? {}
                : {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLocation!,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_selectedLocation == null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s.tapMapHint, // "Bitte tippe auf die Karte..."
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}