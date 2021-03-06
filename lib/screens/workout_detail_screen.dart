import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wod_fit/models/course.dart';
import 'package:wod_fit/models/enums.dart';
import 'package:wod_fit/models/exercise.dart';
import 'package:wod_fit/models/workout_part.dart';
import 'package:wod_fit/providers/workout.dart';
import 'package:wod_fit/utils/utils.dart';
import 'package:intl/intl.dart';
import '../providers/workouts.dart';

class Item {
  Item({
    this.workoutPart,
    this.isExpanded = false,
  });

  WorkoutPart workoutPart;
  bool isExpanded;
}

class WorkoutWithItem {
  final String id;
  final String title;
  final String creatorId;
  final String creatorImageUrl;
  final DateTime date;
  List<Item> workoutParts;

  WorkoutWithItem({
    @required this.id,
    @required this.title,
    @required this.creatorId,
    @required this.workoutParts,
    @required this.creatorImageUrl,
    @required this.date,
  });
}

WorkoutWithItem generateWorkoutWithItems(Workout workout) {
  return WorkoutWithItem(
    id: workout.id,
    title: workout.title,
    creatorId: workout.creatorId,
    creatorImageUrl: workout.creatorImageUrl,
    date: workout.date,
    workoutParts: List.generate(workout.workoutParts.length, (int index) {
      return Item(
        workoutPart: workout.workoutParts[index],
      );
    }),
  );
}

class WorkoutDetailScreen extends StatefulWidget {
  static const routeName = '/workout-detail';

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  WorkoutWithItem _data;
  var _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final itemId = ModalRoute.of(context).settings.arguments as String;
      final loadedWorkout = Provider.of<Workouts>(
        context,
        listen: false,
      ).findById(itemId);
      _data = generateWorkoutWithItems(loadedWorkout);
    }

    _isInit = true;
    super.didChangeDependencies();
  }

  String getCourseText(Course course) {
    if (course.type == courseType.Amrap || course.type == courseType.Emom) {
      return '${EnumToString.parse(course.type)} for ${course.time} minutes';
    } else {
      return '${course.sets.toString()} sets';
    }
  }

  List<Widget> getExercises(List<Exercise> exercsies) {
    return Utils.mapIndexed(
      exercsies,
      (index, Exercise exercsie) => Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  '${String.fromCharCode(0x2022)}  ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            new Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width * 0.7,
              child: new Column(
                children: <Widget>[
                  Text(
                    '${exercsie.description}',
                    softWrap: true,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ).toList();
  }

  List<Widget> getCourses(List<Course> courses) {
    return Utils.mapIndexed(
      courses,
      (index, Course course) => Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.topCenter,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      '- ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Text(
                  getCourseText(course),
                  softWrap: true,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            ...getExercises(course.exercises),
          ],
        ),
      ),
    ).toList();
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _data.workoutParts[index].isExpanded = !isExpanded;
          });
        },
        children: _data.workoutParts.map<ExpansionPanel>((Item item) {
          return ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  EnumToString.parse(item.workoutPart.type),
                ),
              );
            },
            canTapOnHeader: true,
            body: ListTile(
              title: Column(
                  children: <Widget>[...getCourses(item.workoutPart.courses)]),
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(_data.title),
              background: Hero(
                tag: _data.id,
                child: Image(
                  image: NetworkImage(
                      'https://source.unsplash.com/1600x900/?${_data.id}&gym'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Was uploaded in ${DateFormat.yMMMd().format(_data.date)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left),
                ),
                // ...getWorkoutparts(loadedWorkout.workoutParts),
                _buildPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
