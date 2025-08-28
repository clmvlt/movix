import os
import subprocess
import requests
import sys
from datetime import datetime

apiUrl = "http://192.168.1.155:8081/"
apiUrl = "https://api.movix.fr/"

def get_flutter_path():
    """Trouve le chemin vers l'exécutable Flutter"""
    # Chemins possibles pour Flutter sur Windows
    possible_paths = [
        os.path.expanduser("~/flutter/bin/flutter.bat"),
        "C:/flutter/bin/flutter.bat",
        "D:/flutter/bin/flutter.bat",
        os.path.join(os.environ.get('LOCALAPPDATA', ''), 'flutter/bin/flutter.bat')
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
            
    raise FileNotFoundError("Flutter n'a pas été trouvé. Veuillez vérifier que Flutter est installé et ajouté au PATH.")

def build_apk():
    """Construit l'APK en utilisant la commande flutter build apk"""
    try:
        flutter_path = get_flutter_path()
        print(f"Utilisation de Flutter depuis: {flutter_path}")
        subprocess.run([flutter_path, 'build', 'apk', '--release'], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Erreur lors de la construction de l'APK: {e}")
        return False
    except FileNotFoundError as e:
        print(f"Erreur: {e}")
        return False

def get_apk_path():
    """Retourne le chemin de l'APK généré"""
    # Le chemin par défaut de l'APK généré par Flutter
    apk_path = os.path.join('build', 'app', 'outputs', 'flutter-apk', 'app-release.apk')
    if not os.path.exists(apk_path):
        raise FileNotFoundError(f"APK non trouvé à l'emplacement: {apk_path}")
    return apk_path

def upload_apk(version, apk_path):
    """Envoie l'APK à l'API"""
    url = f"{apiUrl}updates/{version}"
    
    try:
        with open(apk_path, 'rb') as apk_file:
            apk_bytes = apk_file.read()
            headers = {
                'Authorization': '123456789clement',
                'Content-Type': 'application/octet-stream'
            }
            response = requests.post(url, data=apk_bytes, headers=headers)
            
            if response.status_code == 201:
                print("APK téléchargé avec succès!")
                print(f"Réponse: {response.json()}")
                return True
            else:
                print(f"Erreur lors du téléchargement: {response.status_code}")
                print(f"Message: {response.text}")
                return False
    except Exception as e:
        print(f"Erreur lors de l'envoi de l'APK: {e}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python build_and_upload_apk.py <version>")
        print("Example: python build_and_upload_apk.py 1.0.0")
        sys.exit(1)

    version = sys.argv[1]
    
    print("Début de la construction de l'APK...")
    if not build_apk():
        sys.exit(1)
    
    print("APK construit avec succès!")
    
    try:
        apk_path = get_apk_path()
        print(f"APK trouvé à: {apk_path}")
        
        print("Début du téléchargement de l'APK...")
        if not upload_apk(version, apk_path):
            sys.exit(1)
            
    except FileNotFoundError as e:
        print(e)
        sys.exit(1)

if __name__ == "__main__":
    main() 