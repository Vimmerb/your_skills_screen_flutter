import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:skills/ui/widgets/chart_widget/radar_map_model.dart';
import 'package:skills/ui/widgets/chart_widget/radar_utils.dart';
// import 'package:flutter/services.dart';

@immutable
class RadarWidget extends StatefulWidget {
  // передаваемые данные
  final RadarMapModel radarMap;
  final TextStyle? textStyle;
  // наклон/смещение диаграммы вправо/лево
  // (использовала для корректировки положения диаграммы относительно центра экрана)
  final double? skewing;
  // конструктор виджета диаграммы
  const RadarWidget(
      {Key? key,
      required this.radarMap,
      this.textStyle = const TextStyle(color: Colors.black),
      this.skewing})
      : super(key: key);

  @override
  _RadarMapWidgetState createState() => _RadarMapWidgetState();
}

class _RadarMapWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  double top = 27;
  double bottom = 27;
  // Список узлов (точек)
  List<Rect> node = [];
  final _counter = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Вычисляем значение переменной sk (перекос) на основе widget.skewing.
    // Если widget.skewing равно null, то присваиваем 0.0.
    // Если значение sk больше 40, то ограничиваем его значением 40.
    double sk = (widget.skewing ?? 0.0) > 40 ? 40 : (widget.skewing ?? 0.0);
    // Если значение sk меньше 0, то устанавливаем его равным 0.
    if (sk < 0) {
      sk = 0;
    }
    // получаем ширину экрана
    var w = MediaQuery.of(context).size.width;
    // Создаём экземпляр RadarMapPainter, который будет рисовать радарную диаграмму.
    var painter = RadarMapPainter(
      w,
      top,
      widget.radarMap,
      (t, b) {
        setState(() {
          top = t;
          bottom = b;
        });
      },
      node,
      sk,
      textStyle: widget.textStyle,
      repaint: _counter,
    );

    // Создаём CustomPaint, который будет рисовать полученный RadarMapPainter.
    // Устанавливаем размер CustomPaint с учётом высоты радарной диаграммы и отступов.
    CustomPaint paint = CustomPaint(
      size: Size(
          w,
          RadarUtils.getHeight(widget.radarMap.radius,
                  widget.radarMap.indicator.length, widget.radarMap.shape) +
              bottom +
              top),
      painter: painter,
    );

    return Column(children: [
      paint,
    ]);
  }
}

// типы функций typedef удобны, когда необходимо объявить функциональные
// типы данных, которые позволяют создавать более гибкие и читаемые функции
// и передавать их как параметры или возвращать из других функций.
typedef WidthHeight = Function(double w, double h);

// класс RadarMapPainter - это настраиваемая кисть,
// которая выполняет отрисовку радарной диаграммы на холсте (canvas).
class RadarMapPainter extends CustomPainter {
  RadarMapModel radarMap; // Модель данных для радарной диаграммы
  late Paint mLinePaint; // Кисть для рисования линий
  late Paint mLineInnerPaint; // Кисть для рисования внутренних линий
  late Paint mAreaPaint; // Кисть для рисования областей
  Paint? mFillPaint; // Кисть для заливки областей
  TextStyle? textStyle; // Стиль текста
  late Path mLinePath; // Путь для соединительных линий
  late int elementLength; // Количество измерений (элементов)
  final WidthHeight _widthHeight;
  double w; // Ширина холста
  double top;
  List<Rect> node; // Список узлов (точек)
  double skewing; // Список узлов (точек)
  RadarMapPainter(this.w, this.top, this.radarMap, this._widthHeight, this.node,
      this.skewing,
      {this.textStyle, Listenable? repaint})
      : super(repaint: repaint) {
    mLinePath = Path();
    mLinePaint = Paint()
      ..color = Colors.grey // Цвет линий - серый
      ..style = PaintingStyle.stroke // Стиль - обводка
      ..strokeWidth = 0.008 * radarMap.radius // Толщина линий
      ..isAntiAlias = true; // Сглаживание
    mFillPaint = Paint() // Кисть для заливки областей
      ..strokeWidth = 0.05 * radarMap.radius // Толщина заливки
      ..color = Colors.black // Цвет заливки
      ..isAntiAlias = true; // Сглаживание
    mLineInnerPaint = Paint()
      ..strokeWidth = 1.5 // Толщина внутренних линий
      ..style = PaintingStyle.stroke // Стиль - обводка
      ..strokeJoin = StrokeJoin.round; // Сглаживание углов
    mAreaPaint = Paint()..isAntiAlias = true; // Кисть для рисования областей
    elementLength = radarMap.indicator.length; // Количество измерений
  }

  @override
  //   рисуем радарную диаграмму
  void paint(Canvas canvas, Size size) {
    canvas.translate(
        w / 2 - skewing,
        radarMap.radius +
            top); // перемещение начала координат холста относительно текущего начала координат
    // вызов функции, которая использует переданный холст и размер для отрисовки внутренних кругов и линий
    drawInnerCircle(canvas, size);
    var maxValue =
        radarMap.indicator.map((item) => item.maxValues).toList().reduce(max);

    ///draw splitArea
    // Создание переменной для хранения предыдущего пути радиальной диаграммы
    Path previousRadarMapPath;
    // Внутри метода drawInnerCircle
    /// draw split area
    /// Цикл для рисования областей разделения даграммы (внутренние кольца)
    for (int i = 0; i < radarMap.splitAreaStyle.colors.length; i++) {
      previousRadarMapPath = getBackgroundPath(
        canvas,
        i * maxValue / radarMap.splitAreaStyle.colors.length,
        maxValue,
      );
      // Получение пути для текущей области диаграммы
      Path radarMapPath = getBackgroundPath(
        canvas,
        (i + 1) * maxValue / radarMap.splitAreaStyle.colors.length,
        maxValue,
      );
      // Нарисовать текущую область, вычитая предыдущую область
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          radarMapPath,
          previousRadarMapPath,
        ),
        mAreaPaint
          ..color = radarMap.splitAreaStyle.colors[i]
              .withAlpha(radarMap.splitAreaStyle.alpha),
      );
    }

    /// draw
    // Цикл для отрисовки данных на диаграмме
    for (int i = 0; i < radarMap.data.length; i++) {
      // Отрисовка области данных на диаграмме
      drawRadarMap(
          canvas,
          radarMap.data[i].data,
          radarMap.indicator.map((item) => item.maxValues).toList(),
          mAreaPaint
            ..color = radarMap.data[i].dataAreaStyle.color
                .withAlpha(radarMap.data[i].dataAreaStyle.alpha));
      // Отрисовка соединительных линий между точками данных
      drawRadarPath(
        canvas,
        radarMap.data[i].data,
        radarMap.indicator.map((item) => item.maxValues).toList(),
        mLineInnerPaint
          ..strokeWidth = radarMap.data[i].connectLineStyle?.width ?? 3
          ..color = radarMap.data[i].connectLineStyle?.color ??
              radarMap.data[i].dataAreaStyle.color,
      );
      // Отрисовка маркеров (точек) данных
      drawDataMarker(
        canvas,
        radarMap.data[i].data,
        radarMap.indicator.map((item) => item.maxValues).toList(),
        mAreaPaint
          ..strokeWidth = radarMap.data[i].dataMarkerStyle.size
          ..color = radarMap.data[i].dataMarkerStyle.color ??
              radarMap.data[i].connectLineStyle?.color ??
              radarMap.data[i].dataAreaStyle.color,
        size: radarMap.data[i].dataMarkerStyle.size,
      );

      // Отрисовка информационного текста
      drawInfoText(canvas);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Возвращаем true, чтобы всегда перерисовывать CustomPainter
  }

  // Метод для отрисовки внутренних кругов и линий осей
  drawInnerCircle(Canvas canvas, Size size) {
    double innerRadius = radarMap.radius; // Задаем внутренний радиус круга
    var line = radarMap.line;
    int ring = line?.line ?? 1; // Количество колец
    Color ringColor = line?.ringColor ?? Colors.white; // Цвет внутренних колец
    Color axisColor = line?.axisColor ?? Colors.grey; // Цвет линии осей

    // Рисуем кольцевые линии
    if (radarMap.shape == Shape.circle) {
      for (int s = ring; s > 0; s--) {
        canvas.drawCircle(
          const Offset(0, 0), // Центр круга
          innerRadius / ring * s, // Радиус текущего кольца
          mLinePaint
            ..color = ringColor
            ..style = PaintingStyle.stroke,
        );
      }
    } else {
      // Рисуем многоугольные линии

      // Углы для равномерного деления круга
      double delta = 2 * pi / elementLength;
      for (int s = ring; s > 0; s--) {
        // Начальный радиус
        var startRa = innerRadius / ring * s;

        Path mapPath = Path();

        // Угол
        double angle = 0;
        mapPath.moveTo(0, -startRa);
        for (int i = 0; i < elementLength; i++) {
          angle += delta;
          mapPath.lineTo(0 + startRa * sin(angle), 0 - startRa * cos(angle));
        }
        mapPath.close();
        canvas.drawPath(
          mapPath,
          mLinePaint
            ..color = ringColor
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // рисуем линии осей
    for (var i = 0; i < elementLength; i++) {
      canvas.save();
      canvas.rotate(360 / elementLength * i / 180 * pi);
      mLinePath.moveTo(0, -innerRadius);
      mLinePath.relativeLineTo(0, innerRadius);
      canvas.drawPath(
        mLinePath,
        mLinePaint
          ..color = axisColor
          ..style = PaintingStyle.stroke,
      );
      canvas.restore();
    }
    canvas.save();
    canvas.restore();
  }

  // Метод для отрисовки области построения диаграммы
  Path drawRadarMap(
      Canvas canvas, List<double> value, List<double> maxList, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; // Длина каждого сегмента
    radarMapPath.moveTo(
        0, -value[0] / (maxList[0] / elementLength) * step); // Начальная точка
    for (int i = 1; i < elementLength; i++) {
      double mark = value[i] / (maxList[i] / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  // Метод для получения фоновой области
  Path getBackgroundPath(Canvas canvas, double value, double max) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; // Длина каждого сегмента
    radarMapPath.moveTo(
        0, -value / (max / elementLength) * step); // Начальная точка
    for (int i = 1; i < elementLength; i++) {
      double mark = value / (max / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    return radarMapPath;
  }

  // Метод для отрисовки разделительной области
  Path drawRadarSplitArea(
      Canvas canvas, value, double maxValue, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; // Длина каждого сегмента
    radarMapPath.moveTo(
        0, -value / (maxValue / elementLength) * step); // Начальная точка
    for (int i = 1; i < elementLength; i++) {
      double mark = value / (maxValue / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  // Метод для отрисовки фоновой области
  Path drawRadarBackground(
      Canvas canvas, List<double> value, List<double> maxList, Paint mapPaint) {
    Path radarMapPath = Path();
    double step = radarMap.radius / elementLength; // Длина каждого сегмента
    radarMapPath.moveTo(
        0, -value[0] / (maxList[0] / elementLength) * step); // Начальная точка
    for (int i = 1; i < elementLength; i++) {
      double mark = value[i] / (maxList[i] / elementLength);
      var deg = pi / 180 * (360 / elementLength * i - 90);
      radarMapPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    radarMapPath.close();
    canvas.drawPath(radarMapPath, mapPaint);
    return radarMapPath;
  }

  // Отрисовка рамки диаграммы
  drawRadarPath(
      Canvas canvas, List<double> value, List<double> maxList, Paint linePaint,
      {drawRadarPath}) {
    Path mradarPath = Path();
    double step = radarMap.radius / value.length;
    mradarPath.moveTo(0, -value[0] / (maxList[0] / value.length) * step);
    for (int i = 1; i < value.length; i++) {
      double mark = value[i] / (maxList[i] / value.length);
      var deg = pi / 180 * (360 / value.length * i - 90);
      mradarPath.lineTo(mark * step * cos(deg), mark * step * sin(deg));
    }
    mradarPath.close();
    canvas.drawPath(mradarPath, linePaint);
  }

  // Отрисовка маркеров данных
  drawDataMarker(
      Canvas canvas, List<double> value, List<double> maxList, Paint linePaint,
      {drawRadarPath, double size = 5}) {
    double step = radarMap.radius / value.length;
    // canvas.drawCircle(Offset(0, -step), 10, linePaint);
    for (int i = 0; i < value.length; i++) {
      double mark = value[i] / (maxList[i] / value.length);
      var deg = pi / 180 * (360 / value.length * i - 90);
      canvas.drawCircle(Offset(mark * step * cos(deg), mark * step * sin(deg)),
          size, linePaint);
    }
  }

  // Отрисовка текста для названия осей
  Future<void> drawInfoText(Canvas canvas) async {
    double innerRadius = radarMap.radius; // Внутренний радиус диаграммы
    double delta = 2 * pi / elementLength; // Угловой шаг между вершинами
    var startRa =
        innerRadius; // Начальный радиус от центра диаграммы до вершины
    var maxWidth = radarMap.maxWidth ?? 40.0; // Максимальная ширина текста
    var top = 0.0; // Смещение сверху
    var bottom = 0.0; // Смещение снизу

    // Угол
    double angle = 0;
    node.clear();
    for (int i = 0; i < elementLength; i++) {
      // Создаем текстовый блок с заданными стилями текста
      final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: textStyle!.fontSize ?? radarMap.radius * 0.10,
          fontWeight: FontWeight.normal));
      paragraphBuilder.pushStyle(ui.TextStyle(
          color: textStyle!.color, textBaseline: ui.TextBaseline.alphabetic));
      paragraphBuilder.addText(radarMap
          .indicator[i].name); // Текст на вершине диаграммы - название оси
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: maxWidth));

      // Расстояние между вершиной и названием вершины
      var out = 15;
      // Вычисляем смещение для позиционирования текста около вершины
      var pianyix = sin(angle) * (paragraph.width / 2 + out);
      var pianyiy = cos(angle) * (paragraph.height / 2 + out);
      var of = Offset(0 + startRa * sin(angle) - paragraph.width / 2 + pianyix,
          0 - startRa * cos(angle) - paragraph.height / 2 - pianyiy);
      // Создаем прямоугольник для обрамления текста
      var rect = Rect.fromCenter(
          center: Offset(0 + startRa * sin(angle) + pianyix - skewing,
              0 - startRa * cos(angle) - pianyiy),
          width: paragraph.width,
          height: paragraph.height);
      // Отрисока текста на холсте
      canvas.drawParagraph(paragraph, of);
//////
      // Создание изображения на холсте
      // final imageAssetPath = radarMap.indicator[i]
      //     .imagePath; // // Получаем путь к изображению для текущего индикатора из RadarMapModel (indicator)
      // final ByteData data = await rootBundle.load(
      //     imageAssetPath); // Загружаем данные изображения из ресурсов приложения по указанному пути
      // final Uint8List uint8List = data.buffer
      //     .asUint8List(); //  Преобразуем данные изображения в Uint8List (последовательность байтов)
      // final ui.Codec codec = await ui.instantiateImageCodec(
      //     uint8List); // Создаем Codec для декодирования изображения
      // final ui.FrameInfo frameInfo = await codec
      //     .getNextFrame(); // Получаем информацию о следующем кадре изображения
      // final ui.Image uiImage =
      //     frameInfo.image; // Извлекаем объект ui.Image из информации о кадре

      // const imageSize = Size(35, 35); // Размер изображения
      // final imageRect = Rect.fromCenter(
      //   center: Offset(of.dx, of.dy - imageSize.height), // Позиция изображения
      //   width: imageSize.width,
      //   height: imageSize.height,
      // );

      // // Отрисовываем изображение на холсте
      // canvas.drawImageRect(
      //   uiImage, // Изображение для отрисовки
      //   imageRect, // Прямоугольник на холсте, куда отрисовать изображение
      //   Rect.fromPoints(Offset.zero,
      //       Offset.zero), // Область в исходном изображении для отрисовки
      //   Paint(), // Кисть для настройки стиля отрисовки (в данном случае, по умолчанию)
      // );
//////
      angle += delta; // Увеличиваем угол для следующей вершины

      if (i == 0) {
        top = paragraph.height + out;
      }
      // Определяем смещения сверху и снизу на основе размеров текста
      if (elementLength % 2 == 0) {
        if (i == elementLength / 2) {
          bottom = paragraph.height + out;
        }
      } else {
        if (i == elementLength ~/ 2) {
          bottom = paragraph.height + out;
        }
        if (i == elementLength ~/ 2 + 1) {
          if (bottom < paragraph.height) {
            bottom = paragraph.height + out;
          }
        }
      }
      // Добавляем созданный прямоугольник в список
      node.add(rect);
    }
    // Вызываем функцию обратного вызова для обновления высоты верхнего и нижнего смещения
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _widthHeight.call(top, bottom);
    });
  }
}
