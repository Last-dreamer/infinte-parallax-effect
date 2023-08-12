

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:inifinite_parallax/parallax_widget.dart';
import 'package:inifinite_parallax/parallex_background_area.dart';

void main() => runApp(  MyApp());



List<String> images = [
  "https://plus.unsplash.com/premium_photo-1675337267945-3b2fff5344a0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1364&q=80",
  "https://images.unsplash.com/photo-1691379635079-9f438036ea58?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80",
  "https://images.unsplash.com/photo-1682685794761-c8e7b2347702?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2370&q=80",
  "https://images.unsplash.com/photo-1682685797527-63b4e495938f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2370&q=80",
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ParallaxBackgroundArea(
                child: CarouselSlider.builder(itemCount: images.length,
                    itemBuilder: (context, index, next) {
                    return ParallaxWidget(
                      parallaxPadding: const EdgeInsets.symmetric(horizontal: 10),
                      background: Image.network(
                      images[index % images.length],
                      fit: BoxFit.cover,
                    ),
                    child: Center(
                       child: Text(
                        "PAGE ${index + 1}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );

                    }, options: CarouselOptions(
                      padEnds: false,
                      viewportFraction: .9,
                      aspectRatio: 1.8
                    ))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
