/**
  * Règle tous les aspects visuels de l'interface
  *
  * Par exemple les couleurs
  */
if('undefined' == typeof window.UI) window.UI = {} ;
$.extend(window.UI, {
  COLORS:{
      current : -1, // L'indice de couleur courant (dernière utilisée)
      list    : ['dodgerblue', 'greenyellow', 'gold', 'forestgreen', 'deeppink'],
      imax    : null // # sera réglé au premier appel
  },
  
  // Méthode qui colorise tous les enfants directes du DOM ELement +container+
  // @param container   Le conteneur
  // @param tag         Les tags enfant direct du container ("div" par défaut)
  // @param options     Les options :
  //                    :color_uniq   Si true, une nouvelle couleur unique est choisie
  //                                  pour tout les enfants de container.
  colorize_children_of:function(container, tag, options){
    var me = this, couleur_suivante ;
    if('undefined' == typeof tag) tag = 'div' ;
    if('undefined' == typeof options) options = {} ;
    if(options.color_uniq) couleur_suivante = this.next_color() ;
    $(container).find(' > ' + tag).each(function(i){
      if(options.color_uniq) {
        $(this).css('background-color', couleur_suivante)
      } else {
        me.apply_next_color( $(this) )
      }
    }) ;
  },
  
  // Méthode qui applique la couleur suivante au DOM ELement +obj+
  apply_next_color:function(obj){
    $(obj).css('background-color', UI.next_color() ) ;
  },
  
  // Retourne la couleur suivante
  next_color:function(){
    if(UI.COLORS.imax == null) UI.COLORS.imax = UI.COLORS.list.length - 1 ;
    ++ UI.COLORS.current ;
    if(UI.COLORS.current > UI.COLORS.imax) UI.COLORS.current = 0 ;
    return UI.COLORS.list[UI.COLORS.current] ;
  },
  
  apply_data_dob:function(){
    $('*[dob]').each(function(index){
      var o = $(this);
      var d = UI.read_dob(o.attr('dob')) ;
      var sty = {} ;
      if(d.left)sty['left'] = d.left + "px" ;
      if(d.width)sty['width'] = d.width + "px" ;
      if(d.top)sty['top'] = d.top + "px" ;
      if(d.right)sty['right'] = d.right + "px" ;
      if(d.height)sty['height'] = d.height + "px" ;
      if(d.mleft)sty['margin-left'] = d.mleft + 'px' ;
      if(d.mtop)sty['margin-top'] = d.mtop + 'px' ;
      if(d.no_display)sty['display'] = "none" ;
      o.css(sty) ;
    })
  },
  read_dob:function(dob){
    var nodisp = false ;
    // Un point d'exclamation en début de string indique que le
    // display est none.
    if(dob.substring(0,1) == "!"){nodisp = true ; dob = dob.substring(1, dob.length)}
    dob = dob.split(':') ;
    dob = $.map(dob, function(edob, idob){ return edob == "" ? null : edob}) ;
    return {no_display: nodisp, left: dob[0], width: dob[1], top: dob[2], height:dob[3], right: dob[4], mleft: dob[5], mtop: dob[6]}
  }
});

Object.defineProperties(window.UI,{
  
})