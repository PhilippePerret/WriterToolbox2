# encoding: UTF-8

class NotAccessibleViewError < StandardError ; end

class Site

  # Message d'erreur qui peut être passé comme on veut
  #
  # La méthode doit faire :
  #   site.__error_message = <le message>
  # la vue, pour afficher le message, doit faire :
  #   <%= __error_message %>
  attr_accessor :__error_message

  # Retourne le code de la page d'erreur +page_affixe+ en mettant
  # le message d'erreur dans @__error_message
  #
  # @param {String} page_affixe
  #                 L'affixe d'une page se trouvant obligatoirement
  #                 dans xTemplate/error_pages
  # @param {Error}  err
  #                 L'erreur, pour récupérer son message à afficher
  #                 dans la page d'erreur    
  def load_error_page page_affixe, err
    debug err
    self.__error_message = err.message
    deserb("./__SITE__/xTemplate/error_pages/#{page_affixe}.erb")
  end

end
