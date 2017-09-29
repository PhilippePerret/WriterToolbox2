# encoding: utf-8
class Forum
  class << self

    # Retourne le code HTML de la liste des derniers messages, 
    # à placer dans le fieldset.
    #
    # Noter que pour un user de grade 0, seuls les messages publics
    # sont affichés.
    #
    def last_messages
      '[Plus tard la liste des derniers messages]' 
    end


  end #/<< self Forum
end #/Forum
