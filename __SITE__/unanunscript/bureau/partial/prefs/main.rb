# encoding: utf-8
class Unan

    SHARINGS = [
      [0, '--- Indéfini ---'],
      [1, "Personne"],
      [2, "Autres auteurs du programme"],
      [3, "Abonnés du site"],
      [4, "Tout le monde"]
    ]

  class UUProgram

    # --------- MÉTHODES UTILES ---------
    
    # Méthode principale qui enregistre les préférences.
    #
    # Ces préférences se répartissent à différents endroits :
    #
    # - le rythme                     Colonne de l'enregistrement de la donnée
    # - recevoir mail                 Options de la donnée
    # - heure de réception du mail    Options de la donnée
    # - après identification          Variable 'goto_after_login' de l'auteur
    # - partage                       Options de la donnée 
    #
    # Note : on ne modifie le goto_after_login que s'il était réglé sur 9, c'est-à-dire
    # que s'il fallait redirigé vers le bureau UN AN UN SCRIPT. Si on modifiait chaque fois,
    # à chaque fois que l'user modifierait ses préférences, il remettrait le goto_after_login
    # à son profil (1).
    #
    def save_prefs
      update({rythme: dparam[:rythme].to_i, options: rebuild_options})
      if goto_after_login_init == 9 || dparam[:after_login]
        user.var['goto_after_login'] = dparam[:after_login] ? 9 : 1
      end
      __notice("Vos préférences pour le programme sont enregistrées.")
    end

    def rebuild_options
      opts = data[:options]
      # debug "Options initiales : #{opts}"
      # debug "dparam = #{dparam.inspect}"
      opts[3] = dparam[:daily_summary] ? '1' : '0'
      opts[4] = dparam[:daily_summary] ? dparam[:send_time].to_i.to_s(24) : '0'
      opts[6] = dparam[:partage]
      return opts
    end

    def dparam
      @dparam ||= param(:prefs)
    end
    # ------- DATA PROGRAM -----------

    def options
      @options ||= data[:options]
    end
      
    def rythme
      @rythme ||= data[:rythme]
    end


    # ----------- DATA VOLATILES ---------------
    
    # Retourne l'heure d'envoi du mail, si elle est définie dans les
    # options du programme
    def send_time
      @send_time ||= options[4].to_i(24) 
    end

    # -------- Pour le réglage des préférences ------------
    def daily_summary?
      options[3] == '1'
    end
    def prefs_after_login
      user.var['goto_after_login'] == 9
    end
    def goto_after_login_init
      @goto_after_login_init ||= user.var['goto_after_login']
    end
  end #/UUProgram
end #/Unan


def program
  @program ||= user.program
end
