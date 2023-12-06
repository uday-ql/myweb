import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_sharing_intent_example/add_timeline_session_page.dart';

import 'cached_video_player.dart';
import 'file_tile.dart';

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
  String defaultTimeline = "initial_timeline";
  String defaultSession = "initial_session";

  List<String> texts = [];
  List<String> urls = [];
  List<File> images = [];
  List<File> videos = [];
  List<File> files = [];

  List<String> keys = [];

  // List<String> timelines = [];
  // List<String> sessions = [];
  // Map<String, List<String>> sessionsMap = {};

  @override
  void initState() {
    _initialFetch();
    super.initState();
  }

  Future<void> _initialFetch() async {
    try {
      await setDefaults();
      keys = await getDataList();
      await setData(keys);
      setState(() {});
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> setData(List<String> keysToFetch) async {
    for (var key in keysToFetch) {
      final res = await SharedPreferenceAppGroup.get(key);
      if (res == null) {
        continue;
      }
      debugPrint(res.toString());
      final value = Uri.tryParse(res);
      if (value == null) {
        texts.add(res);
      } else {
        final bool isFile = value.isScheme("file");
        final bool isUrl = value.isScheme("http") || value.isScheme("https");
        if (isUrl) {
          urls.add(value.toString());
        } else if (isFile) {
          String filePath = value.path;
          File file = File(value.path);
          String? mimeType = lookupMimeType(filePath);
          debugPrint('MIME type: $mimeType');
          if (mimeType == null) {
            continue;
          }
          if (mimeType.contains("image")) {
            images.add(file);
          } else if (mimeType.contains("video")) {
            videos.add(file);
          } else {
            files.add(file);
          }
        } else {
          texts.add(res);
        }
      }
    }
  }

  Future<List<String>> getDataList() async {
    try {
      final key = "${defaultTimeline}_$defaultSession";
      final res = await SharedPreferenceAppGroup.get(key);
      if (res == null) {
        return [];
      } else {
        final keys = (res as List).map((e) => e.toString()).toList();
        return keys;
      }
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      return [];
    }
  }

  Future<void> setDefaults() async {
    defaultTimeline =
        await SharedPreferenceAppGroup.get("default_timeline") as String? ??
            "initial_timeline";
    defaultSession =
        await SharedPreferenceAppGroup.get("default_session") as String? ??
            "initial_session";
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
      final needToFetch = newKeys.toSet().difference(keys.toSet()).toList();
      keys = newKeys;
      await setData(needToFetch);
      setState(() {});
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _onLinkTap(String link) async {
    if (await canLaunchUrl(Uri.parse(link))) {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
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
                  //   value: defaultTimeline,
                  //   icon: const Icon(Icons.keyboard_arrow_down),
                  //   items: timelines.map((String items) {
                  //     return DropdownMenuItem(
                  //       value: items,
                  //       child: Text(items),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       defaultTimeline = newValue!;
                  //     });
                  //   },
                  // ),
                  // DropdownButton<String>(
                  //   value: defaultSession,
                  //   icon: const Icon(Icons.keyboard_arrow_down),
                  //   items: sessions.map((String items) {
                  //     return DropdownMenuItem(
                  //       value: items,
                  //       child: Text(items),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       defaultSession = newValue!;
                  //     });
                  //   },
                  // ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                defaultTimeline.replaceFirst("_", " "),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_outlined)
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                defaultSession.replaceFirst("_", " "),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_outlined)
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
              itemBuilder: (context, index) => ListTile(
                tileColor: Colors.grey[300],
                title: Text(texts[index].toString()),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: texts.length,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList.separated(
              itemBuilder: (context, index) => ListTile(
                tileColor: Colors.grey[300],
                minVerticalPadding: 10,
                title: InkWell(
                  onTap: () async {
                    await _onLinkTap(urls[index]);
                  },
                  child: Text(
                    urls[index],
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              separatorBuilder: (context, index) => const SizedBox(
                height: 8,
              ),
              itemCount: urls.length,
            ),
            SliverList.builder(
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Image.file(images[index]),
              ),
              itemCount: images.length,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList.separated(
              itemBuilder: (context, index) {
                return CachedVideoPlayerWidget(filePath: videos[index].path);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: videos.length,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverList.separated(
              itemBuilder: (context, index) {
                return FileTile(file: files[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemCount: files.length,
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
