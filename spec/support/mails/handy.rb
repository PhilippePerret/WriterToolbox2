# encoding: UTF-8
require 'fileutils'

# Vide le dossier des mails envoyés en local
def reset_mails
  dpath = MailMatcher.folder_mails_temp
  File.exist?(dpath) && FileUtils.rm_rf(dpath)
end
alias :remove_mails :reset_mails

# Retourne un {Array} de tous les mails envoyés en local
def get_all_mails
  MailMatcher.all_mails
end

# retourne un {Array} de tous les mails trouvés lors de la dernier recherche
def get_mails_found
  MailMatcher.mails_found.map{|m| m.data}
end
