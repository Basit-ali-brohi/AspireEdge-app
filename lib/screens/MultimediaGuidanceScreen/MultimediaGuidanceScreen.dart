import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' hide PlayerState;

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

class MultimediaGuidanceScreen extends StatefulWidget {
  const MultimediaGuidanceScreen({super.key});

  @override
  State<MultimediaGuidanceScreen> createState() => _MultimediaGuidanceScreenState();
}

class _MultimediaGuidanceScreenState extends State<MultimediaGuidanceScreen> {
  List<String> _selectedTags = ['All'];
  String _searchQuery = '';
  final List<String> _tags = ['All', 'Experts', 'Career Talks', 'Student Panels'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimedia Guidance'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _buildTagFilter(),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Media List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedTags.contains('All') || _selectedTags.isEmpty
                  ? FirebaseFirestore.instance
                  .collection('multimedia')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('multimedia')
                  .where('tags', arrayContainsAny: _selectedTags)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final mediaList = snapshot.data!.docs.where((doc) {
                  final title = doc['title']?.toString().toLowerCase() ?? '';
                  final matchesSearch = _searchQuery.isEmpty ? true : title.contains(_searchQuery);
                  return matchesSearch;
                }).toList();

                if (mediaList.isEmpty) return const Center(child: Text("No media found"));

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: mediaList.length,
                  itemBuilder: (context, index) {
                    final media = mediaList[index];
                    final type = media['type']?.toString().toLowerCase() ?? 'video';
                    final title = media['title'] ?? '';
                    final url = media['url'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            type == 'video' ? VideoPlayerWidget(url: url) : AudioPlayerWidget(url: url),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilter() {
    return OutlinedButton(
      onPressed: () {
        _showMultiSelectDialog(context);
      },
      child: const Text('Filter Tags'),
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return AlertDialog(
              title: const Text('Select Tags'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: _tags.sublist(1).map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(tag),
                      onChanged: (bool? value) {
                        setStateInDialog(() {
                          if (value == true) {
                            _selectedTags.add(tag);
                            _selectedTags.remove('All');
                          } else {
                            _selectedTags.remove(tag);
                            if (_selectedTags.isEmpty) {
                              _selectedTags.add('All');
                            }
                          }
                        });
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------- Video Player ----------------
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;
  String? videoId;

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.url);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          isLive: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoId == null) {
      return const Center(child: Text('Invalid YouTube URL'));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

// ---------------- Updated Audio Player ----------------
class AudioPlayerWidget extends StatefulWidget {
  final String url;
  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState? _playerState;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.url);
      _audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          _playerState = playerState;
          if (_playerState?.processingState == ProcessingState.ready) {
            _isLoading = false;
          } else {
            _isLoading = true;
          }
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading audio: $e';
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isPlaying = _playerState?.playing ?? false;
    final isReady = _playerState?.processingState == ProcessingState.ready;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: AppColors.primary,
            ),
            onPressed: isReady
                ? () async {
              if (isPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.play();
              }
            }
                : null, // Disable button if not ready
          ),
          Expanded(
            child: StreamBuilder<Duration?>(
              stream: _audioPlayer.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return Text(
                  position.toString().split('.').first.padLeft(8, "0"),
                  style: const TextStyle(color: AppColors.textSecondary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}