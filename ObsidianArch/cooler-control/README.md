Intelligent Cooler Control on Linux

This project allows you to manage the operating profile of a cooling system (cooler) on Linux either automatically or using predefined profiles. It includes scripts to apply profiles, log activity, and configure the system as a service.

🚀 Quick Setup

To ensure the system always starts with the auto profile, create the configuration file at the following path:

/opt/control-cooler/cooler-profile.conf

With the following content:

PERFIL="auto"

This file will be read by the cooler.sh script in each cycle. If the profile hasn't been changed, it will remain in auto.

📂 Project Structure

/opt/control-cooler/cooler.sh: Main script that manages the cooler profile. Reads the cooler-profile.conf configuration file and applies the corresponding profile.

/opt/control-cooler/cooler-profile.conf: Configuration file with the default profile (auto, gaming, silent, or basic).

/opt/control-cooler/cooler-profile: Auxiliary script to set the profile from the command line. Can be invoked with one of the valid profile names as an argument.

🧩 Script Descriptions

cooler.sh: Executes the cooler control cycle. Reads the current profile from cooler-profile.conf and applies the corresponding logic.

cooler-profile: Allows changing the profile from the terminal. Invoked with a valid profile name as an argument. Can also log activity if a log line is added.

cooler-profile.conf: Defines the active profile. Read by cooler.sh to determine the operating mode.

🎛️ Profile Types

auto: Automatically adjusts cooler behavior based on system conditions like temperature and load.

gaming: Maximizes cooling performance for gaming or high-load scenarios.

silent: Minimizes fan noise by reducing speed when possible.

basic: Applies a standard cooling behavior suitable for general use.

🧪 How to Apply Profiles

From the terminal, you can run:

/opt/control-cooler/cooler-profile auto

Or:

/opt/control-cooler/cooler-profile gaming

Or:

/opt/control-cooler/cooler-profile silent

Or:

/opt/control-cooler/cooler-profile basic

This will update the cooler-profile.conf file and the system will apply the new profile in the next cycle.

📋 Activity Logging

If you want to log the date and time each time a profile is applied, add this line at the end of the cooler-profile script:

echo "[$(date)] Auto profile applied" >> /var/log/cooler-profile.log

📦 Optional Installation as systemd Service

If you prefer the profile to be applied automatically when the system starts, you can create a systemd service:

Create the service file:

sudo nano /etc/systemd/system/cooler-profile.service

Paste the following content:

[Unit]
Description=Set auto profile for cooler
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/control-cooler/cooler-profile auto
RemainAfterExit=true
StandardOutput=append:/var/log/cooler-profile.log
StandardError=append:/var/log/cooler-profile.log

[Install]
WantedBy=multi-user.target

Enable the service:

sudo systemctl daemon-reexec
sudo systemctl enable cooler-profile.service

With this, the auto profile will be applied automatically every time the computer is turned on or restarted.

🛠️ Requirements

Linux with systemd

Administrator permissions to create files in /opt and configure services

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

📄 License

This project is distributed under the MIT license.

