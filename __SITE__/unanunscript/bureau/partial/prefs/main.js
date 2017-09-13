window.Program = {

  toggle_div_send_time(coched){
    DOM('div_send_time').style.visibility = coched ? 'visible' :  'hidden' ;
  }
}



isReady().then(function(){
  DOM('prefs_after_login').checked = prefs_after_login;
  DOM('prefs_daily_summary').checked = prefs_daily_summary;
  Program.toggle_div_send_time(prefs_daily_summary);
  if(prefs_daily_summary){
    DOM('prefs_send_time').value = prefs_send_time;
  }
})
