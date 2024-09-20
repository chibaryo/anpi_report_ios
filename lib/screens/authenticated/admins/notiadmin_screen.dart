
import 'dart:convert';

import 'package:anpi_report_flutter/providers/firestore/notification/notification_notifier.dart';
import 'package:auto_route/auto_route.dart';
import 'package:custom_text_form_field_plus/custom_text_form_field_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../../../entity/notitype.dart';
import '../../../entity/topictype.dart';
import '../../../providers/bottomnav/bottomnav_provider.dart';
import '../../../router/app_router.dart';

@RoutePage()
class NotiAdminRouterScreen extends AutoRouter {
  const NotiAdminRouterScreen({super.key});
}

@RoutePage()
class NotiAdminScreen extends HookConsumerWidget {
  const NotiAdminScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncNotis = ref.watch(streamNotificationNotifierProvider);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final tFieldTitleController = useTextEditingController();
    final tFieldBodyController = useTextEditingController();
    //
    final notiType = useState<int>(0);
    final selectedNotiType = useState<int>(NotiType.undefined.sortNumber);
    final selectedNotiTopic = useState<String>(TopicType.undefined.topic);

    // Helper method to get options for DropdownButton
    List<DropdownMenuItem<int>> getNotiTypeDropdownItems() {
      return NotiType.values
      .map((location) => DropdownMenuItem<int>(
            value: location.sortNumber,
            child: Text(location.displayName),
          ))
      .toList();
    }

    List<DropdownMenuItem<String>> getNotiTopicDropdownItems() {
      return TopicType.values
      .map((location) => DropdownMenuItem<String>(
            value: location.topic,
            child: Text(location.displayName),
          ))
      .toList();
    }

    void clearFormFields() {
      tFieldTitleController.text = "";
      tFieldBodyController.text = "";
      selectedNotiType.value = NotiType.undefined.sortNumber;
      selectedNotiTopic.value = TopicType.undefined.topic;
    }


    // FUnc defs
    Widget buildNotiTypeDropDown() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<int>(
          value: selectedNotiType.value,
          onChanged: (int? newValue) {
            if (newValue != null) {
              selectedNotiType.value = newValue;
              debugPrint("selectedNotiType.value: ${selectedNotiType.value}");
            }
          },
          items: getNotiTypeDropdownItems(),
          decoration: const InputDecoration(
            labelText: 'Select notiType',
            border: OutlineInputBorder(),
          ),
        ),
      );
    }

    Widget buildNotiTopicDropDown() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          value: selectedNotiTopic.value,
          onChanged: (String? newValue) {
            if (newValue != null) {
              selectedNotiTopic.value = newValue;
              debugPrint("selectedNotiTopic.value: ${selectedNotiTopic.value}");
            }
          },
          items: getNotiTopicDropdownItems(),
          decoration: const InputDecoration(
            labelText: 'Select topic...',
            border: OutlineInputBorder(),
          ),
        ),
      );
    }

    // End func defs

Future<void> openSendNotiDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text("通知を送信する"),
                content: SingleChildScrollView(
                  child: FormBuilder(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // notiTitle
                        CustomTextFormField(
                          hintText: "タイトル",
                          controller: tFieldTitleController,
                          autofocus: true,
                          padding: const EdgeInsets.all(8.0),
                          enabledBorder: const UnderlineInputBorder(),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(),
                          validator: (String? value) =>
                              Validations.emptyValidation(value),
                        ),
                        // notiBody
                        CustomTextFormField(
                          hintText: "本文",
                          controller: tFieldBodyController,
                          autofocus: true,
                          padding: const EdgeInsets.all(8.0),
                          enabledBorder: const UnderlineInputBorder(),
                          border: const UnderlineInputBorder(),
                          focusedBorder: const UnderlineInputBorder(),
                          validator: (String? value) =>
                              Validations.emptyValidation(value),
                        ),
                        // Notification Type Dropdown
                        //buildNotiTypeDropDown(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
                            value: selectedNotiType.value,
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedNotiType.value = newValue;
                                });
                                //selectedNotiType.value = newValue;
                                debugPrint("selectedNotiType: $selectedNotiType");
                              }
                            },
                            items: NotiType.values.map((location) {
                              return DropdownMenuItem<int>(
                                value: location.sortNumber,
                                child: Text(location.displayName),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: '通知タイプを選択',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // Notification Topic Dropdown
                        //buildNotiTopicDropDown(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<String>(
                            value: selectedNotiTopic.value,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedNotiTopic.value = newValue;
                                  debugPrint("selectedNotiTopic: ${selectedNotiTopic.value}");
                                });
                              }
                            },
                            items: TopicType.values.map((location) {
                              return DropdownMenuItem<String>(
                                value: location.topic,
                                child: Text(location.displayName),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              labelText: '通知先トピックを選択',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      // Clear form
                      clearFormFields();
              
                      if (context.mounted) {
                        context.router.maybePop();
                      }
                    },
                    child: const Text("キャンセル"),
                  ),
                  TextButton(
                    onPressed: selectedNotiType.value < 1 || selectedNotiTopic.value == ""
                        ? null
                        : () async {
                            // Send notification
                            final notiTitle = tFieldTitleController.text;
                            final notiBody = tFieldBodyController.text;
                            final notiType = selectedNotiType.value;
                            final notiTopic = selectedNotiTopic.value;
                            var uuid = Uuid();
                            var newId = uuid.v4();

                            // POST
                            const String apiUrl = "https://anpi-fcm-2024-test.vercel.app/api/sendToTopic";
                            Uri url = Uri.parse(apiUrl);
                            Map<String, String> headers = {'Content-Type': 'application/json'};
                            String body = json.encode(
                              {
                                'title': notiTitle,
                                'body': notiBody,
                                'type': notiType,
                                'topic': notiTopic,
                                'notificationId': newId,
                              }
                            );
                            http.Response resp = await http.post(url, headers: headers, body: body);
                            // Check the result
                            if (resp.statusCode != 200) {
                              // ng
                              final int statusCode = resp.statusCode;
                              print("failed");
                              return;
                            } else {
                              // Ok
                              final int statusCode = resp.statusCode;
                              print("resp.body: ${resp.body}");

                              // Also store the result noti to Firestore
                            }

                            if (context.mounted) {
                              context.router.maybePop();
                            }
                          },
                    child: const Text("送信"),
                  ),
                ],
              );
            }
          );
        },
      );
    }

    useEffect(() {
      // Hide bottomnav
      Future.microtask(() {
        ref.read(bottomNavNotifierProvider.notifier).hide();
      });

      // Clean up: Show bottomnav again when leaving this screen
      return () {
      };
    }, []);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (context.mounted) {
                //
                ref.read(bottomNavNotifierProvider.notifier).show();
                context.router.maybePop();
              }
            },
          ),
          centerTitle: true,
          foregroundColor: Colors.black,
          backgroundColor: Colors.purple[300],
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                  await openSendNotiDialog(context);
              },
              icon: const Icon(Icons.add)
            ),
          ],
        ),
        body: switch(asyncNotis) {
          AsyncData(:final value) => SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: <Widget>[
                  DataTable(
                    showCheckboxColumn: false,
                    columns: const [
                      DataColumn(
                        label: Text("日時"),
                      ),
                      DataColumn(
                        label: Text("タイトル"),
                      ),
                      DataColumn(
                        label: Text("本文"),
                      ),
                    ],
                    rows: asyncNotis.value.map<DataRow>((data) {
                      final rowRecord = data["noti"];
                      debugPrint("rowRecord: ${rowRecord.toString()}");
                              
                      return DataRow(
                        onSelectChanged: (bool? selected) async {
                          if (selected != null && selected) {
                            // Goto individual noti
                            context.router.push(NotiAdminDetailsRoute(notiId: rowRecord.notificationId));
                          }
                        },
                        cells: [
                        DataCell(Text(DateFormat('[M/d h:mm]').format(rowRecord.createdAt))),
                        DataCell(Text(rowRecord.notiTitle)),
                        DataCell(Text(rowRecord.notiBody)),
                      ]);
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
          AsyncError(:final error) => Center(child: Text('エラーが発生しました: ${error.toString()}')),
        _ => const Center(child: CircularProgressIndicator()),
      }
    );
  }
}
