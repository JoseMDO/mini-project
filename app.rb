require "sinatra"
require "sinatra/reloader"
require "http"



get("/") do

  erb(:homepage)
end


post("/results") do 
  first = params.fetch("first_fighter").strip()
  second = params.fetch("second_fighter").strip()
  superhero_access_token = ENV.fetch("SUPERHERO_ACCESS_TOKEN")

  ## THIS SEARCHES FOR THE SUPERHERE IN THE API. IF IT DOES NOT EXIST IT WIL MAKE THE USER TYPE THEM IN AGAIN
  first_resp = HTTP.get('https://www.superheroapi.com/api.php/'+ superhero_access_token + '/search/'+first)
  first_raw_response = first_resp.to_s
  first_parsed_response = JSON.parse(first_raw_response)
  if first_parsed_response.fetch('response') == "error"
    redirect to ('/')
  end


  second_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/search/'+second)
  second_raw_response = second_resp.to_s
  second_parsed_response = JSON.parse(second_raw_response)
  if second_parsed_response.fetch('response') == "error"
    redirect to ('/')
  end

  def index_finder(results, name)
    found = false
    results.each do |result|
      if result.fetch("name").downcase === name.downcase
        found = true
        return result.fetch('id')
      end
    end
    if found == false
      redirect("/")
    end
  end

  first_id = index_finder(first_parsed_response.fetch("results"), first)
  second_id = index_finder(second_parsed_response.fetch("results"), second)

  first_name_response = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ first_id)
  first_name_parsed = JSON.parse(first_name_response.to_s)
  @first_name = first_name_parsed.fetch("name")

  second_name_response = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ second_id)
  second_name_parsed = JSON.parse(second_name_response.to_s)
  @second_name = second_name_parsed.fetch("name")

  first_powerstats_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ first_id + '/powerstats')
  first_parsed_powerstats = JSON.parse(first_powerstats_resp.to_s)
  @first_intelligence = first_parsed_powerstats.fetch("intelligence").to_i
  @first_strength = first_parsed_powerstats.fetch("strength").to_i
  @first_speed = first_parsed_powerstats.fetch("speed").to_i
  @first_durability = first_parsed_powerstats.fetch("durability").to_i
  @first_power = first_parsed_powerstats.fetch("power").to_i
  @first_combat = first_parsed_powerstats.fetch("combat").to_i

  @first_total = @first_intelligence + @first_strength + @first_speed + @first_durability + @first_power + @first_combat

  second_powerstats_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ second_id + '/powerstats')
  second_parsed_powerstats = JSON.parse(second_powerstats_resp.to_s)

  @second_intelligence = second_parsed_powerstats.fetch("intelligence").to_i
  @second_strength = second_parsed_powerstats.fetch("strength").to_i
  @second_speed = second_parsed_powerstats.fetch("speed").to_i
  @second_durability = second_parsed_powerstats.fetch("durability").to_i
  @second_power = second_parsed_powerstats.fetch("power").to_i
  @second_combat = second_parsed_powerstats.fetch("combat").to_i

  @second_total = @second_intelligence + @second_strength + @second_speed + @second_durability + @second_power + @second_combat


  first_image_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ first_id + '/image')
  first_image_parsed = JSON.parse(first_image_resp.to_s)
  @first_image = first_image_parsed.fetch("url")
  second_image_resp = HTTP.get('https://superheroapi.com/api.php/'+ superhero_access_token + '/'+ second_id + '/image')
  second_image_parsed = JSON.parse(second_image_resp.to_s)
  @second_image = second_image_parsed.fetch("url")

  if @first_total > @second_total 
    @result = @first_name
    @winner_image = @first_image
    @winner_total = @first_total
  elsif @second_total > @first_total 
    @result = @second_name
    @winner_image = @second_image
    @winner_total = @second_total
  elsif @first_total == @second_total
    @result = 'tie'
  end


  erb(:results)

end
