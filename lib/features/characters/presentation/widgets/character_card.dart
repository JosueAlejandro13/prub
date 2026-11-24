import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/character.dart';

/// Tarjeta de presentación para un personaje en las listas
class CharacterCard extends StatelessWidget {
  final Character character;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const CharacterCard({
    super.key,
    required this.character,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSave,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppTheme.primaryGreen;
      case 'dead':
        return Colors.redAccent;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(character.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              height: 120,
              child: CachedNetworkImage(
                imageUrl: character.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.surfaceColor(context),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surfaceColor(context),
                  child: const Icon(Icons.broken_image, color: AppTheme.textMuted),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${character.status} - ${character.species}',
                            style: TextStyle(fontSize: 12, color: AppTheme.subtextColor(context), fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Origen: ${character.originName}',
                      style: TextStyle(fontSize: 11, color: AppTheme.subtextColor(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Episodios: ${character.episodeCount}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.portalGreen
                        : AppTheme.primaryGreen)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38),
              ),
              tooltip: isSaved ? 'Guardado en tu misión' : 'Guardar en misión',
              onPressed: onToggleSave,
            ),
          ],
        ),
      ),
    );
  }
}
