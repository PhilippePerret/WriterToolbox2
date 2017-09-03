/**
  * Gestion des fiches
  */

// CLASS Fiche (une fiche d'objet du film)
window.Fiche = function(id) {
  this.id         = id ;
  this.obj        = $('div#' + id) ; // DOM Objet du list-item (jquery)
  this.id_clone   = id + "-clone" ;
  this.displayed  = false ;
  this.zone_stl   = null ;  // La zone {instance ZoneSTL} sur la SupTimeline
}
Object.defineProperties(window.Fiche.prototype,{
  obj_clone:{get:function(){return $('div#' + this.id_clone)}},
  // Fabrique le clone à partir du list-item de l'objet
  clone:{value:function(){
    var clone = this.obj.clone();
    clone.attr('id', this.id_clone);
    clone.removeClass('lit').addClass('fiche');
    clone.find('.btnclose').bind('click', $.proxy(Fiches, 'close'));
    clone.find('fieldset.citations').remove() ;
    UI.observe_all_in( clone ) ;
    $('div#current_fiche').append(clone) ;
  }},
  
  show:{value:function(options){
    // console.log("-> Fiche.show");
    $('div#current_fiche').html(''); // au cas où
    this.clone();
    Fiches.current = this ;
    Fiches.current_oid = this.id ;
    this.displayed = true;
    if(this.obj.attr('start')){
      this.zone_stl = SupTimeline.show([this.start_at, this.end_at], options) ;
    }
  }},
  hide:{value:function(){
    // console.log("-> Fiche.hide");
    this.obj_clone.remove();
    Fiches.current = null; 
    Fiches.current_oid = null ;
    this.displayed = false;
    if( this.zone_stl ){ SupTimeline.remove( this.zone_stl ) }
    return this.id
  }},
  toggle:{value:function(){
    this[this.displayed ? 'hide' : 'show']() ;
  }},
  
  start_at:{
    get:function(){
      if('undefined' == typeof this._start_at) this._start_at = this.obj.attr('start') ;
      return this._start_at
    }
  },
  end_at:{
    get:function(){
      if('undefined' == typeof this._end_at) this._end_at = this.obj.attr('end') ;
      return this._end_at
    }
  }
})