# encoding: UTF-8
=begin

  Module permettant de gérer un paiement.

  TODO
  Pour le moment, il est placé dans le programme UN AN UN SCRIPT où il sert
  mais il devra être déplacé dans un module plus général quand on travaillera
  l'abonnerment.

=end
class Paiement

  include PropsAndDbMethods

  attr_reader :id
  attr_reader :data

  def initialize data
    @data = data
    dispatch data
  end

  # ID de la facture
  def facture_id
    @facture_id ||= data[:id][0..31]
  end

  def auteur
    @auteur ||= data[:auteur]
  end
  def auteur_patronyme
    @auteur_patronyme ||= "#{auteur[:prenom]} #{auteur[:nom]}".strip
  end

  def save
    @id = site.db.insert(
      db_name,
      db_table,
      {
        objet_id:   data[:objet],
        user_id:    data[:user_id],
        facture:    facture_id,
        montant:    data[:montant][:total]
      }
    )
  end

  # Produit la facture pour le paiement courant
  def facture
    <<-HTML
    <style type="text/css">
    table#facture{border:2px solid}
    table#facture tr{border: 1px solid}
    table#facture td{padding: 1px}
    </style>
    <table id="facture">
      <colsgroup>
        <col width="150" />
        <col width="450" />
      </colsgroup>
      <tr>
        <td>Facture ID</td>
        <td>#{facture_id}</td>
      </tr>
      <tr>
        <td>Émise par</td>
        <td>#{site.configuration.titre}</td>
      </tr>
      <tr>
        <td>Pour</td>
        <td>#{auteur_patronyme} (#{user.pseudo} ##{user.id})<br />#{auteur[:mail]}</td>
      </tr>
      <tr>
        <td>Objet</td>
        <td>#{data[:objet]}</td>
      </tr>
      <tr>
        <td>Date</td>
        <td>#{Time.now.strftime('%d %m %Y - %H:%M')}</td>
      </tr>
      <tr>
        <td>Montant</td>
        <td>#{data[:montant][:total]} €</td>
      </tr>
    </table>

    HTML
  end

  def base_n_table
    @base_n_table ||= [:cold, 'paiements']
  end

end
