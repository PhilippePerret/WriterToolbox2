# encoding: utf-8
class Analyse
  class << self

    def eject_user mess = nil
      mess ||= "Vous n’êtes pas en mesure d’accomplir cette opération…"
      redirect_to('home', [mess, :error])
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
      he.analyste? || he.admin? || (return eject_user)
      case ope
      when 'add_file'
        has_contributor?(analyse.id, he.id) || (return eject_user)
        require_lib('analyser:add_file')
        analyse.add_file(param(:file), he)
      end
    end

  end #/<< self

end #/Analyse
