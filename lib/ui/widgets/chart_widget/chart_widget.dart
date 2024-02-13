import 'package:flutter/material.dart';
import 'package:skills/common/colors.dart';
import 'package:skills/common/text_styles.dart';
import 'package:skills/ui/widgets/chart_widget/flutter_radar_map%20copy.dart';
import 'package:skills/ui/widgets/chart_widget/radar_map_model.dart';
import 'chart_data.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({Key? key}) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RadarWidget(
        skewing: 0,
        radarMap: RadarMapModel(
          //названия осей диаграммы
          indicator: indicators,
          data: [
            MapDataModel(
              mapData,
              // область построения диаграммы
              dataAreaStyle: const DataAreaStyle(
                color: CustomColors.chartAreaColor,
                alpha: 100,
              ),
              // точки диаграммы
              dataMarkerStyle: const DataMarkerStyle(
                size: 2.2,
                color: Colors.white,
              ),
              // линии соединения точек диаграммы
              connectLineStyle: ConnectLineStyle(
                color: CustomColors.chartAreaColor,
                width: 2.0,
              ),
            ),
          ],
          // кольца диаграммы
          splitAreaStyle: SplitAreaStyle(
            colors: splitAreaColors,
            alpha: 200,
          ),
          radius: 175,
          shape: Shape.square,
          maxWidth: 120,
          line: LineModel(
            7, // количество колец
            ringColor: CustomColors.ringColor, // цвет бордера колец
            axisColor: CustomColors.axisColor, // цвет линии осей
          ),
        ),
        textStyle: textStyleRubikW400_16_white(),
      ),
    );
  }
}
