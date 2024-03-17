import 'dart:developer';
import 'dart:io';

import 'package:anpi_report_ios/platform-dependent/fcm/initfcm_android.dart';
import 'package:anpi_report_ios/platform-dependent/fcm/initfcm_ios.dart';
import 'package:anpi_report_ios/providers/firestore/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ios_utsname_ext/extension.dart';
import 'package:device_imei/device_imei.dart';
import 'package:flutter_device_identifier/flutter_device_identifier.dart';

import '../../models/deviceinfotable.dart';
import '../../providers/firebaseauth/auth_provider.dart';
import '../../providers/firestore/deviceinfotable/deviceinfotable_provider.dart';
import '../../providers/geolocator/location_provider.dart';
import '../../widgets/fcmalertdialog.dart';

final logger = Logger();

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthProvider);
    final locationInfo = ref.watch(geocodingControllerProvider);
    final currentAddress = ref.watch(addressDataProvider);
    //
    final systemName = useState("");
    final osVersion = useState("");
    final localizedModel = useState("");
    final productName = useState("");
    final uDID = useState("");
    //
    final uDIDNotifier = ref.watch(udidNotifierProvider);

    Future<void> getDevInfo() async {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;

        systemName.value = iosInfo.systemName;
        osVersion.value = iosInfo.systemVersion;
        localizedModel.value = iosInfo.localizedModel;
        final iosMachine = iosInfo.utsname.machine;
        productName.value = iosMachine.iOSProductName;
        uDID.value = iosInfo.identifierForVendor!;

        debugPrint("uDID.value : ${uDID.value}");
        ref.read(udidNotifierProvider.notifier).state = iosInfo.identifierForVendor!;
      } else if (Platform.isAndroid) {
        await FlutterDeviceIdentifier.requestPermission();
        String androidID = await FlutterDeviceIdentifier.androidID;
        debugPrint("### Android ### androidID: $androidID");

        final androidInfo = await deviceInfoPlugin.androidInfo;

        debugPrint("androidInfo: ${androidInfo.toString()}");
        systemName.value = "Android";
        osVersion.value = androidInfo.version.release;
        localizedModel.value = androidInfo.display;
        productName.value = androidInfo.product;
        uDID.value = androidID;

      }
    }

    Future<void> addDeviceInfo() async {
      final serverDate = DateTime.now();
      await FirebaseFirestore.instance
        .collection("tokens")
        .doc(authState.currentUser?.uid)
        .collection("platforms")
        .doc(uDID.value)
        .set({
          "systemName": systemName.value,
          "osVersion": osVersion.value,
          "localizedModel": localizedModel.value,
          "productName": productName.value,
          "udId": uDID.value,
//          "fcmToken": "",
          "createdAt": serverDate,
          "updatedAt": serverDate,
        });
    }

    Future<DocumentSnapshot<Map<String, dynamic>>>
      getPlatformDeviceInfoByUdid() async {
        final docSnapshot = await FirebaseFirestore.instance
          .collection("tokens")
          .doc(authState.currentUser?.uid)
          .collection("platforms")
          .doc(uDID.value)
          .get();

        return docSnapshot;
    }

    Future<DocumentSnapshot<Map<String, dynamic>>>
      getUserDocByUid() async {
        final docSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(authState.currentUser?.uid)
          .get();
        
        return docSnapshot;
    }

    Future<void> toggleFirebaseUserOnlineStatus({
      required String uid,
      required bool isOnlineStatus
    }) async {
      await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({
          "isOnline": isOnlineStatus,
        });
    }
    
    useEffect(() {
      getDevInfo().then((value) {
//        addDeviceInfo().then((value) {
          getPlatformDeviceInfoByUdid().then((value) {
            final data = value.data();
            debugPrint("data: $data");
            if (data == null || data!.isEmpty || data["fcmToken"] == "") {
              debugPrint("Data empty");
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return const FcmAlertDialog();
                }
              );
              addDeviceInfo();
            } else {
              // Get one user
              getUserDocByUid().then((value) {
                final data = value.data();
                final isOnlineStatus = data!['isOnline'];
                debugPrint("user data!['isOnline']: $isOnlineStatus");

                //
                if (!isOnlineStatus) {
                  debugPrint("### still offline ###");
                  debugPrint("Existing devicedata: $data");
                  // Only renew fcmtoken
                  if (Platform.isIOS) {
                    initFCMIOS(authState.currentUser!.uid, uDID.value);
                  } else if (Platform.isAndroid) {
                    initFCMAndroid(authState.currentUser!.uid, uDID.value);
                  }
                  // set flag on
                  ref.read(asyncFirebaseUserNotifierProvider.notifier).toggleFirebaseUserOnlineStatus(
                    uid: authState.currentUser!.uid,
                    isOnlineStatus: true
                  ); // toggleFirebaseUserOnlineStatus(
                }
              });
            }
          });
       // });
      });

/*
      queryDeviceInfoTableByUDID(
        authState.currentUser!.uid,
        uDID
      ).then((value) {
        debugPrint("value: $value");
        if (value.isNotEmpty && value[0].fcmToken != "") {
          debugPrint("value[0].fcmToken : ${value[0].fcmToken}");
        } else if (value.isEmpty || value[0].fcmToken == "") {
          debugPrint("fcmToken is empty or no udid found. so add one record.");
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return const FcmAlertDialog();
            }
          );

          // add to Firestore sub-collection

        };
      }); */

      return () {};

    }, const []);

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            const Text(
              '今までの緊急速報',
              style: TextStyle(fontSize: 32.0),
            ),
            authState.currentUser != null
              ? Text("${authState.currentUser!.displayName} さん")
              : const Text("uid"),
          //
          Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(geocodingControllerProvider.notifier).getCurrentAddress().then((address) {
                          FirebaseFirestore.instance
                            .collection("locations")
                            .doc(authState.currentUser?.uid)
                            .set({
                              "address": FieldValue.arrayUnion(
                                [
                                  address.country,
                                  address.prefecture,
                                  address.city,
                                  address.street
                                ]
                              )
                            });
                            // Store to provider
                            ref.read(addressDataProvider.notifier).setAddress([
                              address.country,
                              address.prefecture,
                              address.city,
                              address.street
                            ]);
                            debugPrint("### currentAddress : ${currentAddress.toString()} ###");

                          context.pushNamed("PostEnqueteScreen");
                        });
                      },
                      child: const Text("回答する"),
                    ),
                  )
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}