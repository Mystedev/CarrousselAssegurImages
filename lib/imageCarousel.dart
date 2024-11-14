// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

class ImageCarousel extends StatefulWidget {
  final int animationInterval;
  final String urlimatges;

  const ImageCarousel(
      {Key? key, required this.animationInterval, required this.urlimatges})
      : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  List<String> imageIds =
      List.generate(12, (index) => '${index + 1}'.padLeft(2, '0'));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkForNewImages();
    });
  }

  Future<void> _checkForNewImages() async {
    final newCount = await _fetchImageCount();
    if (newCount > imageIds.length) {
      setState(() {
        imageIds =
            List.generate(newCount, (index) => '${index + 1}'.padLeft(2, '0'));
      });
    }
  }

  Future<int> _fetchImageCount() async {
    final response = await http.get(Uri.parse(widget.urlimatges));
    if (response.statusCode == 200) {
      List<dynamic> images = json.decode(response.body);
      return images.length;
    } else {
      throw Exception('Error al obtener las imágenes');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla para establecer un diseño responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: CarouselSlider.builder(
          itemCount: imageIds.length,
          itemBuilder: (context, index, realIndex) {
            // Generar la URL de la imagen usando widget.urlimatges
            final imageUrl =
                '${widget.urlimatges}${imageIds[index]}-tauleta.jpg';

            return AspectRatio(
              aspectRatio: 16 / 9, // Mantener la relación de aspecto
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit
                    .cover, // Asegurar que la imagen cubra completamente el área
                width: screenWidth,
                height: screenHeight,
                errorWidget: (context, url, error) => const Center(
                  child: Text('No se puede obtener la imagen'),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: screenHeight, // Usar la altura de la pantalla
            autoPlay: true,
            autoPlayInterval: Duration(seconds: widget.animationInterval),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            viewportFraction: 1.0, // Usar todo el ancho de la pantalla
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollPhysics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
