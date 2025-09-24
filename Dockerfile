# Imagen base ligera
FROM python:3.11-slim

# Crear usuario no root
RUN useradd -m fastapiuser

# Directorio de trabajo
WORKDIR /app

# Copiar dependencias primero (mejor cacheo)
COPY requirements.txt .

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar aplicación
COPY . .

# Ajustar permisos
RUN chown -R fastapiuser:fastapiuser /app

# Cambiar a usuario no root
USER fastapiuser

# Exponer el puerto
EXPOSE 8000

# Comando de ejecución
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
