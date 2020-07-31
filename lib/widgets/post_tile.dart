import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/widgets/custom_image.dart';

import 'post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({this.post});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: cachedNetworkImage(
        post.mediaUrl,
      ),
      onTap: () {},
    );
  }
}
