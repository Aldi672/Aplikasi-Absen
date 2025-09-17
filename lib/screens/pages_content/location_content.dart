import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  GoogleMapController? _mapController;
  // Posisi default diatur ke Monas, Jakarta
  LatLng _currentPosition = const LatLng(-6.175392, 106.827153);
  String _currentAddress =
      "Tekan tombol untuk mendapatkan lokasi & alamat Anda.";
  Marker? _marker;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bagian Peta Google Maps
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                markers: _marker != null ? {_marker!} : {},
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
            ),
          ),

          // Bagian Informasi Lokasi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Koordinat
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Koordinat: ${_currentPosition.latitude.toStringAsFixed(5)}, ${_currentPosition.longitude.toStringAsFixed(5)}",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Info Alamat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_pin, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : _getCurrentLocation, // Nonaktifkan saat loading
                    icon: _isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isLoading ? "Mencari Lokasi..." : "Lokasi Terkini",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    // 1. Mulai state loading dan update UI
    setState(() {
      _isLoading = true;
      _currentAddress = "Mencari alamat...";
    });

    try {
      // 2. Cek izin dan layanan lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen, buka pengaturan.');
      }

      // 3. Ambil posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);

      // 4. Konversi koordinat menjadi alamat (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      String address = "Alamat tidak ditemukan.";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Gabungkan alamat menjadi format yang lebih rapi
        address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
      }

      // 5. Update UI dengan data yang ditemukan
      setState(() {
        _currentAddress = address;
        _marker = Marker(
          markerId: const MarkerId("lokasi_saat_ini"),
          position: _currentPosition,
          infoWindow: InfoWindow(title: 'Lokasi Anda', snippet: address),
        );
      });

      // 6. Arahkan kamera peta ke lokasi baru
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    } catch (e) {
      // Tangani jika ada error
      setState(() {
        _currentAddress = "Gagal mendapatkan lokasi: ${e.toString()}";
      });
    } finally {
      // 7. Selesaikan state loading
      setState(() {
        _isLoading = false;
      });
    }
  }
}
