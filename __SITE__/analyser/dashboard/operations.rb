# encoding: utf-8
class Analyse
  class << self

    def eject_user mess = nil, redirige = true
      mess = "Vous n’êtes pas en mesure d’accomplir cette opération#{mess.nil? ? '' : ' : '+mess}…"
      if redirige
        redirect_to('home', [mess, :error])
      else
        return __error(mess)
      end
    end

    # Traite l'opération désignée par +op+ dans les paramètres
    #
    # Chaque opération fait l'objet d'une librairie dans _lib/library,
    # cette méthode ne doit servir qu'à l'appeler
    #
    # TODO À l'avenir, s'il était avéré que l'opération peut porter
    # sans problème le même nom que la librairie, on pourrait automatiser
    # les choses par convention :
    #     Soit une opération            : 'mon_operation'
    #     Elle appellerait la librairie : '_lib/library/mon_operation.rb'
    #     Et contient la méthode        : do_mon_operation()
    #
    def traite_operation he, ope
      he.analyste? || he.admin? || (return eject_user('vous n’êtes ni analyste ni administrateur'))
      case ope
      when 'add_file'
        require_lib('analyser:add_file')
        analyse.add_file(param(:file), he)
      end
    end

  end #/<< self

end #/Analyse
