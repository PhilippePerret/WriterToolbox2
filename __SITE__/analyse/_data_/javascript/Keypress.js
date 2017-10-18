/**
  * Un objet principal qui va gérer les touches pour l'ensemble
  *
  * Fonctionnement pour l'ensemble :
  *   Quand on choisit un élément (onclick sur un élément), le "groupe" de l'élément,
  *   donc l'objet principal qui le gère, devient le "focus" de Keypress. Si cet
  *   objet principal définit une fonction que Keypress connait, elle l'appelle.
  *
  *   Par exemple pour passer d'un "bloc" à l'autre dans le listing des scènes ou 
  *   dans le diagramme dramatique, on utilise les flèches droite/gauche. Dès qu'on
  *   clique sur un bloc, l'objet Diag (pour le diagramme dramatique) devient l'objet
  *   qui a le focus. Comme Diag répond à la méthode on_right_arrow, si on clique sur
  *   la flèche vers droite, Keypress appelle cette méthode.
  *
  *   Donc, pour qu'un objet réagisse au keypress :
  *     - le mettre en objet focus dans Keypress à l'aide de Keypress.current = <objet>
  *       (par exemple quand on clique dessus ou sur un de ses éléments)
  *       Exemple pour le diagramme dramatique : c'est quand on clique sur un bloc de
  *       qrd que ça le définit.
  *     - Définir dans l'objet courant (p.e. Diag) les méthodes qui doivent réagir, en
  *       leur donnant le nom de la touche.
  *       Diag.on_right_arrow = function(){ ... déplacer vers la droite la sélection ... }
  */
window.Keypress = {
  current : null, // objet principal courant
  event   : null, // L'évènement, pour l'envoyer aux méthodes (pour touches modificatrices)
  on_key_press:function(ev){
    if(this.current == null) return true ;
    this.event = ev ;
    switch(ev.keyCode){
    case 37: // flèche vers la gauche
      if(this.call_if_method('on_left_arrow')) return false ;
      break;
    case 38: // flèche vers le haut
      if(this.call_if_method('on_top_arrow')) return false ;
      break;
    case 39: // flèche vers la droite
      if(this.call_if_method('on_right_arrow')) return false ;
      break;
    case 40: // flèche vers le bas
      if(this.call_if_method('on_down_arrow')) return false ;
      break;
    default:
      if(console) console.log("keyCode = " + ev.keyCode) ;
    }
    switch(ev.charCode){
      
    }
  },
  call_if_method:function(method){
    if('function' == typeof this.current[method]){ 
      this.current[method]( this.event );
      return true ;   // pour stopper
    } else {
      return false ;  // pour poursuivre
    }
  }
}
window.onkeypress = $.proxy(window.Keypress.on_key_press, window.Keypress) ;