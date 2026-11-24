# Multiverse

Aplicación móvil desarrollada en **Flutter & Dart** para la resolución del reto técnico de **MADD SYSTEMS S.A. DE C.V.**

---

## Descripción del Proyecto

**Multiverse** permite a los investigadores consultar información de personajes de la API de Rick and Morty, realizar búsquedas ágiles con filtros, conservar personajes en su registro de misión para consulta offline y operar en dispositivos compartidos manteniendo sus registros totalmente aislados mediante su número de celular.

---

## Tecnologías y Librerías Utilizadas

* **Framework:** Flutter 3.47+ / Dart 3.13+
* **Gestión de Estado & DI:** `flutter_riverpod` (v3)
* **Persistencia Segura (Sesión & Auth):** `flutter_secure_storage` (Cifrado Keystore/Keychain)
* **Base de Datos Local:** `sqflite` + `path` + `sqflite_common_ffi` (para testing)
* **Consumo de API:** `dio`
* **Caché de Imágenes:** `cached_network_image`
* **Detección de Conectividad:** `connectivity_plus`
* **Notificaciones Flotantes:** `top_snackbar_flutter` (Píldoras adaptativas estilo Apple)
* **Criptografía:** `crypto` (sha256 para tokens de sesión)

---

## Arquitectura

El proyecto sigue los principios de **Clean Architecture básica**:

```
lib/
├── core/
│   ├── constants/        # Endpoints y constantes de la API
│   ├── network/          # Cliente Dio y detector de conectividad
│   ├── storage/          # Helper de SQLite y servicio de Secure Storage
│   ├── theme/            # Paleta de colores y estilos visuales
│   └── widgets/          # Componentes reutilizables (AppSnackBar)
├── features/
│   ├── auth/             # Módulo de identificación por celular
│   │   ├── data/         # Repositorio con Secure Storage y cifrado de token
│   │   ├── domain/       # Entidad Researcher y contratos
│   │   └── presentation/ # Riverpod notifier y pantalla de acceso
│   └── characters/       # Módulo de personajes y misiones
│       ├── data/         # DataSources (API pública + SQLite local) y modelos
│       ├── domain/       # Entidades y contratos de repositorio
│       └── presentation/ # Notifiers, pantallas (Explorar, Detalle, Misiones) y widgets
└── main.dart             # Punto de entrada y orquestador de sesión
```

---

## Características Principales

1. **Identificación por Celular (Multi-usuario):**
   * El acceso requiere el número celular del investigador (con código simulado `1234`).
   * El token y número en sesión se guardan de forma encriptada en `flutter_secure_storage`.
   * Permite cerrar sesión y cambiar de investigador sin mezclar misiones ni personajes guardados.
2. **Aislamiento en Base de Datos Local SQLite:**
   * Las misiones se almacenan en SQLite con la clave de partición `user_phone`.
   * Cuando el investigador A guarda un personaje con notas, el investigador B no lo ve en su sesión.
3. **Exploración Ágil con Debounce y Filtros:**
   * Barra de búsqueda con retardo de 400ms para evitar peticiones redundantes a la red.
   * Filtro rápido por estado (*Todos, Vivos, Muertos, Desconocido*).
   * Paginación dinámica (scroll infinito).
4. **Modo Expedición (Offline):**
   * Detección activa de red mediante `connectivity_plus`.
   * Banner de advertencia cuando se pierde la conexión.
   * Consulta completa de personajes guardados para misiones y notas sin internet.
   * Respuestas descriptivas en búsquedas vacías o fallos de red con opción de reintentar.
5. **Centro de Notificaciones:**
   * Centro de eventos del multiverso accesible desde la barra superior con badge de avisos no leídos.
6. **Feedback Visual Estilo Apple (Píldoras Flotantes):**
   * Alertas contextuales tipo cápsula (`AppSnackBar`) adaptadas dinámicamente al tema claro y oscuro para confirmar acciones o reportar errores.
7. **Perfil de Investigador & Tema Dinámico:**
   * Credencial editable (nombre, rango, dimensión y notas) guardada en SQLite.
   * Conmutador dinámico de Tema Claro / Tema Oscuro.
8. **Pruebas Automatizadas Rigurosas:**
   * Suite de 15 pruebas unitarias que validan serialización de modelos, fallback offline del repositorio y aislamiento multi-inquilino en SQLite (`sqflite_common_ffi`).

---

## Instrucciones para Ejecutar el Proyecto

### Prerrequisitos
* Flutter SDK (3.x o superior) instalado y en el PATH.
* Android Studio / Dispositivo físico Android conectado con depuración USB habilitada.

### Pasos
1. Clonar el repositorio:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd multiverse_explorers
   ```
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Verificar análisis estático:
   ```bash
   flutter analyze
   ```
4. Ejecutar suite de pruebas unitarias:
   ```bash
   flutter test
   ```
5. Ejecutar la aplicación en emulador o dispositivo conectado:
   ```bash
   flutter run
   ```

### Generación de APK Release
Para generar el archivo instalable Android:
```bash
flutter build apk --release
```
El archivo generado se ubicará en:  
`build/app/outputs/flutter-apk/app-release.apk`
