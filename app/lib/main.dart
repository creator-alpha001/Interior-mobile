/// The entrypoint.
///
/// At M8 this runs the component gallery and nothing else. The role shell —
/// `GET /me`, `client` to the customer tabs and `professional` to the vendor
/// tabs — arrives in M9 with the bearer session, and the router that owns that
/// decision does not exist yet. A gallery is what M8 is *for*: the design
/// system is the deliverable of this phase, and this is the screen the golden
/// tests photograph.
library;

import 'package:aangan_design/aangan_design.dart';
import 'package:flutter/material.dart';

import 'gallery.dart';

void main() => runApp(const AanganApp());

class AanganApp extends StatelessWidget {
  const AanganApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aangan',
      debugShowCheckedModeBanner: false,
      theme: AanganTheme.light,

      /// Light only, deliberately and on the record — DESIGN.md §3.8.
      ///
      /// Not an oversight, and not `ThemeMode.system` pointing at a dark theme
      /// nobody has looked at. The palette is warm lime-washed plaster and the
      /// argument is daylight on stone; a mechanical inversion reads as a bug.
      themeMode: ThemeMode.light,
      darkTheme: AanganTheme.light,

      home: const GalleryScreen(),
    );
  }
}
