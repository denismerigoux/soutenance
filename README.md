# Soutenance

Voici un utilitaire pour faciliter les diverses vérifications à faire
lorsque l'on veut que sa soutenance soit conforme aux réglementations en
vigueur.

## Description

Premièrement, décrivez votre jury de thèse selon le modèle du fichier
`tests/jury.md`.

Voici la liste des qualifications disponibles pour chaque membre du jury:

- `homme`/`femme` : genre, nécessaire pour calculer l'équilibre homme/femme
- `directeur`/`directrice` : cette personne est directeur/directrice de cette thèse
- `professeur`/`professeure` : titulaire dans un corps de professeurs des universités, directeurs de recherche ou grade équivalent pour des institutions étrangères
- `président`/`présidente` : présidence du jury de thèse
- `habilitation` : titulaire de l'habilitation à diriger les recherches ou équivalent pour les personnes étrangères
- `externe` : personne extérieure à l'établissement d'inscription et à l'école doctorale du candidat
- `rapporteur`/`rapporteuse` : rapporteurs de thèse

## Vérification

Ensuite, exécutez `dist/soutenance.js` sur le fichier qui décrit votre
jury de thèse. Par exemple,

    node dist/soutenance.js tests/jury.md

Si opam est installé sur votre machine, il vous suffit de faire

    opam pin add soutenance https://github.com/denismerigoux/soutenance.git\#main
    soutenance tests/jury.md

## Explications

Le fichier `source_loi.pdf` contient la description législative et algorithmique
de la vérification de la composition du jury de thèse.

## Catala

Ce petit utilitaire est basé sur [le projet Catala](https://catala-lang.org/).

## Contributions

Le code source de ce dépôt est publié sous licence Apache. N'hésitez pas à contribuer!
Il y a plein de fonctionnalités à ajouter, et de manière de partager ce petit
utilitaire :)
