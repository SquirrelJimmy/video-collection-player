import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../index.dart';

class VideoCard extends StatelessWidget {
  VideoCard({Key key, VideoCardType video, this.onToggleCollection}) {
    _video = video;
  }
  Function onToggleCollection;
  VideoCardType _video;
  void _toPlay(BuildContext context) {
    VideoCardState videoCardState =
        Provider.of<VideoCardState>(context, listen: false);
    videoCardState.setCurrentVideo(_video);
    Navigator.pushNamed(context, 'video');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CollectionState>(
      builder: (context, collotionState, child) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Container(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _toPlay(context),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        placeholder: (context, url) => Image.asset(
                          'assets/images/bg.jpg',
                          width: 290,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        imageUrl: _video.pic,
                        fit: BoxFit.cover,
                        width: 290,
                        height: 200,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Text(
                          _video.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Tag(
                        margin: EdgeInsets.only(
                          left: 10,
                          top: 10,
                        ),
                        icon: Icon(
                          Icons.turned_in,
                          size: 18,
                          color: Colors.white,
                        ),
                        text: Text(
                          _video.type,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Tag(
                        margin: EdgeInsets.only(
                          left: 10,
                          top: 4,
                        ),
                        icon: Icon(
                          Icons.date_range,
                          size: 18,
                          color: Colors.white,
                        ),
                        text: Text(
                          _video.last.split(" ")[0],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  top: -5,
                  right: -5,
                  child: IconButton(
                    onPressed: () { collotionState.setCollection(_video); if(onToggleCollection != null) {onToggleCollection();} },
                    icon: Icon(
                      collotionState.idList.contains(_video.id) ? Icons.favorite : Icons.favorite_border,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

  }
}

class Tag extends StatelessWidget {
  Tag({this.text, this.icon, this.margin});
  Icon icon;
  Text text;
  EdgeInsetsGeometry margin;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Theme.of(context).primaryColor,
      ),
      margin: margin ?? EdgeInsets.zero,
      padding: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, text],
      ),
    );
  }
}
