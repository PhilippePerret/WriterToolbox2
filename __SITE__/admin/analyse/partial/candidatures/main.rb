# encoding: utf-8
administrator_only
class Analyse
  class Analyste
    class << self

      # Méthode validant la candidature
      def validate candidat_id
        candidat = User.get(candidat_id)
        # Peut-être que le candidat n'est pas candidat
        if candidat.data[:options][16] != '1'
          return __error("#{candidat.pseudo} n'est pas ou plus candidat.")
        else
          set_bit_analyse(candidat, 3)
        end
        candidat.send_mail({
          subject: "Votre candidature aux analyses a été acceptée !",
          formated: true,
          message: <<-HTML
          <p>#{candidat.pseudo},</p>
          <p>Votre proposition de contribution aux analyses de film de #{site.configuration.name}
          vient d’être acceptée.</p>
          <p>Bravo à vous !</p>
          <p>Si vous vous demandez par où commencer, le mieux est de consulter l'aide à ce sujet.</p>
          <p class="center">#{full_link("aide?p=analyse%2Fcontribuer%2Fou_commencer",'Par où commencer ?')}</p>
          <p>Et bien entendu, n'hésitez pas à vous mettre en relation avec les autres candidats
          qui pourront eux aussi vous aiguiller sur les travaux à accomplir.</p>
          <p>Encore merci pour votre proposition et bon courage à vous !</p>
          HTML
        })
        @candidats = nil # pour forcer le compte 
        __notice("La candidature de #{candidat.pseudo} (##{candidat.id}) a été acceptée.")
      end

      # Méthode pour refuser la candidature
      def refuser candidat_id, motif_refus
        motif_refus != nil || (return __error("Il faut impérativement argumenter votre refus."))
        candidat = User.get(candidat_id)
        # Peut-être que le candidat n'est pas candidat
        if candidat.data[:options][16] != '1'
          return __error("#{candidat.pseudo} n'est pas ou plus candidat.")
        else
          set_bit_analyse(candidat, 2)
        end
        candidat.send_mail({
          subject: "Votre candidature aux analyses a été rejetée",
          formated: true,
          message: <<-HTML
          <p>#{candidat.pseudo},</p>
          <p>J'ai le regret de devoir vous annoncer que votre proposition de 
          contribution aux analyses de films de #{site.configuration.name} a malheureusment
          été refusée…</p>
          <p>La raison invoquée en est la suivante :</p>
          #{formate motif_refus}
          <p>Vraiment désolé pour vous, j'espère que vous aurez plus de chance la prochaine fois.</p>
          HTML
        })
        __notice("La candidature de #{candidat.pseudo} (##{candidat.id}) a été refusée. Le motif de son refus lui a été transmis.")
      end


      # Règle le 17e bit des options de l'user en gardant le reste, en
      # une seule opération
      # Note : noter quand même que puisqu'on est obligé de créer l'instance et
      # d'envoyer un mail, on pourrait tout aussi bien fonctionner normalement en
      # modifiant le bit voulu. C'est pour ça que je le fais ici
      #
      # @param {User}   he
      #                 L'utilisateur dont il faut modifier le bit
      # @param {Fixnum} valeur
      #                 La nouvelle valeur à donner au bit
      def set_bit_analyse he, valeur
        
        opts = he.data[:options]
        opts[16] = valeur.to_s
        he.set(options: opts)

        # La requête que ça pourrait être en une seule requête
        #request = <<-SQL
        #UPDATE users
        #SET options = REPLACE(
        #  options, 
        #  options,
        #  CONCAT(
        #    SUBSTRING(options,1,16), '3', SUBSTRING(options,18,15)
        #  )
        #)
        #SQL
        #site.db.use_database(:hot)
        #site.db.execute(request)
        
      end

      # Retourne le code HTML du li d'un candidat pour les
      # analyses de film
      def li_candidat data
        <<-HTML
        <li class="candidat" id="candidat-#{data[:id]}">
          <div class="fright">
            <a href="admin/analyse/#{data[:id]}?op=valider_candidature" class="btn main small">valider</a>
            <a href="#" onclick="document.querySelector('form#refus_form-#{data[:id]}').style.display='block';return false;" class="btn warning small">refuser</a>
          </div>
          <span class="pseudo">#{User.pseudo_linked(data,true,'nodeco')}</span>
          <form id="refus_form-#{data[:id]}" method="POST" style="display:none;">
            <input type="hidden" name="op" value="refuser_candidature" />
            <input type="hidden" name="candidat_id" value="#{data[:id]}" />
            <div>
              <label>Motif argumenté du refus</label>
              <span class="field">
                <textarea name="motif_refus" rows="6"></textarea>
              </span>
              <div class="explication">Ce texte markdown sera converti en HTML. Il peut contenir du code ERB.</div>
            </div>
            <div class="buttons">
              <input type="submit" class="warning medium" value="Refuser cette candidature" />
            </div>
          </form>
        </li>
        HTML
      end
    end #<< self
  end #/Analyste
end #/Analyse
