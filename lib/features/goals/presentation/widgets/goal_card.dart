import 'dart:ui' as ui;
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/goal_model.dart';

class GoalCard extends StatefulWidget {
  final GoalModel goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String searchQuery;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _downloadGoalImage() async {
    try {
      final boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Capture image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final String fileName =
            'goal_${widget.goal.title.replaceAll(RegExp(r'\s+'), '_')}.png';

        // Web Download using package:web
        final blob = web.Blob([pngBytes.toJS].toJS);
        final url = web.URL.createObjectURL(blob);
        final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
        anchor.href = url;
        anchor.download = fileName;
        anchor.click();
        web.URL.revokeObjectURL(url);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image downloaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download goal: $e')));
      }
    }
  }

  Color _getProgressColor(BuildContext context, int progress) {
    final scheme = Theme.of(context).colorScheme;
    if (progress == 0) return scheme.error;
    if (progress == 100) return scheme.primary;
    return scheme.secondary;
  }

  Widget _buildTitle(BuildContext context) {
    if (widget.searchQuery.isEmpty) {
      return Text(
        widget.goal.title,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    final lowerTitle = widget.goal.title.toLowerCase();
    final lowerQuery = widget.searchQuery.toLowerCase();
    final startIndex = lowerTitle.indexOf(lowerQuery);

    if (startIndex == -1) {
      return Text(
        widget.goal.title,
        style: Theme.of(context).textTheme.titleLarge,
      );
    }

    final endIndex = startIndex + lowerQuery.length;
    final beforeMatch = widget.goal.title.substring(0, startIndex);
    final match = widget.goal.title.substring(startIndex, endIndex);
    final afterMatch = widget.goal.title.substring(endIndex);

    final style = Theme.of(context).textTheme.titleLarge;
    final colorScheme = Theme.of(context).colorScheme;
    final highlightStyle = style?.copyWith(
      backgroundColor: colorScheme.tertiaryContainer,
      color: colorScheme.onTertiaryContainer,
    );

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: beforeMatch),
          TextSpan(text: match, style: highlightStyle),
          TextSpan(text: afterMatch),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      key: _globalKey,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildTitle(context)),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _downloadGoalImage,
                    tooltip: 'Download Image',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        widget.onEdit();
                      } else if (value == 'delete') {
                        widget.onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.goal.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(widget.goal.description),
              ],
              if (widget.goal.startDate != null ||
                  widget.goal.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (widget.goal.startDate != null)
                      Text(
                        'Start: ${DateFormat.yMMMd().format(widget.goal.startDate!.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (widget.goal.startDate != null &&
                        widget.goal.endDate != null)
                      const SizedBox(width: 16),
                    if (widget.goal.endDate != null)
                      Text(
                        'End: ${DateFormat.yMMMd().format(widget.goal.endDate!.toDate())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: widget.goal.progress / 100,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: _getProgressColor(context, widget.goal.progress),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.goal.progress}%',
                    style: TextStyle(
                      color: _getProgressColor(context, widget.goal.progress),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
