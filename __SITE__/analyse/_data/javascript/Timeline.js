// Le raccourci `TL' existe pour Timeline
// Noter qu'il s'agit de la Timeline des scènes, pas de la Timeline supérieure
window.Timeline = {
  current_scene: null,

  show_scenes:function(arr_scenes){
    F.show("Désolé, l'affichage des scènes n'est pas encore pris en charge dans cette nouvelle version de l'application.")
  },

  on_select:function(ev){
    var odom = $(ev.currentTarget);
    if(this.current_scene){
      this.current_scene.toggleClass('selected');
      if(this.current_scene.attr('id') == odom.attr('id')){
        // Déselection
        this.current_scene = null ;
        return ;
      } else {
        Fiches.hide({currentTarget:this.current_scene}) ;
      }
    }
    Keypress.current = Timeline ;
    this.current_scene = odom ;
    this.current_scene.toggleClass('selected') ;
    Fiches.show({currentTarget:this.current_scene}) ;
    if(Movie.exists()) Movie.start_at(parseInt(odom.attr('sid')) - 2) ;
  },
  on_left_arrow:function(ev){
    var acote = this.current_scene.prev();
    while( acote.length ){
      if (acote.hasClass('sc')){ this.on_select( {currentTarget:acote} ); break ;}
      acote = acote.prev() ;
    }
  },
  on_right_arrow:function(ev){
    var acote = this.current_scene.next() ;
    while( acote.length ){
      if (acote.hasClass('sc')){ this.on_select( {currentTarget:acote} ); break ;}
      acote = acote.next() ;
    }
  },

  coef_t2p:function(){
    if('undefined' == typeof this._coef_t2p){
      var timeline_width = $('div.timeline_scenes div.timeline').width() ;
      this._coef_t2p = timeline_width / Film.duree ;
    }
    return this._coef_t2p ;
  },

  // Le voile rouge pour mettre une zone de la timeline en exergue
  red_voile:function(){
    if('undefined' == typeof this._red_voile){
      var code_red_voile = '<div id="tl_red_voile" class="red_voile"></div>' ;
      $('div.timeline_scenes div.timeline').append( code_red_voile ) ;
      this._red_voile = $('div.timeline_scenes div#tl_red_voile') ;
    }
    return this._red_voile ;
  }

}
window.TL = window.Timeline ;
