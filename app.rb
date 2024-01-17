require "sinatra"
require "sinatra/reloader"
require "http"



get("/") do

  erb(:homepage)
end


post("/results") do 
  @first = params.fetch("first_fighter")
  @second = params.fetch("second_fighter")

  superhero_access_token = ENV.fetch("SUPERHERO_ACCESS_TOKEN")

  first_resp = HTTP.get('https://www.superheroapi.com/api.php/'+ superhero_access_token + '/search/'+@first)
  @first_raw_response = first_resp.to_s
  @first_parsed_response = JSON.parse(@first_raw_response)


  second_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/search/'+@second)
  @second_raw_response = second_resp.to_s
  @second_parsed_response = JSON.parse(@second_raw_response)

  @first_id = @first_parsed_response.dig("results", 0, "id")
  @second_id = @second_parsed_response.dig("results", 0, "id")

  @first_powerstats_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ @first_id + '/powerstats')
  @first_parsed_powerstats = JSON.parse(@first_powerstats_resp.to_s)
  first_intelligence = @first_parsed_powerstats.fetch("intelligence").to_i
  first_strength = @first_parsed_powerstats.fetch("strength").to_i
  first_speed = @first_parsed_powerstats.fetch("speed").to_i
  first_durability = @first_parsed_powerstats.fetch("durability").to_i
  first_power = @first_parsed_powerstats.fetch("power").to_i
  first_combat = @first_parsed_powerstats.fetch("combat").to_i

  @first_total = first_intelligence + first_strength + first_speed + first_durability + first_power + first_combat

  @second_powerstats_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ @second_id + '/powerstats')
  @second_parsed_powerstats = JSON.parse(@second_powerstats_resp.to_s)

  second_intelligence = @second_parsed_powerstats.fetch("intelligence").to_i
  second_strength = @second_parsed_powerstats.fetch("strength").to_i
  second_speed = @second_parsed_powerstats.fetch("speed").to_i
  second_durability = @second_parsed_powerstats.fetch("durability").to_i
  second_power = @second_parsed_powerstats.fetch("power").to_i
  second_combat = @second_parsed_powerstats.fetch("combat").to_i

  @second_total = second_intelligence + second_strength + second_speed + second_durability + second_power + second_combat

  if @first_total > @second_total 
    @result = params.fetch("first_fighter")
  elsif @second_total > @first_total 
    @result = params.fetch("second_fighter")
  elsif @first_total == @second_total
    @result = 'tie'
  end

  
  erb(:results)

end
