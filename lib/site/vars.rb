# encoding: UTF-8
=begin

  Les variables propres au site sont enregistrées dans la table
  'users_tables.variables_0'
  Pour obtenir une variable :

      site.var[<nom variable>] ou site.get_var(<nom variable>)

  Pour définir la variable :

      site.var[<nom variable>] = <valeur> ou site.set_var(<nom>, <valeur>)


=end
class Site

  include VarsMethodsModule

  def table_vars_id ; 0 end

end #/Site
