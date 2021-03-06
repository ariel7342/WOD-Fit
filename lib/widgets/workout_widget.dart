import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wod_fit/screens/workout_detail_screen.dart';
import 'package:wod_fit/widgets/workout_title_view.dart';
import '../providers/workout.dart';
import '../providers/auth.dart';

class WorkoutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final authData = Provider.of<Auth>(context, listen: false);
    final workout = Provider.of<Workout>(context, listen: false);
    final userImageUrl = Provider.of<Auth>(context, listen: false).imageUrl;

    return WorkoutTitleView(
      name: workout.title,
      date: DateFormat.yMMMd().format(workout.date),
      workoutId: workout.id,
      userImageUrl: userImageUrl,
      press: () => Navigator.of(context).pushNamed(
        WorkoutDetailScreen.routeName,
        arguments: workout.id,
      ),
    );
  }
}
