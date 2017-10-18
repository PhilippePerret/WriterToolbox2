window.Scene = function(id){
  this.id    = id ; // = Le dom-id du list-item de la scène
  this.obj   = $('div#' + id) ; // le list-item
}
Object.defineProperties(window.Scene.prototype,{
  film_id:{
    get:function(){
      if('undefined' == typeof this._film_id){
        this._film_id = this.obj.attr('fid')
      }
      return this._film_id;
    }
  },
  scene_id:{
    get:function(){
      if('undefined' == typeof this._scene_id){
        this._scene_id = this.obj.attr('sid')
      }
      return this._scene_id;
    }
  },
  
})