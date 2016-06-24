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
	puts @response
	
	erb :answers, :layout => :layout

end

post '/answers' do
	request = params["question"]
	num_entries = params[:num_entries].to_i
    @array = @@rfp_collection.predict(request, {top_n: num_entries}).sort_by{|k,v| v}.reverse
    #get relevance of search terms to documents returned
    @relevance = {}
    @array.each do |a|
    	a.push( Indico.relevance( a[0], request ).first )
    end
    
    erb :answers, :layout => :layout
end