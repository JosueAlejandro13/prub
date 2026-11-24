# Plan de Trabajo y Bitácora Técnica

**Proyecto:** Multiverse (Exploradores del Multiverso)  
**Organización Evaluadora:** MADD SYSTEMS S.A. DE C.V.  
**Candidato:** Desarrollador de Aplicaciones Móviles  
**Tecnología:** Flutter & Dart  

---

## 1. Plan Inicial

### 1.1 Problemas Identificados en el Reto
1. **Espacio de trabajo compartido y no aislado:** Los dispositivos móviles pasan de un investigador a otro. Los registros y selecciones de personajes no deben mezclarse entre colegas.
2. **Pérdida de información en expediciones sin internet:** Las fallas de conectividad impiden a los investigadores consultar los personajes previamente seleccionados para sus misiones.
3. **Dificultad de localización rápida:** Explorar más de 800 personajes en la API pública de Rick and Morty requiere un mecanismo ágil de búsqueda y filtrado.
4. **Retroalimentación deficiente:** Ausencia de retroalimentación clara cuando falla la red o cuando una búsqueda no arroja coincidencias.

### 1.2 Matriz de Tareas, Prioridad y Estimación

| Tarea | Prioridad | Estimación |
| :--- | :---: | :---: |
| **Configuración de Arquitectura Clean y Dependencias** (Riverpod, SQLite, Dio, Secure Storage) | Alta | 1.5 h |
| **Identificación Segura por Celular y Gestión de Sesión** (flutter_secure_storage) | Alta | 1.5 h |
| **Diseño y Persistencia en SQLite Multi-inquilino** (aislamiento por número celular) | Alta | 2.0 h |
| **Consumo de API con Dio, Paginación y Búsqueda con Debounce** | Alta | 2.5 h |
| **Manejo Offline y Estados de Red** (connectivity_plus, banner y fallback local) | Media | 1.5 h |
| **Detalle de Personaje y Registro de Notas de Misión** | Media | 1.0 h |
| **Verificación, Generación de Documentos y Empaquetado APK** | Alta | 1.0 h |
| **Total Estimado** | | **11.0 h** |

---

## 2. Bitácora de Desarrollo

### 2.1 Tareas Realizadas y Orden Cronológico
1. **Inicialización y Limpieza de Proyecto:** Creación del proyecto Flutter bajo la estructura modular Clean Architecture básica (`core`, `features/auth`, `features/characters`).
2. **Capa Core e Infraestructura:**
   - Creación de cliente HTTP con `dio` (`ApiClient`).
   - Implementación de `SecureStorageService` usando `flutter_secure_storage` para proteger el token y el teléfono en sesión.
   - Creación de `DatabaseHelper` con tablas `saved_characters` (con clave foránea compuesta por `user_phone`) y `cached_characters`.
   - Tema oscuro inspirado en la estética interdimensional de Rick and Morty (`AppTheme`).
3. **Módulo de Autenticación (`features/auth`):**
   - Entidad `Researcher` y repositorio `AuthRepositoryImpl`.
   - Simulación de token criptográfico basado en `sha256` y guardado en almacenamiento seguro.
   - Pantalla `LoginScreen` con validación de celular y código de 4 dígitos.
4. **Módulo de Personajes (`features/characters`):**
   - Modelos y mapeos bidireccionales JSON y SQLite.
   - Fuentes de datos: `CharacterRemoteDataSource` (API pública) y `CharacterLocalDataSource` (SQLite).
   - Coordinador `CharacterRepositoryImpl` que realiza caching automático al consumir red y fallback a SQLite cuando no hay conexión.
   - Notificadores Riverpod (`CharacterListNotifier` y `SavedCharactersNotifier`).
5. **Interfaz de Usuario y Experiencia Offline:**
   - Barra de búsqueda con temporizador `debounce` de 400ms para evitar saturación de red.
   - Filtros por estado (*Todos, Vivos, Muertos, Desconocido*).
   - Detección activa de red con banner de "Modo Expedición".
   - Pantalla de detalle con notas personalizadas para misiones.
   - Pantalla dedicada "Mis Misiones" exclusiva para el investigador activo.
6. **Suite de Pruebas Automatizadas y Calidad:**
   - Pruebas unitarias de serialización y modelos (`CharacterModel`).
   - Pruebas de aislamiento multi-inquilino en SQLite demostrando no colisión entre investigadores (`sqflite_common_ffi`).
   - Pruebas del repositorio con fallback offline y consumo de red.
   - Pruebas de autenticación con token seguro y cierre de sesión.
7. **Refinamiento de UX, Notificaciones y Feedback Visual:**
   - Implementación de notificaciones tipo píldora flotante estilo Apple con `top_snackbar_flutter` y adaptación dinámica a tema claro/oscuro.
   - Creación del Centro de Notificaciones con 10 eventos multiversales y badge reactivo.
   - Simplificación del campo de código a formato OTP visible con reenvío de SMS simulado.
   - Rediseño de la pantalla de Perfil con métricas de misión y credencial dimensional.

### 2.2 Decisiones Técnicas Clave
* **Uso exclusivo de Riverpod 3.x:** Se descartó combinar Provider y Riverpod simultáneamente para evitar duplicidad conceptual y mantener consistencia estricta en el árbol de dependencias.
* **Almacenamiento Seguro sobre SharedPreferences:** La sesión y el celular del investigador se gestionan mediante `flutter_secure_storage` para aprovechar el cifrado Keystore en Android.
* **Estrategia Offline Bajo Demanda vs Carga Masiva:** En lugar de saturar la red descargando las 42 páginas de la API en el login, se implementó almacenamiento bajo demanda: la búsqueda y navegación cachea lo consultado, mientras que los personajes marcados para misión se guardan íntegros con notas en SQLite asociados al número celular del investigador.
* **Aislamiento Multi-usuario en Base de Datos:** La tabla SQLite `saved_characters` utiliza `(id, user_phone)` como clave primaria. Esto permite que el dispositivo pase de un investigador a otro sin que los registros de uno sean visibles para el otro.

### 2.3 Dificultades y Soluciones
* **Dificultad:** La API de Rick and Morty responde con código HTTP 404 cuando una búsqueda no arroja coincidencias en lugar de una lista vacía.
  * **Solución:** En `CharacterRemoteDataSource`, se capturó `DioException` evaluando si el status code es 404, retornando una lista vacía para permitir que la capa de presentación muestre un mensaje explicativo al usuario en lugar de un error de conexión genérico.
* **Dificultad:** Dispositivos compartidos que cambian de manos.
  * **Solución:** Se agregó un botón visible para "Cambiar de Investigador" en la barra superior que limpia la sesión en el almacenamiento seguro y recarga el estado de Riverpod sin eliminar los datos locales de cada investigador en SQLite.

### 2.4 Pendientes y Mejoras Futuras
* **Descarga offline de imágenes en disco:** Actualmente se utiliza `cached_network_image`. En una siguiente iteración se podría almacenar el archivo binario o Base64 directamente en el almacenamiento de la aplicación para visualización de fotos incluso tras un reinicio total de caché del sistema operativo.
* **Sincronización remota bidireccional:** Añadir sincronización contra un backend propio cuando se habilite infraestructura de servidor.
