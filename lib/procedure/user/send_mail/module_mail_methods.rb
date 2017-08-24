# encoding: UTF-8
=begin

  Module des méthodes qui seront injectées dans MailSender.
  Elles sont séparées pour être utilisées dans le CRON par exemple.

=end
module MailModuleMethods

  # Les données initiales
  attr_reader :data
  attr_reader :from, :to

  def initialize data = nil
    @data = data
    data.each do |k,v|
      v = v.nil_if_empty if v.is_a?(String)
      instance_variable_set("@#{k}", v)
    end
  end

  # ---------------------------------------------------------------------
  # Le message complet final
  # ------------------------
  def message
    "From: <#{from}>\nTo: <#{to}>\nMIME-Version: 1.0\nContent-type: text/html; charset=UTF-8\nSubject: #{subject}\n\n#{code_html}"
  end

  # ----------------------------------------------------------------------
  #   Sous-méthode de construction du message

  def code_html
    @code_html ||= <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html><head>#{content_type}#{title}#{style_tag}</head><body>#{body}</body></html>
    HTML
  end

  # / Sous-méthode de construction du message
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------
  #   Sous-sous-méthodes de construction du message

  # Pour la balise title du message HTML
  def title
    @title ||= "<title>#{subject}</title>"
  end

  # Définition du SUJET DU MESSAGE
  # ------------------------------
  def subject
    @subject ||= @short_subject || "(sans sujet)"
    if @no_header_subject
      @subject
    elsif @short_subject
      "#{short_header_subject}#{@short_subject}"
    else
      "#{header_subject}#{@subject}"
    end
  end

  # Le corps du message du mail
  def body
    c = header +
        '<div id="message_content">' +
          message_formated  +
          signature         +
          footer +
        '</div>'
    body_style_tag && c = "<div style=\"#{body_style_tag}\">#{c}</div>"
    return c
  end

  def style_tag
    @style_tag ||= begin
      stag = ""
      body_style_tag  && stag << "body{#{body_style_tag}}"
      styles_css      && stag << styles_css
      "<style type='text/css'>#{stag}</style>"
    end
  end

  # / Sous-sous-méthodes
  # ---------------------------------------------------------------------

  # ---------------------------------------------------------------------
  #   Sous-sous-sous méthodes de construction du message


  def header
    case true
    when @no_header     then nil
    when @admin_header  then customized_admin_header
    else customized_header
    end || ''
  end

  def footer
    case true
    when @no_footer then nil
    when @admin_footer  then customized_admin_footer
    else customized_footer
    end || ''
  end

  # ---------------------------------------------------------------------
  #   Sous-sous-sous-sous méthodes de construction du message

  def message_formated
    return @message if already_formarted?
    c = @message
    if return_to_br_in_message?
      if c.match("\n")
        c.gsub!(/\n/, '<br>')
        c.gsub!(/\r/, '')
      elsif c.match("\r")
        c.gsub!(/\r/, '<br>')
        c.gsub!(/\n/, '')
      end
    end
    "<div>#{c}</div>"
  end


  # ---------------------------------------------------------------------
  #   Méthode d'état ou fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne true si le message est formaté HTML
  def already_formarted?
    @formated == true || @message.match(/(<div |<p )/)
  end

  # Return true s'il faut corriger les retours de chariot et
  # les remplacer par des <br>
  # Note : Seulement si le message doit être formaté
  def return_to_br_in_message?
    if defined? CORRECT_RETURN_IN_MESSAGE
      CORRECT_RETURN_IN_MESSAGE
    else
      true
    end
  end
end # /fin module MailModuleMethods
