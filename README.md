# k8s-test: Microservicios CRUD Spring Boot en Kubernetes

## Descripción General
Este proyecto sirve como un "testbed" (banco de pruebas) para el desarrollo, prueba y despliegue de cuatro microservicios CRUD independientes construidos con Spring Boot. La arquitectura se orquesta en Kubernetes (utilizando Minikube para el entorno local) e integra MariaDB como base de datos persistente.

La solución completa abarca:
- Contenerización con Docker
- Pruebas unitarias y de integración exhaustivas (con reportes de cobertura JaCoCo)
- Documentación y pruebas de API con Postman
- Scripts de automatización para CI/CD

## Tabla de Contenidos
1. [Objetivo del Proyecto](#1-objetivo-del-proyecto)
2. [Arquitectura de la Solución](#2-arquitectura-de-la-solución)
3. [Tecnologías Utilizadas](#3-tecnologías-utilizadas)
4. [Estructura del Repositorio](#4-estructura-del-repositorio)
5. [Prerrequisitos](#5-prerrequisitos)
6. [Configuración del Entorno](#6-configuración-del-entorno-de-desarrollo-local-opcional)
7. [Construcción y Contenerización](#7-construcción-y-contenerización-docker)
8. [Despliegue en Kubernetes](#8-despliegue-en-kubernetes-minikube)
9. [Pruebas](#9-pruebas)
10. [Base de Datos MariaDB](#10-base-de-datos-mariadb)
11. [Automatización](#11-automatización)
12. [Entregables](#12-entregables-del-proyecto)
13. [Autor(es)](#13-autores)
14. [Licencia](#14-licencia-opcional)

## 1. Objetivo del Proyecto
Desarrollar cuatro microservicios independientes en Spring Boot, cada uno implementando un endpoint específico del CRUD (Crear, Leer, Actualizar, Eliminar) sobre la entidad Producto, garantizando su correcto funcionamiento mediante pruebas unitarias e integración. Además, desplegar estos microservicios utilizando Kubernetes con MariaDB como base de datos.

## 2. Arquitectura de la Solución
![Diagrama de Infraestructura](diagrams/infraestructura.png)

Componentes principales:
- 4 Microservicios Spring Boot (create/read/update/delete)
- MariaDB con persistencia de datos
- Docker para contenerización
- Kubernetes (Minikube) para orquestación
- Ingress para exposición de servicios

## 3. Tecnologías Utilizadas
| Categoría       | Tecnologías                                                                 |
|-----------------|-----------------------------------------------------------------------------|
| Backend         | Java 17, Spring Boot 3.x, Spring Web, Spring Data JPA, Maven               |
| Base de Datos   | MariaDB 10.9                                                                |
| Contenerización | Docker                                                                      |
| Orquestación    | Kubernetes (Minikube)                                                       |
| Pruebas         | JUnit 5, Mockito, Spring Boot Test, JaCoCo, Postman                        |
| Otros           | Git, GitHub/GitLab, PlantUML, Bash                                          |

## 4. Estructura del Repositorio
