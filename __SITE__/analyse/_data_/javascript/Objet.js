window.Objet = {
  
  scan_paragraphes_ok: false, 
  
  /** Hash consignant au fur et à mesure des clicks sur les boutons
    * "Voir les citations" les objets en relation avec l'objet courant.
    *
    * Structure
    * ---------
    *   clé     : l'identifiant de l'objet (<film id>-<short type>-<index>)
    *   valeur  : un hash contenant :
    *                 clé     : Type des objets
    *                 valeur  : Liste des indexes des objets du type
    *
    */
  objets_of_objet: {},
  
  // Retourne l'identifiant DOM de l'objet de type +o_type+ et d'index +o_id+
  dom_id:function(o_type, o_id){return FILM_ID + '-' + o_type + '-' + o_id },
  
  // Retourne un hash {type, index, film} de l'objet de DOM Element +obj_dom+
  // Retourne toutes ces valeurs à null si obj_dom est null ou n'existe pas
  // dans le document (pour simplifier d'autres méthodes)
  type_and_index_of:function(obj_dom){
    if('undefined' == typeof obj_dom || obj_dom == null || $(obj_dom).length == 0){
      return {type: null, index: null, film: null, id: null} ;
    } 
    var did = $(obj_dom).attr('id').split('-') ;
    return {film: did[0], type: did[1], index: did[2], id: $(obj_dom).attr('id')}
  },
  
  // Retourne l'identifiant jQuery de l'objet
  jid:function(o_type, o_id){ return 'div#' + this.dom_id( o_type, o_id ) },
  
  // Retourne le nom humain du type o_type
  // TYPE_TO_NAME: <défini de façon dynamique d'après FilmObjet::TYPES
  type_to_name:function(o_type, pluriel){
    var d = this.TYPE_TO_NAME[o_type] ;
    if('undefined' == typeof d){
      if(console) console.error("Le type " + o_type + " doit définir son nom !");
      return o_type.toUpperCase() ;
    }else{
      if(pluriel){
        return d[1] || (d[0] + "s")
      } else {
        return d[0]
      }
    }
  },
  /** = Main =
    *
    * Méthode principale appelée quand on clique sur un bouton "Voir les citations"
    *
    * Notes
    * -----
    *   * Les citations dans le synopsis est une forme de citation particulière.
    */
  show_citations:function(ev){
    var btn   = $(ev.currentTarget) ;
    var o_ref = btn.attr('ref').split(':') ;
    var o_domid = this.dom_id( o_ref[0], o_ref[1] ) ;
    var fs_citations = $('div#' + o_domid).find('fieldset#' + o_domid + '-citations') ;

    if( fs_citations.length ){
      //Il faut simplement le toggler
      this.toggle_citations(btn, fs_citations) ;
    } else {
      // Il faut le construire
      this.peuple_all_citations_of( o_domid ) ;
      btn.html("Masquer les citations") ;
    }
  },
  toggle_citations:function(btn, fs_citations){
    var is_visible = fs_citations.is(':visible') ;
    btn.html(is_visible ? "Citations et relations" : "Masquer les citations") ;
    fs_citations.toggle() ;
  },
  // Quand le bouton "Voir les citations" est cliqué, et que le  listing des
  // paragraphes de l'objet n'est pas encore établi, cette méthode construit la
  // liste des citations dans les paragraphes.
  peuple_all_citations_of:function(o_domid){
    var my = this, 
        clone,
        fs_citations = my.build_fieldset_citations_for( o_domid ),
        citations = my.get_references_citations_paragraphe(o_domid) ;
    if( citations == null ){
      fs_citations.append("<div>Aucune citation pour cet élément.</div>") ;
    }else{
      // Afficher tous les objets en relation avec l'objet
      // @note : les paragraphes seront traités à part (cf. plus bas)
      var paragraphes = null ;
      $.map( citations, function( objs_ids, o_type ){
        if(o_type == 'pa'){
          paragraphes = objs_ids
        } else {
          fs_citations.append("<div class='titreobj'>"+my.type_to_name(o_type, true)+"</div>") ;
          $.map(objs_ids, function( o_index, iobj ){
            clone = my.get_clone_of(o_type, o_index) ;
            fs_citations.append( clone ) ;
            clone.addClass(o_type) ; // pour gestion particulière de l'affichage
          })
        }
      }) ;
      if( paragraphes ){
        // Cf. NOTE #0002
        var o_type = 'pa', p_data, balise_owner ;
        var data_paragraphes = {
          synopsis: [],
          resumes : [], // ne seront pas écrites (déjà indiqué)
          others  : {}
        } ;
        // On relève les données de tous les paragraphes en les rangeant par
        // type d'objet
        $.map(paragraphes, function(p_index){
          p_data = Paragraphs.seek_owner_and_prop_of( p_index ) ;
          if (p_data.owner_type == 'sc' && p_data.prop == "Synopsis"){
            data_paragraphes.synopsis.push( p_data ) 
          } else if (p_data.owner_type == 'sc' && p_data.prop == "Résumé"){
            data_paragraphes.resumes.push( p_data ) 
          } else {
            if('undefined' == typeof data_paragraphes.others[p_data.owner_type]){
              data_paragraphes.others[p_data.owner_type] = []
            }
            data_paragraphes.others[p_data.owner_type].push( p_data )
          }
        })
        // On clone les paragraphes dans les fieldset des citations, en ajoutant
        // la marque du propriétaire (owner_tag)
        
        // === Paragraphes du synopsis citant l'objet ===
        Paragraphs.insert_citations( data_paragraphes.synopsis, {
          container: fs_citations,
          for_titre: "le synopsis"
        }) ;
        // Note : data_paragraphes.resumes n'est pas utilisé puisque le résumé
        // des scènes apparait déjà dans la liste des scènes auxquelles appartient
        // l'objet.
        $.map(data_paragraphes.others, function(arr_data, o_type){
          Paragraphs.insert_citations( arr_data, {
            container: fs_citations,
            for_titre: "les " + my.type_to_name(o_type, pluriel = true)
          })
        })
      }
      UI.observe_all_in( fs_citations ) ;
    }
  },
  // Retourne le clone des infos minimales ou du paragraphe de l'objet
  // identifié par +o_type+ et +o_index+
  // @param o_type      {String} Type de l'objet à cloner
  // @param o_index     {String} Index de l'objet à cloner
  // @param owner_tag   {String} La balise du propriétaire (if any - seulement calculé
  //                    avant par les paragraphes)
  get_clone_of:function(o_type, o_index, owner_tag){
    var my = this, 
        clone ;
    if( o_type != 'pa'){
      return $(my.jid(o_type, o_index)).eq(0).find('> .ifm').clone() ;
    } else {
      clone = Paragraphs.get(o_index).clone() ;
      clone.addClass('ifm') ;
      if(clone.find('div.owner').length == 0 && ! owner_tag){
        owner_tag = Paragraphs.balise_owner_and_prop_for( o_index ) ;
      }
      if(owner_tag) clone.append(owner_tag) ;
      return clone ;
    }
  },
  // On place le fieldset sous le bouton tous les paragraphes faisant référence à l'objet
  build_fieldset_citations_for:function( o_domid ){
    $('div#'+o_domid).append("<fieldset id='"+o_domid+"-citations' class='citations'><legend>Citations & relations</legend></fieldset>") ;
    return $('div#'+o_domid).find('fieldset#'+o_domid+'-citations') ;
  },
  
  // Méthode qui relève les citations (objs) de l'objet d'identifiant
  // +o_domid+ ('<film id>-<type court>-<index>)
  // Retourne un Hash qui contient en clé le type d'objet et en valeur la
  // liste des identifiants
  get_references_citations_paragraphe:function(o_domid){
    if ('undefined' == typeof this.objets_of_objet[o_domid]){
      var citations = $('div#'+o_domid).attr('objs') ;
      if(!citations || citations == "") this.objets_of_objet[o_domid] = null ;
      else{
        this.objets_of_objet[o_domid] = this.objs_string_to_hash( citations ) ;
      }
    }
    return this.objets_of_objet[o_domid] ;
  },
  objs_string_to_hash:function(str){
    var my = this,
        h = {} ;
    try {
      $.map( str.split(my.DELIMITER_OBJS_TAG), function( ref_objs, i){
        if(ref_objs.trim() == "") return ;
        ref_objs = ref_objs.split( ':' ) ;
        h[ref_objs[0]] = ref_objs[1].split(',') ;
      }) ;
    } catch (erreur) {
      if(console){
        console.error("Problème avec la chaine “"+str+"” dans Objet.objs_string_to_hash : " + erreur);
      }
      F.error("Problème avec la chaine `"+str+"' : " + erreur);
    } finally {
      return h ;
    }
  },
  
  // Observer le clone qui a été placé dans le fieldset des citations
  observe:function(clone){
    UI.observe_all_in( clone ) ; // Attention : Méthode UI (qui appelle celle ci-dessous)
  },
  
  // Méthode au ready permettant d'observer tous les objets
  // Cette méthode 
  observe_all_in:function(container){
    if(!container) container = $('body') ;
    this.observe_boutons_citations_in( container ) ;
    this.observe_liens_textmate_in( container ) ;
    this.observe_objets_with_oid_in( container ) ;
  },
  observe_boutons_citations_in:function(container){
    container.find('a.citations').bind('click', $.proxy(Objet, 'show_citations'));
  },
  observe_liens_textmate_in:function(container){
    // Tous les boutons pour éditer les objets dans TextMate (if any)
    // Note : l'option d'output des liens textmate doit avoir été activée
    container.find('img.tmlk').each(function(iel){
      var img = $(this) ;
      var dlk = img.attr('dlk').split(':') ;
      var file_id = dlk[0] ; // "film", "persos", "brins"
      var file_line = dlk[1] ;
      var href = "txmt://open/?url=file://" + FILM_AFFIXE_PATH + '.' + file_id ;
      if(file_line == "") file_line = "1"
      href += "&line=" + file_line + "&column=1" ;
      img.bind('click', function(){document.location.href = href}) ;
    });
  },
  observe_objets_with_oid_in:function(container){
    container.find('*[oid][class!="btnclose"]').bind('click', $.proxy(Fiches, 'toggle'));
  }
  
}