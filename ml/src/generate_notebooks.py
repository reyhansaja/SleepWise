import json
import os

base_dir = r"C:\Users\Administrator\.gemini\antigravity\scratch\sleepwise_ml\notebooks"
os.makedirs(base_dir, exist_ok=True)

def make_notebook(cells, filename):
    nb = {
        'cells': cells,
        'metadata': {
            'language_info': {'name': 'python', 'version': '3.13'},
            'kernelspec': {'display_name': 'Python 3', 'language': 'python', 'name': 'python3'}
        },
        'nbformat': 4,
        'nbformat_minor': 5
    }
    filepath = os.path.join(base_dir, filename)
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(nb, f, indent=2)
    print(f"Created {filepath}")

# Notebook 1: EDA & Preprocessing
nb1_cells = [
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': [
            '# 🌙 SleepWise - 01. Exploratory Data Analysis (EDA) & Preprocessing\n',
            '**Fitur:** Dataset & Preprocessing  \n',
            '**Branch:** `feature/01-data-preprocessing`  \n',
            'Notebook ini mencakup pemuatan dataset, pembersihan missing values & duplikat, feature engineering (split Blood Pressure), EDA visualisasi, pemetaan 3 kategori (Good/Average/Poor), dan pipeline encoding.'
        ]
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'import os\n',
            'import pandas as pd\n',
            'import numpy as np\n',
            'import matplotlib.pyplot as plt\n',
            'import seaborn as sns\n',
            'import joblib\n',
            '\n',
            'sns.set_theme(style="whitegrid", palette="muted")\n',
            'df = pd.read_csv("../data/raw/Sleep_health_and_lifestyle_dataset.csv")\n',
            'df.head()'
        ]
    },
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': ['## 1. Pembersihan Data (Missing Values & Standarisasi)']
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            '# 1. Hapus Person ID\n',
            'if "Person ID" in df.columns:\n',
            '    df.drop(columns=["Person ID"], inplace=True)\n',
            '\n',
            '# 2. Imputasi Sleep Disorder\n',
            'df["Sleep Disorder"] = df["Sleep Disorder"].fillna("None")\n',
            '\n',
            '# 3. Standarisasi BMI Category\n',
            'df["BMI Category"] = df["BMI Category"].replace({"Normal Weight": "Normal"})\n',
            '\n',
            '# 4. Split Blood Pressure menjadi Sistolik dan Diastolik\n',
            'bp_split = df["Blood Pressure"].astype(str).str.split("/", expand=True)\n',
            'df["Systolic_BP"] = bp_split[0].astype(int)\n',
            'df["Diastolic_BP"] = bp_split[1].astype(int)\n',
            'df.drop(columns=["Blood Pressure"], inplace=True)\n',
            '\n',
            '# 5. Label Target 3 Kategori (Poor, Average, Good)\n',
            'def map_sleep(score):\n',
            '    if score <= 5: return "Poor"\n',
            '    elif score == 6: return "Average"\n',
            '    else: return "Good"\n',
            '\n',
            'df["Sleep_Quality_Class"] = df["Quality of Sleep"].apply(map_sleep)\n',
            'print("Distribusi Target:")\n',
            'print(df["Sleep_Quality_Class"].value_counts())\n',
            'df.info()'
        ]
    },
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': ['## 2. Visualisasi EDA (Distribusi & Korelasi)']
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'plt.figure(figsize=(8, 5))\n',
            'sns.countplot(x="Sleep_Quality_Class", data=df, palette=["#fbbf24", "#4ade80", "#f87171"], order=["Average", "Good", "Poor"])\n',
            'plt.title("Distribusi Kategori Kualitas Tidur")\n',
            'plt.show()\n',
            '\n',
            'plt.figure(figsize=(10, 6))\n',
            'numeric_cols = df.select_dtypes(include=[np.number]).columns\n',
            'sns.heatmap(df[numeric_cols].corr(), annot=True, cmap="Blues", fmt=".2f")\n',
            'plt.title("Korelasi Fitur Numerik")\n',
            'plt.show()'
        ]
    },
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': ['## 3. Ekspor Data Bersih & ColumnTransformer']
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'from sklearn.model_selection import train_test_split\n',
            'from sklearn.preprocessing import OneHotEncoder, StandardScaler\n',
            'from sklearn.compose import ColumnTransformer\n',
            '\n',
            'cat_cols = ["Gender", "Occupation", "BMI Category", "Sleep Disorder"]\n',
            'num_cols = ["Age", "Sleep Duration", "Physical Activity Level", "Stress Level", "Heart Rate", "Daily Steps", "Systolic_BP", "Diastolic_BP"]\n',
            '\n',
            'X = df[cat_cols + num_cols]\n',
            'y = df["Sleep_Quality_Class"]\n',
            '\n',
            'X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)\n',
            '\n',
            'preprocessor = ColumnTransformer([\n',
            '    ("cat", OneHotEncoder(handle_unknown="ignore", sparse_output=False), cat_cols),\n',
            '    ("num", StandardScaler(), num_cols)\n',
            '])\n',
            'preprocessor.fit(X_train)\n',
            'print("Preprocessing pipeline berhasil dilatih!")'
        ]
    }
]

make_notebook(nb1_cells, '01_eda_and_preprocessing.ipynb')

# Notebook 2: Decision Tree
nb2_cells = [
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': [
            '# 🌳 SleepWise - 02. Decision Tree Classifier\n',
            '**Fitur:** Decision Tree  \n',
            '**Branch:** `feature/02-decision-tree`  \n',
            'Eksperimen training Decision Tree Classifier, Hyperparameter Tuning (GridSearchCV), dan Evaluasi (Confusion Matrix, Precision, Recall, F1-Score).'
        ]
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'import pandas as pd\n',
            'import matplotlib.pyplot as plt\n',
            'import seaborn as sns\n',
            'from sklearn.tree import DecisionTreeClassifier, plot_tree\n',
            'from sklearn.model_selection import GridSearchCV, StratifiedKFold\n',
            'from sklearn.metrics import classification_report, confusion_matrix, accuracy_score\n',
            '\n',
            'X_train = pd.read_csv("../data/processed/X_train.csv")\n',
            'X_test = pd.read_csv("../data/processed/X_test.csv")\n',
            'y_train = pd.read_csv("../data/processed/y_train.csv").squeeze()\n',
            'y_test = pd.read_csv("../data/processed/y_test.csv").squeeze()\n',
            '\n',
            'param_grid = {\n',
            '    "criterion": ["gini", "entropy"],\n',
            '    "max_depth": [3, 4, 5, 6, None],\n',
            '    "min_samples_split": [2, 5, 10],\n',
            '    "min_samples_leaf": [1, 2, 4]\n',
            '}\n',
            '\n',
            'grid = GridSearchCV(DecisionTreeClassifier(random_state=42), param_grid, cv=5, scoring="f1_weighted", n_jobs=-1)\n',
            'grid.fit(X_train, y_train)\n',
            'print("Parameter Terbaik:", grid.best_params_)\n',
            'best_dt = grid.best_estimator_'
        ]
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'y_pred = best_dt.predict(X_test)\n',
            'print("Akurasi:", accuracy_score(y_test, y_pred))\n',
            'print("\\nClassification Report:\\n", classification_report(y_test, y_pred))\n',
            '\n',
            'cm = confusion_matrix(y_test, y_pred, labels=["Average", "Good", "Poor"])\n',
            'plt.figure(figsize=(6, 5))\n',
            'sns.heatmap(cm, annot=True, fmt="d", cmap="Blues", xticklabels=["Average", "Good", "Poor"], yticklabels=["Average", "Good", "Poor"])\n',
            'plt.title("Confusion Matrix - Decision Tree")\n',
            'plt.show()'
        ]
    }
]

make_notebook(nb2_cells, '02_decision_tree_experiments.ipynb')

# Notebook 3: Random Forest
nb3_cells = [
    {
        'cell_type': 'markdown',
        'metadata': {},
        'source': [
            '# 🌲🌲 SleepWise - 03. Random Forest Classifier\n',
            '**Fitur:** Random Forest  \n',
            '**Branch:** `feature/03-random-forest`  \n',
            'Eksperimen training Random Forest Classifier, Pengaturan Jumlah Pohon, Validasi, Evaluasi Matriks, dan Analisis Korelasi Feature Importance.'
        ]
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'import pandas as pd\n',
            'import matplotlib.pyplot as plt\n',
            'import seaborn as sns\n',
            'from sklearn.ensemble import RandomForestClassifier\n',
            'from sklearn.model_selection import GridSearchCV\n',
            'from sklearn.metrics import classification_report, confusion_matrix, accuracy_score\n',
            '\n',
            'X_train = pd.read_csv("../data/processed/X_train.csv")\n',
            'X_test = pd.read_csv("../data/processed/X_test.csv")\n',
            'y_train = pd.read_csv("../data/processed/y_train.csv").squeeze()\n',
            'y_test = pd.read_csv("../data/processed/y_test.csv").squeeze()\n',
            '\n',
            'param_grid = {\n',
            '    "n_estimators": [50, 100, 150],\n',
            '    "max_depth": [4, 6, 8, None],\n',
            '    "min_samples_split": [2, 5]\n',
            '}\n',
            '\n',
            'grid = GridSearchCV(RandomForestClassifier(random_state=42), param_grid, cv=5, scoring="f1_weighted", n_jobs=-1)\n',
            'grid.fit(X_train, y_train)\n',
            'print("Parameter Terbaik:", grid.best_params_)\n',
            'best_rf = grid.best_estimator_'
        ]
    },
    {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {},
        'outputs': [],
        'source': [
            'y_pred = best_rf.predict(X_test)\n',
            'print("Akurasi:", accuracy_score(y_test, y_pred))\n',
            'print("\\nClassification Report:\\n", classification_report(y_test, y_pred))\n',
            '\n',
            '# Feature Importance\n',
            'imp = pd.Series(best_rf.feature_importances_, index=X_train.columns).sort_values(ascending=False).head(10)\n',
            'plt.figure(figsize=(10, 5))\n',
            'imp.plot(kind="barh", color="#10b981").invert_yaxis()\n',
            'plt.title("Top 10 Feature Importance (Random Forest)")\n',
            'plt.show()'
        ]
    }
]

make_notebook(nb3_cells, '03_random_forest_experiments.ipynb')
print("All notebooks created successfully!")
