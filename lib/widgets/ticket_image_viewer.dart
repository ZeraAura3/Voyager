// lib/widgets/ticket_image_viewer.dart
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full-screen image viewer for ticket images
class TicketImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? ticketInfo;

  const TicketImageViewer({
    super.key,
    required this.imageUrl,
    this.ticketInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Ticket Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed:
                ticketInfo != null ? () => _showTicketInfo(context) : null,
            tooltip: 'Ticket Info',
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: const Color(0xFF00B25E),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ticket Information'),
        content: Text(ticketInfo ?? 'No information available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Static method to show image viewer
  static void show(BuildContext context, String imageUrl,
      {String? ticketInfo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketImageViewer(
          imageUrl: imageUrl,
          ticketInfo: ticketInfo,
        ),
      ),
    );
  }
}

/// Widget for displaying ticket thumbnail with tap to view full screen
class TicketImageThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double? width;
  final BoxFit fit;
  final String? ticketInfo;

  const TicketImageThumbnail({
    super.key,
    required this.imageUrl,
    this.height = 120,
    this.width,
    this.fit = BoxFit.cover,
    this.ticketInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return GestureDetector(
      onTap: () => TicketImageViewer.show(
        context,
        imageUrl!,
        ticketInfo: ticketInfo,
      ),
      child: Hero(
        tag: imageUrl!,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  height: height,
                  width: width,
                  fit: fit,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFF00B25E),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                ),
                // Tap indicator overlay
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Tap to view',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
