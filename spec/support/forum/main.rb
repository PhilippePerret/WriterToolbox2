=begin

  Fichier principal du support pour le forum

=end

def forum_truncate_all_tables
  site.db.use_database :forum
  forum_tables.each do |table_name|
    site.db.execute("TRUNCATE TABLE #{table_name};")
  end
end


def forum_tables
  @forum_tables ||= ['sujets', 'posts', 'follows', 'posts_content', 'posts_votes']
end
