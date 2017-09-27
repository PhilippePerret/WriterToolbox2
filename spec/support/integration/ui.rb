
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
