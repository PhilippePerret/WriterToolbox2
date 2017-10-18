=begin

  PRODUIT UNE SAUVEGARDE "INTELLIGENTE" DE TOUTES LES BASES DE DONNÉES
  DE LA BOITE À OUTILS

  Pour le lancer, jouer simplement : CTRL + CMD + T

  "INTELLIGENTE" signifie que :
  - seules les tables de la boite à outils sont sauvegardées
  - une ligne est ajoutée pour détruire toutes les tables de 'users_tables'
    sauf les 3 premières.

  Pour pouvoir obtenir le fichier, il est inutile de détruire le fichier du jour
  puisque c'est fait par le programme.

  ATTENTION DE BIEN PARTIR D'UN JEU DE BASES VIERGES, EN CHARGEANT UN DES
  FICHIERS DU DOSSIER 'vierges'.

=end

describe 'Pour sauver toutes les bases de données' do
  before(:all) do
    require_support_db_for_test
    File.exist?(backup_all_data_filepath) && File.unlink(backup_all_data_filepath)
    backup_all_data_si_necessaire
    puts "Backup créé dans : #{backup_all_data_filepath}"
  end
  it 'produit une sauvegarde de toutes les données' do
    expect(true).to eq true
  end
end
