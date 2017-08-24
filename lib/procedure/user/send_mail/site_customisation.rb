# encoding: UTF-8
class MailSender

  # L'entête à ajouter devant le titre défini dans le message
  def header_subject
    '[La Boite à outils de l’auteur] '
  end

  # L'entête de sujet de message dans sa version courte.
  # Pour l'utiliser, définir `short_subject` au lieu de `subject` dans les
  # données du message.
  def short_header_subject
    '[BOA] '
  end

  # Entêtes de message customisé
  # ---------------------------
  def customized_header
    @customized_header ||= begin
      ch_file = File.join(File.dirname(__FILE__),'custom_header.erb')
      if File.exist?(ch_file)
        '<div id="header">'+
          ERB.new(File.read(ch_file).force_encoding('utf-8')).result(site.bind) +
        '</div>'
      else '' end
    end
  end

  def customized_admin_header
    @customized_admin_header ||= begin
      ch_file = File.join(File.dirname(__FILE__),'custom_header_admin.erb')
      if File.exist?(ch_file)
        '<div id="header">'+
          ERB.new(File.read(ch_file).force_encoding('utf-8')).result(site)+
        '</div>'
      else '' end
    end
  end

  # Pieds de page customisés
  # -------------------------
  def customized_footer
    @customized_footer ||= begin
      foo = '<hr />'
      foo << "<div class='tiny'>#{site.configuration.titre}</div>"
      foo << "<div class='tiny'>Site : #{site.configuration.url_online}</div>"
      fb = site.configuration.facebook
      fb && foo << "<div class='tiny'>Facebook : http://www.facebook.com/#{fb}</div>"
      tw = site.configuration.twitter
      tw && foo << "<div class='tiny'>Twitter : https://twitter.com/#{tw}</div>"
      foo
    end
  end
  def customized_admin_footer
    @customized_admin_footer ||= begin
      foo = '<hr />'
      foo << "<div class='tiny'>#{site.configuration.titre}</div>"
      foo
    end
  end

  # Signature
  def signature
    @signature ||= site.configuration.titre
  end

  def content_type
    '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>'
  end

  # Style du body (en fait du body ET du div conteneur principal)
  # Inséré dans une balise DIV contenant tout le mail
  # + Inséré dans la balise <style>...</style>
  def body_style_tag
    "margin:0;background-color:white;color:#555;font-size:17.2pt"
  end

  # ---------------------------------------------------------------------
  #     DÉFINITION DES STYLES
  #   ---------------------------------------------------------------------

  # Styles ajoutés à la balise <style>...</style> du message
  def styles_css
    @styles_css ||= begin
      style_bande_logo      +
      style_message_content +
      style_citation        +
      other_styles          +
      style_signature
    end
  end

  def style_bande_logo
    "div#logo{font-size:1.7em;font-variant:small-caps;padding:8px 32px;background-color:#578088;color:white;}"
  end

  # Style du message, hors de l'entête (header) donc hors bande
  # logo
  def style_message_content
    "div#message_content{margin:2em 4em}"
  end

  # Style pour la citation d'auteur
  def style_citation
    <<-CSS
    div#citation a, div#citation a:hover, div#citation a:link, div#citation a:visited{
    text-decoration: none; color: black; font-size:13.2pt!important;
    }
    div#citation span#quote_citation{
    font-style: italic;
    }
    div#citation span#quote_auteur{
    display: block; text-align: right; font-size: 0.85em; text-variant: small-caps
    }
    CSS
  end

  # Styles pour la signature
  def style_signature
    "span#signature{font-size:15.2pt;color:#555}"
  end

  # Note : appelé une seule fois
  def other_styles
    <<-CSS
    .tiny{font-size:11.2pt}
    .small{font-size:14.3pt}
    CSS
  end

end
