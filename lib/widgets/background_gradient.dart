import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../providers/ad_provider.dart';

const double opacity = 0.9;
List<List<Color>> colors = [
  [
    Colors.blue.withOpacity(opacity),
    Colors.purple.withOpacity(0.7),
    Colors.red.withOpacity(opacity),
  ],
];

const List<Alignment> alignmentList = [
  Alignment.bottomLeft,
  Alignment.bottomRight,
  Alignment.topRight,
  Alignment.topLeft,
];

class BackgroundGradient extends StatefulWidget {
  final Widget child;

  const BackgroundGradient({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _BackgroundGradientState createState() => _BackgroundGradientState();
}

class _BackgroundGradientState extends State<BackgroundGradient> {
  bool started = false;
  BannerAd? bannerAd;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final adProvider = Provider.of<AdProvider>(context, listen: false);
    adProvider.initialization.then((status) {
      setState(() {
        bannerAd = BannerAd(
          size: AdSize.banner,
          adUnitId: adProvider.bannerAdUnitId,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              ad.dispose();
            },
          ),
        )..load();
      });
    });
  }

  int index = 1;
  List<Color> selectColors = colors[0];
  Alignment begin = alignmentList[0];
  Alignment end = alignmentList[1];

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      if (!started) {
        setState(() {
          started = true;
          begin = alignmentList[1];
          end = alignmentList[2];
        });
      }
    });
    return Stack(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 3000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: selectColors,
            stops: const [0.42, 0.5, 0.58],
          ),
        ),
        onEnd: () {
          setState(() {
            index = index + 1;
            selectColors = colors[index % colors.length];
            begin = alignmentList[index % alignmentList.length];
            end = alignmentList[(index + 1) % alignmentList.length];
          });
        },
      ),
      Column(
        children: [
          Expanded(child: widget.child),
          if (bannerAd != null)
            SizedBox(
              height: AdSize.banner.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
        ],
      )
    ]);
  }
}
