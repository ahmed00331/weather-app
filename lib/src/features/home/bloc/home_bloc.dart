// ignore_for_file: invalid_use_of_visible_for_testing_member, unnecessary_brace_in_string_interps, avoid_print, non_constant_identifier_names

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/utils.dart';
import '../models/weather_one_call_model.dart';
import '../resources/home_repository.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial());

  static HomeBloc get(context) => BlocProvider.of(context);
  final _repository = HomeRepository();
  late Database database;
  double? lat;
  double? long;
  List<Map> weather = [];

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is GetHomeData) {
      yield* _mapGetHomeDataEventToState(event);
    }
    if (event is LocationError) {
      yield* _mapLocationNotEnabledToState(event);
    }
  }

  Stream<HomeState> _mapLocationNotEnabledToState(LocationError event) async* {
    yield HomeLocationNotEnabled(event.error);
  }

  Stream<HomeState> _mapGetHomeDataEventToState(GetHomeData event) async* {
    yield HomeLoading();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('lat', event.lat);
    prefs.setDouble('long', event.long);
    // try {
    Response response =
        await _repository.getHomeData(lat: event.lat, long: event.long);
    Response gRes =
        await _repository.getLocationName(lat: event.lat, long: event.long);
    // print(response.data);
    if (response.statusCode == 200) {
      final weatherData = WeatherData.fromJson(response.data);

      final place =
          gRes.data['results'][0]["address_components"][1]["long_name"];
      // final gData = GMapData.fromJson(gRes.data);
      // final place = gData.results[0].addressComponents[1].longName;
      yield HomeSuccess(weatherData, place);
    } else {
      yield HomeFailed(response.data['message']);
    }
    // } catch (e) {
    //   yield HomeFailed(e.toString());
    // }
  }

  void getLocation() async {
    try {
      Position pos = await determinePosition();
      lat = pos.latitude;
      long = pos.longitude;
      add(GetHomeData(lat: lat!, long: long!));
    } catch (err) {
      // showSnackBar(context, err.toString());
      add(LocationError(err.toString()));
    }
  }

  void CreateDataBase() {
    openDatabase('weather.db', version: 1, onCreate: (databse, version) {
      print('database created');
      databse
          .execute(
              'CREATE TABLE weather (id INTEGER PRIMARY KEY , title TEXT,date TEXT,time TEXT,status TEXT)')
          .then((value) {
        print('table Created');
      }).catchError((error) {
        print('Error when creating table ${error}');
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      print('database opend');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseStates());
    });
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO weather(title, date, time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        emit(AppInsertDatabaseStates());
        getDataFromDatabase(database);
        print('$value inserted successfully');
      }).catchError((error) {
        print('Error when new record inserted ${error.toString()} ');
      });
    });
  }

  void getDataFromDatabase(database) {
    weather = [];

    emit(getDatabaseLoadingState());
    database.rawQuery('SELECT * FROM weather').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          weather.add(element);
        }
      });
      emit(AppGetDatabaseStates());
    });
  }
}
