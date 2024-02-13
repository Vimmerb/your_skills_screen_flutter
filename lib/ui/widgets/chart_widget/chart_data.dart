import 'package:flutter/material.dart';
import 'package:skills/common/colors.dart';
import 'package:skills/ui/widgets/chart_widget/radar_map_model.dart';

List<IndicatorModel> indicators = [
  IndicatorModel('Духовность', 'assets/images/spheres/sphere_dollar.png', 7),
  IndicatorModel('Здоровье', 'assets/images/spheres/sphere_plus.png', 7),
  IndicatorModel('Карьера', 'assets/images/spheres/sphere_dollar.png', 7),
  IndicatorModel('Окружение', 'assets/images/spheres/sphere_people.png', 7),
  IndicatorModel('Любовь', 'assets/images/spheres/sphere_heart.png', 7),
  IndicatorModel('Личный рост', 'assets/images/spheres/sphere_dollar.png', 7),
  IndicatorModel('Творчество', 'assets/images/spheres/sphere_heart.png', 7),
  IndicatorModel('Отдых', 'assets/images/spheres/sphere_dollar.png', 7),
];

List<Color> splitAreaColors = [
  CustomColors.chartColor1,
  CustomColors.chartColor2,
  CustomColors.chartColor3,
  CustomColors.chartColor4,
  CustomColors.chartColor4,
  CustomColors.chartColor6,
  CustomColors.chartColor7,
];

List<double> mapData = [4, 4, 2.3, 1.3, 0.7, 5, 2, 4];
