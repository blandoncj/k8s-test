#!/bin/bash

# ==============================================================================
# Script para Realizar Copias de Seguridad de MariaDB en Kubernetes
# ==============================================================================

# --- Configuración ---
# !!! IMPORTANTE: AJUSTA ESTAS VARIABLES SEGÚN TU ENTORNO !!!
K8S_NAMESPACE="microservices-ns"      # Namespace donde corre MariaDB
DB_NAME="proddb_k8s"                  # Nombre de la base de datos a respaldar (debe coincidir con MARIADB_DATABASE en el Secret)
BACKUP_BASE_DIR="${HOME}/mariadb_backups_parcial3" # Directorio base donde se guardarán los backups

# Nombre de la etiqueta 'app' para el pod de MariaDB (debe coincidir con el Deployment)
MARIADB_APP_LABEL="mariadb"

# --- Funciones Auxiliares ---
log_info() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $1" >&2
}

# Verifica el código de salida del último comando ejecutado
check_command_success() {
  if [ $? -ne 0 ]; then
    log_error "El comando anterior falló. Abortando script."
    exit 1
  fi
}

# --- Lógica Principal ---
log_info "--- Iniciando Script de Backup de MariaDB ---"

# Crear directorio de backup si no existe
log_info "Verificando/Creando directorio de backup: ${BACKUP_BASE_DIR}"
mkdir -p "${BACKUP_BASE_DIR}"
check_command_success

# Obtener el nombre del pod de MariaDB (asume que solo hay uno con esa etiqueta)
log_info "Obteniendo nombre del pod de MariaDB en namespace '${K8S_NAMESPACE}' con etiqueta app='${MARIADB_APP_LABEL}'..."
MARIADB_POD_NAME=$(kubectl get pods -n "${K8S_NAMESPACE}" -l "app=${MARIADB_APP_LABEL}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$MARIADB_POD_NAME" ] || [ "$MARIADB_POD_NAME" == "null" ]; then
    log_error "No se encontró ningún pod de MariaDB con la etiqueta app='${MARIADB_APP_LABEL}' en el namespace '${K8S_NAMESPACE}'."
    log_error "Verifica la etiqueta y el namespace."
    exit 1
fi
log_info "Pod de MariaDB encontrado: ${MARIADB_POD_NAME}"

# Generar nombre del archivo de backup con fecha y hora
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE_NAME="backup_${DB_NAME}_${TIMESTAMP}.sql.gz" # Backup comprimido
FULL_BACKUP_PATH="${BACKUP_BASE_DIR}/${BACKUP_FILE_NAME}"

log_info "Iniciando backup de la base de datos '${DB_NAME}' desde el pod '${MARIADB_POD_NAME}'..."
log_info "El backup se guardará en: ${FULL_BACKUP_PATH}"

# Comando a ejecutar dentro del pod de MariaDB
# Utiliza las variables de entorno MARIADB_ROOT_PASSWORD y MARIADB_DATABASE que están definidas
# en el contenedor de MariaDB (inyectadas desde el Secret).
# Si tu Secret define MARIADB_USER y MARIADB_PASSWORD para un usuario específico de la app,
# podrías usarlos en lugar de root si ese usuario tiene permisos de DUMP.
# Por simplicidad, usamos root aquí, asumiendo que MARIADB_ROOT_PASSWORD está disponible.
COMMAND_TO_EXEC="sh -c 'mariadb-dump --user=root --password=\"\$MARIADB_ROOT_PASSWORD\" --databases \"${DB_NAME}\" | gzip -c'"

# Ejecutar el comando de backup
log_info "Ejecutando comando de backup dentro del pod..."
if kubectl exec -n "${K8S_NAMESPACE}" "${MARIADB_POD_NAME}" -- \
    $COMMAND_TO_EXEC > "${FULL_BACKUP_PATH}"; then
    log_info "Comando de backup ejecutado."
else
    log_error "Falló la ejecución del comando de backup dentro del pod."
    # Eliminar archivo de backup parcial si se creó
    [ -f "${FULL_BACKUP_PATH}" ] && rm "${FULL_BACKUP_PATH}"
    exit 1
fi


# Verificar si el backup se creó y no está vacío
if [ -f "${FULL_BACKUP_PATH}" ] && [ -s "${FULL_BACKUP_PATH}" ]; then
    log_info "Backup de MariaDB completado exitosamente."
    log_info "Archivo de backup: ${FULL_BACKUP_PATH}"
    log_info "Tamaño del backup: $(du -h "${FULL_BACKUP_PATH}" | cut -f1)"
else
    log_error "El backup falló o el archivo de backup está vacío o no se pudo crear."
    # Eliminar archivo vacío si existe
    [ -f "${FULL_BACKUP_PATH}" ] && rm "${FULL_BACKUP_PATH}"
    exit 1
fi

log_info "Listando los 5 backups más recientes en ${BACKUP_BASE_DIR}:"
ls -lt "${BACKUP_BASE_DIR}" | head -n 6 # head -n 6 para incluir la línea de 'total'

log_info "--- Script de Backup de MariaDB Finalizado ---"
exit 0
