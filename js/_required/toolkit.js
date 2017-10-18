/**
  *
  * Tout un tas de fonctions utiles, mais limitées à celles que j'utilise
***/

// Pour afficher un message d'erreur
function __error(mess){Flash.error(mess)}
// Affiche un message notice
function __notice(mess){Flash.notice(mess)}

function DOM(id){
  return document.getElementById(id);
}
// ---------------------------------------------------------------------
window.UI = {
  // Usage : UI.toggle(<jid>)
  toggle: function(jid){
    let e = document.querySelector(jid);
    if(e.style.display=='none'){e.style.display=''}
    else{e.style.display='none'}
  }
}
// ---------------------------------------------------------------------
//  Private
window.Flash = {
  notice: function(mess){
    this.makeDiv('notice', mess);
  },
  error: function(mess) {
    this.makeDiv('error', mess);
  },
  lastId: 0,// pour un identifiant qui permettra de le supprimer
  makeDiv(type, mess){
    let domid = "flash-" + (this.lastId ++);
    let div = document.createElement('div');
    div.id = domid
    div.className = type;
    div.innerHTML = mess;
    this.flash().append(div);
    this._flash.style.display='block';
    let len = mess.length;
    type == 'error' && (len *= 1.5);
    this.runTimerForText(domid, len);
  },

  flash: function(){
    let f = DOM('flash');
    if(!f){f = document.createElement('div');f.id = 'flash';document.body.append(f);}
    this._flash = f;
    return f;
  },

  runTimerForText: function(id, longueur) {
    this.timers || (this.timers = {});
    var duree = longueur * 150;
    if ( duree < 5000 ) { duree = 5000 }
    this.timers[id] = setTimeout(Flash.removeDiv.bind(Flash, id),duree);
  },
  removeDiv: function(id){clearTimeout(this.timers[id]);this.clear(id)},
  clear: function(id) {DOM(id).style.display = 'none'},

  // Méthode appelée au chargement de la page quand un message est affiché. Elle
  // est différente des méthodes qui gèrent les messages en javascript comme
  // ci-dessus.
  removeAfterReading: function(){
    let len = DOM('flash').innerHTML.replace( /<(.*?)>/g,'' ).length;
    Flash.timer = setTimeout(function(){
      clearTimeout(Flash.timer);Flash.flash().style.display='none';
    }, len * 250);
  },
}
