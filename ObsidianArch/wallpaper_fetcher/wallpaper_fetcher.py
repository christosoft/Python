import subprocess
import sys
import importlib.util
import os, time, random, argparse
from datetime import date

# 📦 Verificar e instalar dependencias
def ensure_package(pkg_name):
    if importlib.util.find_spec(pkg_name) is None:
        print(f"📦 Instalando {pkg_name}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", pkg_name])
        print(f"✅ {pkg_name} instalado.")

ensure_package("selenium")
ensure_package("requests")

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import requests

# 🎛️ Argumentos CLI
parser = argparse.ArgumentParser(description="Descarga y aplica wallpapers.")
parser.add_argument("--source", choices=["wallhaven"], default="wallhaven", help="Fuente de imágenes")
parser.add_argument("--apply", action="store_true", help="Aplicar fondo con swww")
parser.add_argument("--clean", action="store_true", help="Eliminar wallpapers antiguos")
args = parser.parse_args()

# 📁 Carpeta destino
wall_dir = os.path.expanduser("~/.local/share/wallpapers")
os.makedirs(wall_dir, exist_ok=True)
today = date.today().isoformat()
wall_path = os.path.join(wall_dir, f"{today}.jpg")

# 🌐 Fuente: Wallhaven favoritos seguros
if args.source == "wallhaven":
    gallery_url = "https://wallhaven.cc/search?categories=110&purity=100&sorting=favorites&order=desc&page=1"

    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")

    driver = webdriver.Chrome(options=options)
    driver.get(gallery_url)
    time.sleep(5)

    thumbs = driver.find_elements(By.CSS_SELECTOR, "figure.thumb > a.preview")
    image_pages = [thumb.get_attribute("href") for thumb in thumbs]

    if not image_pages:
        print("❌ No se encontraron imágenes.")
        driver.quit()
        sys.exit(1)

    selected_page = random.choice(image_pages)
    driver.get(selected_page)
    time.sleep(5)

    try:
        img_element = driver.find_element(By.CSS_SELECTOR, "img#wallpaper")
        img_url = img_element.get_attribute("src")
    except Exception as e:
        print(f"❌ No se encontró imagen expandida: {e}")
        driver.quit()
        sys.exit(1)

    driver.quit()

    try:
        r = requests.get(img_url)
        with open(wall_path, "wb") as f:
            f.write(r.content)
        print(f"✅ Imagen descargada en: {wall_path}")
    except Exception as e:
        print(f"❌ Error al descargar la imagen: {e}")
        sys.exit(1)

# 🧹 Limpieza de wallpapers antiguos
if args.clean:
    for file in os.listdir(wall_dir):
        if file.endswith((".jpg", ".png")) and not file.startswith(today):
            os.remove(os.path.join(wall_dir, file))
    print("🧹 Wallpapers antiguos eliminados.")

# 🖼️ Aplicar fondo con swww
if args.apply:
    try:
        subprocess.run(["swww", "img", wall_path], check=True)
        print("🖼️ Fondo aplicado con swww.")
    except Exception:
        print("⚠️ No se pudo aplicar el fondo. ¿swww está corriendo?")
