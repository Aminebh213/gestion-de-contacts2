import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/person.dart';
import '../models/user.dart';

class ApiService {
  // Use localhost for web, 10.0.2.2 for Android emulator
  static String get baseUrl => kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  // ============= Authentication Methods =============
  
  // Register a new user
  static Future<User> register(String nom, String prenom, String numero, String motDePasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'prenom': prenom,
        'numero': numero,
        'mot_de_passe': motDePasse,
      }),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Erreur lors de l\'inscription');
    }
  }

  // Login user
  static Future<User> login(String numero, String motDePasse) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': numero,
        'mot_de_passe': motDePasse,
      }),
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Erreur de connexion');
    }
  }

  // ============= Person Methods =============

  // Récupérer toutes les personnes
  static Future<List<Person>> getPersons(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/personnes/$userId'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Person.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors du chargement des personnes');
    }
  }

  // Rechercher des personnes
  static Future<List<Person>> searchPersons(int userId, String query) async {
    final response = await http.get(Uri.parse('$baseUrl/personnes/search/$userId/$query'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Person.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }



  // Récupérer une personne par ID
  static Future<Person> getPerson(int userId, int id) async {
    final response = await http.get(Uri.parse('$baseUrl/personnes/detail/$userId/$id'));
    
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Personne non trouvée');
    }
  }



  // Ajouter une personne
  static Future<Person> addPerson(Person person) async {
    final response = await http.post(
      Uri.parse('$baseUrl/personnes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de la personne');
    }
  }


  // Mettre à jour une personne
  static Future<Person> updatePerson(int userId, int id, Person person) async {
    final response = await http.put(
      Uri.parse('$baseUrl/personnes/$userId/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(person.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Person.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la personne');
    }
  }




  // Supprimer une personne
  static Future<void> deletePerson(int userId, int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/personnes/$userId/$id'));
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la personne');
    }
  }
}
