require 'sinatra'
require 'indico'
require 'json'

#move this to ENV
Indico.api_key =  '42677a221b5a0133c313cc36901fcd62'

@@collections = Indico::collections()
@@rfp_collection = Indico::Collection.new("rfpresponses")

before do
  puts '[Params]'
  p params
end

get '/' do
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
    @array = Indico.keywords(response, {version: 2})
    erb :index, :layout => :layout
end

get '/answers' do
	#get the answers to a question here
	request = params["message"]

	erb :answers, :layout => :layout

end

post '/answers' do
	request = params["question"]
	num_entries = params[:num_entries].to_i
    @array = @@rfp_collection.predict(request, {top_n: num_entries}).sort_by{|k,v| v}.reverse
    #get relevance of search terms to documents returned and append to array
    @array.each do |a|
    	a.push( Indico.relevance( a[0], request ).first )
    	#a.push( Indico.text_tags(a[0], {top_n: 3}) )
    	a.push( Indico.keywords(a[0], {top_n: 3}) )
    end
    
    erb :answers, :layout => :layout
end