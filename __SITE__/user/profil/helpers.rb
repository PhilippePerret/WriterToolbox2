# encoding: utf-8
#
# Helper pour la construction de la carte de l'user
# Division modulaire permettant d'offrir les quatre sortes de carte différentes.
class User

  def row_inscrit_depuis
    since_and_ago = "<span>#{data[:created_at].as_human_date}</span> <span class=\"small\">(#{data[:created_at].ago})</span>"
    row("Inscrit#{f_e} sur le site depuis le", since_and_ago)
  end

  # La rangée indiquant le grade
  def row_grade
    row("Grade", human_grade)  
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
  def row libelle, value
    <<-HTML
    <div>
      <span class="libelle">#{libelle}</span>
      <span class="value">#{value}</span>
    </div>
    HTML
  end

end #/User
