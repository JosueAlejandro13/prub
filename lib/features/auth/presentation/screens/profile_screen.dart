import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../characters/presentation/providers/saved_characters_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final currentProfile = ref.read(profileProvider);
    final nameController = TextEditingController(text: currentProfile.name);
    final rankController = TextEditingController(text: currentProfile.rank);
    final dimensionController = TextEditingController(text: currentProfile.dimension);
    final notesController = TextEditingController(text: currentProfile.notes);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registro de Investigador',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(ctx),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Nombre de Investigador', ctx),
                TextFormField(
                  controller: nameController,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor(ctx)),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Rick Sánchez, Morty Smith...',
                  ),
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Rango / Título', ctx),
                TextFormField(
                  controller: rankController,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor(ctx)),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Científico Jefe, Explorador de Campo...',
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Dimensión de Asignación', ctx),
                TextFormField(
                  controller: dimensionController,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor(ctx)),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Tierra C-137, Dimensión 35-C...',
                  ),
                ),
                const SizedBox(height: 14),
                _buildFieldLabel('Notas de Credencial', ctx),
                TextFormField(
                  controller: notesController,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13, color: AppTheme.textColor(ctx)),
                  decoration: const InputDecoration(
                    hintText: 'Anotaciones opcionales...',
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    await ref.read(profileProvider.notifier).updateProfile(
                          name: nameController.text.trim(),
                          rank: rankController.text.trim().isEmpty
                              ? 'Explorador Novato'
                              : rankController.text.trim(),
                          dimension: dimensionController.text.trim().isEmpty
                              ? 'Tierra C-137'
                              : dimensionController.text.trim(),
                          notes: notesController.text.trim(),
                        );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    if (context.mounted) {
                      AppSnackBar.showSuccess(context, 'Datos de perfil actualizados exitosamente.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('GUARDAR DATOS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFieldLabel(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.subtextColor(context)),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        surfaceTintColor: Theme.of(ctx).cardColor,
        title: Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor(ctx))),
        content: Text(
          '¿Deseas cerrar tu sesión de investigador? Tus misiones y datos de perfil quedarán guardados de forma segura e independiente en este dispositivo.',
          style: TextStyle(color: AppTheme.subtextColor(ctx)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancelar', style: TextStyle(color: AppTheme.subtextColor(ctx))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              Future.microtask(() {
                ref.read(authNotifierProvider.notifier).logout();
              });
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final authState = ref.watch(authNotifierProvider);
    final userPhone = authState.researcher?.phone ?? profile.phone;
    final savedCharacters = ref.watch(savedCharactersProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final hasRegisteredName = profile.name.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Investigador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Editar credencial',
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppTheme.portalGreen.withValues(alpha: 0.3), AppTheme.accentCyan.withValues(alpha: 0.2)]
                                : [AppTheme.primaryGreen.withValues(alpha: 0.18), AppTheme.accentCyan.withValues(alpha: 0.1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                            width: 2.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            hasRegisteredName ? profile.name.substring(0, 1).toUpperCase() : '🛸',
                            style: TextStyle(
                              fontSize: hasRegisteredName ? 34 : 36,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEditProfileDialog(context, ref),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                            border: Border.all(color: Theme.of(context).cardColor, width: 2),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 14,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasRegisteredName ? profile.name : 'Investigador sin registrar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildBadgeChip(
                        icon: Icons.military_tech_rounded,
                        label: profile.rank,
                        context: context,
                        isHighlight: true,
                      ),
                      _buildBadgeChip(
                        icon: Icons.public_rounded,
                        label: profile.dimension,
                        context: context,
                        isHighlight: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    icon: Icons.bookmark_added_rounded,
                    value: '${savedCharacters.length}',
                    label: 'Misiones',
                    subtitle: 'Guardados offline',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context: context,
                    icon: Icons.phone_android_rounded,
                    value: userPhone.isNotEmpty ? userPhone : 'N/A',
                    label: 'Celular ID',
                    subtitle: 'Espacio asignado',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderColor(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Datos de la Credencial',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showEditProfileDialog(context, ref),
                          child: Text(
                            'Modificar',
                            style: TextStyle(
                              color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: AppTheme.borderColor(context), height: 20),
                    _buildCredentialRow(
                      icon: Icons.phone_outlined,
                      label: 'Número Celular',
                      value: userPhone,
                      context: context,
                    ),
                    _buildCredentialRow(
                      icon: Icons.travel_explore_rounded,
                      label: 'Dimensión Asignada',
                      value: profile.dimension,
                      context: context,
                    ),
                    _buildCredentialRow(
                      icon: Icons.badge_outlined,
                      label: 'Rango Oficial',
                      value: profile.rank,
                      context: context,
                    ),
                    if (profile.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Anotaciones de Misión:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.subtextColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.notes,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderColor(context)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            size: 22,
                            color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo Oscuro',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.textColor(context),
                              ),
                            ),
                            Text(
                              isDark ? 'Estética espacial activa' : 'Luz clara predeterminada',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.subtextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: isDark,
                      activeThumbColor: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              label: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeChip({
    required IconData icon,
    required String label,
    required BuildContext context,
    required bool isHighlight,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight
            ? (isDark
                ? AppTheme.portalGreen.withValues(alpha: 0.15)
                : AppTheme.primaryGreen.withValues(alpha: 0.12))
            : AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isHighlight
                ? (isDark ? AppTheme.portalGreen : AppTheme.primaryDark)
                : AppTheme.subtextColor(context),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHighlight
                  ? (isDark ? AppTheme.portalGreen : AppTheme.primaryDark)
                  : AppTheme.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.subtextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.subtextColor(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: AppTheme.subtextColor(context)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
