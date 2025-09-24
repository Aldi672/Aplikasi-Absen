// Enhanced Location Status Card - Widget Terpisah
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EnhancedLocationStatusCard extends StatelessWidget {
  final bool isWithinOfficeRadius;
  final double distanceToOffice;
  final Position? currentPosition;

  const EnhancedLocationStatusCard({
    super.key,
    required this.isWithinOfficeRadius,
    required this.distanceToOffice,
    required this.currentPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Background putih solid untuk kontras yang jelas
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Shadow yang lebih dramatis
        boxShadow: [
          BoxShadow(
            color: isWithinOfficeRadius
                ? Colors.green.withOpacity(0.4)
                : Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // Border yang lebih tebal dan kontras
        border: Border.all(
          color: isWithinOfficeRadius
              ? Colors.green.shade400
              : Colors.red.shade400,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          // Header dengan ikon dan status utama
          Row(
            children: [
              // Container ikon dengan background warna
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isWithinOfficeRadius
                      ? Colors.green.shade500
                      : Colors.red.shade500,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isWithinOfficeRadius ? Colors.green : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isWithinOfficeRadius
                      ? Icons.verified_user_rounded
                      : Icons.location_disabled_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status utama dengan font yang lebih besar dan bold
                    Text(
                      isWithinOfficeRadius
                          ? 'DALAM AREA PPKD'
                          : 'LUAR AREA PPKD',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isWithinOfficeRadius
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Sub-status dengan informasi jarak
                    Text(
                      currentPosition != null
                          ? 'Jarak: ${distanceToOffice.toStringAsFixed(1)}m dari PPKD'
                          : 'Menunggu data lokasi...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge status dengan warna kontras
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isWithinOfficeRadius
                      ? Colors.green.shade500
                      : Colors.red.shade500,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isWithinOfficeRadius ? Colors.green : Colors.red)
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isWithinOfficeRadius ? 'AKTIF' : 'NON-AKTIF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Informasi detail dengan background berwarna
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isWithinOfficeRadius
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWithinOfficeRadius
                    ? Colors.green.shade200
                    : Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Ikon informasi
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isWithinOfficeRadius
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isWithinOfficeRadius
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    color: isWithinOfficeRadius
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWithinOfficeRadius
                            ? 'Lokasi Valid untuk Absensi'
                            : 'Mohon Dekati Area PPKD',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isWithinOfficeRadius
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isWithinOfficeRadius
                            ? 'Anda dapat melakukan check-in/check-out'
                            : 'Batas maksimal: 50 meter dari kantor',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar untuk visualisasi jarak
          if (currentPosition != null) ...[
            const SizedBox(height: 12),
            _buildDistanceProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildDistanceProgressBar() {
    final maxDistance = 100.0; // Maksimal 100 meter untuk visualisasi
    final progress =
        (maxDistance - distanceToOffice.clamp(0, maxDistance)) / maxDistance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visualisasi Jarak',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${distanceToOffice.toStringAsFixed(1)}m / 50m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWithinOfficeRadius
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isWithinOfficeRadius
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Marker untuk batas 50m
                  Positioned(
                    left:
                        constraints.maxWidth *
                        0.5, // 50% untuk 50m dari 100m max
                    child: Container(
                      width: 2,
                      height: 8,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 2, color: Colors.orange.shade600),
            const SizedBox(width: 4),
            Text(
              'Batas Area (50m)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
