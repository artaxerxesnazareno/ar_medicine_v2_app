import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  String nome;
  String email;
  String
      senha; // Note: In production, this should never be stored as plain text

  User({
    required this.nome,
    required this.email,
    required this.senha,
  });

  // Convert user to JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'senha': senha, // In real apps, never store raw passwords
    };
  }

  // Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
    );
  }

  // Create account
  static Future<bool> criarConta(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if email already exists
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      final emailExists = users.any((u) => u['email'] == user.email);
      if (emailExists) {
        return false; // Email already exists
      }

      // Add new user
      users.add(user.toJson());
      await prefs.setString('users', jsonEncode(users));

      // Set current user
      await prefs.setString('current_user', jsonEncode(user.toJson()));

      return true;
    } catch (e) {
      print('Error creating account: $e');
      return false;
    }
  }

  // Authentication
  static Future<User?> autenticar(String email, String senha) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get users
      final usersJson = prefs.getString('users') ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);

      // Find matching user
      final userJson = users.firstWhere(
        (u) => u['email'] == email && u['senha'] == senha,
        orElse: () => null,
      );

      if (userJson == null) {
        return null; // Authentication failed
      }

      // Create user object
      final user = User.fromJson(userJson);

      // Store current user
      await prefs.setString('current_user', jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      print('Error authenticating: $e');
      return null;
    }
  }

  // Get current logged in user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');

      if (userJson == null) {
        return null;
      }

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Logout current user
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }
}
