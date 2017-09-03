window.DiagrammeDramatique = {
  
  qd_selected:null,
  
  // Quand on sélectionne la portion
  on_select:function(ev){
    // console.log("-> Diag.on_select("+$(odom).attr('id')+")");
    var odom = $(ev.currentTarget) ;
    if(this.qd_selected){
      this.qd_selected.toggleClass('selected');
      if(this.qd_selected.attr('id') == odom.attr('id')){
        // Déselection de l'élément sélectionné
        window.Keypress.current = null ;
        this.qd_selected = null ;
        return ;
      }
    }
    window.Keypress.current = DiagrammeDramatique ;
    odom.toggleClass('selected');
    this.qd_selected = odom ;
    this.over_portion( {currentTarget:odom} ) ; // simulation du survol
  },
  on_left_arrow:function(ev){
    var acote = this.qd_selected.prev(); 
    if ( acote.length ) this.on_select( {currentTarget:acote} );
  },
  on_right_arrow:function(ev){
    var acote = this.qd_selected.next() ;
    if ( acote.length ) this.on_select( {currentTarget:acote} );
  },
  
  over_portion:function(ev){
    var obj_portion = $(ev.currentTarget) ;
    // On commence par vider l'affichage
    this.hide_all_textes_qrd() ;
    this.remove_all_red_links() ;
    // On affiche les éléments de la portion
    var data_qrds = obj_portion.attr('data');
    if('undefined' == typeof data_qrds) return ; // je ne sais pas pourquoi ça arrive
    data_qrds = data_qrds.split('-');
    // Affichage de la scène
    Fiches.show_by_id(FILM_ID+'-sc-'+data_qrds.pop()) ;
    if(data_qrds[0] == "") return ; // pas de qrds
    var next_hauteur_redlink = 110 ;
    for(var i=0, len = data_qrds.length; i<len; ++i){
      d = data_qrds[i].split('.') ;
      h = {
        qd_id:d[0], left:d[1], width:d[2], start:d[3], end:d[4], scene:d[5], 
        top:(next_hauteur_redlink -= 16)} ;
      // Afficher le texte de la Qd et de la Rd
      $('div#' + h.qd_id + "-textes").show() ;
      // Construire les red-links liant Qd et Rd
      this.conteneur_redlinks().append( this.div_redlink_with(h)  ) ;
    }
  },
  div_redlink_with:function(h){
    var style_redlink = "width:"+h.width+"px;left:"+h.left+"px;top:"+h.top+"px" ;
    var style_horloge = (h.width > 160) ? 'in' : 'out'
    // Code retourné
    return "<div class='redlink_qdrd' style='"+style_redlink+"'>"+
          "<span class='hlg start "+style_horloge+"'>"+h.start+"</span>" +
          "<span class='hlg end "+style_horloge+"'>"+h.end+"</span>" +
          "</div>" ;
  },
  conteneur_redlinks:function(){ return $('div#diagdrama_conteneur_redlinks') },
  conteneur_textes:function(){ return $('div#diagdrama_conteneur_textes') },
  hide_all_textes_qrd:function(){
    this.conteneur_textes().find('> div').hide() ;
  },
  remove_all_red_links:function(){
    this.conteneur_redlinks().find('*').remove() ;
  },
  
  observe:function(){
    $('div.diagramme_dramatique div.bqrd').bind('mouseover', $.proxy(Diag, 'over_portion'))
    $('div.diagramme_dramatique div.bqrd').bind('click', $.proxy(Diag, 'on_select'))
  }
}
// Raccourcis
window.diagdrama = window.Diag = DiagrammeDramatique ;