import sqlite3
import pandas as pd
from sklearn.decomposition import TruncatedSVD
from scipy.sparse import csr_matrix
import os

# 1. Connexion à ta base de données
# On vérifie le chemin
db_path = "../assets/database/base_miaam.db"
if not os.path.exists(db_path):
    print(f"❌ Erreur : Le fichier {db_path} est introuvable !")
    exit()

conn = sqlite3.connect(db_path)

print("Chargement des données...")
# 2. Charger la table de liaison
query = "SELECT plat_id, ingredient_id FROM Plat_ingredient"
df = pd.read_sql_query(query, conn)

# Création de la matrice creuse
df['value'] = 1
plats = df['plat_id'].astype('category')
ingredients = df['ingredient_id'].astype('category')

matrix = csr_matrix((df['value'], (plats.cat.codes, ingredients.cat.codes)))
print(f"Matrice créée : {matrix.shape[0]} plats et {matrix.shape[1]} ingrédients.")

# 3. L'ALGORITHME SVD (Réduction à 27 dimensions)
print("Calcul des 27 dimensions (SVD)...")
svd = TruncatedSVD(n_components=27, random_state=42)
vectors = svd.fit_transform(matrix)

# Création du DataFrame avec les noms de colonnes
cols = [f'v{i}' for i in range(27)]
vector_df = pd.DataFrame(vectors, columns=cols)
vector_df['plat_id'] = plats.cat.categories.astype(int) # On s'assure que c'est de l'entier

# --- CORRECTION ICI : ON REORDONNE LES COLONNES ---
# On met 'plat_id' en première position
vector_df = vector_df[['plat_id'] + cols]

# 4. ÉCRITURE DANS LA BASE DE DONNÉES
print("Création de la table plat_vectors dans SQLite...")
cursor = conn.cursor()

cursor.execute("DROP TABLE IF EXISTS plat_vectors")

# Construction de la requête de création (plat_id d'abord)
v_cols_sql = ", ".join([f"v{i} REAL" for i in range(27)])
cursor.execute(f"CREATE TABLE plat_vectors (plat_id INTEGER PRIMARY KEY, {v_cols_sql})")

# Insertion
placeholders = ", ".join(["?"] * 28)
cursor.executemany(f"INSERT INTO plat_vectors VALUES ({placeholders})", vector_df.values.tolist())

conn.commit()
conn.close()

print("✅ Terminé ! Ta base de données est prête pour l'algo vectoriel.")