import 'dart:convert';
import 'dart:io';

import 'package:bifrost_ui/Vehicles/vehicle_tax.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/user_manager.dart';
import 'add_vehicle_dialog.dart';

class VehicleDTO {
  final String vehicleNumber;
  final String? owner;
  final String? chassisNumber;
  final String? engineNumber;
  final String? vehicleClass;
  final String? insuranceProvider;
  final String? financeProvider;


  VehicleDTO({
    required this.vehicleNumber,
    required this.owner,
    required this.chassisNumber,
    required this.engineNumber,
    required this.vehicleClass,
    required this.insuranceProvider,
    required this.financeProvider
  });
}

class VehicleActions{
  Future<bool> saveVehicle({
  required String vehicleNumber,
  required String owner,
  required String chassisNumber,
  required String engineNumber,
  required String vehicleClass,
  required String? insuranceProvider,
  required String? financeProvider,
  required List<VehicleTax> vehicleTaxes,
  }) async{

    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/create-new-vehicle');
    var formData = {
      'vehicle_num': vehicleNumber,
      'owner': owner,
      'chassis_num': chassisNumber,
      'engine_num': engineNumber,
      'vehicle_class': vehicleClass,
      'insurance_provider': insuranceProvider,
      'finance_provider': financeProvider
    };
    var request = http.MultipartRequest('POST', url);
    var vehicleJsonPart = http.MultipartFile.fromString(
      'createVehiclePayload',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );

    List<VehicleTaxRequest> vehicleTaxRequest = await imageSegregateHelper(vehicleTaxes, request);
    var taxesJsonPart = http.MultipartFile.fromString(
      'vehicleTaxes',
      jsonEncode(vehicleTaxRequest.map((request) => request.toJson()).toList()),
      contentType: MediaType('application', 'json'),
    );


    request.headers['X-User-Id'] = userManager.username;
    request.files.add(vehicleJsonPart);
    request.files.add(taxesJsonPart);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<VehicleTaxRequest>> imageSegregateHelper(List<VehicleTax> vehicleTaxes, http.MultipartRequest request) async {
    List<VehicleTaxRequest> vehicleTaxDetails = [];
    for (var vehicleTax in vehicleTaxes) {
      VehicleTaxRequest vehicleTaxRequest = VehicleTaxRequest();
      vehicleTaxRequest.tax_type = vehicleTax.taxType!;
      vehicleTaxRequest.renewal_amount = vehicleTax.amount;
      vehicleTaxRequest.validity_start = '${vehicleTax.validityStartDate.year}-${vehicleTax.validityStartDate.month.toString().padLeft(2, '0')}-${vehicleTax.validityStartDate.day.toString().padLeft(2, '0')}';
      vehicleTaxRequest.validity_end = '${vehicleTax.validityEndDate.year}-${vehicleTax.validityEndDate.month.toString().padLeft(2, '0')}-${vehicleTax.validityEndDate.day.toString().padLeft(2, '0')}';
      vehicleTaxDetails.add(vehicleTaxRequest);
      switch(vehicleTax.taxType){
        case 'PUC':
          var pucImageField = await http.MultipartFile.fromPath('puc', vehicleTax.receipt!.path);
          request.files.add(pucImageField);
          break;
        case 'FITNESS':
          var fitnessImageField = await http.MultipartFile.fromPath('fitness', vehicleTax.receipt!.path);
          request.files.add(fitnessImageField);
          break;
        case 'PERMIT':
          var permitImageField = await http.MultipartFile.fromPath('permit', vehicleTax.receipt!.path);
          request.files.add(permitImageField);
          break;
        case 'INSURANCE':
          var insuranceImageField = await http.MultipartFile.fromPath('insurance', vehicleTax.receipt!.path);
          request.files.add(insuranceImageField);
          break;
        case 'TAX':
          var taxImageField = await http.MultipartFile.fromPath('tax', vehicleTax.receipt!.path);
          request.files.add(taxImageField);
          break;
        case 'OTHERS':
          var othersImageField = await http.MultipartFile.fromPath('others', vehicleTax.receipt!.path);
          request.files.add(othersImageField);
          break;
      }
    }
    return vehicleTaxDetails;
  }

  Future<List<VehicleDTO>> getAllVehicles() async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<dynamic> vehicleDTOs = jsonDecode(response.body);
    final List<VehicleDTO> vehicles = vehicleDTOs.map((data) {
      return VehicleDTO(
          vehicleNumber: data['vehicle_num'] as String,
          owner: data['owner'] as String?,
          chassisNumber: data['chassis_num'] as String?,
          engineNumber: data['engine_num'] as String?,
          vehicleClass: data['vehicle_class'] as String?,
          insuranceProvider: data['insurance_provider'] as String?,
          financeProvider: data['finance_provider'] as String?
      );
    }).toList();
    return vehicles;
  }

  Future<List<String>> getVehicleNumbers() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/get-vehicle-numbers');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> vehicleNumbers = jsonDecode(response.body).cast<String>();
    return vehicleNumbers;
  }

  Future<List<String>> getVehicleTaxTypes() async {
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/tax-types');
    var headers = {'X-User-Id': userManager.username};
    var response = await http.get(url, headers: headers);
    List<String> vehicleTaxTypes = jsonDecode(response.body).cast<String>();
    return vehicleTaxTypes;
  }

  Future<bool> uploadVehicleTax({
    required int? amount,
    required String? vehicleNumber,
    required String? taxType,
    required DateTime? validityStartDate,
    required DateTime? validityEndDate,
    required File? receipt,
  }) async{
    UserManager userManager = UserManager();
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/$vehicleNumber/upload-new-vehicle-tax');
    var formData = {
      'tax_type': taxType,
      'renewal_amount': amount,
      'validity_start': '${validityStartDate?.year}-${validityStartDate?.month.toString().padLeft(2, '0')}-${validityStartDate?.day.toString().padLeft(2, '0')}',
      'validity_end': '${validityEndDate?.year}-${validityEndDate?.month.toString().padLeft(2, '0')}-${validityEndDate?.day.toString().padLeft(2, '0')}',
    };
    var jsonPart = http.MultipartFile.fromString(
      'vehicleTax',
      jsonEncode(formData),
      contentType: MediaType('application', 'json'),
    );
    var request = http.MultipartRequest('POST', url);
    request.headers['X-User-Id'] = userManager.username;
    var imageField = await http.MultipartFile.fromPath('taxReceipt', receipt!.path);

    request.files.add(jsonPart);
    request.files.add(imageField);

    var response = await request.send();
    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateVehicle({
    required String currentVehicleNumber,
    required String vehicleNumber,
    required String owner,
    required String chassisNumber,
    required String engineNumber,
    required String vehicleClass,
    required String? insuranceProvider,
    required String? financeProvider,
  }) async{
    UserManager userManager = UserManager();
    String encodedVehicleNumber = Uri.encodeComponent(currentVehicleNumber);
    var url = Uri.parse('http://10.0.2.2:6852/bifrost/vehicles/$encodedVehicleNumber/update-vehicle');
    var formData = {
      'vehicle_num': vehicleNumber,
      'owner': owner,
      'chassis_num': chassisNumber,
      'engine_num': engineNumber,
      'vehicle_class': vehicleClass,
      'insurance_provider': insuranceProvider,
      'finance_provider': financeProvider
    };
    final headers = {
      'Content-Type': 'application/json',
      'X-User-Id': userManager.username,
    };
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(formData),
    );

    if(response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}