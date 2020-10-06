import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'index.dart';

void main() {
  Global.init().then((e) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: VideoSourceState()),
          ChangeNotifierProvider.value(value: ThemeModel()),
          ChangeNotifierProvider.value(value: PaginationState()),
          ChangeNotifierProvider.value(value: VideoCardState()),
          ChangeNotifierProvider.value(value: CollectionState()),
          ChangeNotifierProvider.value(value: VideoTypeState()),
          ChangeNotifierProvider.value(value: VideoSearchState()),
        ],
        child: MyApp(),
      )));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeModel themeModel = Provider.of<ThemeModel>(context);
    // final VideoSourceState source = Provider.of<VideoSourceState>(context);
    return MaterialApp(
      title: '视频采集',
      theme: ThemeData(
        primarySwatch: themeModel.theme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePageRoute(title: '视频采集'),
      routes: <String, WidgetBuilder>{
        'video': (context) => VideoDetail(),
        'search': (context) => SearchPage(),
        'collection': (context) => CollotionPage(),
      },
    );
  }
}
