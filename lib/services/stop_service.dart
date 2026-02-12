import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/stop_model.dart';

class StopService {
  static const _cacheKey = 'ls_stops_cache';

  // Return cached stops if available; otherwise return built-in mock.
  static List<StopModel> getStops() {
    // Try to read cache synchronously is not possible, so keep returning mock data here.
    // Consumers should listen to AlarmService which will refresh stops after async fetch.
    return [
      StopModel(id: 's1', name: 'Central Park', position: const LatLng(49.8015, 73.1094)),
      StopModel(id: 's2', name: 'Main Street', position: const LatLng(49.8020, 73.1100)),
      StopModel(id: 's3', name: 'University', position: const LatLng(49.8060, 73.0860)),
      StopModel(id: 's4', name: 'Airport', position: const LatLng(49.6708, 73.3344)),
      StopModel(id: 's5', name: 'Buhar Jirau (Terminal)', position: const LatLng(49.8010, 73.1090)),
    ];
  }

  // Fetch stops from Overpass (OSM) for Karaganda bbox and cache result.
  static Future<List<StopModel>> fetchAndCacheStops() async {
    try {
      final bbox = '49.60,73.00,49.90,73.35';
      final query = '''[out:json][timeout:25];
        (
          node["highway"="bus_stop"]($bbox);
          node["public_transport"="platform"]($bbox);
        );
        out;''';

      final uri = Uri.parse('https://overpass-api.de/api/interpreter');
      final res = await http.post(uri, body: {'data': query});
      if (res.statusCode != 200) throw Exception('Overpass error ${res.statusCode}');

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final List elements = data['elements'] ?? [];
      final List<StopModel> stops = elements.where((e) => e['lat'] != null && e['lon'] != null).map((e) {
        final id = e['id'].toString();
        final tags = e['tags'] as Map<String, dynamic>?;
        final name = (tags != null && tags['name'] != null) ? tags['name'].toString() : 'Stop $id';
        final lat = e['lat'] as num;
        final lon = e['lon'] as num;
        return StopModel(id: 'osm_\$id', name: name, position: LatLng(lat.toDouble(), lon.toDouble()));
      }).toList();

      // cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(elements));

      return stops;
    } catch (e) {
      return getStops();
    }
  }

  // Try to read cached stops from SharedPreferences (async).
  static Future<List<StopModel>> readCachedStops() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return getStops();
    try {
      final List elements = jsonDecode(raw) as List;
      final List<StopModel> stops = elements.where((e) => e['lat'] != null && e['lon'] != null).map((e) {
        final id = e['id'].toString();
        final tags = e['tags'] as Map<String, dynamic>?;
        final name = (tags != null && tags['name'] != null) ? tags['name'].toString() : 'Stop $id';
        final lat = e['lat'] as num;
        final lon = e['lon'] as num;
        return StopModel(id: 'osm_\$id', name: name, position: LatLng(lat.toDouble(), lon.toDouble()));
      }).toList();
      return stops;
    } catch (e) {
      return getStops();
    }
  }

  static StopModel? getById(String id) {
    final list = getStops();
    try {
      return list.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  static StopModel? getPreLastStop(List<StopModel> stops, StopModel lastStop) {
    final index = stops.indexOf(lastStop);
    if (index <= 0) return null;
    return stops[index - 1];
  }
}
