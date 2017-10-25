function changeSpec(span){
  let prop = span.getAttribute('data-id');
  let hiddfield = document.getElementById('specs_'+prop);
  let spanfield = document.getElementById(prop+'_id');
  let cur_value = hiddfield.value;
  let become_actif = cur_value == '0';
  let new_value = become_actif ? '1' : '0' ;
  hiddfield.value = new_value;
  spanfield.className = 'spec_btn' + (new_value == '1' ? ' actif' : '');
  // On doit faire apparaitre aussi les explications humaines plus
  // détaillées avec des liens.
  document.getElementById(prop+'-exp0').style.display = become_actif ? 'none' : 'block';
  document.getElementById(prop+'-exp1').style.display = become_actif ? 'block' : 'none';
}

function changeDocState(span)
{
  let bit = span.getAttribute('data-id');
  let hiddfield = document.getElementById('doc-'+bit+'-value');
  let spanfield = document.getElementById('btn_doc-'+bit);
  let cur_value = hiddfield.value;
  let become_actif = cur_value == '0';
  let new_value = become_actif ? '1' : '0' ;
  hiddfield.value = new_value;
  spanfield.className = 'doc_btn' + (new_value == '1' ? ' actif' : '');
  // // On doit faire apparaitre aussi les explications humaines plus
  // // détaillées avec des liens.
  document.getElementById('doc-'+bit+'-li').style.display = become_actif ? '' : 'none';
}
