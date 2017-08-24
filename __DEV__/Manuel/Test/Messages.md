# Messages en cours de test {#testmessages}


## Ajout de messages (de succès) dans les retours de test {#test_ajout_messages_success}

Pour ajouter des messages dans les retours de test, on peut utiliser les méthodes :

* `success(<message de succès>)`,
* `failure(<message de failure>)` (malgré le titre, il peut être intéressant parfait d'ajouter des messages d'échec sans interrompre le processus, par exemple "Le fichier untel est introuvable, je ne peux pas le vérifier." et poursuivre le processus qui ne dépend pas de ce fichier).

Ces deux méthodes ajoutent respectivement un message vert ou route.

C'est particulièrement utile dans les `scenarios` des tests d'intégration. Le mieux est de mettre le titre du scénario avec un "=> " au début (ce message apparaitra en dernier — cf. l'exemple), de définir la tabulation nécessaire pour que les messages soient bien alignés et de les ajouter comme nécessaire.

On utilise la méthode `success_tab` pour définir la tabulation (les espaces) qui précèderont le message de succès ou d'échec.

Par exemple :

```ruby

feature "Un essai" do

  before :all do
    success_tab('    ') # ajouté devant messages
  end

  context "avec les bons messages" do

    scenario "=> fonctionne parfaitement." do

      ... opération test ...
      success 'exécute la première opération'

      ... autre opération test ...
      success 'exécute la deuxième opération'

      ...
      success 'exécute la troisième opération'
    end

  end
end


```

Ce test produira en console :

<code style="display:block;white-space:pre-wrap;background:black;color:#CCC;padding:1em;">
Un essai
  avec les bons messages
      <span style="color:#0D0">exécute la première opération</span>
      <span style="color:#0D0">exécute la deuxième opération</span>
      <span style="color:#0D0">exécute la troisième opération</span>
      <span style="color:#0D0">=> fonctionne parfaitement.</span>
</code>

## Astuce pour texte récurrent en début de ligne {#testmessage_recurrent_texte}

On peut détourner la méthode `success_tab` pour ajouter un texte récurrent à tous les message de succès. Par exemple, dans l'exemple précédent, le mot "exécute" se trouve en début de chaque opération. Pour produire le même affichage, on peut donc faire plutôt :

```ruby

feature "Un essai" do
  before :all do
    success_tab('    exécute ') # ajouté devant les messages
  end
  context "avec les bons messages" do
    scenario "=> fonctionne parfaitement." do
      ... opération test ...
      success 'la première opération'
      ... autre opération test ...
      success 'la deuxième opération'
      ...
      success 'la troisième opération'
    end
  end
end

```
