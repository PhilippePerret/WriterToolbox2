/**
  * Objet gérant les fiches en tant qu'ensemble
  */
window.Fiches = {
  list    :{},              // Hash des instances Fiche déjà instanciées
  current :null,            // Instance Fiche courante
  current_oid:null,         // Identifiant du list-item de la fiche courante
  
  // Toggle une fiche
  toggle:function( foo ){
    // console.log("-> Fiches.toggle");
    var oid = this.oid_of(foo); // ne doit être mis dans current_oid que par 'show'
    if($('div#'+oid).length) this.toggle_by_id( oid ) ;
    else F.error("Impossible de trouver le list-item d'identifiant “"+this.current_oid+"”");
    if(Foo.is_jquery_event(foo)){
      foo.stopPropagation();
      foo.preventDefault();
      return false ;
    }
  },
  toggle_by_id:function(id){
    var is_fiche_displayed = this.current_oid == id ;
    if(this.current != null){ this.hide_by_id( this.current_oid ) }
    if( is_fiche_displayed ) return ;
    else this.show_by_id(id);
  },
  
  // Affiche une fiche
  show:function( foo ) {
    this.show_by_id(this.oid_of(foo));
  },
  show_by_id:function(id){
    this.fiche(id).show();
  },
  // Masque une fiche
  hide:function( foo ){
    this.hide_by_id(this.oid_of(foo)) ;
  },
  hide_by_id:function(id){
    this.fiche(id).hide() ;
  },
  
  // Fermer une fiche (alias de hide)
  close:function( foo ){this.hide(foo)},
  
  // Retourne l'instance Fiche d'identifiant +id+, l'instancie si elle
  // n'existe pas encore.
  // @note: C'est cette méthode qu'il faut appeler quand on possède l'id
  // d'une fiche. Par exemple : Fiches.fiche(<id>).show()
  fiche:function(id){
    if('undefined' == typeof this.list[id]) this.list[id] = new Fiche(id);
    return this.list[id] ;
  },
  
  // Retourne l'identifiant String à partir de +foo+ qui peut être
  // soit l'identifiant lui-même, soit l'objet DOM, soit l'évènement
  // ayant appelé l'action.
  oid_of:function(foo){
    if('string' == typeof foo) return foo ;
    else if(Foo.is_jquery_element(foo)) return foo.attr('oid') ;
    else if(Foo.is_dom_element(foo))    return $(foo).attr('oid') ;
    else if(Foo.is_jquery_event(foo))   return $.proxy(Fiches, 'oid_of', foo.currentTarget)() ;
    else if(Foo.is_dom_event(foo))      return $.proxy(Fiches, 'oid_of', foo.originalTarget)() ;
    else {
      F.error("Impossible de récupérer l'ID du list-item à afficher. foo = " + foo);
      return null;
    }
  },
  
  
  //---------------------------------------------------------------------
  

}