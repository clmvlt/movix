import os
import subprocess
import requests
import sys
from datetime import datetime

# Configuration des environnements
ENVIRONMENTS = {
    "1": {
        "name": "beta",
        "url": "https://api.beta.movix.fr/",
        "requires_confirmation": False
    },
    "2": {
        "name": "demo",
        "url": "https://api.demo.movix.fr/",
        "requires_confirmation": True
    },
    "3": {
        "name": "prod",
        "url": "https://api.movix.fr/",
        "requires_confirmation": True
    }
}

# Variable globale pour l'environnement sélectionné
selected_env = None

def select_environment():
    """Affiche le menu de sélection d'environnement et retourne la configuration"""
    global selected_env

    print("\n" + "=" * 50)
    print("SELECTION DE L'ENVIRONNEMENT DE DEPLOIEMENT")
    print("=" * 50)
    print("\n1: beta   (api.beta.movix.fr)")
    print("2: demo   (api.demo.movix.fr)")
    print("3: prod   (api.movix.fr)")
    print("4: all    (beta + demo + prod)")
    print()

    while True:
        choice = input("Choisissez l'environnement (1/2/3/4): ").strip()

        # Option "all" - déployer sur les 3 environnements
        if choice == "4":
            print("\n ATTENTION: Vous allez deployer sur TOUS les environnements (beta, demo, prod)")
            confirm = input("Etes-vous sur de vouloir deployer sur TOUS les environnements? (oui/non): ").strip().lower()

            if confirm not in ["oui", "o", "yes", "y"]:
                print("Deploiement annule.")
                sys.exit(0)

            all_envs = [ENVIRONMENTS["1"], ENVIRONMENTS["2"], ENVIRONMENTS["3"]]
            print("\nEnvironnements selectionnes: beta, demo, prod")
            return all_envs

        if choice not in ENVIRONMENTS:
            print("Choix invalide. Veuillez entrer 1, 2, 3 ou 4.")
            continue

        env = ENVIRONMENTS[choice]

        # Demander confirmation pour demo et prod
        if env["requires_confirmation"]:
            print(f"\n ATTENTION: Vous allez deployer sur {env['name'].upper()}")
            confirm = input(f"Etes-vous sur de vouloir deployer sur {env['name']}? (oui/non): ").strip().lower()

            if confirm not in ["oui", "o", "yes", "y"]:
                print("Deploiement annule.")
                sys.exit(0)

        selected_env = env
        print(f"\nEnvironnement selectionne: {env['name']}")
        print(f"   URL: {env['url']}")
        return env


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
    global selected_env
    api_url = selected_env["url"]
    url = f"{api_url}updates/{version}"
    
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

def upload_to_env(env, version, apk_path):
    """Upload l'APK vers un environnement spécifique"""
    api_url = env["url"]
    url = f"{api_url}updates/{version}"

    print(f"\nTelechargement vers {env['name'].upper()} ({env['url']})...")

    try:
        with open(apk_path, 'rb') as apk_file:
            apk_bytes = apk_file.read()
            headers = {
                'Authorization': '123456789clement',
                'Content-Type': 'application/octet-stream'
            }
            response = requests.post(url, data=apk_bytes, headers=headers)

            if response.status_code == 201:
                print(f"  APK telecharge avec succes sur {env['name']}!")
                return True
            else:
                print(f"  Erreur lors du telechargement sur {env['name']}: {response.status_code}")
                print(f"  Message: {response.text}")
                return False
    except Exception as e:
        print(f"  Erreur lors de l'envoi de l'APK sur {env['name']}: {e}")
        return False


def main():
    if len(sys.argv) != 2:
        print("Usage: python upload.py <version>")
        print("Example: python upload.py 1.0.0")
        sys.exit(1)

    version = sys.argv[1]

    print("=" * 50)
    print("DEPLOIEMENT APK MOVIX")
    print("=" * 50)

    # Sélection de l'environnement
    env_selection = select_environment()

    print("\nDebut de la construction de l'APK...")
    if not build_apk():
        sys.exit(1)

    print("APK construit avec succes!")

    try:
        apk_path = get_apk_path()
        print(f"APK trouve a: {apk_path}")

        # Déploiement sur un ou plusieurs environnements
        if isinstance(env_selection, list):
            # Déploiement sur tous les environnements
            failed_envs = []
            success_envs = []

            for env in env_selection:
                if upload_to_env(env, version, apk_path):
                    success_envs.append(env['name'])
                else:
                    failed_envs.append(env['name'])

            # Résumé
            print("\n" + "=" * 50)
            print("RESUME DU DEPLOIEMENT")
            print("=" * 50)

            if success_envs:
                print(f"Deploiements reussis: {', '.join(success_envs)}")
            if failed_envs:
                print(f"Deploiements echoues: {', '.join(failed_envs)}")
                sys.exit(1)
        else:
            # Déploiement sur un seul environnement
            global selected_env
            selected_env = env_selection

            print(f"\nDebut du telechargement de l'APK vers {selected_env['name'].upper()}...")
            if not upload_apk(version, apk_path):
                sys.exit(1)

            print(f"\nDeploiement sur {selected_env['name'].upper()} termine avec succes!")

    except FileNotFoundError as e:
        print(e)
        sys.exit(1)

if __name__ == "__main__":
    main() 