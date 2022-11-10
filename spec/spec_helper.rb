require 'net/http'
require 'net/https'
require 'uri'
require 'nokogiri'
require 'json'

require_relative '../logger'

# Get item status for barcode
def item_status (barcode)
  path = '/sharedCollection/itemAvailabilityStatus'

  body = {
    "barcodes": [barcode]
  }

  response = post path, body

  response = JSON.parse response.body

  response.first["itemAvailabilityStatus"]
end

def item_by_barcode (barcode, deleted: false, institutions: ['NYPL'])
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": "Barcode",
    "owningInstitutions": institutions
  }

  body = JSON.parse result.body

  raise "Could not find item by barcode: #{barcode}" if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1

  body['searchResultRows'].first
end

# Fetch all bnums associated with barcode (i.e. bound-with)
def bnums_by_barcode (barcode, deleted: false)
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": "Barcode",
    "owningInstitutions": [
      "NYPL"
    ]
  }

  body = JSON.parse result.body

  raise "Could not find item by barcode: #{barcode}" if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1

  body['searchResultRows'].map { |res| res['owningInstitutionBibId'] }
end

# Fetch all bnums associated with barcode (i.e. bound-with)
def holdings_ids_by_barcode (barcode, deleted: false)
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": "Barcode",
    "owningInstitutions": [
      "NYPL"
    ]
  }

  body = JSON.parse result.body

  raise "Could not find item by barcode: #{barcode}" if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1

  body['searchResultRows'].map { |res| res['owningInstitutionHoldingsId'] }
end

def update_item (institution, which)
  data = File.open("./spec/data/#{which}").read
  path = "/sharedCollection/submitCollection?institution=#{institution}&isCGDProtected=false"
  response = post path, data

  Logger.debug "POSTed the following to #{path}:\n\n#{data}\n\nResulting in http status #{response.code} response with body:\n\n#{response.body}"
  puts 'response:'
  p response
end

def items_by_bnum (bnum, institution: 'NYPL')
  result = post '/searchService/search', {
    "deleted": false,
    "fieldValue": bnum,
    "fieldName": "OwningInstitutionBibId",
    "owningInstitutions": [
      institution
    ]
  }

  body = JSON.parse result.body

  raise "Could not find items by bnum: #{bnum}" if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1

  items = body['searchResultRows']
  items = items.first['searchItemResultRows'] unless items.first['searchItemResultRows'].empty?
  items
end


def post (path, body = nil , options = {})
  Logger.debug "POSTing the following to #{path}:\n\n#{body.nil? ? '""' : body.to_json}"

  uri = URI.parse("#{ENV['BASE_URL']}#{path}")

  request = Net::HTTP::Post.new(uri, 'api_key' => ENV['API_KEY'])

  if !body.nil?
    request.body = body
    # Some endpoints require a Content-Type of application/json (submitCollection) even if we're not posting json...
    request['Content-Type'] = 'application/json'

    if body.is_a?(Hash) || body.is_a?(Array)
      request.body = body.to_json
      request['Content-Type'] = 'application/json'
    end
  end

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme === 'https') do |http|
    http.request(request)
  end

  Logger.debug "POSTed the following to #{path}:\n#{body.to_json}\n\nResulting in http status #{response.code} (Content-Type #{response['Content-Type']}) response with body:\n#{response.body}\n"

  response
end

def get (path, options = {})
  # options = parse_http_options options

  # Logger.debug "Fetching path: #{path}"

  uri = URI.parse("#{ENV['BASE_URL']}#{path}")

  request = Net::HTTP::Get.new(uri, 'api_key' => ENV['API_KEY'])

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme === 'https') do |http|
    http.request(request)
  end

  Logger.debug "Fetched the following path: #{path}\n\nResulting in http status #{response.code} response with body:\n#{response.body}\n"

  response
end

def parse_xml (content)
  doc = Nokogiri::XML(content)
  doc.remove_namespaces!
  doc
end

def query_string(h)
  return URI.encode_www_form(h)
end


