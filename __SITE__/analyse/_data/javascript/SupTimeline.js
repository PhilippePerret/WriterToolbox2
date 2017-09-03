window.SupTimeline = {
  zones     : [],       // Les zones déjà définies
  last_id   : 0,        // dernier ID attribué à une zone
  
  /** = Main =
    *
    * Affiche la ou les zones suivant les données +data+
    *
    * @param data   Peut être :
    *           - Un array [start, end]
    *           - Un Hash définissant au moins {zone:[start,end], ...}
    * @param  options   Peut définir :
    *           :keep     Si true, les zones sont "fusionnés"
    */
  // Main méthode pour afficher une zone (ou un ensemble de zones)
  show:function(data, options){
    var my = this, z ;
    if('undefined' == typeof options) options = {} ;
    if(Foo.is_array(data)){
      // Quand les data se limitent à un array, c'est la zone à montrer ([start,end])
      data = { zone: data } ;
    } else if (Foo.is_object(data)) {
      // Data peut rester tel quel
    }
    if( options.keep ) data = this.merge_with( data ) ;
    
    // On construit finalement la zone
    this.reset();
    z = new ZoneSTL( data ) ;
    z.build() ;
    this.show_zone_fieldienne_if_needed(z.zone) ;
    return z ;
  },
  
  // Détruit la zone +zone+ ({ZoneSTL})
  remove:function(zone){
    zone.remove() ;
    this.zones[zone.id - 1] = null;
    delete zone ;
  },
  
  // Merge la zone courante avec la zone de données +data+
  merge_with:function( data ){
    var liste_temps = [] ;
    for(var i = 0, len = this.zones.length; i < len ; ++i){
      liste_temps.push(this.zones[i].start_at) ;
      liste_temps.push(this.zones[i].end_at) ;
    }
    liste_temps.push(data.zone[0]) ;
    liste_temps.push(data.zone[1]) ;
    liste_temps.sort() ;
    data.zone = [liste_temps[0], liste_temps[liste_temps.length-1]] ;
    return data ;
  },
  // Vide complètement la SupTimeline
  reset:function(){
    this.timeline.html('')
    this.last_id  = 0 ;
    this.zones    = [] ;
  },
  
  // Affiche la zone fieldienne si nécessaire
  // @param zone  La zone pour laquelle on teste la zonne fieldienne
  show_zone_fieldienne_if_needed:function(zone){
    var key_zone = this.zone_fieldienne(zone) ;
    if(key_zone == null) return ;
    this.build_zone_fieldienne( key_zone ) ;
  },
  
  // Affiche la zone fieldienne
  build_zone_fieldienne:function(key_zone){
    var data_zone   = this.zones_fieldiennes[key_zone],
        zone_field  = data_zone.zone,
        sta_fld     = zone_field[0],
        end_fld     = zone_field[1],
        duree_fld   = end_fld - sta_fld,
        left_fld    = Math.round(sta_fld * this.coef),
        width_fld   = Math.round(duree_fld * this.coef) ;
    var sty = "left:"+left_fld+"px;width:"+width_fld+"px;" ;
    this.timeline.prepend("<div class='zone_field' style='"+sty+"'><span>Zone "+data_zone.name+"</span></div>");
  }
}
Object.defineProperties(window.SupTimeline, {
  
  // Retourne la zone fieldienne pour la zone +zone+ si elle existe
  // (le retour est un [start, end])
  zone_fieldienne:{value:function(zone){
    var sta_at = zone[0] ;
    var end_at = zone[1] ;
    for(var key_zone in this.zones_fieldiennes){
      var zone_field = this.zones_fieldiennes[key_zone].zone ;
      var sta_fld = zone_field[0] ;
      var end_fld = zone_field[1] ;
      if (sta_at < end_fld && end_at > sta_fld) return key_zone ;
      else if (end_at < end_fld) return null ;
    }
    return null ;
  }},
  zones_fieldiennes:{get:function(){
    if('undefined' == typeof this._zones_fieldiennes){
      var quart3 = 3 * this.quart ;
      this._zones_fieldiennes = {
        pivot1  : {zone: [this.quart - this.douzieme, this.quart + this.douzieme], name: "Pivot 1"},
        cdv     : {zone: [this.moitie - this.douzieme, this.moitie + this.douzieme], name:"Clé de voûte"},
        pivot2  : {zone: [quart3 - this.douzieme, quart3 + this.douzieme], name:"Pivot 2"},
        climax  : {zone: [FILM_DUREE - this.douzieme, FILM_DUREE], name: "Climax"}
      }
    }
    return this._zones_fieldiennes ;
  }},
  // <time> * this.coef = nombre de pixels
  coef:{
    get:function(){
      if('undefined' == typeof this._coef){
        this._coef = this.width / FILM_DUREE ;
      }
      return this._coef
    }
  },
  
  next_id:{value:function(){return ++this.last_id ;}},
  
  // Return l'objet jQuery de la timeline
  timeline:{
    get:function(){ return $('div#suptimeline')}
  },
  // Largeur de la suptimeline
  width:{
    get:function(){ return this.timeline.width() }
  },
  
  // Douzieme du film
  douzieme:{get:function(){
    if('undefined' == typeof this._douzieme) this._douzieme = Math.round(FILM_DUREE/12);
    return this._douzieme ;
  }},
  // Quart temps
  quart:{get:function(){ 
    if('undefined' == typeof this._quart) this._quart = Math.round(FILM_DUREE / 4)
    return this._quart ;
  }},
  // Quart temps
  moitie:{get:function(){ 
    if('undefined' == typeof this._moitie) this._moitie = Math.round(FILM_DUREE / 2)
    return this._moitie ;
  }}
  
})
