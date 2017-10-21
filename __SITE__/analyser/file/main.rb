# encoding: utf-8

# Instanciation du fichier courant traité
#
# Il n'est défini que si site.route.objet_id est un Fixnum. C'est alors
# l'ID du fichier dans la base.
#
# Pour instancier ce fichier, on envoie également l'instance de l'user
# courant pour qu'elle devienne le `ufiler` du fichier qui permettra de
# tout gérer en fonction de son statut, créateur, rédacteur, administrateur,
# etc.
#
def afile
  @afile ||= site.route.objet_id.is_a?(Fixnum) ? 
    Analyse::AFile.new(site.route.objet_id, user) : nil
end
