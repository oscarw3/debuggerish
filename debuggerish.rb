require 'typhoeus'
require 'byebug'

def validcontroller?(input, type)
	if ((input == "resources" || input == "groups" || input == "reservations" || input == "users") && type == "controller")
		return true
	else 
		return false
	end
end

def validoperation?(input, type)
	if ((input == "create" || input == "read" || input == "update" || input == "destroy") && type == "operation")
		return true
	else
		return false
	end
end

def checkoptions(input, type)
	if validcontroller?(input, type) || validoperation?(input, type)
		return input
	else
		if (input == "help")
			if (type == "controller")
				puts "Your options are: resources, groups, reservations and users. What controller do you want to access?"
			elsif (type == "operation")
				puts "Your options are: create, read, update, destroy. What operation do you want to do?"
			else
			end
		else
			puts "invalid action. Try again. Type 'help' for more information"
		end
		input = gets.chomp
		checkoptions(input, type)
	end
end

def checkparams(input, controller)
	if input == "display params"
		if controller == "resources"
			puts "For resources, please see the following example:"
			puts 'resource[name]=<string>, resource[description]=<string>'
		elsif controller == "groups"
			puts "For groups, please see the following example:"
			puts 'group[name]=<string>, group[resourcemanagement]=<integer>, group[reservationmanagement]=<integer>, group[usermanagement]=<integer>, group[hidden]=<boolean>'
		elsif controller == "users"
			puts "For users, please see the following example:"
			puts 'user[firstname]=<string>, user[lastname]=<string>, user[email]=<string>' 
		elsif controller == "reservations"
			puts "For reservations, please see the following example:"
			puts 'reservation[occupied]=<integer>, reservation[resource_id]=<integer>, reservation[starttime]=<datetime>, reservation[endtime]=<datetime>'
		else
		end
		puts "What parameters do you want to put in?"
		input = gets.chomp
		return checkparams(input, controller)
	else
		paramshash = {}
		input.split(', ').each do |array|
			params = array.split('=')
			paramshash[params[0]] = params[1]
		end
		#TODO: check this to make sure it works
		#{ 'resource[name]' => 'testwithtyphoues', 'resource[description]' => 'alsotest'}
		return paramshash
	end
end

def checkuser(email, token)
	request = Typhoeus::Request.new("http://localhost:3000/api/resources",
                                  method: :get,
                                  headers: { 'ContentType' => "application/json", 
                                  	'X-User-Email' => email, 
                                  	'X-User-Token' => token})
  	json = JSON.parse(request.run.response_body)
  	if json.class != [].class
  		puts "That is not a valid user email and token."
  		exit
  	end
end

def main
	puts "Welcome to the Organizerish API Debugger. Please put in your email:"
		email = gets.chomp
	puts "Please put in your API token:"
		token = gets.chomp
	checkuser(email, token)
	puts "Great you've been authenticated! What controller do you want to access? Type 'help' for options."
	input = gets.chomp
	controller = checkoptions(input, "controller")
	puts "Great, you've selected the #{controller} controller. What operation do you want to do? Type 'help' for options."
	input = gets.chomp
	operation = checkoptions(input, "operation")
	json = nil
	if operation == 'update' || operation == 'destroy'
		puts 'What id?'
		id = gets.chomp
	end
	if operation == "read"
		request = Typhoeus::Request.new("http://localhost:3000/api/#{controller}",
                                  method: :get,
                                  headers: { 'ContentType' => "application/json", 
                                  	'X-User-Email' => email, 
                                  	'X-User-Token' => token})
		json = JSON.parse(request.run.response_body)
	elsif operation == "destroy"
		request = Typhoeus::Request.new("http://localhost:3000/api/#{controller}/#{id}",
                                  method: :delete,
                                  headers: { 'ContentType' => "application/json", 
                                  	'X-User-Email' => email, 
                                  	'X-User-Token' => token})
		response = request.run.response_body
		puts response

	else
		puts "What parameters do you want to put in? Type 'display params' for an example."
		input = gets.chomp
		paramshash = checkparams(input, controller)
		
		if operation == "create"
			request = Typhoeus::Request.new("http://localhost:3000/api/#{controller}",
	                                  method: :post,
	                                  params: paramshash,
	                                  headers: { 'ContentType' => "application/json", 
	                                  	'X-User-Email' => email, 
	                                  	'X-User-Token' => token})
			json = JSON.parse(request.run.response_body)
		else #update
			 request = Typhoeus::Request.new("http://localhost:3000/api/#{controller}/#{id}",
	                                  method: :patch,
	                                  params: paramshash,
	                                  headers: { 'ContentType' => "application/json", 
	                                  	'X-User-Email' => email, 
	                                  	'X-User-Token' => token})
			request.run
		end
	end
	puts json

end

main