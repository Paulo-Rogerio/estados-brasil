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
    estados.each do |sigla_uf|
      sigla_uf_obj = Estado.new(:sigla => sigla_uf["uf"], :nome => sigla_uf["cidades"])   
      sigla_uf_obj.save
      
      sigla_uf["cidades"].each do |city|
        
        c = Cidade.new
        c.nome = city
        c.estado = sigla_uf_obj
        c.capital = capital?(city, sigla_uf)
         
        #abort c.capital.inspect
        #abort c.nome.inspect
        c.save
      end
    end
  end
end

BRPopulate.populate
