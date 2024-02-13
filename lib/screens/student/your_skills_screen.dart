import 'package:flutter/material.dart';
import 'package:skills/common/text_styles.dart';
import 'package:skills/components/buttons.dart';
import 'package:skills/ui/widgets/chart_widget/chart_widget.dart';

class YourSkillsScreen extends StatelessWidget {
  const YourSkillsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //ширина экрана
    double width = MediaQuery.of(context).size.width;
    // отступы
    double sidePadding = 17;
    double topPadding = 63;
    double bottomPadding = 53;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //верхняя часть экрана: кнопка 'Назад', заголовок
            Padding(
              padding: EdgeInsets.only(
                left: sidePadding,
                right: sidePadding,
                top: topPadding,
                bottom: bottomPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Buttons().back(context),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      'Твои навыки',
                      style: textStyleRubikW700_24_white(),
                    ),
                  ),
                  const SizedBox(
                    width: 38,
                    height: 38,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      //  с данными отступами, диаграмма при загрузке страницы
                      // смещена влево, скроллинг позволяет увидеть названия осей диаграммы
                      EdgeInsets.symmetric(
                          horizontal: (width - 200) / 2, vertical: 15),
                  child: ChartWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
