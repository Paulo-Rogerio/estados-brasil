# Popular registros de todas as cidades e estados do Brasil

<h3> Criar os scaffold </h3>


~~~
 _________________                    ____________________
|     Estados     |                  |       Cidades      |
|-----------------| 1 ------------ * |--------------------|
|  estado:string  |                  |  cidade:string     |
|  uf:string      |                  |  capital:boolean   |
 ----------------                    |  estado_id:integer |
                                      --------------------
rails g scaffold cidades cidade capital:boolean estado_id:integer
rails g scaffold estados estado uf
~~~

<h3> Criar o seed </h3>

~~~
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
~~~

<h3>Populando os Registros</h3>

<code> rake db:seed</code>
