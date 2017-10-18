
// ---------------------------------------------------------------------
// Classe d'une zone de la SupTimeline
ZoneSTL = function(data){
  this.id = SupTimeline.next_id() ;
  this.dispatch( data ) ;
  SupTimeline.zones.push( this ) ;
}
Object.defineProperties(ZoneSTL.prototype,{
  dispatch:{value:function(data){
    if('undefined' == typeof data) return ;
    for(k in data){this[k] = data[k]}
  }},
  build:{value:function(){
    var sty = "left:"+this.left+"px;width:"+this.width+"px;"
    var div = "<div class='zone' id='zone"+this.id+"' style='"+sty+"'></div>" ;
    SupTimeline.timeline.append( div ) ;
  }},
  remove:{value:function(){$('div#suptimeline > div#zone'+this.id).remove()}}
})
// Les propriétés dynamiques de ZoneSTL
Object.defineProperties(ZoneSTL.prototype,{
  start_at  :{get:function(){return this.zone[0]}},
  end_at    :{get:function(){return this.zone[1]}},
  duree     :{get:function(){return this.end_at - this.start_at}},
  left      :{get:function(){return Math.round(this.start_at * SupTimeline.coef)}},
  width     :{get:function(){
    var w = Math.round(this.duree * SupTimeline.coef) ;
    return (w < 4) ? 4 : w ; 
  }}
})