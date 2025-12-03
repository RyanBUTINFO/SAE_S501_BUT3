import pandas as pd
import requests
from bs4 import BeautifulSoup
import os
from urllib.parse import urlparse

# === CONFIGURATION CLÉ ===
# FICHIER D'ENTRÉE : Fichier contenant la colonne 'image_path' (l'URL de la page web).
INPUT_CSV = "plats.csv" 
# NOM DU DOSSIER où les images seront stockées.
IMAGES_FOLDER = "images_plats" 
# SÉPARATEUR Du CSV
CSV_SEPARATOR = ',' 
# === FIN CONFIGURATION ===

# Crée le dossier pour stocker les images s'il n'existe pas.
os.makedirs(IMAGES_FOLDER, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/50 (Windows NT 10.0; Win64; x64) "
                  "AppleWebKit/537.36 (KHTML, like Gecko) "
                  "Chrome/120.0.0.0 Safari/537.36"
}

# Fonction pour déterminer l'extension du fichier (évite les erreurs si l'URL est propre)
def get_file_extension(url):
    """Extrait l'extension du fichier à partir de l'URL."""
    path = urlparse(url).path
    # Sépare le chemin en nom de base et extension
    ext = os.path.splitext(path)[1]
    # S'il y a une extension (e.g., .jpg), la retourne. Sinon, retourne '.jpg' par défaut.
    return ext if ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp'] else '.jpg'

# === Télécharger une image à partir d'une URL ===
def download_image(image_url, filename):
    """Télécharge une image à partir de l'URL fournie et la sauvegarde."""
    try:
        response = requests.get(image_url, headers=HEADERS, timeout=10)
        # Lève une exception pour les codes de statut 4xx ou 5xx
        response.raise_for_status() 

        filepath = os.path.join(IMAGES_FOLDER, filename)
        with open(filepath, "wb") as f:
            f.write(response.content)
        return True
    
    except requests.exceptions.RequestException as e:
        print(f" Erreur de requête/téléchargement pour {image_url}: {e}")
        return False
    except Exception as e:
        print(f" Erreur inconnue lors du téléchargement: {e}")
        return False

# === Extraire l'image principale via og:image ===
def extract_image_from_page(page_url):
    """Accède à l'URL de la page et cherche l'image principale via la balise og:image."""
    try:
        r = requests.get(page_url, headers=HEADERS, timeout=10)
        r.raise_for_status() # S'assurer que le contenu est accessible
        
        soup = BeautifulSoup(r.text, "html.parser")
        meta_img = soup.find("meta", property="og:image")
        
        if meta_img and "content" in meta_img.attrs:
            return meta_img["content"]
        
        # Fallback pour d'autres balises d'image
        meta_img_fallback = soup.find("meta", itemprop="image")
        if meta_img_fallback and "content" in meta_img_fallback.attrs:
             return meta_img_fallback["content"]

        return ""
    except requests.exceptions.RequestException as e:
        # Erreur si la page n'est pas trouvée (404) ou autre problème HTTP
        print(f" Erreur lors de l'accès à la page {page_url}: {e}")
        return ""
    except Exception as e:
        print(f" Impossible d'extraire l'image depuis {page_url}: {e}")
        return ""

# === Exécution Principale ===
def run_image_downloader():
    try:
        df = pd.read_csv(INPUT_CSV, sep=CSV_SEPARATOR, encoding="utf-8")
        
        print(f"Démarrage du téléchargement pour {len(df)} plats.")

        for idx, row in df.iterrows():
            page_url = row.get("image_path", "")
            # Utilisation de l'ID du plat comme nom de base du fichier
            plat_id = row.get("id") 
            plat_nom = row.get("nom", "Plat inconnu")
            
            # Vérification et sécurité de l'ID
            if plat_id is None:
                 print(f"AVERTISSEMENT: Ligne {idx+1} sans 'id'. Ignorée.")
                 continue

            if isinstance(page_url, str) and page_url.startswith("http"):
                print(f"\n➡ Traitement du plat {plat_id} : {plat_nom}")
                
                # Étape 1: Extraire l'URL de l'image réelle
                img_url = extract_image_from_page(page_url)
                
                if img_url:
                    # Étape 2: Déterminer l'extension
                    ext = get_file_extension(img_url)
                    
                    # Étape 3: Créer le nom de fichier basé uniquement sur l'ID
                    filename = f"{plat_id}{ext}" 
                    
                    # Étape 4: Télécharger et sauvegarder l'image
                    if download_image(img_url, filename):
                        print(f"✔ Image téléchargée et nommée : {filename}")
                    else:
                        print(f" Échec du téléchargement de l'image pour l'ID {plat_id}.")
                else:
                    print(f" Aucune image 'og:image' trouvée sur la page pour l'ID {plat_id}.")
            else:
                print(f" URL invalide pour le plat {plat_id} ('{page_url}').")
        
        print("\n🎉 Tous les téléchargements terminés !")
        print(f"📁 Images stockées dans : {IMAGES_FOLDER}")

    except FileNotFoundError:
        print(f"ERREUR : Le fichier {INPUT_CSV} n'a pas été trouvé. Veuillez vérifier le chemin.")
    except Exception as e:
        print(f"Une erreur générale est survenue : {e}")

if __name__ == "__main__":
    run_image_downloader()