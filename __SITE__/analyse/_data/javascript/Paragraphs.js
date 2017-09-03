/**
  * Objet Paragraphs
  * ----------------
  * Gestion des paragraphes
  *
  */
window.Paragraphs = {
  /**
    * Pour consigner les données des paragraphes. En clé l'index du paragraphe
    * (p.e. "f1-pa-12") et en donnée un Hash définissant :
    *   film            {String} Identifiant du film (le plus souvent: "f1")
    *   paragraph_index {String} Index du paragraphe (= clé)
    *   paragraph_id    {String} DOM Id du paragraphe (p.e. "f1-pa-12")
    *   owner           jQuery Set du propriétaire
    *   owner_id        {String} Id du DOM Element
    *   owner_type      {String} Type court du propriétaire (p.e. "sc")
    *   owner_index     {String} Index du propriétaire
    *   prop            {String} Propriété du paragraphe (if any)
    *   surowner        {jQuery Set} Propriétaire du propriétaire
    *   surowner_id     {String} Id du DOM Element
    *   surowner_type   {String} Type court du sur-propriétaire
    *   surowner_index  {String} Index du sur-propriétaire
    */
  data: {},
  
  /** Insert dans +params.container+ les paragraphes définis par +arr_data+
    *
    * @param arr_data {Array} de données telles que renvoyées par la méthode
    *                 `owner_and_prop_of'.
    *                 Note : peut être vide ou indéfini.
    * @param params   {Hash} définissant les clés :
    *                   container : le fieldset contenant les citations, en général
    *                   for_titre : Si définit, un titre sera ajouté, donnant :
    *                               "Citations dans <for_titre>"
    *                   show_count: Si true (par défaut), indique le nombre de citations
    */
  insert_citations:function(arr_data, params){
    var my = this, 
        owner_tag,
        clone,
        nb_citations ;
    if('undefined' == typeof arr_data || null == arr_data || (nb_citations = arr_data.length) == 0) return ;
    if(params.for_titre){
      params.container.append("<div class='titreobj'>Citations dans "+params.for_titre+"</div>")
    }
    if(params.show_count !== false){ // Indication du nombre de citations
      params.container.append(
        "<div style='text-align:right;font-style:italic;'>" +
        nb_citations + " citation" + (nb_citations > 1 ? "s" : "") + "</div>"
      );
    }
    $.map(arr_data, function(p_data){
      params.container.append( Objet.get_clone_of('pa', p_data.paragraph_index) ) ;
    });
  },
  /** Retourne la balise à insérer après le paragraphe, indiquant son propriétaire
    * et permettant d'afficher sa fiche.
    * @param onp  SOIT {Number} Index du paragraphe
    *             SOIT {Hash} définissant les données telles que retournées par la
    *                  méthode `owner_and_prop_of'
    */
  balise_owner_and_prop_for:function(onp){
    if('object' != typeof onp) onp = this.owner_and_prop_of(onp /* index de paragraph */) ;
    if (onp == null ) return null ;
    var tag = '<div class="owner"> (<lkfi oid="' + onp.owner_id + '">' ;
    if( onp.prop) tag += onp.prop.toLowerCase() + " de " ; 
    tag += Objet.TYPE_TO_NAME[onp.owner_type][0].toLowerCase() + " ";
    if(onp.owner_type != 'sc') tag += "#" ;
    tag += onp.owner_index ;
    tag += '</lkfi>' ;
    if(onp.surowner){
      // Cas du sur-propriétaire (par exemple Fondamentales : le groupe principal)
      tag += " dans " + '<lkfi oid="'+onp.surowner_id+'">' ;
      tag += Objet.TYPE_TO_NAME[onp.surowner.type][0].toLowerCase() + " #" + onp.surowner_index ;
      tag +='</lkfi>' ;
    }
    tag += ")</div>" ;
    return tag ;
  },
  /** Retourne le propriétaire et la propriété du paragraphe d'index +p_index+
    * Note : Pour les fondamentales, retourne aussi le "sur-propriétaire", c'est
    * à dire le groupe de fondamentales
    */
  owner_and_prop_of:function(p_index){
    if('undefined' == typeof this.data[p_index]){
      this.data[p_index] = this.seek_owner_and_prop_of(p_index) ;
    }
    return this.data[p_index] ;
  },
  
  // Retourne l'élément DOM du paragraphe d'index +index+
  get:function( p_index ){
    return  $('div#'+FILM_ID+'-pa-' + p_index).eq(0) ;
  },
  // Retourne le DOMElement (jQuery) de la scène du paragraphe d'index +index+
  get_scene_of:function( index ){
    return this.scene_obj_of( this.get( index ) ) ;
  },
  // retourne la balise owner de la scène du paragraphe d'index +index+
  get_balise_owner_of:function( index, as_clone ){
    var scene_obj = this.get_scene_of(index) ;
    if(scene_obj == null){
      return null ; // erreur a été signalée avant
    }
    var owner_tag = scene_obj.find('> div.owner') ;
    if(as_clone) return owner_tag.clone();
    else return owner_tag ;
  },
  // Retourne le dom-obj de la scène contenant le paragraphe dans le synopsis
  // ou dans la scène par un de ses éléments dom quelconque +inner+
  scene_obj_of:function( inner ){
    if(inner == null) return null ;
    inner = $(inner) ;
    var inner_init = $(inner) ;
    var iloop = 0 ;
    do {
      inner = inner.parent() ;
      ++ iloop ;
      if(iloop > 20){
        if(console) console.error("Impossible de trouver la scène du synopsis de "+inner_init.attr('id'));
        return null ;
      }
    } while( ! (inner.hasClass('syn') || inner.hasClass('lit')) ) ;
    return inner ;
  },
  
  // Pour trouver le owner de façon complexe, car parfois (paragraphes synopsis), il
  // est indiqué de façon explicite dans une balise .owner, d'autre fois, il n'est pas
  // indiqué
  // Par exemple, pour la fonction de la scène, il faut remontrer les parents du paragraphe,
  // trouver une balise .fct (qui indique que c'est une fonction) puis remonter encore pour
  // trouver la scène dont c'est la fonction.
  // NOTE: Mais ça devient très compliqué, juste pour ne pas créer de balise .owner…
  //
  seek_owner_and_prop_of:function( p_index ){
    // ownt -> le nom humain
    var my = this,
        class_list = [], // liste des class css qui seront rencontrées
        p_id = FILM_ID + '-pa-' + p_index,
        dom = my.get( p_index ),
        prop_name     = null,
        obj_owner     = null,
        obj_surowner  = null ;
    // Trouver la propriété d'objet auquel appartient le paragraph
    while(dom.parent().length) {
      dom = dom.parent() ;
      class_list.push( dom[0].className ) ; // pour débug
      if(dom.hasClass('syn')) {
        obj_owner = my.get_scene_of_paragraph( dom ) ;
        prop_name = "Synopsis" ;
      }
      else if( dom.hasClass('fct')) prop_name = "Fonction" ;
      else if (dom.hasClass('desc'))  prop_name = "Description" ;
      else if (dom.hasClass('tit'))   prop_name = "Titre" ;
      else if (dom.attr('ownt'))      prop_name = dom.attr('ownt') ;
      else if (dom.hasClass('lit') || dom.hasClass('fiche')) obj_owner = dom ;
      else continue ;
      break ; // si on a trouvé
    }
    // Trouver l'objet auquel appartient le paragraphe
    if ( obj_owner == null && dom && dom.length && dom.parent().length) {
      while( dom.parent().length ){
        dom = dom.parent() ;
        class_list.push( dom[0].className )
        if( dom.hasClass('fd') ){
          obj_owner     = dom ;
          obj_surowner  = dom.parent() ;
        }
        else if (dom.hasClass('lit') || dom.hasClass('fiche')) obj_owner = dom ;
        else continue ;
        break ; // si on a trouvé
      }
    }
    // console.log("\n* PARAGRAPHE " + p_index) ;
    if ( ! obj_owner){
      if(console) console.error("Impossible de trouver le propriétaire du paragraphe " + p_index)
      return null ;
    }
    // console.log("Liste des classes rencontrées : " + class_list.join(', ')) ;
    var downer  = Objet.type_and_index_of( obj_owner ) ;
    var dsowner = Objet.type_and_index_of( obj_surowner) ;
    if(prop_name == "Titre" && obj_owner && downer.type == 'sc') prop_name = "Résumé" ;
    return {
      paragraph_index: p_index, paragraph_id: p_id,
      film: downer.film,
      owner: obj_owner, owner_type: downer.type, owner_index: downer.index, owner_id: downer.id,
      prop: prop_name, 
      surowner: obj_surowner, surowner_type: dsowner.type, surowner_index: dsowner.index,
      surowner_id: dsowner.id
    };
  },

  // Retourne le Div de la scène contenant le paragraphe dans +obj_syn+
  get_scene_of_paragraph:function( obj_syn ){
    if( obj_syn.find('> .owner').length ){
      return $('div#' + obj_syn.find('> .owner > lkfi').attr('oid')) ;
    }
  }
}