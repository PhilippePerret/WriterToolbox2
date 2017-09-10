
function isReady() {
  return new Promise(function(ok,ko){
    let timer = setInterval(function(){
      if('complete'===document.readyState){clearInterval(timer);ok()}
    },10)
  })
}


isReady().then(function(){
  // À faire sur toutes les pages quand le document est prêt.
  if(DOM('flash')){Flash.removeAfterReading()}
})
