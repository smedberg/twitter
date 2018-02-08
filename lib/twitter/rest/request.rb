require 'addressable/uri'
require 'faraday'
require 'json'
require 'timeout'
require 'twitter/error'
require 'twitter/headers'
require 'twitter/rate_limit'
require 'channels/log_helper'

module Twitter
  module REST
    class Request
      attr_accessor :client, :headers, :options, :rate_limit, :request_method,
                    :path, :uri
      alias_method :verb, :request_method

      include ::Channels::LogHelper

      # @param client [Twitter::Client]
      # @param request_method [String, Symbol]
      # @param path [String]
      # @param options [Hash]
      # @return [Twitter::REST::Request]
      def initialize(client, request_method, path, options = {})
        @client = client
        @request_method = request_method.to_sym
        @path = path
        @uri = Addressable::URI.parse(client.connection.url_prefix + path)
        set_timeout_options!(options)
        @options = options
      end

      def set_timeout_options!(options)
        @timeout = options.delete(:timeout)
        @open_timeout = options.delete(:open_timeout)
      end

      # @return [Array, Hash]
      def perform
        @headers = Twitter::Headers.new(@client, @request_method, @uri.to_s, @options).request_headers
        begin
          response = nil
          duration = Benchmark.ms do
            response = @client.connection.send(@request_method, @path, @options) do |request|
              request.headers.update(@headers)
              request.options.timeout = @timeout.to_i if @timeout
              request.options.open_timeout = @open_timeout.to_i if @open_timeout
            end.env
          end
        rescue Faraday::Error::TimeoutError, Timeout::Error => error
          raise(Twitter::Error::RequestTimeout.new(error))
        rescue Faraday::Error::ClientError, JSON::ParserError => error
          raise(Twitter::Error.new(error))
        end
        @rate_limit = Twitter::RateLimit.new(response.response_headers)
        body = response.body
        log("Twitter response body nil. URI: #{@uri}, Time taken: #{duration}, Status: #{response.status}, Headers: #{response.response_headers}") if body.nil?
        body
      end
    end
  end
end
