# encoding: UTF-8

require_form_support

class Site

  def check_for_operation
    if Form.form_already_submitted?(param(:FORMID))
      __error("Ce formulaire a déjà été soumis… Évitez de recharger votre page, après une soumission.")
    elsif param(:operation) == 'signin' && param(:user)
      User.check_login(param(:user))
    end
  end

end #/Site

class User
class << self

  def check_login dlogin
    debug "-> check_login"

    login_data_ok?(dlogin) || return

    debug "login_data_ok?, oui"
    # On peut rediriger l'utilisateur en fonction de
    # ses préférences.
    redirect_after_login

  end

  def redirect_after_login
    debug "[redirect_after_login] user.pseudo = #{user.pseudo}"
    debug "user.var['goto_after_login'] = #{user.var['goto_after_login'].inspect}"
    redirect_to(
      case user.var['goto_after_login']
      when 0, nil then 'home'
      when 1 then 'user/profil'
      when 2 then user.get_var('last_route') || 'home'
      when 9 then 'unanunscript/bureau'
      else 'home'
      end
    )
  end

  def login_data_ok? dlogin

    # Barrière de limite de tentatives
    site.online? && begin
      site.session['tentatives_login'] ||= 0
      if site.session['tentatives_login'].to_i > 25
        redirect_to 'home', ["Vous avez dépassé votre quotat de tentatives de connexions.", :error]
      else
        site.session['tentatives_login'] += 1
      end
    end

    umail = dlogin[:mail].nil_if_empty
    upwd  = dlogin[:password].nil_if_empty

    debug "umail = #{umail.inspect} / upwd = #{upwd.inspect}"

    umail != nil || raise('Comment vous reconnaitre, sans votre mail ?…')
    upwd  != nil || raise('Comment vous reconnaitre, sans votre mot de passe ?…')

    res = site.db.select(:hot, 'users', {mail: umail}, [:id, :mail, :cpassword, :salt, :options])
    res = res.first

    res != nil || raise("Aucun utilisateur du site ne possède cet email…")

    password_valide?(res.merge(password: upwd)) || raise("Je ne vous reconnais pas…")

    mail_confirmed?(res[:options]) || raise("Vous devez confirmer votre mail pour poursuivre.")

    # On peut logguer l'user et lui souhaiter la bienvenue
    User.get(res[:id]).login
    __notice "Soyez #{user.f_la} bienvenu#{user.f_e}, #{user.pseudo} !"

  rescue Exception => e
    param(:user, {})
    __error(e.message)
  else
    true
  end

  # @return TRUE
  #         Si le mot de passe est valide.
  # @param {Hash} duser
  #               Données pour le test du password, c'est-à-dire :
  #               :mail, :password, :cpassword et :salt.
  #
  def password_valide? duser
    require 'digest/md5'
    tested_pwd = Digest::MD5.hexdigest("#{duser[:password]}#{duser[:mail]}#{duser[:salt]}")
    return duser[:cpassword] == tested_pwd
  end

  # Retourne true si le mail a été confirmé
  def mail_confirmed? options
    options.get_bit(2) == 1
  end

  # Plus tard, des options permettront à l'user de choisir sa redirection
  def after_login

  end
end #/<< self
end # User
