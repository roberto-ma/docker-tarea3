# CI/CD Pipeline con Docker y GitHub Actions

Este proyecto implementa un pipeline de integración y despliegue continuo (CI/CD) para aplicaciones FastAPI utilizando GitHub Actions, Docker Hub y Docker Scout para análisis de seguridad.

## 🚀 Características

- **Construcción automática** de imágenes Docker en cada push a master
- **Análisis de vulnerabilidades** con Docker Scout
- **Despliegue automático** a Docker Hub
- **Reportes de seguridad** como artefactos de GitHub Actions

## 📋 Prerequisitos

- Cuenta en [Docker Hub](https://hub.docker.com/)
- Repositorio en GitHub
- Aplicación FastAPI con Dockerfile configurado

## ⚙️ Configuración

### 1. Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** → **Secrets and variables** → **Actions**
3. Agrega los siguientes secrets:

```
DOCKERHUB_USERNAME: tu_usuario_dockerhub
DOCKERHUB_TOKEN: tu_token_dockerhub
```

> **Nota:** Para obtener el token de Docker Hub, ve a Account Settings → Security → New Access Token

### 2. Crear GitHub Action

1. En tu repositorio, ve a **Actions**
2. Haz clic en **New workflow**
3. Selecciona **Set up a workflow yourself**
4. Reemplaza el contenido con el workflow proporcionado abajo

## 🔧 Workflow de GitHub Actions

Crea el archivo `.github/workflows/docker-build-scan.yml`:

```yaml
name: Build and Analyze Docker Image

on:
  push:
    branches: [ "master" ]

env:
  IMAGE_NAME: rcmaldonadop/scout
  SHA: ${{ github.sha }}

jobs:
  build-and-analyze:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        with:
          install: true
          driver: docker

      - name: Build image and load to runner
        id: build
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./Dockerfile
          push: true
          load: true
          tags: ${{ env.IMAGE_NAME }}:sha-${{ env.SHA }}

      - name: Install Docker Scout
        run: |
          mkdir -p ~/.docker/cli-plugins
          curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh
          sudo cp ~/.docker/cli-plugins/docker-scout /usr/local/bin/
          docker-scout version

      - name: Scan image with Docker Scout
        run: |
          echo "🔍 Ejecutando análisis de vulnerabilidades con Docker Scout..."
          docker scout cves ${{ env.IMAGE_NAME }}:sha-${{ github.sha }} --output json 2>&1 | tee scout-report.json
          echo "==== Resumen de vulnerabilidades detectadas ===="
          cat scout-report.json

      - name: Upload Scout JSON report
        uses: actions/upload-artifact@v4
        with:
          name: docker-scout-report
          path: scout-report.json
```

## 📊 Visualización de Resultados

### Reportes de Vulnerabilidades

Después de cada ejecución del workflow:

1. Ve a la pestaña **Actions** de tu repositorio
2. Haz clic en la ejecución más reciente
3. En la sección **Artifacts**, encontrarás el reporte `docker-scout-report`
4. Descarga el archivo JSON para ver el análisis detallado de vulnerabilidades

### Imágenes en Docker Hub

Las imágenes construidas se subirán automáticamente a Docker Hub con el tag:
```
rcmaldonadop/scout:sha-<commit-hash>
```

## 🔍 Qué hace cada paso

1. **Checkout repository**: Descarga el código fuente
2. **Log in to Docker Hub**: Se autentica con Docker Hub usando los secrets
3. **Set up Docker Buildx**: Configura el constructor de Docker
4. **Build image**: Construye y sube la imagen Docker
5. **Install Docker Scout**: Instala la herramienta de análisis de seguridad
6. **Scan image**: Ejecuta el análisis de vulnerabilidades
7. **Upload report**: Sube el reporte como artefacto

## 🛠️ Personalización

Para adaptar este workflow a tu proyecto:

1. Cambia `IMAGE_NAME` por tu repositorio de Docker Hub
2. Modifica la rama de trigger si no usas `master`
3. Ajusta la ruta del Dockerfile si está en otra ubicación
4. Personaliza los tags de la imagen según tus necesidades

## 🔒 Seguridad

- Los secrets nunca se exponen en los logs
- Docker Scout analiza automáticamente las vulnerabilidades
- Los reportes quedan disponibles para auditoría

## 📝 Estructura del Proyecto

```
tu-proyecto/
├── .github/
│   └── workflows/
│       └── docker-build-scan.yml
├── Dockerfile
├── requirements.txt
├── main.py (tu aplicación FastAPI)
└── README.md
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.
