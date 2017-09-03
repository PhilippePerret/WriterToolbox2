window.Scenes = {
  list          :{},        // Hash des instances {Scene} déjà initiées
  current       :null,      // Instance {Scene} courante

  /** Hash contenant en clé d'index de la scène et en valeurs :
    *   id:           ID dom de l'objet de la scène
    *   scene_index:  Index de la scène (= la clé)
    *   start:        Seconds de début de la scène
    *   end:          Seconds de fin de la scène
    *   duree:        Durée en secondes de la scène
    *
    * Notes
    *   * La donnée est peuplée par la méthode get_data_times
    *     => if(this.data_times == null) this.get_data_times() ;
    */
  data_times: null,


  // Retourne l'instance {Scene} de la scène d'identifiant number +id+
  scene:function(id){
    if('undefined' == typeof this.list[id]) this.list[id] = new Scene(id) ;
    return this.list[id] ;
  },

  //---------------------------------------------------------------------
  //  Classement par durée
  //---------------------------------------------------------------------
  /** = Main =
    *
    * Construit le classement par durée si nécessaire
    */
  build_sorted_by_duration:function(){
    var pan_sorted = $('div#'+FILM_ID+"-scenes-sorted_by_duree") ;
    var container_scenier = pan_sorted.find("> div.scenier") ;
    if(container_scenier.find('> div.ifm').length) return ;
    var arr_data = this.get_data_times()  ;
    arr_data.sort(function(sa, sb) sb.duree - sa.duree ) ;
    // Construire la liste des scènes classées
    this.build_scenier_with({
      list:       arr_data,
      container:  container_scenier,
      suffix:     'sbd',
      remplace_start_by_duree: true
    }) ;
    // Définir les statistiques
    this.set_statistiques_durees( arr_data ) ;
    // On finit en observant tout
    UI.observe_all_in( pan_sorted ) ;
  },
  set_statistiques_durees:function( sorted_list ){
    var dshortest = sorted_list[sorted_list.length - 1] ;
    var clone_short = $('div#'+dshortest.id).find('> div.ifm').clone() ;
    this.replace_start_by_duree_in(clone_short, this.duree_humaine(dshortest.duree) ) ;

    var dlongest  = sorted_list[0] ;
    var clone_long  = $('div#'+dlongest.id ).find('> div.ifm').clone() ;
    this.replace_start_by_duree_in(clone_long, this.duree_humaine(dlongest.duree) ) ;

    var div_stats = $('div.scenes_sorted_by_duree div.statistiques') ;
    div_stats.find("div.longest_scene > span.value").html('').append(clone_long) ;
    div_stats.find("div.shortest_scene > span.value").html('').append(clone_short) ;
  },

  // raccourci pour obtenir la durée au format humain
  duree_humaine:function(seconds){
    return Time.s2h( seconds, {hour_if_0:false, unit_hours: "h", unit_minutes:"’", unit_seconds: "”"})
  },
  // Construit un scénier à partir des la liste +arr_scenes+
  // @param data  {Hash} définissant :
  //      list  {Array} de {Hash} qui définissent au minimum `id', l'identifiant
  //            dom de la scène (p.e. "f1-sc-12")
  //      container:   {jQuery Set} Container du scénier produit
  //      suffix:      {String} Suffixe à ajouter à l'identifiant original de la scène
  build_scenier_with:function(data){
    var my = this, s_id, clone, duree_h ;
    $.map(data.list, function(hdata, iscene){
      s_id = hdata.id ;
      clone = $('div#'+s_id).find('> div.ifm').clone() ;
      clone.attr('id', s_id + '-' + data.suffix) ;
      clone.attr('oid', s_id) ; // mais supplantera tous les autres à l'intérieur…
      if(data.remplace_start_by_duree){
        // On remplace les horloges start-at par la durée de la scène
        // Utile pour le classement par durée
        duree_h = my.duree_humaine( hdata.duree ) ;
        my.replace_start_by_duree_in( clone, duree_h ) ;
      }
      data.container.append( clone ) ;
    }) ;
  },
  // Remplace dans +container+ le contenu du span.hlg.start par +duree+
  replace_start_by_duree_in:function( container, duree_h){
    var span_horloge = container.find('span.hlg.start') ;
    span_horloge.html( duree_h ) ;
    span_horloge.removeClass('start').addClass('duree') ;
  },
  // Relève les informations de start, de end et de duree de toutes les
  // scène.
  // Renseigne this.data_times
  get_data_times:function(){
    var my = this ;
    var arr_data = [] ;
    my.data_times = {} ;
    $("div#"+FILM_ID+'-scenes > div.lit').each(function(i){
      var s_obj = $(this) ;
      var data = {
        id:     s_obj.attr('id'),
        scene_index: s_obj.attr('id').split('-')[2],
        start:  parseInt(s_obj.attr('start')),
        end:    parseInt(s_obj.attr('end')),
        duree:  null
      }
      data.duree = data.end - data.start ;
      arr_data.push( data ) ;
      my.data_times[data.scene_index] = data ;
    })
    return arr_data ;
  },
  //---------------------------------------------------------------------
  toggle_data_generales:function(ev){
    var fi = $(ev.currentTarget).parent().parent() ;
    var id = $(fi).attr('sid') ;
    UI.toggle(id +"-dgene");
  },

  observe_all:function(){
    this.observe_all_scenes_timeline() ;
    this.observe_listing();
  },
  observe_all_scenes_timeline:function(){
    $('div.timeline > div.sc').bind('click', $.proxy(TL, 'on_select'));
    $('div.timeline > div.sc').bind('mouseover', $.proxy(Fiches, 'show'));
    $('div.timeline > div.sc').bind('mouseout', $.proxy(Fiches, 'hide'));
  },

  observe_listing:function(){
    $('div.listing.scenier > div.lit a.btn_dg').bind('click', $.proxy(Scenes, 'toggle_data_generales')) ;
  }

}
