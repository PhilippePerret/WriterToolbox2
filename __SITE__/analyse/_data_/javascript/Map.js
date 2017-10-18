/**
  * Objet Map
  * ---------
  * Gestion de la carte complète du film
  *
  */

window.Map = {
  
  // Placer les observers sur la map
  observe_all:function(){
    $('div.filmmap_map div.map_o').bind('click', $.proxy(Map, 'toggle_obj'))
    
  },
  
  toggle_obj:function(ev){$(ev.currentTarget).toggleClass('expanded')},
  // Ouvrir l'objet pour pouvoir le lire entièrement
  expand_obj:function(odom){$(odom).addClass('expanded')},
  // Referme l'objet pour le remettre dans son état normal
  collapse_obj:function(odom){$(odom).removeClass('expanded')},
  
  
  // Pour afficher/masquer un type
  toggle_type: function(odom){
    var type = $(odom).attr('data-type') ;
    var show = odom.checked == true ;
    var allthis = null ;
    if( type == "br" ){
      allthis = $("div.filmmap_map div.map_br")
    }else if (type == "sc"){
      allthis = $("div.filmmap_map  div.map_sc")
    }else{
      allthis = $("div.filmmap_map div.map_o."+type) ;
    }
    allthis[show ? 'show' : 'hide']() ;
  },
  
  //---------------------------------------------------------------------
  //  OPTIONS
  
  Options:{
    panneau_visible: false,
    // === LES OPTIONS ===
    exergue_liens_objets: false,
    indiquer_temps      : false,
    
    // Pour afficher/masquer le panneau des options
    toggle:function(){
      $('div#map_options_panneau')[this.panneau_visible ? "hide" : "show"]() ;
      this.panneau_visible = !this.panneau_visible ;
    },
    // Pour cocher/décocher tous les types d'objets
    check_all_types:function(){
      var cocher = ! $('div#map_options_cb_all_types input[type="checkbox"]').eq(0).is(':checked') ;
      $('div#map_options_cb_all_types input[type="checkbox"]').map(function(i,o){
        o.checked = cocher ;
        $.proxy(Map.toggle_type, Map)(o) ;
      });
    },
    
    // Pour mettre (ou démettre) en exergue les objets liés à
    // l'objet sélectionné
    set_exergue_liens_objets:function(oui){
      this.exergue_liens_objets = oui ;
    },
    // Pour suivre les temps
    // Si l'option est activée, tous les temps des objets seront affichés et la souris
    // sera "suivie".
    set_indiquer_temps:function(oui){
      this.indiquer_temps = oui ;
    }
  }
}