import sqlite3
import os

db_path = "../assets/database/base_miaam.db"

if not os.path.exists(db_path):
    print(f"❌ Base de données introuvable : {db_path}")
    exit()

conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("="*60)
print("📋 STRUCTURE DE LA BASE DE DONNÉES")
print("="*60)

# Lister toutes les tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()

print(f"\n🗂️  Tables disponibles ({len(tables)}) :")
for table in tables:
    print(f"   - {table[0]}")

# Vérifier la structure de plat_vectors
print("\n" + "="*60)
print("🧬 Structure de la table 'plat_vectors'")
print("="*60)

cursor.execute("PRAGMA table_info(plat_vectors)")
columns = cursor.fetchall()

if not columns:
    print("❌ La table 'plat_vectors' n'existe PAS !")
    print("   → Lance le script generate_vectors.py")
else:
    print(f"\n✅ Colonnes de plat_vectors ({len(columns)}) :")
    for col in columns[:5]:  # Les 5 premières
        print(f"   {col[1]} ({col[2]})")
    if len(columns) > 5:
        print(f"   ... et {len(columns) - 5} autres colonnes")

# Vérifier la structure de plats
print("\n" + "="*60)
print("📦 Structure de la table 'plats'")
print("="*60)

cursor.execute("PRAGMA table_info(plats)")
plats_cols = cursor.fetchall()
print(f"\n✅ Colonnes principales :")
for col in plats_cols[:10]:
    print(f"   {col[1]} ({col[2]})")

# Test de jointure
print("\n" + "="*60)
print("🔗 Test de jointure plats <-> plat_vectors")
print("="*60)

try:
    cursor.execute("""
        SELECT p.plat_id, p.nom, v.v0, v.v1 
        FROM plats p 
        INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
        LIMIT 3
    """)
    
    results = cursor.fetchall()
    
    if results:
        print(f"✅ Jointure réussie ! Exemple (3 premiers plats) :")
        for row in results:
            print(f"   ID {row[0]}: {row[1][:30]} → v0={row[2]:.3f}, v1={row[3]:.3f}")
    else:
        print("⚠️ Jointure OK mais aucun résultat")
        
except Exception as e:
    print(f"❌ ERREUR lors de la jointure : {e}")

# Vérifier spécifiquement "Poulet frit"
print("\n" + "="*60)
print("🍗 Test spécifique : Poulet frit à l'air croustillant")
print("="*60)

cursor.execute("SELECT plat_id, nom FROM plats WHERE nom LIKE '%Poulet frit%'")
poulet = cursor.fetchone()

if poulet:
    poulet_id, nom = poulet
    print(f"✅ Plat trouvé : ID={poulet_id}")
    
    # Chercher son vecteur
    cursor.execute("SELECT v0, v1, v2 FROM plat_vectors WHERE plat_id = ?", (poulet_id,))
    vec = cursor.fetchone()
    
    if vec:
        print(f"✅ Vecteur trouvé : [{vec[0]:.3f}, {vec[1]:.3f}, {vec[2]:.3f}...]")
    else:
        print(f"❌ PROBLÈME : Pas de vecteur pour ce plat !")
        
        # Vérifier s'il a des ingrédients
        cursor.execute("SELECT COUNT(*) FROM Plat_ingredient WHERE plat_id = ?", (poulet_id,))
        nb_ing = cursor.fetchone()[0]
        
        if nb_ing > 0:
            print(f"   → Le plat a {nb_ing} ingrédients MAIS pas de vecteur")
            print(f"   → SOLUTION : Relance generate_vectors.py")
        else:
            print(f"   → Le plat n'a AUCUN ingrédient !")
            print(f"   → SOLUTION : Ajoute des ingrédients à ce plat")
else:
    print("❌ Plat 'Poulet frit' introuvable")

conn.close()

print("\n" + "="*60)
print("✅ Diagnostic terminé")
print("="*60)
