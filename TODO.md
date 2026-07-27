# MotorCheck - Tareas Pendientes

## Alta Prioridad

- [ ] **Recordatorios / Próximos mantenimientos**
  - Definir intervalos (km o fecha) por categoría
  - Dashboard muestra "Próximo: cambio de aceite en 500km o 15 Ago"
  - Notificación push local al acercarse el intervalo

- [ ] **Estadísticas y gráficos**
  - Dashboard con charts usando `fl_chart`
  - Gasto mensual acumulado (barras)
  - Distribución por categoría (torta)
  - Evolución de costos por vehículo (línea)

- [ ] **Exportar datos**
  - Exportar mantenimientos a CSV
  - Compartir archivo con mecánico o como respaldo

## Media Prioridad

- [ ] **Adjuntar fotos**
  - Subir foto de factura/recibo al registrar mantenimiento
  - Guardar en `image_path` local
  - Mostrar miniatura en detalle

- [x] **Modo oscuro**
  - Toggle en Configuración
  - `ThemeMode.system / dark / light`
  - Guardar preferencia con `shared_preferences`

- [ ] **Plantillas de mantenimiento**
  - Definir paquetes predefinidos (ej: "Cambio de aceite completo")
  - Items pre-cargados: aceite + filtro + mano de obra
  - Seleccionar plantilla al registrar → auto-llena formulario

## Baja Prioridad

- [ ] **Seguimiento de combustible**
  - Nueva feature: cargas de combustible
  - Campos: fecha, km, litros, costo
  - Dashboard muestra consumo (km/L)

- [ ] **Backup / Restore**
  - Exportar toda la DB SQLite a un archivo `.db`
  - Importar desde archivo
  - Útil al cambiar de teléfono

- [x] **Más campos del vehículo**
  - VIN / número de serie
  - Fecha vencimiento SOAT
  - Fecha revisión técnico-mecánica
  - Recordatorios de vencimiento en dashboard

---

*Última actualización: Jul 2026*
