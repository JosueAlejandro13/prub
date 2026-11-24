import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/character.dart';
import '../providers/saved_characters_provider.dart';

/// Pantalla de detalle exhaustivo para un personaje
class CharacterDetailScreen extends ConsumerStatefulWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  ConsumerState<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final savedList = ref.read(savedCharactersProvider);
    final savedMatch = savedList.where((c) => c.id == widget.character.id).firstOrNull;
    _notesController = TextEditingController(text: savedMatch?.notes ?? widget.character.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
    final savedCharacters = ref.watch(savedCharactersProvider);
    final isSaved = savedCharacters.any((c) => c.id == widget.character.id);
    final statusColor = _getStatusColor(widget.character.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character.name),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.portalGreen
                      : AppTheme.primaryGreen)
                  : AppTheme.subtextColor(context),
            ),
            tooltip: isSaved ? 'Quitar de mi misión' : 'Guardar en mi misión',
            onPressed: () {
              ref.read(savedCharactersProvider.notifier).toggleSaveCharacter(
                    widget.character,
                    notes: _notesController.text.trim().isEmpty
                        ? null
                        : _notesController.text.trim(),
                  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor(context), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 280,
                    child: CachedNetworkImage(
                      imageUrl: widget.character.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.surfaceColor(context),
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.surfaceColor(context),
                        child: const Icon(Icons.broken_image, size: 64, color: AppTheme.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.character.status.toUpperCase()} - ${widget.character.species.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Datos Biológicos y de Especie',
              children: [
                _buildInfoRow('Género', widget.character.gender),
                if (widget.character.type.isNotEmpty)
                  _buildInfoRow('Subtipo', widget.character.type),
                _buildInfoRow('Episodios registrados', '${widget.character.episodeCount}'),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Ubicación Dimensional',
              children: [
                _buildInfoRow('Origen', widget.character.originName),
                _buildInfoRow('Última localización conocida', widget.character.locationName),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Notas de Misión del Investigador',
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    style: TextStyle(color: AppTheme.textColor(context), fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Añade anotaciones clave para tu misión...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white38
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () async {
                    final noteText = _notesController.text.trim();
                    await ref.read(savedCharactersProvider.notifier).saveOrUpdateCharacter(
                          widget.character,
                          notes: noteText.isEmpty ? null : noteText,
                        );
                    if (context.mounted) {
                      AppSnackBar.showSuccess(
                        context,
                        isSaved
                            ? 'Notas actualizadas exitosamente en tu misión.'
                            : 'Personaje guardado con notas en tu misión local.',
                      );
                    }
                  },
                  icon: Icon(isSaved ? Icons.save : Icons.bookmark_add, color: Colors.white),
                  label: Text(
                    isSaved ? 'ACTUALIZAR NOTAS DE MISIÓN' : 'GUARDAR EN MI MISIÓN',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.portalGreen : AppTheme.accentCyan,
              ),
            ),
            Divider(color: AppTheme.borderColor(context), height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.subtextColor(context), fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: AppTheme.textColor(context), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
