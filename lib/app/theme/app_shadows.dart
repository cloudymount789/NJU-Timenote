import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x220062FF), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const overlay = <BoxShadow>[
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
