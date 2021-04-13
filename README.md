# Soutenance

Voici un utilitaire pour faciliter les diverses vérifications à faire
lorsque l'on veut que sa soutenance soit conforme aux réglementations en
vigueur.

## Utilisation

Premièrement, décrivez votre jury de thèse selon le modèle du fichier
`tests/jury.md`.

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
