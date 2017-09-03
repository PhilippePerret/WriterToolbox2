if('undefined' == typeof window.UI) window.UI = {} ;
$.extend(window.UI, {
  toggle:function(id){
    $('div#'+id).toggle();
  },
  
  // Pour tout élément repliable/dépliable qui fonctionne avec
  // les classes 'collapsed' et 'expanded'
  toggle_collapsed:function(ev){
    var odom = $(ev.currentTarget);
    odom.toggleClass('collapsed') ;
    odom.toggleClass('expanded') ;
  },
  
  
  // Affiche/Masque un onglet principal
  toggle_onglet:function(id) {
    var panneau = $('div#'+id) ;
    var onglet  = $('a#onglet-'+id) ;
    if(onglet.hasClass('actif')){
      panneau.hide();
      onglet.removeClass('actif');
    }else{
      panneau.show();
      onglet.addClass('actif');
      window.location = "#" + id ;
      $(window).scrollTop($(window).scrollTop() - 200);
      switch(id){
      case FILM_ID + '-scenes-sorted_by_duree':
        Scenes.build_sorted_by_duration() ; // ne le fait qu'une fois
        break ;
      case FILM_ID + '-synopsis' :
        Synopsis.reset() ;
        break
      }
    }
  },
  
  on_click_horloge:function(ev){
    var hdom = $(ev.currentTarget) ;
    var time = Time.h2s( hdom.html() ) ;
    SupTimeline.show([time, time + 10], {keep: ev.shiftKey}) ;
    ev.stopImmediatePropagation();
    ev.stopPropagation();
    ev.preventDefault();
    UI.clear_selection() ; // Car arrêter l'évènement ne fonctionne pas
    return false;
  },
  
  set_interface:function(){
    this.set_body_header() ;
    this.observe_all_in() ;
    // Appliquer les données (left, width, etc.) définies par l'attribut `dob'
    this.apply_data_dob() ;
    // Colorisation des scènes de la timeline
    this.colorize_children_of($('div.timeline_scenes > div.timeline'), 'div.sc');
    // Colorisation des scènes de la Map
    this.colorize_children_of($('div.film_map > div.filmmap_map'), 'div.map_sc');
    // Colorisation des blocs de brins
    $('div.film_map > div.filmmap_map > div.map_br').each(function(index){
      UI.colorize_children_of($(this), 'div.obr', {color_uniq: true})
    })
  },
  
  
  // Règle la bande supérieure
  set_body_header:function(){
    var honglets
    var suptl   = $('div#body_header > div#suptimeline') ;
    var hsuptl  = suptl.height() + parseInt(suptl.css('bottom')) ;
    var onglets = $('div#body_header > div#onglets') ;
    var honglets = onglets.height() + parseInt(onglets.css('padding-top')) + parseInt(onglets.css('padding-bottom'));
    var h_header = hsuptl + honglets ;
    $('div#body_header').height( h_header ) ;
    $('div#body_content').css('margin-top', h_header + "px") ;
  },
  
  observe_all_in:function( container ){
    if(!container) container = $('body') ;
    this.observe_collapsed_in( container ) ;
    this.observe_horloges_in( container ) ;
    Objet.observe_all_in( container ) ;
  },
  observe_collapsed_in:function(container){
    // Tous les éléments dont la classe est 'collapsed' doivent pouvoir
    // être ouverts
    container.find('div.collapsed').bind('click', $.proxy(UI, 'toggle_collapsed'))
  },
  observe_horloges_in:function(container){
    container.find('span.hlg').bind('click', $.proxy(UI, 'on_click_horloge'))
  },
  

  //---------------------------------------------------------------------
  //  Méthodes utilitaires
  //---------------------------------------------------------------------

  // Pour supprimer toute sélection
  clear_selection:function(){
    if (window.getSelection) {
       if (window.getSelection().empty) {  // Chrome
         window.getSelection().empty();
       } else if (window.getSelection().removeAllRanges) {  // Firefox
         window.getSelection().removeAllRanges();
       }
    } else if (document.selection) {  // IE
      document.selection.empty();
    }
  }
})