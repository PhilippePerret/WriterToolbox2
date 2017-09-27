
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
  code_element = scrollTo(element_jid)
  codejs = "let e = #{code_element}; e.checked = true;"
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
alias :click_vraiment_bouton :click_bouton_by_id


# Choisis une valeur dans un menu select, autrement que par le texte
#
# @param {Hash} params
#     :selector       Le JID du menu (p.e. select#mon_menu)
#     On définit l'option à sélectionner d'une des trois façons suivantes :
#     :selectedIndex    L'index de l'option
#     :value            La value de l'option
#     :text             Le texte
#
# @param {Fixnum} sleep_time
#                 Temps d'attente ensuite, en sachant qu'ici ça n'est
#                 pas Capybara qui gère ça
def selectionne params, sleep_time = nil
  code = "let m = document.querySelector('#{params[:selector]}');"
  if params.key?(:selectedIndex)
    code << "m.selectedIndex = #{params[:selectedIndex]};"
  elsif params.key?(:value)
    code << "m.value = '#{params[:value]}';"
  elsif params.key?(:text)
    code << "let v = m.querySelector('option[text=\"#{params[:text]}\"]');"
    code << "m.value = '#{v}';"
  end
  sleep (sleep_time || 1)
end
