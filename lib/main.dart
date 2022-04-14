import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rental_app/data/repository_impl.dart';
import 'package:rental_app/presentation/data_controller.dart';
import 'package:rental_app/presentation/repository_provider.dart';
import 'package:rental_app/presentation/widgets/item_property.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      repository: DummyRepositoryImpl(),
      child: MaterialApp(
        title: 'Rental App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            toolbarTextStyle: _titleTextStyle,
            titleTextStyle: _titleTextStyle,
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }

  TextStyle get _titleTextStyle {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xff333333),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pageController = PageController(viewportFraction: 0.92);
  late final dataController =
      PropertiesDataController(repository: context.repository);

  @override
  void initState() {
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      dataController.fetch();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hi Jasper"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(dataController: dataController),
            _Content(
              dataController: dataController,
              pageController: pageController,
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key, required this.dataController}) : super(key: key);

  final PropertiesDataController dataController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextFormField(
        onChanged: (newText) {
          dataController.fetch(param: newText);
        },
        
        decoration: InputDecoration(
          hintText: "Search..",
          prefixIcon: const Icon(Icons.search),
          fillColor: Colors.grey[100],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    Key? key,
    required this.dataController,
    required this.pageController,
  }) : super(key: key);

  final PropertiesDataController dataController;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: Container(
        height: size.height * 0.6,
        margin: const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 32,
        ),
        child: AnimatedBuilder(
          animation: dataController,
          builder: (c, _) {
            if (dataController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (dataController.data?.isEmpty ?? true) {
              return const Center(child: Text("No property available "));
            }
            return PageView.builder(
              controller: pageController,
              itemCount: dataController.data?.length,
              itemBuilder: (c, index) => ItemProperty(
                property: dataController.data![index],
              ),
            );
          },
        ),
      ),
    );
  }
}