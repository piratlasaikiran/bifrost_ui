class VehicleTaxRequest{
  late String tax_type;
  late int renewal_amount;
  late String validity_start;
  late String validity_end;

  Map<String, dynamic> toJson() {
    return {
      'tax_type': tax_type,
      'renewal_amount': renewal_amount,
      'validity_start': validity_start,
      'validity_end': validity_end,
    };
  }
}