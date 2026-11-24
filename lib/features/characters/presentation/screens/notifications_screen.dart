import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';

class NotificationItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final bool isUnread;
  final Color iconColor;

  const NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.isUnread,
    required this.iconColor,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const List<NotificationItem> _mockNotifications = [
    NotificationItem(
      title: 'Fluctuación Dimensional Detectada',
      description: 'Brecha de portal no autorizada en el sector C-137. Mantener precaución en campo.',
      time: 'Hace 5 min',
      icon: Icons.radar_rounded,
      isUnread: true,
      iconColor: Colors.amber,
    ),
    NotificationItem(
      title: 'Personaje Añadido a Misión',
      description: 'Rick Sanchez fue sincronizado exitosamente en la memoria local del dispositivo.',
      time: 'Hace 22 min',
      icon: Icons.bookmark_added_rounded,
      isUnread: true,
      iconColor: AppTheme.primaryGreen,
    ),
    NotificationItem(
      title: 'Protocolo de Expedición Offline',
      description: 'Se activó el almacenamiento en caché SQLite para navegación sin cobertura satelital.',
      time: 'Hace 45 min',
      icon: Icons.wifi_off_rounded,
      isUnread: true,
      iconColor: AppTheme.accentCyan,
    ),
    NotificationItem(
      title: 'Actualización de Datos de la Ciudadela',
      description: 'Nuevos registros biométricos de variantes de Morty disponibles en la red pública.',
      time: 'Hace 2 h',
      icon: Icons.hub_rounded,
      isUnread: false,
      iconColor: Colors.blueAccent,
    ),
    NotificationItem(
      title: 'Batería de Microverso Estable',
      description: 'Nivel de energía al 98% en el generador de portal de la nave de exploración.',
      time: 'Hace 3 h',
      icon: Icons.battery_charging_full_rounded,
      isUnread: false,
      iconColor: AppTheme.primaryGreen,
    ),
    NotificationItem(
      title: 'Alerta de Parásito Telepático',
      description: 'Verificar recuerdos recientes de la tripulación. Recuerdos placenteros bajo sospecha.',
      time: 'Hace 5 h',
      icon: Icons.warning_amber_rounded,
      isUnread: false,
      iconColor: Colors.redAccent,
    ),
    NotificationItem(
      title: 'Cambio de Investigador Registrado',
      description: 'Sesión anterior cerrada y credenciales cifradas con éxito en Keystore local.',
      time: 'Hace 8 h',
      icon: Icons.lock_outline_rounded,
      isUnread: false,
      iconColor: Colors.deepPurpleAccent,
    ),
    NotificationItem(
      title: 'Sincronización de Notas de Misión',
      description: 'Anotaciones de reconocimiento guardadas de forma independiente en tu perfil.',
      time: 'Ayer, 18:30',
      icon: Icons.edit_note_rounded,
      isUnread: false,
      iconColor: AppTheme.accentCyan,
    ),
    NotificationItem(
      title: 'Informe Meteorológico: Cronenberg',
      description: 'Lluvia ácida de ADN mutante en la dimensión de reemplazo. Portar traje Hazmat.',
      time: 'Ayer, 12:15',
      icon: Icons.science_outlined,
      isUnread: false,
      iconColor: Colors.teal,
    ),
    NotificationItem(
      title: 'Bienvenido al Multiverse Explorer',
      description: 'Tu terminal móvil está configurada con acceso a más de 800 registros cósmicos.',
      time: 'Hace 2 días',
      icon: Icons.rocket_launch_rounded,
      isUnread: false,
      iconColor: AppTheme.primaryGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
              AppSnackBar.showSuccess(context, 'Todas las notificaciones marcadas como leídas.');
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _mockNotifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _mockNotifications[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item.isUnread
                  ? (isDark
                      ? AppTheme.portalGreen.withValues(alpha: 0.08)
                      : AppTheme.primaryGreen.withValues(alpha: 0.06))
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isUnread
                    ? (isDark
                        ? AppTheme.portalGreen.withValues(alpha: 0.35)
                        : AppTheme.primaryGreen.withValues(alpha: 0.3))
                    : AppTheme.borderColor(context),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: item.iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isUnread ? FontWeight.w800 : FontWeight.w600,
                                color: AppTheme.textColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.subtextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.subtextColor(context),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
