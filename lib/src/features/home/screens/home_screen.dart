import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/image_const.dart';
import '../../../core/constants/string_const.dart';
import '../../../core/themes/text_styles.dart';
import '../../../core/utils/utils.dart';
import '../../../views/widgets/padding.dart';
import '../bloc/home_bloc.dart';
import '../models/weather_one_call_model.dart';
import '../widgets/dialy_weather_widget.dart';
import '../widgets/hourly_weather_widget.dart';
import '../widgets/weather_detail_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomeBloc()..getLocation(),
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeFailed) {
              showSnackBar(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Loading();
            }
            if (state is HomeSuccess) {
              final weather = state.weatherData;
              return SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      CurrentWeather(place: state.place, weather: weather),
                      WeatherDetailsWidget(curWeather: weather.current),
                      padding16,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.topLeft,
                        child: Text(
                          "24 Hours",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      padding16,
                      HourlyWeatherWidget(hourWeather: weather.hourly),
                      padding16,
                      DailyWeatherWidget(dailyWeather: weather.daily)
                    ],
                  ),
                ),
              );
            }
            if (state is HomeFailed) {
              return SomethingWentWrong(message: state.error);
            }
            if (state is HomeLocationNotEnabled) {
              if (state.error == locationDisabledError) {
                return Center(
                  child: Text(
                    'Location services are disabled.\nPlease Restart app after enabling it.',
                    style: subTitleTextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }
              return SomethingWentWrong(message: state.error);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({
    Key? key,
    required this.place,
    required this.weather,
  }) : super(key: key);

  final String place;
  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return SizedBox(
      width: _size.width,
      child: Stack(
        children: [
          Positioned(
            top: -_size.width * 0.10,
            right: -_size.width * 0.05,
            child: Image.asset(
              ImageAssets.getAsset(weather.current.weather.first.icon),
              height: _size.height * 0.50,
              width: _size.width * 0.90,
            ),
          ),
          Container(
            width: _size.width * 0.60,
            padding: EdgeInsets.symmetric(
                horizontal: _size.width * 0.08, vertical: _size.height * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  place,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: theme.colorScheme.secondary),
                  textAlign: TextAlign.center,
                ),
                padding8,
                Text('${weather.current.temp}°',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headline6?.copyWith(
                      fontSize: 64,
                      color: theme.colorScheme.tertiary,
                    )),
                padding16,
                WeatherTypeChip(title: weather.current.weather.first.main),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherTypeChip extends StatelessWidget {
  const WeatherTypeChip({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        title,
        style: theme.textTheme.titleMedium
            ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
        textAlign: TextAlign.center,
      ),
    );
  }
}
