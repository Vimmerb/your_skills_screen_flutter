import 'package:flutter/material.dart';
import 'package:skills/common/colors.dart';

// Тип формы диаграммы: круг и квадрат
enum Shape { circle, square }

class RadarMapModel {
  List<MapDataModel> data; // данные диаграммы
  List<IndicatorModel> indicator; // подписи осей диаграммы
  Shape shape; // форма
  double radius; // радиус
  int alpha; // прозрачность фона (диапазон от 0 до 255)
  LineModel? line; // модель линий
  double? outTextSize; // размер внешнего текста
  double? maxWidth; // максимальная ширина
  SplitAreaStyle splitAreaStyle; // стиль областей разделения

  RadarMapModel({
    required this.data,
    required this.indicator,
    required this.radius,
    this.shape = Shape.circle,
    this.line,
    this.alpha = 80,
    this.outTextSize,
    this.maxWidth,
    this.splitAreaStyle = const SplitAreaStyle(),
  });
}

// Линии диаграммы
class LineModel {
  final int line;
  final Color? ringColor; // цвет бордера внутренних колец
  double? widthLineRing; // ширина линий бордера внутренних колец
  final Color? axisColor; // цвет линии осей
  final double? textFontSize;
  final Color? textColor;

  LineModel(this.line,
      {this.ringColor,
      this.axisColor,
      this.widthLineRing,
      this.textFontSize,
      this.textColor});
}

//  модель подписи осей
class IndicatorModel {
  final String name; // имя оси
  final String imagePath; // изображение
  final double maxValues; // максимальное значение подписи оси

  IndicatorModel(
    this.name,
    this.imagePath,
    this.maxValues,
  );
}

// модель области построения диаграммы
class MapDataModel {
  final List<double> data; // Данные
  final ConnectLineStyle? connectLineStyle; // Стиль соединительных линий
  final DataAreaStyle dataAreaStyle; // Стиль области построения дмаграммы
  DataMarkerStyle dataMarkerStyle; // Стиль маркера данных (точки)

  MapDataModel(this.data,
      {this.connectLineStyle,
      this.dataAreaStyle = const DataAreaStyle(),
      this.dataMarkerStyle = const DataMarkerStyle()});
}

// Стиль области разделения (кольца диаграммы)
class SplitAreaStyle {
  final List<Color> colors; // значения цветов колец диаграммы
  final int alpha; // прозрачность
  final bool showLines; // Показывать ли линии разделения между кольцами
  final Color? splitLineColor; // Цвет линий разделения

  const SplitAreaStyle({
    this.colors = const [],
    this.alpha = 50,
    this.showLines = true,
    this.splitLineColor,
  });
}

// область построения диаграммы
class DataAreaStyle {
  final Color color; // цвет фона области построения
  final int alpha; // прозрачность фона
  const DataAreaStyle(
      {this.color = CustomColors.chartAreaColor,
      this.alpha = 0}); //цвет бордера области построения диаграммы
}

// Стиль области данных
class DataMarkerStyle {
  final double size;
  final Color? color;
  final int alpha;
// точки диаграммы
  const DataMarkerStyle({this.size = 3, this.color, this.alpha = 1});
}

// линии соединения точек (маркеров)
class ConnectLineStyle {
  Color color;
  double width;
  // double? shadowBlurRadius; // радиус размытия тени
  // Color? shadowColor; // цвета тени
  ConnectLineStyle({
    required this.color,
    required this.width,
    // this.shadowBlurRadius,
    // this.shadowColor,
  });
}
