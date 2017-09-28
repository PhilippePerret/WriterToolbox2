def click_link_by_href link_href, sleep_time = nil
  page.execute_script("document.querySelector('a[href=\"#{link_href}\"]').click();")
end

# Permet de cliquer un bouton en jouant aussi son 'onclick' qui n'est
# pas joué lorsqu'on utilise simplement 'click_button'
def click_bouton_by_id bouton_id, sleep_time = nil
  scrollTo bouton_id
  page.execute_script("document.getElementById('#{bouton_id}').click();")
  sleep (sleep_time || 1) # car capybara ne gère pas l'arrêt, ici
end
alias :click_vraiment_bouton :click_bouton_by_id
alias :click_link_by_id :click_bouton_by_id

def scrollTo element_jid
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
let e = #{code_element}, p = #{code_parent};window.scrollTo(0,p.offsetTop);
  JS
  page.execute_script(codejs)
  return code_element
end
