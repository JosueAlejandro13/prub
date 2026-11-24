import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Barra de búsqueda con debounce y selector de filtros por estado
class SearchFilterBar extends StatefulWidget {
  final String initialQuery;
  final String initialStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const SearchFilterBar({
    super.key,
    required this.initialQuery,
    required this.initialStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const statuses = ['all', 'alive', 'dead', 'unknown'];
    final labels = {
      'all': 'Todos',
      'alive': 'Vivos',
      'dead': 'Muertos',
      'unknown': 'Desconocido',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buscar personaje',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              style: TextStyle(
                color: AppTheme.textColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  color: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                  size: 20,
                ),
                hintText: 'Ingresa nombre (ej. Rick, Morty)...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        icon: Icon(Icons.clear, color: AppTheme.subtextColor(context), size: 18),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((status) {
                final isSelected = widget.initialStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(labels[status]!),
                    selected: isSelected,
                    onSelected: (_) => widget.onStatusChanged(status),
                    selectedColor: isDark
                        ? AppTheme.portalGreen.withValues(alpha: 0.25)
                        : AppTheme.primaryGreen.withValues(alpha: 0.15),
                    checkmarkColor: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                    backgroundColor: AppTheme.surfaceColor(context),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? (isDark ? AppTheme.portalGreen : AppTheme.primaryDark)
                          : AppTheme.subtextColor(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? (isDark ? AppTheme.portalGreen : AppTheme.primaryGreen)
                          : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
