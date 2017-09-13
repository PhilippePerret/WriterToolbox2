# encoding: utf-8
class Unan
  class UUProjet

    TYPES = {
      0 => {hname:'---Indéfini ---',        value:0, shorthname: 'Néant',           pages: 300  },
      1 => {hname:'Film (scénario)',        value:1, shorthname: 'Scénario',        pages: 90   },
      2 => {hname:"Roman (manuscrit)",      value:2, shorthname: 'Roman',           pages: 300  },
      3 => {hname:"BD (scénario)",          value:3, shorthname: 'Bande dessinée',  pages: 48   },
      4 => {hname:"Jeu vidéo (Game design)",value:4, shorthname: 'Jeu vidéo',       pages: 200  },
      8 => {hname:"Je ne sais pas encore",  value:8, shorthname: 'Projet',          pages: 120  },
      9 => {hname:"Autre",                  value:9, shorthname: 'Projet',          pages: 120  }
    }

    # ----------------------------------------------------------------------------- 
    #
    #   MÉTHODES DE TRANSFORMATION
    #
    # ----------------------------------------------------------------------------- 

    def save
      user.admin? || projet.owner?(user) || raise("Vous tentez le diable…")
      data_valides? || return
      update(data2save)
      __notice('Les nouvelles données du projet ont été enregistrées.')
    end
    
    def data_valides?
      dparam[:titre] || raise('Le projet doit avoir un titre.')
    rescue Exception => e
      debug e
      return __error(e.message)
    else
      return true
    end


    # Retourne true si l'auteur +u+ {User} est l'auteur du projet
    # courant. False dans le cas contraire.
    def owner? u
      data[:auteur_id] == u.id
    end

    def data2save
      {
        titre:  dparam[:titre],
        resume: dparam[:resume],
        specs:  rebuild_specs
      }
    end

    def rebuild_specs
      c = specs[0]
      c << dparam[:type]
      c << "0" # Avant, c'était le partage (maintenant dans les options du programme)
      c <<  TYPES[dparam[:type].to_i][:pages].to_s.rjust(3,'0')
      return c
    end

    # ----------------------------------------------------------------------------- 
    #
    #   MÉTHODES DE DONNÉES
    #
    # ----------------------------------------------------------------------------- 
    def titre
      dparam[:titre]
    end
    def resume
      dparam[:resume]
    end
    def specs
      @specs ||= data[:specs]
    end

    # Soit les paramètres (lorsque le formulaire a été soumis), soit
    # les données du projet enregistrées.
    def dparam
      @dparam ||= begin
                    if param(:projet)
                      d = param(:projet)  
                      d.each do |k, v| d[k] = v.gsub(/\r\n/,"\n").nil_if_empty end
                      d
                    else
                      data
                    end
                  end
    end

    # --- DATA VOLATILES ---
    def actifs ; @is_actif ||= specs[0].to_i == 1 end
    def type   ; @type     || specs[1].to_i       end
    def partage; @partage  ||= specs[2].to_i      end

  end #/UUProjet
end #/Unan


def projet
  @projet ||= Unan::UUProjet.new(user.program.projet_id)
end
