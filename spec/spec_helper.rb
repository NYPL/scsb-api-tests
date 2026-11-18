require 'net/http'
require 'net/https'
require 'uri'
require 'nokogiri'
require 'json'

require_relative '../logger'

# Get item status for barcode
def item_status(barcode)
  path = '/sharedCollection/itemAvailabilityStatus'

  body = {
    "barcodes": [barcode]
  }

  response = post path, body

  response = JSON.parse response.body

  response.first['itemAvailabilityStatus']
end

def item_by_barcode(barcode, deleted: false, institutions: ['NYPL'])
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": 'Barcode',
    "owningInstitutions": institutions
  }

  body = JSON.parse result.body

  if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1
    raise "Could not find item by barcode: #{barcode}"
  end

  body['searchResultRows'].first
end

def records_by(what, value)
  result = post '/searchService/search', {
    "deleted": false,
    "fieldName": what,
    "fieldValue": value,
    "owningInstitutions": [
      'NYPL'
    ]
  }

  body = JSON.parse result.body

  if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1
    raise "Could not find item by #{what}: #{value}"
  end

  body['searchResultRows']
end

def records_by_bib_id(bibid)
  records_by('OwningInstitutionBibId', bibid)
end

# Fetch all bnums associated with barcode (i.e. bound-with)
def bnums_by_barcode(barcode, deleted: false)
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": 'Barcode',
    "owningInstitutions": [
      'NYPL'
    ]
  }

  body = JSON.parse result.body

  if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1
    raise "Could not find item by barcode: #{barcode}"
  end

  body['searchResultRows'].map { |res| res['owningInstitutionBibId'] }
end

# Fetch all bnums associated with barcode (i.e. bound-with)
def holdings_ids_by_barcode(barcode, deleted: false)
  result = post '/searchService/search', {
    "deleted": deleted,
    "fieldValue": barcode,
    "fieldName": 'Barcode',
    "owningInstitutions": [
      'NYPL'
    ]
  }

  body = JSON.parse result.body

  if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1
    raise "Could not find item by barcode: #{barcode}"
  end

  body['searchResultRows'].map { |res| res['owningInstitutionHoldingsId'] }
end

def update_item(institution, which)
  data = File.open("./spec/data/#{which}").read
  path = "/sharedCollection/submitCollection?institution=#{institution}&isCGDProtected=false"
  response = post path, data

  Logger.debug "POSTed the following to #{path}:\n\n#{data}\n\nResulting in http status #{response.code} response with body:\n\n#{response.body}"
end

def items_by_bnum(bnum, institution: 'NYPL')
  result = post '/searchService/search', {
    "deleted": false,
    "fieldValue": bnum,
    "fieldName": 'OwningInstitutionBibId',
    "owningInstitutions": [
      institution
    ]
  }

  body = JSON.parse result.body

  if body.nil? || body['searchResultRows'].nil? || body['searchResultRows'].size < 1
    raise "Could not find items by bnum: #{bnum}"
  end

  items = body['searchResultRows']
  items = items.first['searchItemResultRows'] unless items.first['searchItemResultRows'].empty?
  items
end

def post(path, body = nil, _options = {})
  # Logger.debug "POSTing the following to #{path}:\n#{body.nil? ? '""' : body.to_json}\n"

  uri = URI.parse("#{ENV['BASE_URL']}#{path}")

  request = Net::HTTP::Post.new(uri, 'api_key' => ENV['API_KEY'])

  unless body.nil?
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

  Logger.debug "POSTed the following to #{path}:\n#{body.to_json}\n\nResulting in http status #{response.code} (Content-Type #{response['Content-Type']}) response with body:\n#{response.body}\n" unless _options[:quiet]

  response
end

def get(path, _options = {})
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

def select_random_nypl_records(count=1, item_count=nil)
  path = '/searchService/search'
  body = {
    'owningInstitutions': ['NYPL'],
    'collectionGroupDesignations': ['Shared'],
    'availability': ['Available'],
    'pageSize': 100,
    'fieldName': 'Title_search',
    'fieldValue': ['type', 'source', 'book', 'manuscript', 'pamphlet', 'record'].sample
  }
  response = post path, body, { quiet: true }
  results = JSON.parse response.body

  r = results['searchResultRows'].select do |bib|
    item_count.nil? || !bib['searchItemResultRows'] || bib['searchItemResultRows'].size == 1
  end
    .sample(count)
  if r.empty?
    raise "Could not find random records for search #{body}"
  end

  r
end

def select_random_nypl_barcode
  select_random_nypl_barcodes(1).first
end

def select_random_nypl_barcodes(count=10, item_count=nil)
  records = select_random_nypl_records(count, item_count)

  barcodes = []
  records.each do |bib|
    barcodes << bib['barcode'] if bib['barcode']
    if bib['searchItemResultRows']
      item_barcodes = bib['searchItemResultRows']
                      .filter { |item| item['collectionGroupDesignation'] == 'Shared' }
                      .map { |item| item['barcode'] }
      barcodes.concat(item_barcodes)
    end
  end
  barcodes
end

def parse_xml(content)
  doc = Nokogiri::XML(content)
  doc.remove_namespaces!
  doc
end

def query_string(h)
  URI.encode_www_form(h)
end
