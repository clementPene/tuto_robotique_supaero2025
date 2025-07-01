# Fichier shell.nix
# ------------------
# Ce fichier décrit un environnement de développement complet pour votre projet de robotique.
# Lancez-le avec la commande `nix-shell` dans votre terminal.

{ pkgs ? import <nixpkgs> {} }:

# On définit un "shell" de développement
pkgs.mkShell {
  # --- 1. DÉPENDANCES SYSTÈME (Bibliothèques C++ avec bindings Python) ---
  # Ce sont les outils lourds qui ne sont pas de purs paquets Python.
  # Nix les gère comme des paquets du système d'exploitation.
  nativeBuildInputs = [
    # Outils de compilation et de gestion de version, toujours utiles
    pkgs.cmake
    pkgs.git
  ];

  buildInputs = [
    # Le coeur de la robotique
    pkgs.pinocchio
    pkgs.crocoddyl
    pkgs.proxsuite

    # Le visualiseur MeshCat
    pkgs.meshcat-python
  ];


  # --- 2. ENVIRONNEMENT PYTHON DÉDIÉ ---
  # On définit ici un interpréteur Python 3.11 avec une liste de bibliothèques.
  # C'est la méthode propre et moderne pour gérer les dépendances Python avec Nix.
  python = pkgs.python311.withPackages (ps: [
    # Paquets que vous avez listés, traduits pour Nix :
    ps.numpy
    ps.scipy
    ps.matplotlib
    ps.jupyterlab         # Pour les notebooks et un environnement de travail interactif
    ps.mim-solvers
    ps.example-robot-data
  ]);


  # --- 3. COMMANDES D'INITIALISATION ---
  # Ce "hook" exécute des commandes dès que vous entrez dans le shell.
  shellHook = ''
    # Affiche un message de bienvenue pour confirmer que tout est prêt
    echo "------------------------------------------------------------"
    echo " Environnement de Robotique (Pinocchio & Crocoddyl) activé."
    echo " Lancez 'jupyter lab' pour commencer à travailler."
    echo "------------------------------------------------------------"

    # GEPETUTO : Ce paquet n'est pas dans l'archive principale de Nix.
    # Nous utilisons pip pour l'installer dans un dossier temporaire,
    # propre à cette session du shell. C'est une pratique courante.
    export PYTHONUSERBASE=$(mktemp -d)
    pip install --user gepetuto

    # IMPORTANT : Indique à Python où trouver les bindings de Pinocchio & Crocoddyl
    # que Nix a installés. Sans cette ligne, `import pinocchio` échouerait.
    export PYTHONPATH=${pkgs.pinocchio}/lib/python3.11/site-packages:${pkgs.crocoddyl}/lib/python3.11/site-packages:${pkgs.proxsuite}/lib/python3.11/site-packages:$PYTHONPATH
  '';
}
