# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Trunca os dados de todas as tabelas

ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'

  # Trunca tabela - PostgreSQL
  ActiveRecord::Base.connection.execute("TRUNCATE #{table}")

  # Trunca as sequences
  ActiveRecord::Base.connection.reset_pk_sequence!("#{table}")
  
  puts "Tabela sendo truncada: #{table}"
 
end


require 'net/http'
require 'net/https'
require 'json'

module BRPopulate
  def self.estados
    http = Net::HTTP.new('raw.githubusercontent.com', 443); http.use_ssl = true
    JSON.parse http.get('/Paulo-Rogerio/estados-brasil/master/estados-brasil.json').body
  end

  def self.populate
    estados.each do |state|
      state_obj = Estado.new(:uf => state["uf"], :estado => state["estado"])
      state_obj.save


      state["cidades"].each do |city|

        c = Cidade.new
        c.cidade = city
        c.estado_id = state_obj["id"]

	# Checa se a cidade e uma capital
	
        if city == state["capital"]
               c.capital = "true"
        else
               c.capital = "false"
        end

        c.save
      end
    end
  end
end

BRPopulate.populate

