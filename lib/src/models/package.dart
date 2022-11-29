import 'package:flutter/material.dart';

class Package {
  final String location;
  final String wr;
  final DateTime date;
  final Color color;
  late Icon icono;
  late String descrition;

  Package({
    required this.location,
    required this.wr,
    required this.date,
    required this.color,
    required this.icono,
    required this.descrition,
  });
}
