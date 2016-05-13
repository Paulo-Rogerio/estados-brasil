ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  next if table == 'schema_migrations'
  next if table == 'cities'
 
  # Trunca tabela - PostgreSQL
  ActiveRecord::Base.connection.execute("TRUNCATE #{table}")

  # Trunca as sequences
  ActiveRecord::Base.connection.reset_pk_sequence!("#{table}")
  
  puts "Tabela sendo truncada: #{table}"
 
end


require 'net/http'
require 'net/https' # for ruby 1.8.7
require 'json'

module BRPopulate
  def self.estados
    http = Net::HTTP.new('raw.githubusercontent.com', 443); http.use_ssl = true
    JSON.parse http.get('/Paulo-Rogerio/estados-brasil/master/estados-brasil.json').body
  end

  def self.capital?(cidade, estado)
    cidade["name"] == estado["capital"]
  end

  def self.populate
    estados.each do |uf|
      uf_obj = Estado.new(:sigla => uf["acronym"], :nome => uf["name"])
      uf_obj.save
      
      uf["cities"].each do |city|
        
        c = Cidade.new
        c.nome = city
        c.estado = uf_obj
        c.capital = capital?(city, uf)
         
        #abort c.estado.inspect
        #abort c.nome.inspect
        c.save
      end
    end
  end
end

BRPopulate.populate
