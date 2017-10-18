# encoding: UTF-8
=begin

  Ce script doit servir à fabriquer le fichier `analyses_seed.sql` qui
  permet d'injecter les données analyses dans les nouvelles tables biblio

  Principes
  =========

    * Pour toutes les analyses, Phil est mis en créateur et Marion est
      mise en correctrice.
    * On essaie de lire dans les fichiers des analyses une date de création

=end

FOLDER_MYE = './__SITE__/analyse/_data_/film_MYE'
FOLDER_TM  =  './__SITE__/analyse/_data_/film_tm'

request = <<-SQL
SELECT fa.specs, f.*
  FROM filmodico f
  INNER JOIN films_analyses fa ON f.id = fa.id
SQL
site.db.use_database(:biblio)
films_analyses = site.db.execute(request)

# Pour exécuter la requête immédiatement
data_user_per_analyse = Array.new

# Pour composer le seed
code_sql = Array.new


films_analyses.each do |ha|

  # On passe celles-ci, ajoutées en dur
  [67,102,125,249].include?(ha[:id]) && next


  begin
    titre = ha[:titre].force_encoding('utf-8').upcase
    debug "\n*** Analyse de #{titre} ***"
    (ha[:created_at] && ha[:updated_at]) || begin
      debug "=== recherche date de création et d'update"
      folder_mye = File.join(FOLDER_MYE, ha[:film_id])
      if File.exist?(folder_mye)
        debug "=== Le dossier #{folder_mye} existe"
        cdates = Array.new
        mdates = Array.new
        Dir["#{folder_mye}/**/*.*"].each do |f|
          File.directory?(f) && next
          cdates << File.stat(f).ctime.to_i
          mdates << File.stat(f).mtime.to_i
        end
        ha[:created_at] ||= cdates.min || mdates.min || ha[:updated_at] || Time.now.to_i
        ha[:updated_at] ||= mdates.min || cdates.min || ha[:created_at] || Time.now.to_i
      else
        debug "=== Dossier film inexistant"
        ha[:created_at] ||= ha[:updated_at] || Time.now.to_i
        ha[:updated_at] ||= (ha[:created_at] + 60000)
      end

      if ha[:created_at] > ha[:updated_at]
        ha[:created_at], ha[:updated_at] = [ha[:updated_at], ha[:created_at]]
      end
    end
    debug "*** Crée le     : #{ha[:created_at].as_human_date}"
    debug "*** Modifiée le : #{ha[:updated_at].as_human_date}"

    # On passe les films non analysés
    (ha[:specs] && ha[:specs][0] == '1') || begin
      debug "=== NON ANALYSÉ ==="
      next
    end


    data_user_per_analyse << [
      1, ha[:id], 1|32|64|128|256, ha[:created_at], ha[:updated_at]
    ]
    data_user_per_analyse << [
      3, ha[:id], 1|4, ha[:updated_at], ha[:updated_at]
    ]

    csql = <<-SQL
    --
    -- FILM #{titre}
    --
    (1, #{ha[:id]}, 1|32|64|128|256, #{ha[:created_at]}, #{ha[:updated_at]}),
    (3, #{ha[:id]}, 1|4, #{ha[:created_at]}, #{ha[:updated_at]})
    SQL

    code_sql << "    #{csql.strip}"

  rescue Exception => e
    debug "# Problème avec #{ha.inspect}"
    debug e
  end
end

# request = <<-SQL
# INSERT INTO user_per_analyse
#   (user_id, film_id, role, created_at, updated_at)
#   VALUES (?, ?, ?, ?, ?)
# SQL
# site.db.use_database(:biblio)
# site.db.execute(request, data_user_per_analyse)

code_sql_final = <<-SQL
-- MySQL dump 10.13  Distrib 5.7.13, for osx10.11 (x86_64)
--
-- Host: localhost    Database: boite-a-outils_biblio
-- ------------------------------------------------------
-- Server version	5.7.13


-- Pour ré-injecter les données :
-- se placer dans ce dossier et incorporer dans mysql :
-- cd '/Users/philippeperret/Sites/WriterToolbox2/__DEV__/__TODO__'
-- mysql < analyses_seed.sql

USE `boite-a-outils_biblio`;

TRUNCATE TABLE user_per_analyse;

INSERT INTO user_per_analyse
  (user_id, film_id, role, created_at, updated_at)
  VALUES
    --
    -- FILM : JAWS
    --
    (1, 67, 1|32|64|128|256, 1462053600, 1462053600),
    (3, 67, 1|4, 1462065600, 1462065600),
    --
    -- FILM : MINORITY REPORT
    --
    (1, 102, 1|32|64|128|256, 1456354800, 1456354800),
    (3, 102, 1|4, 1459116000, 1459116000),
    --
    -- FILM : ROCKY #125 (25-02-2016)
    --
    (1, 125, 1|32|64|128|256, 1456354800, 1456354800),
    (3, 125, 1|4, 1464213600, 1464213600),
    --
    -- FILM THE LAST SAMOURAI #249 (28-12-2016)
    --
    (1, 249, 1|32|64|128|256, 1482879600, 1482879600),
    -- Co-créateur : Benoit
    (2, 249, 1|16|64|128, 1482891600, 1482891600),
    (3, 249, 1|4, 1483570800, 1483570800),
#{code_sql.join(",\n")};
SQL


seed_file = '/Users/philippeperret/Sites/WriterToolbox2/__DEV__/__TODO__/analyses_seed.sql'
File.exist?(seed_file) && File.unlink(seed_file)
File.open(seed_file,'wb'){|f| f.write code_sql_final}
