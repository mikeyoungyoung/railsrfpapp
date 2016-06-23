require 'sinatra'
require 'indico'
require 'json'

#move this to ENV
Indico.api_key =  '42677a221b5a0133c313cc36901fcd62'

@@collections = Indico::collections()
@@rfp_collection = Indico::Collection.new("rfpresponses")

get '/' do
  #'Hello World'
  @sent = 0.0
  @array = Indico::collections()
  
  erb :index, :layout => :layout
end

post '/' do
	#add questions and responses to the rfpresponses collection
	question = params["question"]
	response = params["response"]
    @@rfp_collection.add_data([question, response])
    @@rfp_collection.train()
    @test_resp = Indico.keywords(response, {version: 2})
    @array = Indico.keywords(response, {version: 2}) #["this", "is","sparta!"]
    erb :index, :layout => :layout
end

get '/answers' do
	#get the answers to a question here
	request = params["message"]
	puts request
	#@response = Indico.keywords(request, {version: 2})
	puts @response

	#{}"This is the response"
	erb :answers, :layout => :layout

end

post '/answers' do
	request = params["question"]
    @array = @@rfp_collection.predict(request) #Indico.keywords(request, {version: 2})
    #{}"#{resp}"

    erb :answers, :layout => :layout
end