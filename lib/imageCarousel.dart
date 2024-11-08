// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;

class ImageCarousel extends StatefulWidget {
  final int animationInterval;

  const ImageCarousel({Key? key, required this.animationInterval})
      : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final String baseUrl = 'https://www.assegur.com/img/tauletes/';
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
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> images = json.decode(response.body);
      return images.length;
    } else {
      throw Exception('Error al obtenir les imatges');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CarouselSlider.builder(
        itemCount: imageIds.length,
        itemBuilder: (context, index, realIndex) {
          final imageUrl = '$baseUrl${imageIds[index]}-tauleta.jpg';
          return SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Center(
                child: Text('No es pot obtenir la imatge'),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: screenHeight,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: widget.animationInterval),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInExpo,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
          scrollPhysics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
