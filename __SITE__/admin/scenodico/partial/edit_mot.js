window.Scenodico = {

  /**
   *  Appelée pour éditer le mot dont l'ID est spécifié
   *  dans le champ mot_id
   *
   */
  edit_mot() {
    var mid = DOM('mot_id').value;
    var lin =  "admin/scenodico/"+mid+"?op=edit_mot";
    __notice("Le lien est " + lin);
    window.location.href = lin;
    return false
  },

  /**
   * Méthode appelée lorsque l'on clique un mot dans une des
   * listes de mots (relatifs, synonymes ou contraires)
   * Permet d'ajouter ou de retirer le mot en fonction de sa
   * présence ou non. En fait, on se sert simplement de la
   * classe de l'item, qui peut être checked ou non.
   *
   * "aor" signifie "add or remove"
   *
   */
  aor_mot(menu){
    let type = menu.getAttribute('data-type');
    let iselected = menu.selectedIndex;
    let option = menu.querySelectorAll('option')[iselected];
    let mot_id  = option.getAttribute('value');
    // Ajouter à hidden des values du type
    let hidden_field = DOM('mot_'+type);
    let ids = hidden_field.value;
    if ( ids == '' ){
      ids = [];
    }else{
      ids = ids.split(' ');
    }
    // Retrait ou ajout ?
    let dec = ids.indexOf(mot_id);
    if ( dec < 0  ){
      // Le mot doit être ajouté
      ids.push(mot_id);
      option.className = 'checked';
    }else{
      // Le mot doit être retiré
      ids.splice(dec,1);
      option.className = '' ;
    }
    ids = ids.join(' ');
    hidden_field.value = ids;
    let scrollY = menu.scrollTop;
    menu.selectedIndex = -1;
    // On se repositionne après la déselection
    menu.scroll(0, scrollY);
  },

  /**
   * Méthode qui permet de n'afficher que les mots qui sont checkés
   * en changeant la classe du menu.
   * En ajoutant 'only_checked', le menu d'affiche que les mots
   * checkés.
   */
  show_only_checkeds(cb,forcer_etat){
    if(!cb){cb = DOM('cb_only_checkeds')}
    if(undefined != forcer_etat){cb.checked = forcer_etat}
    // il faut afficher seulement les checkés
    for(var type of ['relatifs','synonymes','contraires']){
      var omenu = DOM('menu_mot_'+type);
      if(cb.checked){
        omenu.className += ' only_checkeds';
      }else{
        omenu.className = omenu.className.replace(/only_checkeds/,'').trim(); 
      }
    }
  },
  /**
   *  Méthode retirant un mot d'une liste de mots (relatifs, synonymes,
   *  contraires). Pour le moment, cette méthode n'est pas utilisée. Elle
   *  le sera lorsqu'on fera un listing des mots.
   *
   */
  remove(type,mot_id){
    // TODO Supprimer dans hidden des values du type
    DOM('a#'+type+'-'+mot_id).style.display = 'none';
  },

/**
 * Appelé lorsqu'on choisit une catégorie.
 *
 * Ajoute ou supprime la catégorie du listing des catégories en fonction
 * du fait qu'elle soit déjà présente ou non.
 *
 */
  on_choose_categorie(menu){
    let cate = menu.value;
    let cates = DOM('mot_categories').value.split(' ');
    let dec = cates.indexOf(cate);
    console.log("dec = ", dec);
    if( dec < 0 ){
      cates.push(cate);
    }else{
      cates.splice(dec,1);
    }
    DOM('mot_categories').value = cates.join(' ');
    menu.selectedIndex = 0;
  },


  set_menu_mots(type){
    let menu = DOM('menu_mot_'+type);
    let hidden_field = DOM('mot_'+type);
    let values = hidden_field.value;
    if (values == '') { values = [] }
    else {
      values = values.split(' ');
      for(var id of values){
        menu.querySelector("option[value=\""+id+"\"]").className = 'checked';
      }
    }
    DOM('nombre_mots_'+type).innerHTML = values.length;
    menu.selectedIndex = -1;
  }
}

isReady().then(function(){
  Scenodico.set_menu_mots('relatifs');
  Scenodico.set_menu_mots('synonymes');
  Scenodico.set_menu_mots('contraires');
})

/**
 * Au chargement de la page, on n'affiche que les mots qui sont des
 * relatifs, synonymes et contraires.
 */
Scenodico.show_only_checkeds(DOM('cb_only_checkeds'));
