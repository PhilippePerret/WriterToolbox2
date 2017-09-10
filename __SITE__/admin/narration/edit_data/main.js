
isReady().then(function(){

  // Pour que la touche Entrée ne déclenche pas le formulaire, ce qui
  // poserait des problèmes en cas de changement incomplet des valeurs.
  // Il faut impérativement passer par le bouton pour soumettre le
  // formulaire.
  DOM('narration_edit_data_form').addEventListener('keypress', function(ev){
    if(ev.key == 'Enter'){
      window.sousmissionParReturn = true;// empêchera de soumettre le formulaire
      ev.stopPropagation();ev.preventDefault();
      __error("Par mesure de sécurité, j’ai désactivé la touche Entrée sur le formulaire.");
      __notice("Cliquer sur le bouton pour soumettre le formulaire.")
      return false;
    }
  });
})
