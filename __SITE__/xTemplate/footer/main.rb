# encoding: UTF-8
class Site

  def user_footer_buttons
    c = String.new
    if user.identified?
      c << '<a href="user/signout">se déconnecter</a>'
      unless user.suscribed? || user.admin?
        c << '<a href="user/suscribe">s’abonner</a>'
      end
    else
      c << '<a href="user/signin">s’identifier</a>'
      c << '<a href="user/signup">s’inscrire</a>'
    end
    return c
  end

  def contact_link
    '<a href="site/contact">contact</a>'
  end

  def tool_list_link
    site.route.objet != 'outils' || (return '')
    '<a href="outils">outils</a>'
  end


  def cb_page_fixe
    user.admin? || (return '')
    <<-HTML
<span class="fleft">
  <input type="checkbox" id="cb_fix_contents" onclick="toggle_fix_contents()">
  <label for="cb_fix_contents">Page fixe</label>
  <script type="text/javascript">
    window.page_is_fixed = false;
    function toggle_fix_contents(){
      var o = DOM('contents');
      if (page_is_fixed){
        o.style.position = ''; o.style.left = ''; o.style.top = '';
        window.scroll(0,window.windowTop);
      }else{
        window.windowTop = window.scrollY;
        var top = "-"+window.scrollY+"px";
        o.style.position = 'fixed'; o.style.left = 0;
        o.style.top = top;
      }
      page_is_fixed = !page_is_fixed;
    }
    document.getElementById('cb_fix_contents').checked = false;
  </script>
</span>
    HTML
  end

end
