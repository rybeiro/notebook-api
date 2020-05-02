# README
Este Manual é para esclarecer e auxiliar na criação de uma ***API*** com *Rails*, além esclarecer dúvidas frequentes sobre alguns recursos utilizados no *Framework*

> Objetivo do projeto - Criar uma agenda
- Contact (Contatos) tem um Kind
- Kind (Tipos de contatos)
- Phone (Numeros de telefone) tem um contato

## Requisitos minimos e opcionais
- Ruby  => versão => 2.5
- Rails => versão => 5.2
- Node  (Opcional)
- mysql (Opcional)

## Criando a aplicação
```
Rails new notebook-api --api -d mysql
``` 
Esse comando criará uma nova aplicação. O parâmentro *--api* sinaliza para o *Rails* que é uma *API* com isso não será criado arquivos de *View* e o *-d* sinaliza qual banco de dados será utilizado na aplicação.

### Gerando o CRUD
Para gerar o crud utilizaremos o *scaffold*
```
rails g scaffold Contato nome:string email:string aniversario:date
```

### Criando o banco de dados com Rails
Configure o arquivo *database.yml* com as credenciais do banco de dados depois execute o comando.
```
rails db:create
```

## Criando uma Task (tarefa) para popular nossa tabela
Para obter dados para utlizar em desenvolvimento podemos utilizar uma biblioteca para gerar dados falsos, como nomes, endereços e números de telefone etc. [Faker](https://github.com/faker-ruby/faker).
Inclua no arquivo *Gemfile* no ambiente de desenvolvimento. Depois de inserir execute ```bundle install```

Para criar uma tarefa através do gerador do *Rails*, utilize o comando:
```
rails g task dev setup
```
Vai criar o *namespace **dev*** e a tarefa como *setup*. O arquivo será criado no diretório *lib/tasks/dev.rb* esse arquivo deve ficar assim:
```
namespace :dev do
  require 'faker'
  desc "Configuração do ambiente de Desenvolmento"
  task setup: :environment do
    100.times do |i|
      Contact.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        birthday: Faker::Date.birthday(min_age: 18, max_age: 65) #=> "Mar, 28 Mar 1986"
      )
    end
  end
end
```

Execute a tarefa com o comando: ```rails dev:setup``` e sua tabela conterá 100 registros.

# Render JSON
Por padrão invoca implicitamente o método *as_json*
```
render json: @variable
``` 
Retorna todos os dados.
```
render json: @variable
```
Retorna o nome raiz dos dados no json.
```
render json: @variable, root: true
```

### Retornando apenas alguns dados no render
Retorna somente nome e email
```
render json: @variable, only: [:nome, :email]
```
Retorna exceto nome e email
```
render json: @variable, except: [:nome, :email]
```

### Acrescentando informações ao retorno
Exemplo incluir no retorno um Autor/Nome, mesmo que não esse elemento não esteja na tabela. Para isso utilizamos o *Map* com o *Merge*
```
render json: @variable.map {|variable| variable.attributes.merge({author: "Fabio Ribeiro"})}
``` 
Esse exemplo é para ser utilizado quando retornar muitos elementos.
```
render json: @variable.attributes.merge({author: "Fabio Ribeiro"})
``` 
Esse exemplo é para ser utilizado quando retornar apenas um elemento.

Podemos simplificar criando um método.
```
render json: @variable, methods: :author
```
Esse exemplo fará todo o processo acima de incluir o atributo e fazer a mesclagem. Mas...

Temos que criar no *Model* esse método. Assim a mágica acontece.

```
def author
  "Fabio Ribeiro"
end
```

> Podemos ainda **sobreescrever** o método *as_json* recebendo um *Hash* de opções como paâmentro. Assim as informações ficarão disponíveis no *show*
```
def as_json(options = {})
  super(methods: :author, root: true)
end
```

## Render com Associações
### GET
#### Model
Para isso passaremos na função implicita do retorno json a função ```as_json``` o método include.

Retorna os Contatos com o atributo kind (tipo)
```
include: :kind
```
Retorna os contatos com o atributo kind (tipos) e somente a descrição
```
include: {kind: {only: :description}}
```

Pense em criar um método que sobreescre o método ```as_json``` no Model de Contact (Contatos)
```
def kind_description
  self.kind.description
end

def as_json(options = {})
  super(
    methods: kind_description
  )
end
```
#### Controller
Podemos fazer o retorno na *Controller* para retorno com relacionamento e todos os campos.
```
render json: @variable, include: :kind
```
Podemos fazer o retorno na *Controller* para retorno com o relacionamento e apenas a descrição.
```
render json: @variable, include: {kind: {only: :description}}
```

### POST
Para criar um novo Contato que contém relacionamento obrigatório com outra tabela de forma forçada podemos configurar na Model com o parâmentro ```optional: true```

Mas por padrão deixamos o Modelo para exigir esse relacionamento.
```
class Contact < ApplicationRecord
  belongs_to :kind, optional: true
end
```

Para criar um novo Contact (Contato) que contém relacionamento obrigatório, já passando o id. Para isso é necessário permitir na lista branca da Model Kind (Tipos).
### Active Suport Json
- JSON.encode() ou to_json - Parseia uma Hash em Json (String)
- JSON.decode - Parseia um Json em Hash

### Active Model Serializers JSON
- as_json   - Parseia um elemento do Model (objeto) e representar como Hash. E para transformar em json basta usar o to_json.
- from_json - 

## Map/Collect
São a mesma coisa e retorna um novo array, exemplo:
```
x = [1,2,3,4,5]
x.collect {|i| i*3}
ou
x.map {|i| i*3}
```

# Migrations
Criando *migration* com Rails e passando a chave estrangeira para a tabela Contato automaticamente.
## Gerando a migration via console
O comando abaixo cria uma *migration*: *add_kind* vai criar a tabela **kind (tipo)** *to_contact (contato)* informa ao *Rails* que haverá um relacionamento da tabela *tipo* para *contato* e o *kind:references* indica ao *Rails* que deve alterar a tabela *Contact* recebe a chave estrangeira *kind_id*
```
rails g migration add_kind_to_contact kind:references
```
## Gerando o Crud de Kind
```
rails g scaffold Kind description:string
```
Para executar as *Migrates* vamos executar o comando:
```
rails db:migrate
```

#### Crie uma Task para os kind (tipos)
Adicionar os tipos de contato na: *lib/task/dev.rb*

Depois execute o comando para Apagar a tabela, criar, migrar e popular as tabelas.
```
rails db:drop db:create db:migrate dev:setup
```

> Criar o relacionamento na *Model Contact* do tipo *belongs_to*
```
belongs_to :kind
```

# I18N - Internacionalização
Trata-se da configuração e tratamento do idioma a ser exibido.
Para usar a internacionalização, primeiramente criamos um arquivo no diretório *config/initializers/locale.rb*. Exemplo:
```
#I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml')]
# É possível colocar os arquivos de traduções no diretório *lib* se preferir. Mas o arquivo locale.rb deve ser criado dentro da pasta lib e a linha de cima deve ser descomentada.

#Set default locale to something other that :en
I18n.default_locale = :'pt-BR'
```
Para traduzir nossa aplicação vou utilizar uma biblioteca (*gem 'rails-i18n'*) pronta em [Rails i18n](https://github.com/svenfuchs/rails-i18n). O passo é simples, insira no arquivo *Gemfile* essa linha ```'gem 'rails-i18n', '~> 6.0.0' # For 6.0.0 or higher'```
> **Atenção:** é importante verificar a sua versão rails para adicionar a versão correta da *Gem*.

Vamos criar o arquivo com as devidas traduções que deve ficar no diretório *config/locales/pt_br.yml* com o seguinte conteúdo.
```
'pt-BR':
  hello: "Olá Mundo"
```
Para testar vamos utilizar o console do Rails
```
rails c
```
### Exemplos no console
#### Traduzir uma chave
```
I18n.translate(hello) ou I18n.t(hello)
```
*output:* Olá Mundo.
#### Verificar o idioma padrão
```
I18n.default_locale
```
*output:* 'pt-BR'
#### Alterando o idioma
```
I18n.default_locale = :en
```
Repita o exemplo de traduzir a chave *hello*
*output:* Hello World

#### Traduções de datas - utilizaremos o comando: I18n.l() localizado no idioma padrão
```
Date.today
```
*output:* Fri, 01 May 2020
```
I18n.l(Date.today)
```
*output:* "01/05/2020"
```
I18n.default_locale = :en
I18n.l(Date.today)
```
*output:* "2020-05-01"

# Crindo a Model Telefones (Phones)
Gerar apenas o *Model*. O comando já criará a *migration* e o relacionamento *belongs_to :contact*.
```
rails g model Phone number:string contact:references
```
No *Model* Contatos o relacionamento que informa que um contato tem vários números de telefones com *has_many :phones*
### Task para popular os telefones
```
Contact.all.each do |contact|
  Random.rand(5).times do |i|
    phone = Phone.create!(number: Faker::PhoneNumber.cell_phone)
    contact.phones << phone
    contact.save!
  end
end
```
Recriar o banco de dados com todas as novas migrações.
```
rails db:drop db:create db:migrate dev:setup
```

# Dicas úteis
### Internacionalização 
Para utilizar a tradução da data para pt-br e incluir o relacionamentos. Já sabendo que o retorno em Json utiliza-se do método as_json implicitamente, faremos a sobreescrita do método no *Model*
```
# Model/Contacts.rb
def as_json(options={})
  h = super(options)
  h[:birthday] = (I18n.l(self.birthday) unless self.birthday.blank?)
  h
end
```
### Estilando o console do rails
Para ter um terminal mais elegante e estilizado. Incluir no ambiente de desenvolvimento ```gem 'pry-rails``` a biblioteca está disponível em [Pry Rails](https://github.com/rweng/pry-rails)

## Retornando e postando dados com relacionamento has_many
Para retornar os dados de um relacionamento *has_many* incluiremos no retorno do *json* na *Controller*
```
#Controller/contacts_controller.rb
render json: @contact, include: :phones
```
Para criar um novo contato postando o telefone é necessário fazer a configuração na *Model*
- Nested Attributes with has_many (atributos aninhados com muitos dados)

```
# Model/Contact.rb
accepts_nested_attributes_for :phones
```
> Relembrando com incluir um contato através de *Hash*
```
# exemplo de hash
params = {
  contact: {
    name: "Fabio", 
    email: "fabio@faker.com", 
    birthday: "2000-01-01", 
    kind_id: 3
  }
}
# exemplo para salvar através de hash somente o contato
Contact.create(params[:contact])
```
Uma forma de incluir os telefones junto com o contato e através de *Hash* com o método *attributes*
```
# exemplo que inclui o contato com telefone
params = {
  contact: {
    name: "Fabio", 
    email: "fabio@faker.com", 
    birthday: "2000-01-01", 
    kind_id: 3,
    phones_attributes: [
      {number: (11) 98765-4321},
      {number: (11) 89765-4321},
      {number: (11) 79865-4321}
    ]
  }
}
# exemplo para salvar através de hash somente o contato
Contact.create(params[:contact])
```
> Depurando erro de transação (transaction)
```
# atribuir o comando em uma variável
depuracao = Contact.create(params[:contact])
# O método erro
depuracao.errors
```
O *Model/Phone.rb* espera receber um contato sempre que está sendo criado. Para tiramos essa obrigatoriedade setamos o parâmetro *optinal: true* no *belongs_to :contact, optinal: true*

Também ajuste o *contacts_controller.rb* para permitir que o telefone seja persistido na inclusão do contato.
```
# Inclusão de phones_attributes
# Only allow a trusted parameter "white list" through.
def contact_params
  params.require(:contact).permit(:name, :email, :birthday, :kind_id, phones_attributes:[:id, :number])
end
```
### PATCH - Fazendo a atualização dos dados com relacionamento
> Na atualização de um registro é necessário passar o id na requisição. Importante lembrar que para atualizar os registros do relaciomento, também é necessário passar o id, senão será criado um novo registro.
#### Apagando registro com relacionamento
Precisamos permitir a exclusão do registro no *Model/Contact* para exclusão de forma aninhada dos respectivos telefones.
```
# Inclusão de allow_destroy em accept_nested_attributes_for
accept_nested_attributes_for :phone, allow_destroy: true
```
Também permitir a exclusão no *contact_params*
```
def contact_params
  params.require(:contact).permit(:name, :email, :birthday, :kind_id, phones_attributes:[:id, :number, :_destroy])
end
```

Na chamada do método PATCH temos que passar os parâmetros *id* e *_destroy*
```
# exemplo
{
  "contact": {
    "name": ...,
    "email": ...,
    "birthday": ...,
    "kind_id": ...,
    "phones_attributes": [
      {
        "id": 15,
        "_destroy": 1
      }
    ]
  }
}
```


# Solução de Problemas
### Fix auto-Reloading
Checa automáticamente alterações do status code no rails
```
# config/Enviroment/development.rb
config.file_watcher=ActiveSupport::FileUpdateChecker
```
### Warnings deprecate exibidos no terminal. ruby version > 2.6
```
export RUBYOPT='-W:no-deprecated'
```

