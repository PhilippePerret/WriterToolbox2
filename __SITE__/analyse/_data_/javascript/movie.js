/**
  * Code javascript permet de gérer le film
  *
  * Code de base pour faire jouer à un temps donné :
  *   Movie.start_at(<le temps en secondes>)
  */
window.Movie = {
  time: null,
  is_visible:false,
  start_at:function(time){
    this.time = time ;
    var delay = 0 ;
    if(this.is_visible){
      this.timer = null ;
      this.delay_start_at() ;
    }else{
      this.show();
      this.timer = setTimeout($.proxy(this.delay_start_at, this), 2 * 1000)
    }
  },
  delay_start_at:function(){
    if(this.timer) clearTimeout(this.timer) ;
    this.set_time( ( this.time * 1000 ) + MOVIE_TIME_OFFSET );
    this.start();
  },
  start:function(){
    document.movie.Play();
  },
  stop:function(){
    document.movie.Stop();
  },
  set_time:function(time){
    document.movie.SetTime(time);
  },
  get_time:function(time){
    return document.movie.GetTime();
  },
  // Affiche le film
  show:function(){
    $('div#div_movie').show();
    this.is_visible = true ;
  },
  hide:function(){
    $('div#div_movie').hide();
    this.is_visible = false ;
  },
  // Return true si le film existe dans la page (div#div_movie)
  exists:function(){
    return $('div#div_movie').length > 0 ;
  }
}