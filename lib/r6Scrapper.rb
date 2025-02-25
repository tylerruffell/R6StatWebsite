#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'json'

puts "The scraper is running!"

# Record the start time
start_time = Time.now

# Generate URLs dynamically (pages 1 to 50)
base_url = 'https://r6.tracker.network/r6siege/leaderboards?platformFamily=pc&season=36&gamemode=pvp_ranked&board=RankPoints&page='
urls = (1..50).map { |page| "#{base_url}#{page}" }

# Function to scrape a page
def scrape_page(url)
  response = Net::HTTP.get_response(URI(url))
  return [] unless response.code == "200"
  
  html_content = response.body[116000..-1] # Slice content
  doc = Nokogiri::HTML(html_content)

  user_ids = []
  doc.to_html.scan(/"platformUserIdentifier":"(.*?)"/) do |match|
    user_ids << match[0]
  end
  
  user_ids
end

# Store results from threads
results = []
threads = []

# Start threads for each URL
urls.each do |url|
  threads << Thread.new { results.concat(scrape_page(url)) }
end

# Wait for all threads to complete
threads.each(&:join)

# Remove duplicates
unique_results = results.uniq

if unique_results.empty?
  puts "No platformUserIdentifier found!"
else
  puts "Extracted #{unique_results.length} unique User IDs:"
  puts unique_results
end

# Record the end time
end_time = Time.now

# Calculate the runtime
elapsed_time = end_time - start_time
puts "Script executed in #{elapsed_time.round(2)} seconds."
