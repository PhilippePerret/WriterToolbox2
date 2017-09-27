
# Pour cocher l'élément +element_jid+ dans le formulaire
#
# Cette méthode est nécessaire car si on coche un élément qui n'est
# pas visible, il ne se coche pas. Donc il faut scroller jusqu'à
# l'élément, puis le cocher.
#
# Cette méthode fonctionne pour les CHECKBOX et les RADIOS.
#
# @param {String} element_jid
#                 Soit simplement le "input#id" soit l'élément auquel
#                 appartient l'élément, par exemple "div#id input#id",
#                 soit même l'identifiant seul.
# @param {String} form_id
#                 Éventuellement, le formulaire dans lequel on doit opérer
#                 Mais pour la clarté, il vaut mieux l'indiquer dans le
#                 test et appeler cette méthode à l'intérieur de :
#                 within('form#id') do
#                   coche 'input#id'
#                 end
def coche element_jid, form_id = nil
  if element_jid.match(/ /)
    dpath = element_jid.split(' ')
    element_jid = dpath.pop
    path    = dpath.join(' ')
  else
    path = nil
  end
  if element_jid.match(/#/)
    tag, elid = element_jid.split('#')
    code_element = "document.getElementById('#{elid}')"
  elsif element_jid.match('/\./')
    tag, elclass = element_jid.split('.')
    code_element = "document.getElementsByClassName('#{elclass}')[0]"
  else # c'est l'identifiant seul
    code_element = "document.getElementById('#{element_jid}')"
  end
  if path
    code_parent = "document.querySelector('#{path}')"
  else
    code_parent = code_element
  end
  codejs = <<-JS
let e = #{code_element}, p = #{code_parent};window.scrollTo(0,p.offsetTop);e.checked = true;
  JS
  if form_id
    within("form##{form_id}") do
      page.execute_script(codejs)
    end
  else
    page.execute_script(codejs)
  end
end

# Permet de cliquer un bouton en jouant aussi son 'onclick' qui n'est
# pas joué lorsqu'on utilise simplement 'click_button'
def click_bouton_by_id bouton_id, sleep_time = nil
  page.execute_script("document.getElementById('#{bouton_id}').click();")
  sleep (sleep_time || 1) # car capybara ne gère pas l'arrêt, ici
end
