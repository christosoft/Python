from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import requests, os, random, time
from datetime import date

# 📁 Carpeta destino
wall_dir = os.path.expanduser("~/.local/share/wallpapers")
os.makedirs(wall_dir, exist_ok=True)
wall_path = os.path.join(wall_dir, f"{date.today()}.jpg")

# ⚙️ Configuración de Chromium headless
options = Options()
options.add_argument("--headless")
options.add_argument("--disable-gpu")
options.add_argument("--window-size=1920,1080")

# 🚀 Iniciar navegador
driver = webdriver.Chrome(options=options)
driver.get("https://www.freepik.es/fotos-vectores-gratis/wallpaper")
time.sleep(5)

# 🔄 Scroll para cargar más imágenes
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
time.sleep(3)

# 🖼️ Extraer imágenes con src o data-src
images = driver.find_elements(By.CSS_SELECTOR, "img")
img_urls = []

for img in images:
    src = img.get_attribute("src") or img.get_attribute("data-src")
    if src and (".jpg" in src or ".png" in src):
        img_urls.append(src)

driver.quit()

# 🎯 Seleccionar una imagen aleatoria
if img_urls:
    selected = random.choice(img_urls)
    r = requests.get(selected)
    with open(wall_path, "wb") as f:
        f.write(r.content)
    print(f"✅ Fondo guardado en: {wall_path}")
else:
    print("❌ No se encontraron imágenes válidas.")
