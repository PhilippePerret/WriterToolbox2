# encoding: utf-8
#
# Helper pour la construction de la carte de l'user
# Division modulaire permettant d'offrir les quatre sortes de carte différentes.
class User

  
  # --------------------------------------------------------------------------------
  #
  #   CONSTRUCTION DES RANGÉES
  #
  # --------------------------------------------------------------------------------
  
  def row_inscrit_depuis
    since_and_ago = <<-HTML
    <span class="created_at date">#{data[:created_at].as_human_date}</span> <span class="small">(#{data[:created_at].ago})</span>
    HTML
    row("Inscrit#{f_e} sur le site depuis le", since_and_ago)
  end

  # La rangée indiquant le grade
  def row_grade
    row("Grade", human_grade, 'grade')
  end

  def row_is_administrateur
    admin? || (return '')
    row('', "#{pseudo} est un#{f_e} administrat#{f_rice}.")
  end

  def row_contact
    require_lib('user:contact')
    ok_contacted = "accepte d’être contacté#{f_e}"
    accepte_par =
      if world_contact?
        "#{ok_contacted} par tout le monde"
      elsif inscrits_contact?
        "n’#{ok_contacted} que par des inscrits"
      elsif admin_contact?
        "n’#{ok_contacted} que par l’administration du site"
      else
        "refuse tout contact"
      end
    row('Contact', "#{pseudo} #{accepte_par}#{le_contacter}.")
  end



  # --------------------------------------------------------------------------------
  #
  #   CONSTRUCTION DES ÉLÉMENTS DE RANGÉES
  #
  # --------------------------------------------------------------------------------

  def le_contacter
   ok = (world_contact? || (inscrits_contact? && user.identified?) || (admin_contact? && user.admin?))
   ok || (return '')
   return " (#{simple_link("user/contact/#{id}", "#{f_la} contacter", 'exergue')})"
  end


  def human_grade
    @human_grade ||= ERB.new(GRADES[grade][:hname]).result(self.bind)
  end
  # La liste des privilèges en fonction du grade
  def row_privileges
    # On rassemble les privilèges
    a = Array.new
    (0..grade-1).each do |igrade|
      priv = GRADES[igrade][:privilege_forum]
      priv.start_with?('!!!') || a << "#{priv},"
    end
    priv = GRADES[self.grade][:privilege_forum]
    priv.start_with?('!!!') && priv = priv[3..-1]
    a << "#{priv}."
    # On met les privilèges en forme dans une liste
    privs = a.collect{|priv| "<li>#{priv}</li>"}.join('')
    privs = <<-HTML
      <p>Avec le grade “#{human_grade}”, #{pseudo} peut…</p>
      <ul class="privileges">#{privs}</ul>
    HTML
    row('Privilèges forum', privs)
  end

  # Construction d'une rangée quelconque
  # @param {String|Nil} css
  #                     Attention, ça n'est pas la classe pour le div
  #                     principal, mais pour le span value.
  def row libelle, value, css = nil
    css = css ? " #{css}" : ''
    <<-HTML
    <div>
      <label for="">#{libelle}</label>
      <span class="field#{css}">#{value}</span>
    </div>
    HTML
  end

end #/User
