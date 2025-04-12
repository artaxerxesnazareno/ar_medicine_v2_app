import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_journey.dart';
import '../models/quiz_model.dart';

class StorageService {
  static const String _userProgressKey = 'user_progress';
  static const String _currentUserIdKey = 'current_user_id';
  static const String _quizResultsKey = 'quiz_results';

  // User ID management (for demonstration, actual auth would be implemented separately)
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_currentUserIdKey);

    // If no user ID exists, create a new one (temporary ID for demo)
    if (userId == null) {
      userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_currentUserIdKey, userId);

      // Initialize empty user progress
      final userProgress = UserProgress.createNew(userId);
      await saveUserProgress(userProgress);
    }

    return userId;
  }

  // Save user progress
  static Future<void> saveUserProgress(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await prefs.setString(_userProgressKey, jsonString);
  }

  // Get user progress
  static Future<UserProgress?> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProgressKey);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString);
      return UserProgress.fromJson(json);
    } catch (e) {
      print('Error loading user progress: $e');
      return null;
    }
  }

  // Update journey progress
  static Future<void> updateJourneyProgress(
      String journeyId, JourneyProgress progress) async {
    final userProgress = await getUserProgress();
    if (userProgress == null) return;

    userProgress.journeyProgress[journeyId] = progress;
    await saveUserProgress(userProgress);
  }

  // Mark module as completed
  static Future<void> markModuleCompleted(
      String journeyId, String moduleId) async {
    final userProgress = await getUserProgress();
    if (userProgress == null) return;

    // Get or create journey progress
    JourneyProgress journeyProgress;
    if (userProgress.journeyProgress.containsKey(journeyId)) {
      journeyProgress = userProgress.journeyProgress[journeyId]!;
    } else {
      journeyProgress = JourneyProgress.createNew(journeyId);
      userProgress.journeyProgress[journeyId] = journeyProgress;
    }

    // Mark module as completed
    journeyProgress.completedModules[moduleId] = true;
    journeyProgress.lastAccessedDate = DateTime.now();

    // Save updated progress
    await saveUserProgress(userProgress);
  }

  // Save quiz result
  static Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing results
    List<QuizResult> results = await getQuizResults();

    // Add new result
    results.add(result);

    // Save all results
    final jsonList = results.map((r) => r.toJson()).toList();
    await prefs.setString(_quizResultsKey, jsonEncode(jsonList));

    // Update journey progress with quiz score
    final userProgress = await getUserProgress();
    if (userProgress != null) {
      JourneyProgress? journeyProgress =
          userProgress.journeyProgress[result.moduleId.split('-').first];
      if (journeyProgress != null) {
        journeyProgress.quizScores[result.moduleId] = result.score;
        await saveUserProgress(userProgress);
      }
    }
  }

  // Get all quiz results
  static Future<List<QuizResult>> getQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_quizResultsKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => QuizResult.fromJson(json)).toList();
    } catch (e) {
      print('Error loading quiz results: $e');
      return [];
    }
  }

  // Get quiz results for a specific module
  static Future<List<QuizResult>> getQuizResultsByModule(
      String moduleId) async {
    final allResults = await getQuizResults();
    return allResults.where((result) => result.moduleId == moduleId).toList();
  }

  // Clear all stored data (for testing/debugging)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
