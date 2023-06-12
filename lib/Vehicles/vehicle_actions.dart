import 'dart:convert';

import 'package:bifrost_ui/Vehicles/vehicle_tax.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/user_manager.dart';
import 'add_vehicle_dialog.dart';


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
      vehicleTaxRequest.tax_type = vehicleTax.taxType;
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
}