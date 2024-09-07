import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  //Get User Location of the User
  Future<LatLng?> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable it
      return null;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, exit
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return null;
    }

    // Get the current location of the user
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLocation = LatLng(position.latitude, position.longitude);

    return userLocation;
  }

  Future<List<String>> getNearbyDeliveryPersons(LatLng userLocation) async {
    const double radiusInKm = 15; // Radius in kilometers
    final double lat = userLocation.latitude;
    final double lng = userLocation.longitude;

    // Fetch all documents from the 'DeliveryPersons' collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('DeliveryPersons')
        .where('active', isEqualTo: 'online')
        .get();

    List<String> nearbyDeliveryPersons = querySnapshot.docs
        .map((doc) {
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('geolocation')) {
            // Extract geolocation data
            String coordinatesString = data['geolocation'] as String;
            List<String> parts = coordinatesString.split(',');

            if (parts.length == 2) {
              double deliveryPersonLat = double.parse(parts[0].trim());
              double deliveryPersonLng = double.parse(parts[1].trim());

              // Calculate distance between the patient and the delivery person
              double distance = _calculateDistance(
                  lat, lng, deliveryPersonLat, deliveryPersonLng);

              // Check if the distance is within the specified radius
              if (distance <= radiusInKm) {
                return doc.id; // Return the delivery person ID
              }
            }
          }
          return null; // Return null if data is missing or not within radius
        })
        .whereType<String>() // Filter out null values
        .toList(); // Convert to list

    print("Delivery persons close to user location: $nearbyDeliveryPersons");
    return nearbyDeliveryPersons;
  }

  // Method to fetch pharmacies within a radius of 15 km
  Future<List<String>> getNearbyPharmacies(LatLng userLocation) async {
    const double radiusInKm = 15;
    final double lat = userLocation.latitude;
    final double lng = userLocation.longitude;

    // Fetch all documents from the 'pharmacies' collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('pharmacies').get();

    // Use map to transform documents into a list of pharmacy IDs
    List<String> nearbyPharmacies = querySnapshot.docs
        .map((doc) {
          // Ensure the document data is not null and contains the 'coordinates' field
          var data =
              doc.data() as Map<String, dynamic>?; // Safely cast document data
          if (data != null && data.containsKey('coordinates')) {
            String coordinatesString = data['coordinates'] as String;
            List<String> parts = coordinatesString.split(',');

            if (parts.length == 2) {
              double pharmacyLat = double.parse(parts[0].trim());
              double pharmacyLng = double.parse(parts[1].trim());

              // Calculate distance to determine if it's within the radius
              double distance =
                  _calculateDistance(lat, lng, pharmacyLat, pharmacyLng);

              if (distance <= radiusInKm) {
                return doc.id; // Return document ID if within radius
              }
            }
          }
          return null; // Return null for documents not within radius or with missing data
        })
        .whereType<
            String>() // Filter out null values and ensure non-nullable type
        .toList(); // Convert to list

    print("Pharmacies close to user location: $nearbyPharmacies");
    return nearbyPharmacies;
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
