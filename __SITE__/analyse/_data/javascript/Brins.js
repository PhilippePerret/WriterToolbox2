window.Brins = {
  
  // = Main =
  //
  // Méthode évènement appelée au click sur "Voir les scènes du brin"
  show_scenier:function(ev){
    var odom      = $(ev.currentTarget) ;
    var b_id      = odom.attr('bid') ;
    var b_dom_id  = FILM_ID + "-br-" + b_id ;
    var obrin     = $('div#' + b_dom_id) ;
    var oscenier  = obrin.find('div.scenier')
    // Il faut rendre le scénier visible (ou le masquer)
    if(oscenier.is(':visible')){
      oscenier.hide() ;
    }else{
      oscenier.show() ;
      // On doit passer par toutes les scènes du brin si nécessaire
      if(oscenier.find('> div.sc > div.ifm').length == 0){
        F.show("Merci de patienter, j'établis le scénier…") ;
        this.scenes_of_brin = oscenier.find('> div.sc') ;
        this.loop_on_scenes();
      }
    }
  }
}
Object.defineProperties(window.Brins,{
  jid_panneau:{get:function(){return 'div#'+FILM_ID+"-brins"}},
  obj_panneau:{get:function(){return $(this.jid_panneau)}},
  obj_listing:{get:function(){return this.obj_panneau.find('div.listing.brins')}}
})