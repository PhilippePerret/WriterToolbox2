=begin

  Pour utiliser ces méthodes de test, ajouter cette ligne en haut des feuilles
  de test :

    require_db_support

=end

def db_get_user_by_pseudo pseudo
  db_client.query('use `boite-a-outils_hot`;')
  statement = db_client.prepare('SELECT * FROM users WHERE pseudo = ?')
  statement.execute(pseudo).each do |row|
    return row
  end
end

def db_get_user_by_id uid
  db_client.query('use `boite-a-outils_hot`;')
  statement = db_client.prepare('SELECT * FROM users WHERE id = ?')
  statement.execute(uid).each do |row|
    return row
  end
end
