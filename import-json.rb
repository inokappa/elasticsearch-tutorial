require "net/http"
require "uri"
require "json"

class AbemaTvSchedule
  ENDPOINT = "http://localhost:9200"

  def initialize(date, slots = [])
    @date = date
    @slots = slots
  end

  def post_index
    uri = URI.parse("#{ENDPOINT}/_bulk")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req["Content-Type"] = "application/json"
    req.body = bulk_data
    res = http.request(req)
    puts "#{res.code} #{res.body}"
  end

  private

  def bulk_data
    docs = ''
    @slots.each do |slot|
      doc_id = slot['id']
      doc = <<~EOS
      {"index":{"_id":"#{doc_id}","_index":"abema-channel-#{@date}","_type":"_doc"}}
      #{JSON.dump(slot)}
      EOS
      docs << doc
    end
    docs
  end
end

hash = JSON.parse File.read('abema-tv1.json')
hash.each do |c|
  next if c['slots'].empty?
  AbemaTvSchedule.new(c['date'], c['slots']).post_index
end
