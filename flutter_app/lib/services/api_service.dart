import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/schedule.dart';
import '../models/registration.dart';

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  String? _token;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null && _currentUser != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> _saveSession(String token, User user) async {
    _token = token;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'createdAt': user.createdAt.toIso8601String(),
    }));
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/register'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      final user = User.fromJson(data['user']);
      await _saveSession(data['token'], user);
      return {'success': true};
    }
    return {'success': false, 'error': data['error'] ?? 'Error al registrar'};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final user = User.fromJson(data['user']);
      await _saveSession(data['token'], user);
      return {'success': true};
    }
    return {'success': false, 'error': data['error'] ?? 'Credenciales inválidas'};
  }

  Future<List<Event>> getEvents({int? categoryId, String? search}) async {
    String url = '${AppConfig.baseUrl}/events';
    final params = <String, String>{};
    if (categoryId != null) params['categoryId'] = categoryId.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Event.fromJson(e)).toList();
    }
    throw Exception('Error al cargar eventos');
  }

  Future<Event> getEvent(int id) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/events/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    }
    throw Exception('Evento no encontrado');
  }

  Future<Event> createEvent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/events'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Error al crear evento');
  }

  Future<Event> updateEvent(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}/events/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Error al actualizar evento');
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/events/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Error al eliminar evento');
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/categories'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Category.fromJson(e)).toList();
    }
    throw Exception('Error al cargar categorías');
  }

  Future<Category> createCategory(String name, {String? description}) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/categories'),
      headers: _headers,
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 201) {
      return Category.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear categoría');
  }

  Future<List<Location>> getLocations() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/locations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Location.fromJson(e)).toList();
    }
    throw Exception('Error al cargar ubicaciones');
  }

  Future<List<Schedule>> getSchedules(int eventId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/events/$eventId/schedules'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Schedule.fromJson(e)).toList();
    }
    throw Exception('Error al cargar agenda');
  }

  Future<Schedule> createSchedule(int eventId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/events/$eventId/schedules'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Schedule.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear sesión');
  }

  Future<void> deleteSchedule(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/schedules/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar sesión');
    }
  }

  Future<List<Registration>> getRegistrations(int userId) async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/registrations?userId=$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Registration.fromJson(e)).toList();
    }
    throw Exception('Error al cargar inscripciones');
  }

  Future<Registration> createRegistration(int userId, int eventId) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/registrations'),
      headers: _headers,
      body: jsonEncode({'userId': userId, 'eventId': eventId}),
    );
    if (response.statusCode == 201) {
      return Registration.fromJson(jsonDecode(response.body));
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Error al inscribirse');
  }

  Future<void> deleteRegistration(int id) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}/registrations/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Error al cancelar inscripción');
    }
  }
}
