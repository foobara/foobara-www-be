require "uri"
require "net/http"

module Foobara
  module RubyGemsApi
    class Search < Foobara::Command
      API_URL = "https://rubygems.org/api/v1/search.json".freeze

      inputs do
        query :string, :required
      end

      result ::Array

      def execute
        build_request_body
        build_request_headers
        issue_http_request
        parse_response
        build_gems

        gems
      end

      attr_accessor :request_body, :request_headers, :response, :response_body, :gems

      def build_request_body
        self.request_body = { query: }
      end

      def build_request_headers
        self.request_headers = {
          "Content-Type" => "application/json"
        }
      end

      def issue_http_request
        uri = URI(API_URL)
        uri.query = URI.encode_www_form(request_body)
        self.response = Net::HTTP.get_response(uri, request_headers)
      end

      def parse_response
        json = if response.is_a?(Net::HTTPSuccess)
                 response.body
               else
                 binding.pry
                 # :nocov:
                 raise "Could not successfully hit #{API_URL}: " \
                       "#{response.code} #{response.message}"
                 # :nocov:
               end

        self.response_body = JSON.parse(json)
      end

      def build_gems
        self.gems = response_body
      end
    end
  end
end
