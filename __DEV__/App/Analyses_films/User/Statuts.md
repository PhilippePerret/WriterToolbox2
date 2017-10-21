# Statuts de l'user {#analyse_statuts_user}

## Définition des statuts

Dans une analyse, un user quelconque peut avoir de nombreux statuts :

Simple lecteur (inscrit)
: Il n'a aucun pouvoir, il peut lire, c'est tout.

Correcteur de fichier
: Il a le pouvoir de corriger les fichiers dont il s'occupe, il est donc aussi contributeur, mais avec des pouvoir réduits.

Rédacteur (de fichier)
: Il rédige, modifie, augmente, etc. un fichier dont il n'est pas le créateur. C'est un contributeur de fait de l'analyse.

Créateur (de fichier)
: Il est contributeur à une analyse (accepté) et il a créé un fichier. Il peut décider qui travaille dessus. Il ne peut pas supprimer le fichier, même s'il l'a créé.

Créateur de l'analyse
: Il a créé l'analyse, l'a initiée. Il a tous les pouvoirs dessus et sur ses fichiers.

Administrateur
: Mêmes pouvoirs que le créateur de l'analyse, avec en plus celui de retirer son statut de créateur à ce créateur d'analyse (en cas extrême).

## Statuts dans l'application

Pour faciliter la gestion d'un utilisateur au travers du programme, et ne pas avoir à recalculer partout ce statut, on utilise plusieurs sous-instance, pour les analyses et pour les fichiers :

```ruby

  class Analyse

    attr_accessor :uanalyser

    class UAnalyser

      # C'est un user dans une analyse, il doit être défini là où
      # il est rentré dans l'application.

    end
```

Pour les fichiers :

```ruby

  class Analyse
    class AFile

      attr_accessor :ufiler

      class UFiler

        # C'est un user pour un fichier, quel que soit son statut par
        # rapport à ce fichier, même s'il est simple lecteur.

```

J'insiste sur le fait que cette propriété n'a rien à voir avec le propriétaire ou le créateur de l'analyse ou du fichier, mais concerne vraiment le visiteur courant ou le visiteur « entré » (quand c'est par exemple un test ou l'administrateur qui fait quelque chose).

## Méthodes pour tester le statut de l'user

On possède ensuite, grâce à ces propriétés, des méthodes qui facilitent grandement le travail :

Pour l'analyse :

```ruby

  uanalyser   # Donc un user quelconque, même un non identifié, dans une
              # analyse qu'il est en train de consulter.

  uanalyser.creator?          # TRUE si c'est le créateur de l'ANALYSE
  uanalyser.contributor?      # TRUE s'il contribue à l'analyse
  uanalyser.admin?            # TRUE si c'est un administrateur (simplement pour
                              # "cohériser" le code)
  uanalyser.simple_reader?    # TRUE s'il n'est que lecteur

```

Pour les fichiers :

```ruby

  ufiler.creator?             # TRUE si c'est le créateur du fichier
  ufiler.redactor?            # TRUE si c'est un rédacteur du fichier
  ufiler.corrector?           # TRUE SI c'est un correcteur (mais il peut être
                              # aussi autre chose, comme rédacteur)
  ufiler.simple_corrector?    # TRUE s'il n'est QUE correcteur
  ufiler.admin?               # TRUE si c'est un administrateur - pour simplifier



```
