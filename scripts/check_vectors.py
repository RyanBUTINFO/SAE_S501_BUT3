import sqlite3
import os

db_path = "../assets/database/base_miaam.db"

if not os.path.exists(db_path):
    print(f"❌ Base de données introuvable : {db_path}")
    exit()

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# 1. Vérifier que la table existe
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='plat_vectors'")
if not cursor.fetchone():
    print("❌ La table 'plat_vectors' n'existe pas !")
    print("→ Tu dois lancer le script generate_vectors.py d'abord")
    exit()

# 2. Compter le nombre de plats
cursor.execute("SELECT COUNT(*) FROM plats")
nb_plats = cursor.fetchone()[0]
print(f"📊 Nombre total de plats : {nb_plats}")

# 3. Compter le nombre de vecteurs
cursor.execute("SELECT COUNT(*) FROM plat_vectors")
nb_vectors = cursor.fetchone()[0]
print(f"🧬 Nombre de vecteurs générés : {nb_vectors}")

if nb_vectors < nb_plats:
    print(f"⚠️ PROBLÈME : Il manque {nb_plats - nb_vectors} vecteurs !")

# 4. Vérifier un vecteur spécifique (Poulet frit)
cursor.execute("SELECT plat_id FROM plats WHERE nom LIKE '%Poulet frit%'")
poulet_id = cursor.fetchone()

if poulet_id:
    poulet_id = poulet_id[0]
    print(f"\n🔍 Recherche du plat 'Poulet frit' (ID: {poulet_id})")
    
    cursor.execute(f"SELECT * FROM plat_vectors WHERE plat_id = ?", (poulet_id,))
    vector = cursor.fetchone()
    
    if vector:
        print(f"✅ Vecteur trouvé : {vector[1:6]}... (5 premières dimensions)")
    else:
        print(f"❌ PROBLÈME : Pas de vecteur pour ce plat !")
else:
    print("\n⚠️ Plat 'Poulet frit' introuvable dans la base")

# 5. Afficher quelques exemples de vecteurs
print("\n📋 Échantillon de vecteurs (5 premiers plats) :")
cursor.execute("SELECT p.plat_id, p.nom, v.v0, v.v1, v.v2 FROM plats p LEFT JOIN plat_vectors v ON p.plat_id = v.plat_id LIMIT 5")
for row in cursor.fetchall():
    if row[2] is not None:
        print(f"   ✅ ID {row[0]}: {row[1][:30]} → [{row[2]:.3f}, {row[3]:.3f}, {row[4]:.3f}...]")
    else:
        print(f"   ❌ ID {row[0]}: {row[1][:30]} → VECTEUR MANQUANT")

conn.close()

print("\n" + "="*60)
print("💡 SOLUTIONS :")
print("1. Si des vecteurs manquent → Relance generate_vectors.py")
print("2. Si la table n'existe pas → Lance generate_vectors.py")
print("3. Vérifie que le fichier base_miaam.db dans assets/ est bien à jour")
