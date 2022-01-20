import 'dart:io';

import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? url;

  const ProductImage({Key? key, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Container(
        width: double.infinity,
        height: size.height * 0.45,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Opacity(
          opacity: 0.85,
          child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              child: getImage(url)),
        ),
      ),
    );
  }

  Widget getImage(String? url) {
    if (url == null) {
      return Image.asset('assets/no-image.png', fit: BoxFit.cover);
    }
    if (url.startsWith('http')) {
      return FadeInImage(
          placeholder: AssetImage('assets/jar-loading.gif'),
          image: NetworkImage(this.url!),
          fit: BoxFit.cover);
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
    );
  }
}
