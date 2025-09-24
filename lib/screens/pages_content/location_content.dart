// pages_content/location_content.dart - With Address Display and Manual Refresh Only
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCard extends StatefulWidget {
  final Function(Position? position, String fullAddress) onLocationUpdate;
  const LocationCard({super.key, required this.onLocationUpdate});

  @override
  State<LocationCard> createState() => LocationCardState();
}

class LocationCardState extends State<LocationCard>
    with TickerProviderStateMixin {
  static const LatLng _officeLocation = LatLng(-6.210437, 106.813966);
  static const double _boundaryRadius = 50; // Radius 50 meter

  // --- State Variables ---
  Position? currentPosition;
  String currentAddress = "Klik refresh untuk mendapatkan lokasi";
  String fullAddress = ""; // Untuk alamat lengkap
  bool isLoadingLocation = false;
  bool isLoadingAddress = false;
  bool isMapExpanded = false;

  // --- Map Controllers & State ---
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    // Hapus pemanggilan _getCurrentLocation() agar tidak otomatis load
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        throw Exception("Layanan lokasi tidak aktif. Silakan aktifkan GPS.");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception(
            "Izin lokasi ditolak. Aplikasi memerlukan izin untuk berfungsi.",
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Izin lokasi ditolak permanen. Aktifkan di pengaturan aplikasi.",
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      if (mounted) {
        setState(() {
          currentPosition = position;
          currentAddress = _formatCoordinatesFromPosition(position);
        });
        _updateMapElements(position);
        _animateToCurrentLocation();
        _getAddressFromPosition(position); // Dapatkan alamat lengkap
        widget.onLocationUpdate(currentPosition, fullAddress);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentAddress = "Gagal mendapatkan lokasi: ${e.toString()}";
          fullAddress = "";
        });
        widget.onLocationUpdate(null, "");
      }
    } finally {
      if (mounted) setState(() => isLoadingLocation = false);
    }
  }

  Future<void> _getAddressFromPosition(Position position) async {
    if (!mounted) return;
    setState(() => isLoadingAddress = true);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks.first;
        String address = _buildAddressString(place);
        setState(() => fullAddress = address);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          fullAddress = "Gagal mendapatkan alamat lengkap";
        });
      }
    } finally {
      if (mounted) setState(() => isLoadingAddress = false);
    }
  }

  String _buildAddressString(Placemark place) {
    return [
      if (place.name != null && place.name!.isNotEmpty) place.name,
      if (place.street != null && place.street!.isNotEmpty) place.street,
      if (place.subLocality != null && place.subLocality!.isNotEmpty)
        place.subLocality,
      if (place.locality != null && place.locality!.isNotEmpty) place.locality,
      if (place.subAdministrativeArea != null &&
          place.subAdministrativeArea!.isNotEmpty)
        place.subAdministrativeArea,
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty)
        place.administrativeArea,
    ].where((s) => s != null).join(', ');
  }

  void _updateMapElements(Position userPosition) {
    if (!mounted) return;
    final LatLng userLatLng = LatLng(
      userPosition.latitude,
      userPosition.longitude,
    );

    _markers.clear();
    _circles.clear();

    // 1. Marker untuk Lokasi Pengguna
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: userLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: 'Lokasi Anda',
          snippet: fullAddress.isNotEmpty ? fullAddress : 'Memuat alamat...',
        ),
      ),
    );

    // 2. Lingkaran Akurasi di Lokasi Pengguna
    _circles.add(
      Circle(
        circleId: const CircleId('accuracy_circle'),
        center: userLatLng,
        radius: userPosition.accuracy,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue.withOpacity(0.3),
        strokeWidth: 1,
      ),
    );

    // 3. Marker untuk Lokasi Kantor
    _markers.add(
      Marker(
        markerId: const MarkerId('office_location'),
        position: _officeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Lokasi PPKD',
          snippet: 'Titik referensi absensi',
        ),
      ),
    );

    // 4. Lingkaran Batas di Lokasi Kantor
    _circles.add(
      Circle(
        circleId: const CircleId('boundary_circle'),
        center: _officeLocation,
        radius: _boundaryRadius,
        fillColor: Colors.transparent,
        strokeColor: Colors.red.withOpacity(0.7),
        strokeWidth: 2,
      ),
    );

    setState(() {});
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              currentPosition!.latitude,
              currentPosition!.longitude,
            ),
            zoom: 18.0,
            tilt: 30,
          ),
        ),
      );
    }
  }

  void _changeMapType(MapType mapType) {
    setState(() => _currentMapType = mapType);
  }

  String _formatCoordinatesFromPosition(Position position) {
    return "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
  }

  bool _isWithinBoundary() {
    if (currentPosition == null) return false;
    double distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );
    return distance <= _boundaryRadius;
  }

  // --- UI BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationInfo(),
          if (isMapExpanded) _buildInteractiveMap(),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: currentPosition == null
                    ? Colors.grey
                    : (_isWithinBoundary() ? Colors.green : Colors.red),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Radius kerja: ${_boundaryRadius.toInt()}m dari kantor',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isMapExpanded ? Icons.keyboard_arrow_up : Icons.map_outlined,
                  color: Colors.blue,
                ),
                onPressed: () => setState(() => isMapExpanded = !isMapExpanded),
              ),
              IconButton(
                icon: isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, color: Colors.blue),
                onPressed: isLoadingLocation ? null : _getCurrentLocation,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alamat Lengkap:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentPosition != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (_isWithinBoundary() ? Colors.green : Colors.red)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isWithinBoundary() ? 'DALAM AREA' : 'LUAR AREA',
                          style: TextStyle(
                            color: _isWithinBoundary()
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (currentPosition == null)
                  const Text(
                    'Klik tombol refresh untuk memuat lokasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else if (isLoadingAddress)
                  const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Memuat alamat...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else if (fullAddress.isNotEmpty)
                  Text(
                    fullAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  )
                else
                  const Text(
                    'Alamat tidak tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                if (currentPosition != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koordinat:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Akurasi: ${currentPosition!.accuracy.toStringAsFixed(1)}m',
                              style: TextStyle(
                                fontSize: 11,
                                color: _getAccuracyColor(
                                  currentPosition!.accuracy,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Jarak: ${_getDistanceToOffice()}m',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isWithinBoundary()
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap() {
    return Column(
      children: [
        const Divider(height: 1, indent: 20, endIndent: 20),
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition != null
                        ? LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          )
                        : _officeLocation,
                    zoom: 18.0,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  mapType: _currentMapType,
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (currentPosition != null)
                  PulsingBoundaryCircle(
                    officeLocation: _officeLocation,
                    boundaryRadius: _boundaryRadius,
                  ),
              ],
            ),
          ),
        ),
        if (currentPosition != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  label: 'Lokasi Saya',
                  onPressed: _animateToCurrentLocation,
                  color: Colors.blue,
                ),
                _buildMapControlButton(
                  icon: Icons.business,
                  label: 'Lokasi PPKD',
                  onPressed: () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(_officeLocation, 18.0),
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 10) return Colors.green.shade700;
    if (accuracy <= 20) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _getDistanceToOffice() {
    if (currentPosition == null) return "0";
    double distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );
    return distance.toStringAsFixed(1);
  }
}

// === WIDGET ANIMASI UNTUK BOUNDARY CIRCLE ===
class PulsingBoundaryCircle extends StatefulWidget {
  final LatLng officeLocation;
  final double boundaryRadius;

  const PulsingBoundaryCircle({
    super.key,
    required this.officeLocation,
    required this.boundaryRadius,
  });

  @override
  State<PulsingBoundaryCircle> createState() => _PulsingBoundaryCircleState();
}

class _PulsingBoundaryCircleState extends State<PulsingBoundaryCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.05, end: 0.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final screenRadius = widget.boundaryRadius * 5;
            return Container(
              width: screenRadius * 2,
              height: screenRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(_pulseAnimation.value),
              ),
            );
          },
        ),
      ),
    );
  }
}
