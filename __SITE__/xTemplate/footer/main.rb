# encoding: UTF-8
class Site

  def contact_link
    '<a href="site/contact">contact</a>'
  end
  def signin_link
    '<a href="user/signin">s’identifier</a>'
  end
  def signup_link
    '<a href="user/signup">s’inscrire</a>'
  end
  def suscribe_link
    '<a href="user/suscribe">s’abonner</a>'
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
