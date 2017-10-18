$(document).ready(function(){
  
  if($('div#div_movie').length){
    $('div#div_movie').css({width:MOVIE_WIDTH+'px'})
    $('div#div_movie').draggable({
      disabled:true
    }) ;
    $('div#div_movie > div.poignee').bind('mousedown',function(){
      $('div#div_movie').draggable("enable") ;
    })
    $('div#div_movie > div.poignee').bind('mouseup',function(){
      $('div#div_movie').draggable("disable") ;
    })
  }
  
  Film.init_values();
  
  Flash.on_load_page() ; // timer éventuel sur le message affiché
  UI.set_interface() ; // place aussi tous les observers généraux
  Scenes.observe_all() ;
  DiagrammeDramatique.observe() ;
  Map.observe_all() ;

})