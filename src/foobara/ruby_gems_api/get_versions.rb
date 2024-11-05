require "uri"
require "net/http"

module Foobara
  module RubyGemsApi
    class GetVersions < Foobara::Command
      API_URL = ->(gem_name) { "https://rubygems.org/api/v1/versions/#{gem_name}.json" }

      inputs do
        gem_name :string, :required
      end

      result [Version]

      def execute
        build_request_body
        build_request_headers
        issue_http_request
        parse_response
        build_versions

        versions
      end

      attr_accessor :request_body, :request_headers, :response, :response_body, :versions

      def build_request_body
        self.request_body = {}
      end

      def build_request_headers
        self.request_headers = {
          "Content-Type" => "application/json"
        }
      end

      def url
        API_URL.call(gem_name)
      end

      def issue_http_request
        uri = URI(url)
        uri.query = URI.encode_www_form(request_body)
        self.response = Net::HTTP.get_response(uri, request_headers)
      end

      def parse_response
        json = if response.is_a?(Net::HTTPSuccess)
                 response.body
               else
                 # :nocov:
                 raise "Could not successfully hit #{url}: " \
                       "#{response.code} #{response.message}"
                 # :nocov:
               end

        self.response_body = JSON.parse(json)
      end

      def build_versions
        self.versions = response_body
      end
    end
  end
end
