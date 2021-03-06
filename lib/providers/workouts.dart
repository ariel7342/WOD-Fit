import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:wod_fit/models/workout_part.dart';
import '../providers/workout.dart';

class Workouts with ChangeNotifier {
  final String baseUrl = 'https://wod-fit-46e9a.firebaseio.com/';
  List<Workout> _workouts = [];

  final String authToken;
  final String userId;
  final FirebaseUser currentUser;

  Workouts(this.authToken, this.userId, this._workouts, this.currentUser);

  List<Workout> get workouts {
    return [..._workouts];
  }

  Workout findById(String id) {
    return _workouts.firstWhere((workout) => workout.id == id);
  }

  Future<void> fetchAndSetWorkouts([bool filterByUser = false]) async {
    final filterUrl =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = '$baseUrl/workouts.json?auth=$authToken&$filterUrl';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      } else {
        final List<Workout> loadedWorkouts = [];
        extractedData.forEach((workoutId, workoutData) {
          loadedWorkouts.add(Workout.fromJson(
            workoutData,
            workoutId,
          ));
        });
        _workouts = loadedWorkouts;
        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addWorkout(Workout workout) async {
    final url = '$baseUrl/workouts.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': workout.title,
            'creatorId': userId,
            'creatorImageUrl': currentUser.photoUrl,
            'workoutParts': json.encode(workout.workoutParts
                .map((workoutPart) => workoutPart.toJson())
                .toList()),
            'date': DateTime.now().millisecondsSinceEpoch,
          }));

      final newWorkout = Workout(
        title: workout.title,
        creatorId: workout.creatorId,
        id: json.decode(response.body)['name'],
        creatorImageUrl: currentUser.photoUrl,
        workoutParts: workout.workoutParts,
        date: DateTime.now(),
      );

      _workouts.add(newWorkout);
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteWorkout(String id) async {
    final url = '$baseUrl/workouts/$id.json?auth=$authToken';
    final existingWorkoutIndex =
        _workouts.indexWhere((workout) => workout.id == id);
    var existingWorkout = _workouts[existingWorkoutIndex];

    _workouts.removeAt(existingWorkoutIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _workouts.insert(existingWorkoutIndex, existingWorkout);
      notifyListeners();
      throw HttpException('Could not delete item');
    } else {
      existingWorkout = null;
    }
  }
}
