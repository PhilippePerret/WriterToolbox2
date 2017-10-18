/**
  * Objet Synopsis
  * --------------
  * Permet de gérer les "citations" des objets dans les paragraphes du
  * synopsis complet
  *
  */
window.Synopsis = {
  paragraphes: {}, // Les paragraphes déjà traités
  
  // Re-montre tous les paragraphes et remet le synopsis à sa place
  reset:function(){
    this.remove_all_ellipsis();
    if($(this.jid_panneau + ' > ' + this.jid_synopsis).length == 0){
      this.obj_panneau.append(this.obj_synopsis) ;
    }
    this.obj_synopsis.find(' div.par').show();
    this.obj_synopsis.find(' > h3').html('Synopsis complet') ;
  },
  
  // Méthode d'évènement (répond au click sur le bouton pour voir les citations de
  // l'objet)
  show:function( ev ){
    var odom = $(ev.currentTarget) ;
    var refs = odom.attr('ref').split(':') ;
    this.nombre_paragraphes_found = 0 ;
    this.show_paragraphes_of( refs[0], refs[1]) ;
    // On met un message si aucun paragraphe n'a été trouvé
  },
  
  // On a placé des "…" dans les textes manquant, il faut les supprimer avant
  // chaque opération.
  remove_all_ellipsis:function(){
    this.obj_synopsis.find('div.par.ellipsis').remove() ;
  },
  // Montre les paragraphes qui contiennent l'objet de type +otype+ et d'identifiant
  // +oid+
  show_paragraphes_of:function(otype, oid){
    var my = this, objets ;
    // On place le synopsis juste avant l'item et on change son titre
    this.remove_all_ellipsis() ;
    this.obj_synopsis.find(' > h3').html('Citations dans le synopsis complet') ;
    this.obj_synopsis.insertBefore($('div#' + FILM_ID + '-' + otype + '-' + oid)).show() ;
    var last_is_ellipsis = false ;
    
    // Boucle sur chaque div de scène
    this.obj_synopsis.find('div.syn').each(function(){
      nombre_paragraphes_scene = 0 ;
      // Boucle sur chaque paragraphe de scène
      $(this).find('div.par').each(function(){
        objets = my.objets_of( $(this) );
        if('undefined' == typeof objets[otype] || objets[otype].indexOf(oid) < 0){
          $(this).hide() ;
          if( ! last_is_ellipsis ) $("<div class='par ellipsis'>…</div>").insertBefore( $(this) ) ;
          last_is_ellipsis = true ;
        } 
        else{
          ++ nombre_paragraphes_scene ;
          $(this).show() ;
          last_is_ellipsis = false ;
        }
      }) // fin de boucle sur les paragraphes de la scène
      if(nombre_paragraphes_scene > 0){ 
        $(this).find('div.owner').show(); 
        my.nombre_paragraphes_found += nombre_paragraphes_scene ;
      }
    })
  },
  
  // Retourne les objets du paragraphe d'identifiant +par_id+
  // @param par_id    Soit l'index du paragraphe - p.e. : `4'
  //                  Soit l'identifiant DOM du parapgrah - p.e. `f1-pa-12'
  //                  Soit l'objet DOM jquery du paragraphe
  objets_of:function(par_id){
    switch(typeof par_id)
    {
    case 'number' : domid = FILM_ID + "-pa-" + par_id ; break ;
    case 'string' : domid = ""+par_id ; par_id = null ; break ;
    default : domid = $(par_id).attr('id') ; par_id = null ; break ;
    }
    if(par_id == null) par_id = domid.split('-')[2] ;
    if('undefined' == typeof this.paragraphes[par_id]){
      // Il faut lire ses objets
      var opara = this.obj_synopsis.find('div#'+domid) ;
      if(!opara){
        var err = "[Synopsis.objets_of] Paragraphe " + domid + " introuvable…" ;
        if(console) console.error(err); F.error(err) ;
        return {};
      }
      var objs  = opara.attr('objs') ;
      if (!objs) return {} ;
      objs = Objet.objs_string_to_hash( objs ) ;
      // if(console) console.dir(objs) ;
      this.paragraphes[par_id] = objs ;
    }
    return this.paragraphes[par_id] ;
  },
  
}
Object.defineProperties(window.Synopsis,{
  jid_panneau:{get:function(){return 'div#'+FILM_ID+"-synopsis"}},
  obj_panneau:{get:function(){return $(this.jid_panneau)}},
  jid_synopsis:{get:function(){return 'div#'+FILM_ID+"-synopsis-scenes"}},
  obj_synopsis:{get:function(){return $(this.jid_synopsis)}}
})