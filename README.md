![MrBricolage](https://www.mr-bricolage.fr/static/version1551157594/frontend/Pictime/mrbricolage/fr_FR/images/mrbricolage-logo.png)
# La reprise de données dans le contexte client **Mr.Bricolage**

## Introduction
Scripts de reprise des données issues du système d'informations tiers "SIGMA", pour intégration dans le back-office METI.
Les règles de gestion ainsi que les règles de validation et contrôles de volumétrie post-reprise sont abordés dans le document [Règles de validation](https://docs.google.com/document/d/107S8XQBlX7a58akmwZmzyQYD_aJ4a2b4M-r1LLTH3SE/edit?usp=sharing).

L'arborescence présentée ci-dessus doit être conservée et déposée sur le serveur d'application de(s) machine(s) concernée(s), à l'emplacement que vous souhaitez.

## Les étapes de la reprise

### Tables temporaires
#### 📍Alimentation des tables temporaires avec les données SIGMA
Les tables temporaires sont alimentées via les shells _load_ et les fichiers _CTL_. Les données transmises par SIGMA sont stockés sous forme de fichiers .txt dans le dossier DATA.
Pour alimenter les tables temporaires, il faut exécuter uniquement l'étape 1 du script de RDD : 
- `sh START.sh 1 1` ⏱4min

### Le Référentiel
#### 📍Identification des cas d'utilisation et application des règles de gestion
Les règles de gestion sont portées dans les scripts _PL/SQL_ à la racine du projet.
Pour lancer la reprise de données du référentiel, il faut exécuter le script de lancement de l'étape 1 à l'étape 4 :
- `sh START.sh 2 4` ⏱30min

La reprise peut également être exécutée d'une étape X à une étape Y
- `sh START.sh 2 3` on exécute de l'étape 2 à l'étape 3
- `sh START.sh 3 3` on exécute seulement l'étape 3

#### 📍Contrôle des cas d'utilisation identifiés
Un premier contrôle est exécuté après l'alimentation des tables temporaires et le retravail des données.
Ce contrôle permet de s'assurer que le volumes de données transmis par SIGMA est le même que celui qui va être intégré dans METI.

Pour lancer le contrôle, exécutez la commande suivant : 
- `sh START.sh X X` ⏱1 minute

Si les contrôles s'avèrent corrects, et qu'aucun écart n'est déclaré, alors on peut passer à l'étape suivante.

#### 📍Génération du fichier RAR et intégration du fichier en CENTRALE
On génére un fichier _RAR.csv_ adapté au flux de référentiel Mr.Bricolage _RAR_SPE_BRICO_.
Pour lancer la génération du fichier _RAR.csv_, suivi de son intégration, il faut exécuter le script de lancement de l'étape 5 à l'étape 6 :
- `sh START.sh 5 6` ⏱20 minutes

Se référer à la consultation du flux _RAR_SPE_BRICO_ sur eMag afin de s'assurer que tout s'est bien déroulé.


#### 📍Contrôle de la volumétrie sur la CENTRALE après intégration du fichier RAR
Un second contrôle peut être exécuté après l'alimentation du référentiel CENTRALE via le fichier _RAR.csv_.
Ce contrôle permet de s'assurer que le volume de données intégré dans le référentiel correspond au volume identifié lors du premier contrôle.

Pour lancer le contrôle, exécutez la commande suivant : 
- `sh START.sh Y Y` ⏱1 minute

Si le contrôle s'avère correct, et qu'aucun écart n'est déclaré, alors on peut passer à l'étape suivante.

### RER vers site
#### 📍Export RER Fournisseurs
Lancer l'export RER Global "Fournisseur" sur le dossier CENTRALE vers le dossier MAGASIN.⏱5min

#### 📍Export RER Articles
Lancer l'export RER Global "Articles" sur le dossier CENTRALE vers le dossier MAGASIN.⏱10min

#### Import RER en magasin
Lancer l'import RER sur le dossier MAGASIN pour le fichier RER des FOURNISSEURS.⏱5min
Lancer l'import RER sur le dossier MAGASIN pour le fichier RER des ARTICLES.⏱45min

### Les Historiques
#### 📍Intégration des historiques dans METI, sur le dossier MAGASIN
Les règles de gestion sont portées dans les scripts _PL/SQL_ à la racine du projet.
On intègre les données d'historiques dans le dossier MAGASIN en éxécutant le script d'historique associé.

Pour lancer la reprise des données d'historiques, il faut exécuter le script de lancement de l'étape 7 à l'étape 11 :
- `sh START.sh 7 10` ⏱60min 
-- Les stocks ⏱10min 
-- Les achats ⏱10min
-- Les commandes ⏱10min
-- Les ventes ⏱10min 

#### 📍Contrôle de la volumétrie sur le MAGASIN après intégration des historiques
Un contrôle des HISTORIQUES est exécuté après l'alimentation des données en MAGASIN.
Ce contrôle permet de s'assurer que le volume et les statistiques de données intégré dans le MAGASIN correspondent à ceux transmis par SIGMA.
Si le contrôle s'avère correct, et qu'aucun écart n'est déclaré, alors on peut passer à l'étape suivante.

### Traitements Post-Reprise
On lance les traitements post-reprise qui ne peuvent être exécutés en amont de la RDD.
- `sh post_reprise.sh` ⏱10min

# La reprise de données est terminée 🏁
