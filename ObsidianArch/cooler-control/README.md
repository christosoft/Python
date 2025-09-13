📄 README.md

# 🧊 Cooler Control para Linux

Control inteligente y modular de bomba y ventiladores para sistemas con refrigeración líquida, usando `liquidctl`, `lm-sensors` y `nvidia-smi`. Este script ajusta dinámicamente la velocidad de la bomba y el color del cooler según la temperatura más alta del sistema, con soporte para perfiles de rendimiento que puedes cambiar sin reiniciar el servicio.

---

## 📦 Instalación

### 1. Clona el repositorio

```bash
sudo git clone https://github.com/tuusuario/control-cooler.git /opt/control-cooler

2. Instala dependencias

sudo apt install lm-sensors liquidctl bc
sudo sensors-detect

Para GPU NVIDIA:

sudo apt install nvidia-smi

3. Da permisos de ejecución

sudo chmod +x /opt/control-cooler/*.sh

⚙️ Configurar como servicio systemd

1. Crea el archivo del servicio

sudo nano /etc/systemd/system/cooler-control.service

2. Pega esto:

[Unit]
Description=Control de ventiladores y bomba con perfiles personalizados
After=network.target

[Service]
Type=simple
ExecStart=/opt/control-cooler/cooler.sh
Restart=always
RestartSec=5
StandardOutput=append:/opt/control-cooler/cooler-control.log
StandardError=append:/opt/control-cooler/cooler-control.log

[Install]
WantedBy=multi-user.target

3. Activa el servicio

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable cooler-control.service
sudo systemctl start cooler-control.service

🎛️ Cambiar perfil de rendimiento

Edita el archivo:

sudo nano /opt/control-cooler/cooler-profile.conf

Ejemplo:

PERFIL="gaming"

El script detecta el cambio automáticamente en menos de 10 segundos.

🧪 Perfiles disponibles

🎮 gaming

Velocidades: 70% / 85% / 100%

Color base: Magenta (ff00ff)

Uso recomendado: Juegos, benchmarks, carga máxima

PERFIL="gaming"

🤫 silent

Velocidades: 20% / 35% / 50%

Color base: Cyan (00ffff)

Uso recomendado: Navegación web, multimedia, tareas livianas

PERFIL="silent"

🧩 basic

Velocidades: 35% / 50% / 65%

Color base: Beige (ffffcc)

Uso recomendado: Trabajo de oficina, desarrollo, multitarea moderada

PERFIL="basic"

⚙️ auto (por defecto)

Velocidades: 40% / 55% / 75% / 100%

Color base: Dinámico según temperatura

Uso recomendado: Control automático según sensores

PERFIL="auto"

📋 Logs

Los eventos se registran en:

/opt/control-cooler/cooler-control.log

Para monitorear en tiempo real:

tail -f /opt/control-cooler/cooler-control.log

🛠️ Personalización

Puedes modificar los colores, temperaturas límite y velocidades en los archivos:

config.sh → Temperaturas base

profiles.sh → Perfiles personalizados

control.sh → Colores por temperatura

🧠 Requisitos

Linux con systemd

Cooler compatible con liquidctl

Sensores detectables por lm-sensors

(Opcional) GPU NVIDIA con nvidia-smi

📬 Contribuciones

Pull requests y sugerencias son bienvenidas. Este proyecto busca modularidad, claridad y control total del hardware desde el entorno Linux.

🧑‍💻 Autor

Christosoft Especialista en automatización Linux, scripting modular y entornos reproducibles.

