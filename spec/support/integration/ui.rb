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

# @param {String} element_jid
#                 Selector vers lequel il faut scroller
# @param {Fixnum|Nil} offset
#                 Le décalage éventuel.
#                 P.e., s'il est égal à -200, on scrolle 200 pixels
#                 plus haut.
def scrollTo element_jid, offset = 0
  offset = 0 # pour le moment, on remet comme ça
  js = <<-JAVASCRIPT
  let e = document.querySelector("#{element_jid}");
  let o = e.offsetTop + #{offset};
  window.scrollTo(0,o);
  return o;
  JAVASCRIPT
  # puts "Code scrollTo : #{js}"
  o = page.execute_script(js)
  # puts "Offset de scrollTo : #{o.inspect}"
  return
end
