window.Scenodico = {
  // "aor" pour "add or remove", car si le mot n'existe pas
  // on l'ajoute mais s'il existe on le retire.
  aor_mot(type,menu){
    let iselected = menu.selectedIndex;
    let option = menu.querySelectorAll('option')[iselected];
    let mot_id  = option.getAttribute('value');
    let mot_mot = option.getAttribute('data'); 
    let lien = "<a id=\""+type+"-"+mot_id+"\" href=\"#\" onclick=\"Scenodico.remove('"+type+"',"+mot_id+")\">"+mot_mot+'</a>';
    DOM('mots_'+type).insertAdjacentHTML('beforeend', lien);
        // TODO Ajouter à hidden des values du type
  },
  remove(type,mot_id){
    // TODO Supprimer dans hidden des values du type
    DOM('a#'+type+'-'+mot_id).style.display = 'none';
  }
}
