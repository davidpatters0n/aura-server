require 'sinatra'
require './lib/visa_api_client'
require 'json'
require 'sinatra/cross_origin'
require 'pry'
require 'net/http'

configure do
  enable :cross_origin
end

get '/' do
  content_type :json
  @strDate = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
    @visa_api_client = VisaAPIClient.new
    address = params.any? ? params['address'] : 'Oxford Circus, London'

    @atmInquiryRequest = {
      requestData: {
        culture: 'en-gb',
        distance: '20',
        distanceUnit: 'mi',
        location: {
          placeName: address
        },
        options: {
          range: {
            count: 20
          }
        }
      },
      wsRequestHeaderV2: {
        applicationId: "VATMLOC",
        correlationId: "909420141104053819418",
        requestMessageId: "test12345678",
        requestTs: "#{@strDate}",
        userBid: "10000108",
        userId: "CDISIUserID"
      }
    }

  base_uri = 'globalatmlocator/'
  resource_path = 'v1/localatms/atmsinquiry'
  visa_response = @visa_api_client.doMutualAuthRequest("#{base_uri}#{resource_path}", "Locate ATM test", "post", @atmInquiryRequest.to_json)
  JSON.parse(visa_response)['responseData'][0]["matchedLocations"].to_json
end

get '/current-location' do
  content_type :json

  Net::HTTP.get(URI('http://api.wipmania.com/json'))
end

