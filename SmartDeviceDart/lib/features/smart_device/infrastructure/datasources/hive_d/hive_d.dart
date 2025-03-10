import 'package:SmartDeviceDart/core/my_singleton.dart';
import 'package:SmartDeviceDart/features/smart_device/infrastructure/datasources/hive_d/hive_objects_d/hive_devices_d.dart';
import 'package:SmartDeviceDart/features/smart_device/infrastructure/datasources/hive_d/hive_store_d.dart';
import 'package:hive/hive.dart';

class HiveD {
  String hiveFolderPath;
  static bool finishedInitializing;
  static const String smartDeviceBoxName = 'SmartDevices';
  static const String cellDeviceListInSmartDeviceBox = 'deviceList';
  static const String cellDatabaseInformationInSmartDeviceBox =
      'databaseInformation';

  HiveD._privateConstructor() {
//    contractorAsync();
  }

  static final HiveD _instance = HiveD._privateConstructor();

  factory HiveD() {
    return _instance;
  }

  Future<bool> contractorAsync() async {
    if (finishedInitializing == null) {
      String currentUserName = await MySingleton.getCurrentUserName();
      hiveFolderPath = '/home/' + currentUserName + '/Documents/hive';
      print('Path of hive: ' + hiveFolderPath);
      Hive..init(hiveFolderPath);

      Hive.openBox(
          smartDeviceBoxName); // TODO: check if need await, it creates error: HiveError: Cannot read, unknown typeId: 34
      Hive.registerAdapter(TokenAdapter());
      Hive..registerAdapter(HiveDevicesDAdapter());

      finishedInitializing = true;
    }
    return finishedInitializing;
  }

  Future<Map<String, List<String>>> getListOfSmartDevices() async {
    await contractorAsync();

    var box = await Hive.openBox(smartDeviceBoxName);

    HiveDevicesD a = box.get(cellDeviceListInSmartDeviceBox);

    return a?.smartDeviceList;
  }

  Future<Map<String, String>> getListOfDatabaseInformation() async {
    await contractorAsync();

    var box = await Hive.openBox(smartDeviceBoxName);

    HiveDevicesD firebaseAccountsInformationMap =
        box.get(cellDatabaseInformationInSmartDeviceBox);

    return firebaseAccountsInformationMap?.databaseInformationList;
  }

  Future<void> saveAllDevices(
      Map<String, List<String>> smartDevicesMapList) async {
    await finishedInitializing;

    var box = await Hive.openBox(smartDeviceBoxName);

    HiveDevicesD hiveDevicesD = HiveDevicesD()
      ..smartDeviceList = smartDevicesMapList;

    await box.put(cellDeviceListInSmartDeviceBox, hiveDevicesD);
  }

  Future<void> saveListOfDatabaseInformation(
      Map<String, String> firebaseAccountsInformationMap) async {
    await finishedInitializing;

    var box = await Hive.openBox(smartDeviceBoxName);

    HiveDevicesD hiveDevicesD = HiveDevicesD()
      ..databaseInformationList = firebaseAccountsInformationMap;

    await box.put(cellDatabaseInformationInSmartDeviceBox, hiveDevicesD);
  }
}
