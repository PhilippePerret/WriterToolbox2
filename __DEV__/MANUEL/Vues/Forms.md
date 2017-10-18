# Vue - Les formulaires

* [Requérir le support de formulaire](#vue_require_support_form)
* [Les types de formulaires](#form_types)
* [Définir la taille d'un formulaire](#form_taille)
* [Aide pour la construction d'un select](#form_aide_build_select)

## Requérir le support de formulaire {#vue_require_support_form}

Selon le principe du chargement minimum, il faut requérir le support de librairie pour bénéficier des quelques outils utiles :

```html
<%
  require_form_support
%>
<form ...>


```

## Construction type d'un formulaire {#vue_form_building_type}

```html

<form ...>

  <!-- Une rangée type de formulaire -->
  <div>
    <label for="">...</label>
    <span class="field">
      <!-- Champs de saisie ici -->
    </span>
  </div>

  <div>
    <label>... <span><!-- (1) --></span></label>
    <span class="field">
      <!-- Champs de saisie ici -->
    </span>
  </div>


  ...

  <!-- Les boutons sous le formulaire -->
  <div class="buttons">
    <input type="button" class="left" value="Le bouton à gauche">
    <input type="submit" class="main" value="Main bouton (vert)">
  </div>

```

(1) Un `span` dans un label sera toujours considéré comme une explication et sera affiché moins grosse que le reste du texte.


## Les types de formulaires {#form_types}

```

    form.class        Description
    ============================================================================

    div-inline        Les div se présentent en "inline", c'est-à-dire
                      que label et span.field sont en ligne, pas l'un sur l'autre
                      comme c'est le cas par défaut.
                      Typiquement, ça fonctionne bien pour les formulaires sans
                      champ de saisie textarea.

```


## Définir la taille d'un formulaire {#form_taille}

Ajouter les classes suivantes pour modifier les tailles :

```
  w40pc       40% de la largeur
  w50pc       50% de la largeur page à peu près
  w75pc       75% de la largeur de la page à peu près

```

## Définir la taille des labels en mode in-line {#form_label_width}

Si la form.class contient `div-inline`, on peut définir aussi la taille des libellés :

```

  lab50pc     Les libellés feront 50% de la largeur (les champs aussi)
  lab30pc     Les libellés feront 30% de la largeur, (les champs 70%)
  lab20pc     Les libellés feront 20% de la largeur

```



Toujours penser qu'il doit pouvoir s'afficher sur un mobile.

## Définir la taille des champs

On peut appliquer les classes suivantes à tous les champs de saisie (text, select, etc.)

```

  medium      Taille moyenne, donc à peu près 50% du champ
  short       Champ court, par exemple pour une année

```



## Gérer le non rechargement à l'aide d'un FORMID {#vue_form_gerer_non_rechargement}

```html

<% require_form_support %>

<form ...>

  <input type="hidden" name="FORMID" value="<%= Form.unique_id %>">

</form>

```

Et ensuite on le checke à l'aide de :

```ruby

  if Form.form_already_submitted?(param(:FORMID))
    # => une alerte ou autre
  end

```


## Aide pour la construction d'un select {#form_aide_build_select}

```ruby

Form.build_select({
  id:             # ID du select
  name:           # NAME du select
  values:         # Les valeurs, une liste de paires ou un hash définissant
                  # :hname (cf. plus bas)
  options:        # = values
  first_option:   # {String} Un premier menu éventuel
  class:          # {String} Class CSS
  })

```

### Valeurs du menu

Elles peuvent être passées par un `Array` :

```ruby

  values = [
    ['val1', 'titre1'],
    ['val2', 'titre2'],
    etc.
  ]

```

Ou sous forme d'un `Hash`. Les clés seront les valeurs, les valeurs des clés doivent être des `hash` qui définissent la propriété `:hname` :

```ruby

  values = {
    'val1' => {..., hname: 'titre1'},
    'val2' => {..., hname: 'titre2'},
    etc.
  }

```
