Exemple de site Web

Avec du Python-Flask, du Javascript et une BD Oracle

Ce site Web devra obligatoirement être déployé sur votre machine à la fin de la première séance de TP.

Etapes: 

    Exécutez le fichier creabase.sql sur votre compte Oracle (machine telline), en utilisant SQLDeveloper
    Installer les libraries python (flask, sqlalchemy et cx-Oracle)
        pip install Flask
        pip install SQLAlchemy
        pip install cx_Oracle
    Installer le client oracle
        https://oracle.github.io/odpi/doc/installation.html#linux (points 1, 2, 3 et 4)
        Attention à la version car les liens parfois sont pour 19_3 mais on utilise 19_5
        La commande LD_LIBRARY_PATH (point 4 du lien oracle)
            Cette commande doit être exécuté dans la console qui démarre python
            export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_5:$LD_LIBRARY_PATH
    Télécharger l’exemple et l’exécuter
        Dézipper le fichier
        Modifiez le fichier server_ex.py avec vos identifiants de connexion (login/mdp)
        Affichez le site en lançant le serveur Flask:
            Dans le navigateur ouvrir http://localhost:5000   
