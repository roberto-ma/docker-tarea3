from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import socket
import os

app = FastAPI()

# Configurar directorios de plantillas y estáticos
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
def read_root(request: Request):
    hostname = socket.gethostname()
    client_ip = request.client.host
    return templates.TemplateResponse("index.html", {
        "request": request,
        "hostname": hostname,
        "client_ip": client_ip,
        "app_name": "FastAPI Sample App"
    })
