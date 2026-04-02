import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class YouTubeController extends GetxController {
  late YoutubePlayerController _controller;
  String? videoId;

  final String videoUrl;
  final bool? autoPlay;
  final bool? mute;
  final bool? enableCaption;
  final String? captionLanguage;

  YouTubeController({
    required this.videoUrl,
    this.autoPlay,
    this.mute,
    this.enableCaption,
    this.captionLanguage,
  });

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Extrai o ID do vídeo da URL do YouTube
    videoId = YoutubePlayer.convertUrlToId(videoUrl);

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: autoPlay ?? false,
          mute: mute ?? false,
          enableCaption: enableCaption ?? false,
          captionLanguage: captionLanguage ?? 'pt',
          loop: true,
          useHybridComposition: true,
        ),
      );
      // Inicia com volume máximo
      _controller.setVolume(100);
    }
  }

  YoutubePlayerController get controller => _controller;
  bool get hasValidVideoId => videoId != null;

  void onPlayerReady() {
    print('Player is ready.');
  }

  void onVideoEnded(YoutubeMetaData data) {
    print('Video ended');
  }

  @override
  void onClose() {
    if (videoId != null) {
      _controller.dispose();
    }
    // Restaura as orientações permitidas
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.onClose();
  }
}

class YouTubeMiniPlayer extends StatelessWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final bool? autoPlay;
  final bool? mute;
  final bool? enableCaption;
  final String? captionLanguage;

  const YouTubeMiniPlayer({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    this.autoPlay,
    this.mute,
    this.enableCaption,
    this.captionLanguage,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(
      YouTubeController(
        videoUrl: videoUrl,
        autoPlay: autoPlay,
        mute: mute,
        enableCaption: enableCaption,
        captionLanguage: captionLanguage,
      ),
      tag: videoUrl, // Tag única para cada instância
    );

    return GetBuilder<YouTubeController>(
      tag: videoUrl,
      builder: (controller) {
        if (!controller.hasValidVideoId) {
          return Container(
            width: width ?? 320,
            height: height ?? 180,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'invalid_youtube_url'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width ?? 320,
              height: height ?? 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: YoutubePlayer(
                  controller: controller.controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                  onReady: controller.onPlayerReady,
                  onEnded: controller.onVideoEnded,
                  bottomActions: [
                    CurrentPosition(),
                    ProgressBar(isExpanded: true),
                    RemainingDuration(),
                    PlaybackSpeedButton(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: Text('watch_on_youtube'.tr),
              onPressed: () async {
                final url =
                    'https://www.youtube.com/watch?v=${controller.videoId}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
