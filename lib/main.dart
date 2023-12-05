import 'dart:async';

// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:path/path.dart' as p;

import 'package:flutter_sharing_intent_example/add_timeline_session_page.dart';
import 'package:flutter_sharing_intent_example/constant_strings.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceAppGroup.setAppGroup(
      "group.com.techind.flutterSharingIntentExample");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> data = [];
  List<dynamic> images = [];
  List<dynamic> keys = [];

  // List<String> timelines = [];
  // List<String> sessions = [];
  // Map<String, List<String>> sessionsMap = {};
  // String? selectedTimeline;
  // String? selectedSession;

  @override
  void initState() {
    setData();
    super.initState();
  }

  Future<void> setData() async {
    try {
      keys = await getDataList();
      for (var key in keys) {
        final res = await SharedPreferenceAppGroup.get(key);
        if (res == null) {
          return;
        }
        if (res.runtimeType != List<Object?>) {
          final uInt8List = Uint8List.fromList(res.toList());
          //  final file = File.fromRawPath(uInt8List);
          //  file.path;
          //  file.uri;
          //  String extension = p.extension(file.path);
          // String filename = p.basename(file.path);
          //
          //  print("Extension: $extension");
          //  print("Filename: $filename");

          images.add(uInt8List);
        } else {
          data.add(res.first);
        }
      }

      setState(() {});
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  Future<List<dynamic>> getDataList() async {
    try {
      const key = "${StringConst.timeline}_${StringConst.section}";
      final res = await SharedPreferenceAppGroup.get(key);
      if (res == null) {
        return [];
      } else {
        return res;
      }
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  // Future<List<dynamic>> getTimelinesAndSession() async {
  //   try {
  //     final res = await SharedPreferenceAppGroup.get("timelines");
  //     final sesRes = await SharedPreferenceAppGroup.get("sessions");
  //     if (res == null) {
  //       return [];
  //     } else {
  //       return res;
  //     }
  //   } catch (e, st) {
  //     debugPrint(e.toString());
  //     debugPrintStack(stackTrace: st);
  //     return [];
  //   }
  // }

  Future<void> refresh() async {
    try {
      final newKeys = await getDataList();
      final needToFetch = newKeys.toSet().difference(keys.toSet());
      keys = newKeys;
      for (var key in needToFetch) {
        final res = await SharedPreferenceAppGroup.get(key);
        if (res == null) {
          return;
        }
        if (res.runtimeType != List<Object?>) {
          final uInt8List = Uint8List.fromList(res.toList());
          images.add(uInt8List);
        } else {
          data.add(res.first);
        }
      }

      setState(() {});
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTimelineAndSessionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  // DropdownButton<String>(
                  //   value: selectedTimeline,
                  //   icon: const Icon(Icons.keyboard_arrow_down),
                  //   items: timelines.map((String items) {
                  //     return DropdownMenuItem(
                  //       value: items,
                  //       child: Text(items),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       selectedTimeline = newValue!;
                  //     });
                  //   },
                  // ),
                  // DropdownButton<String>(
                  //   value: selectedSession,
                  //   icon: const Icon(Icons.keyboard_arrow_down),
                  //   items: sessions.map((String items) {
                  //     return DropdownMenuItem(
                  //       value: items,
                  //       child: Text(items),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       selectedSession = newValue!;
                  //     });
                  //   },
                  // ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Timeline 1',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_drop_down_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Session 5',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_drop_down_outlined)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverList.separated(
              itemBuilder: (context, index) => ListTile(tileColor: Colors.grey[300],
                title: Text(data[index].toString()),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 8,),
              itemCount: data.length,
            ),
            SliverList.builder(
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.memory(images[index]!),
              ),
              itemCount: images.length,
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            refresh();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
