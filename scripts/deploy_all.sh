#!/bin/bash

# ==============================================================================
# Script para Automatizar la Construcción, Publicación y Despliegue de
# Microservicios Spring Boot en Kubernetes (Minikube) con MariaDB
# ==============================================================================

# --- Configuración ---
# !!! IMPORTANTE: AJUSTA ESTAS VARIABLES SEGÚN TU ENTORNO !!!
DOCKERHUB_USER="tu_usuario_dockerhub"  # Reemplaza con tu nombre de usuario de Docker Hub
K8S_NAMESPACE="microservices-ns"      # Namespace de Kubernetes donde se desplegarán los recursos
MINIKUBE_PROFILE="minikube"           # Perfil de Minikube (si usas uno específico, sino "minikube")
DEFAULT_APP_VERSION="latest"          # Etiqueta por defecto para las imágenes Docker

# Nombres de los directorios de los microservicios (deben coincidir con tus carpetas)
MICROSERVICE_CREATE_DIR="producto-create-service"
MICROSERVICE_READ_DIR="producto-read-service"
MICROSERVICE_UPDATE_DIR="producto-update-service"
MICROSERVICE_DELETE_DIR="producto-delete-service"

# Nombres de las imágenes Docker (sin el usuario de Docker Hub)
IMAGE_NAME_CREATE="producto-create-service"
IMAGE_NAME_READ="producto-read-service"
IMAGE_NAME_UPDATE="producto-update-service"
IMAGE_NAME_DELETE="producto-delete-service"

# Context paths para los endpoints (deben coincidir con server.servlet.context-path)
CONTEXT_PATH_CREATE="/create"
CONTEXT_PATH_READ="/read"
CONTEXT_PATH_UPDATE="/update"
CONTEXT_PATH_DELETE="/delete"

# Paths relativos (asume que este script está en una carpeta 'scripts/' y los proyectos un nivel arriba)
BASE_PROJECT_DIR=$(pwd)/.. 
K8S_GLOBAL_DIR="${BASE_PROJECT_DIR}/k8s-global"

# --- Funciones Auxiliares ---
log_info() {
    echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo "[WARN] $(date +'%Y-%m-%d %H:%M:%S') - $1"
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

# Función para construir y subir una imagen Docker
build_and_push_image() {
    local service_dir_name=$1
    local image_name_without_user=$2
    local service_path="${BASE_PROJECT_DIR}/${service_dir_name}"
    local full_image_name="${DOCKERHUB_USER}/${image_name_without_user}:${DEFAULT_APP_VERSION}"

    log_info "Procesando microservicio: ${service_dir_name}"
    if [ ! -d "$service_path" ]; then
        log_error "Directorio del microservicio ${service_path} no encontrado. Abortando."
        exit 1
    fi
    cd "$service_path" || exit 1

    log_info "Construyendo imagen Docker: ${full_image_name}"
    # Intenta obtener el nombre del JAR dinámicamente (puede necesitar ajustes)
    # Esto es una simplificación; si tienes nombres de JAR complejos, ajústalo o hardcodea.
    # ARTIFACT_ID=$(./mvnw help:evaluate -Dexpression=project.artifactId -q -DforceStdout)
    # VERSION=$(./mvnw help:evaluate -Dexpression=project.version -q -DforceStdout)
    # JAR_FILE_NAME_IN_DOCKERFILE="${ARTIFACT_ID}-${VERSION}.jar" 
    # docker build -t "$full_image_name" --build-arg JAR_FILE_NAME="${JAR_FILE_NAME_IN_DOCKERFILE}" .
    # Si tu Dockerfile usa un comodín para el JAR (ej. target/*.jar), lo siguiente es más simple:
    docker build -t "$full_image_name" .
    check_command_success

    log_info "Subiendo imagen ${full_image_name} a Docker Hub..."
    docker push "$full_image_name"
    check_command_success

    cd "${BASE_PROJECT_DIR}/scripts" || exit 1 # Volver al directorio de scripts
    log_info "Imagen para ${service_dir_name} construida y subida exitosamente."
}

# Función para aplicar YAMLs de Kubernetes
apply_k8s_yaml() {
    local file_path=$1
    local namespace_flag=""
    if [[ "$file_path" != *"-pv.yaml" ]]; then # PVs no son namespaced
        namespace_flag="-n ${K8S_NAMESPACE}"
    fi
    log_info "Aplicando YAML: ${file_path} ${namespace_flag}"
    kubectl apply -f "${file_path}" ${namespace_flag}
    check_command_success
}

# --- Fase 0: Preparación del Entorno ---
log_info "--- Iniciando Fase 0: Preparación del Entorno ---"

log_info "Verificando estado de Minikube (perfil: ${MINIKUBE_PROFILE})..."
if ! minikube status -p "${MINIKUBE_PROFILE}" | grep -E "host: Running|controlplane: Running|kubelet: Running|apiserver: Running" > /dev/null; then
  log_info "Minikube no está corriendo. Intentando iniciar Minikube..."
  minikube start -p "${MINIKUBE_PROFILE}" --driver=docker # Ajusta el driver si es necesario
  check_command_success
else
  log_info "Minikube ya está corriendo."
fi

log_info "Habilitando addon Ingress en Minikube (si no está activo)..."
minikube addons enable ingress -p "${MINIKUBE_PROFILE}"
check_command_success

# Apuntar kubectl al contexto de minikube y el entorno Docker al demonio de Minikube
# eval $(minikube -p "${MINIKUBE_PROFILE}" docker-env) # Comentado; puede ser preferible construir con el Docker del host.
# log_info "Configurado el entorno Docker para usar el demonio Docker de Minikube (si aplica)."

log_info "Creando namespace '${K8S_NAMESPACE}' si no existe..."
kubectl create namespace "${K8S_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
# No usamos check_command_success aquí porque si ya existe, el comando puede retornar un error no fatal.

log_info "--- Fase 0 Completada ---"


# --- Fase 1: Construir y Subir Imágenes Docker ---
log_info "--- Iniciando Fase 1: Construcción y Subida de Imágenes Docker ---"
if [ "${DOCKERHUB_USER}" == "tu_usuario_dockerhub" ]; then
    log_error "Por favor, edita este script y reemplaza 'tu_usuario_dockerhub' con tu nombre de usuario real de Docker Hub."
    exit 1
fi

# Iniciar sesión en Docker Hub (puede pedir credenciales si no estás logueado)
docker login

build_and_push_image "${MICROSERVICE_CREATE_DIR}" "${IMAGE_NAME_CREATE}"
build_and_push_image "${MICROSERVICE_READ_DIR}" "${IMAGE_NAME_READ}"
build_and_push_image "${MICROSERVICE_UPDATE_DIR}" "${IMAGE_NAME_UPDATE}"
build_and_push_image "${MICROSERVICE_DELETE_DIR}" "${IMAGE_NAME_DELETE}"

log_info "--- Fase 1 Completada: Todas las imágenes construidas y subidas ---"


# --- Fase 2: Desplegar/Actualizar Recursos de Kubernetes ---
log_info "--- Iniciando Fase 2: Despliegue en Kubernetes ---"

# Desplegar MariaDB y recursos globales
log_info "Desplegando recursos globales de MariaDB..."
apply_k8s_yaml "${K8S_GLOBAL_DIR}/01-mariadb-pv.yaml"
apply_k8s_yaml "${K8S_GLOBAL_DIR}/02-mariadb-pvc.yaml"
apply_k8s_yaml "${K8S_GLOBAL_DIR}/03-mariadb-secret.yaml"
apply_k8s_yaml "${K8S_GLOBAL_DIR}/04-mariadb-deployment.yaml"
apply_k8s_yaml "${K8S_GLOBAL_DIR}/05-mariadb-service.yaml"

log_info "Esperando a que MariaDB Deployment esté listo (timeout 5 mins)..."
kubectl wait --for=condition=available deployment/mariadb-deployment -n "${K8S_NAMESPACE}" --timeout=300s
check_command_success
log_info "MariaDB desplegado y listo."

# Desplegar microservicios
log_info "Desplegando microservicios de producto..."
apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_CREATE_DIR}/k8s/${IMAGE_NAME_CREATE}-deployment.yaml"
apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_CREATE_DIR}/k8s/${IMAGE_NAME_CREATE}-service.yaml"

apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_READ_DIR}/k8s/${IMAGE_NAME_READ}-deployment.yaml"
apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_READ_DIR}/k8s/${IMAGE_NAME_READ}-service.yaml"

apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_UPDATE_DIR}/k8s/${IMAGE_NAME_UPDATE}-deployment.yaml"
apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_UPDATE_DIR}/k8s/${IMAGE_NAME_UPDATE}-service.yaml"

apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_DELETE_DIR}/k8s/${IMAGE_NAME_DELETE}-deployment.yaml"
apply_k8s_yaml "${BASE_PROJECT_DIR}/${MICROSERVICE_DELETE_DIR}/k8s/${IMAGE_NAME_DELETE}-service.yaml"

# Esperar a que todos los deployments de microservicios estén listos
log_info "Esperando a que los deployments de microservicios estén listos..."
kubectl wait --for=condition=available "deployment/${IMAGE_NAME_CREATE}-deployment" -n "${K8S_NAMESPACE}" --timeout=180s
check_command_success
kubectl wait --for=condition=available "deployment/${IMAGE_NAME_READ}-deployment" -n "${K8S_NAMESPACE}" --timeout=180s
check_command_success
kubectl wait --for=condition=available "deployment/${IMAGE_NAME_UPDATE}-deployment" -n "${K8S_NAMESPACE}" --timeout=180s
check_command_success
kubectl wait --for=condition=available "deployment/${IMAGE_NAME_DELETE}-deployment" -n "${K8S_NAMESPACE}" --timeout=180s
check_command_success
log_info "Todos los microservicios desplegados y listos."

# Desplegar Ingress
log_info "Desplegando Ingress..."
apply_k8s_yaml "${K8S_GLOBAL_DIR}/06-app-ingress.yaml"
log_info "--- Fase 2 Completada: Todos los recursos de Kubernetes desplegados ---"


# --- Fase 3: Verificación de Endpoints con curl ---
log_info "--- Iniciando Fase 3: Verificación de Endpoints ---"
MINIKUBE_IP=$(minikube ip -p "${MINIKUBE_PROFILE}")
if [ -z "$MINIKUBE_IP" ]; then
  log_error "No se pudo obtener la IP de Minikube. Abortando verificación."
  exit 1
fi
log_info "Minikube IP: ${MINIKUBE_IP}. Los endpoints estarán disponibles en http://${MINIKUBE_IP}/<context-path>/productos"

log_info "Esperando 20 segundos para que el Ingress se estabilice y los servicios estén completamente accesibles..."
sleep 20

# Prueba de Create
CREATE_URL="http://${MINIKUBE_IP}${CONTEXT_PATH_CREATE}/productos"
PRODUCT_JSON_PAYLOAD='{"nombre":"Producto Script Automatizado","precio":199.99}'
log_info "Probando POST a ${CREATE_URL} con payload: ${PRODUCT_JSON_PAYLOAD}"
HTTP_RESPONSE_CREATE=$(curl -s -o /tmp/create_api_response.json -w "%{http_code}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$PRODUCT_JSON_PAYLOAD" \
  "$CREATE_URL")

NEW_PRODUCT_ID=""
if [ "$HTTP_RESPONSE_CREATE" -eq 201 ]; then
    log_info "CREATE exitoso (HTTP ${HTTP_RESPONSE_CREATE}). Respuesta en /tmp/create_api_response.json"
    # Asegúrate de tener 'jq' instalado: sudo pacman -S jq
    if command -v jq &> /dev/null; then
        NEW_PRODUCT_ID=$(jq -r '.id' /tmp/create_api_response.json)
        if [ -z "$NEW_PRODUCT_ID" ] || [ "$NEW_PRODUCT_ID" == "null" ]; then
            log_warning "No se pudo obtener el ID del producto creado desde la respuesta JSON."
        else
            log_info "Producto creado con ID: ${NEW_PRODUCT_ID}"
        fi
    else
        log_warning "'jq' no está instalado. No se puede extraer el ID del producto creado para pruebas posteriores."
    fi
else
    log_error "Fallo en CREATE (HTTP ${HTTP_RESPONSE_CREATE}). Respuesta en /tmp/create_api_response.json"
    log_error "Contenido de la respuesta de error:"
    cat /tmp/create_api_response.json
    echo "" # Nueva línea
fi

# Prueba de Read One (si se creó un producto)
if [ -n "$NEW_PRODUCT_ID" ] && [ "$NEW_PRODUCT_ID" != "null" ]; then
    READ_ONE_URL="http://${MINIKUBE_IP}${CONTEXT_PATH_READ}/productos/${NEW_PRODUCT_ID}"
    log_info "Probando GET a ${READ_ONE_URL}"
    HTTP_RESPONSE_READ_ONE=$(curl -s -o /dev/null -w "%{http_code}" "$READ_ONE_URL")
    if [ "$HTTP_RESPONSE_READ_ONE" -eq 200 ]; then
        log_info "READ ONE exitoso (HTTP ${HTTP_RESPONSE_READ_ONE}) para ID ${NEW_PRODUCT_ID}."
    else
        log_error "Fallo en READ ONE para ID ${NEW_PRODUCT_ID} (HTTP ${HTTP_RESPONSE_READ_ONE})."
    fi
else
    log_warning "Saltando prueba READ ONE porque no se pudo obtener un ID de producto válido."
fi

# Prueba de Read All
READ_ALL_URL="http://${MINIKUBE_IP}${CONTEXT_PATH_READ}/productos"
log_info "Probando GET a ${READ_ALL_URL}"
HTTP_RESPONSE_READ_ALL=$(curl -s -o /dev/null -w "%{http_code}" "$READ_ALL_URL")
if [ "$HTTP_RESPONSE_READ_ALL" -eq 200 ]; then
    log_info "READ ALL exitoso (HTTP ${HTTP_RESPONSE_READ_ALL})."
else
    log_warning "Fallo o respuesta inesperada en READ ALL (HTTP ${HTTP_RESPONSE_READ_ALL}). Esto puede ser normal si la lista está vacía y devuelve 204, o si hay un error."
fi
log_info "--- Fase 3 Completada ---"

log_info ">>> Script de despliegue y verificación completado <<<"
log_info "Puedes acceder a tus servicios a través de http://${MINIKUBE_IP}/<context-path>/productos"
log_info "Ejemplo: http://${MINIKUBE_IP}${CONTEXT_PATH_CREATE}/productos (POST), http://${MINIKUBE_IP}${CONTEXT_PATH_READ}/productos (GET)"

exit 0