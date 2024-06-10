require "forwardable"

require_relative "httpbin/version"

module RSpec
  class HTTPBin
    extend Forwardable

    class << self
      def call(env)
        new(env).call
      end
    end

    # @return [Rack::Request] Rack request
    attr_reader :req

    def initialize(env)
      @req = Rack::Request.new(env)
    end

    def_delegators :req, :content_type, :form_data?, :get?, :post?, :delete?, :url, :query_string, :path, :path_info,
      :patch?, :put?, :env

    def call
      case path_info
      when "/get"
        get? ? ok_response : error_405
      when "/post"
        post? ? ok_response : error_405
      when "/delete"
        delete? ? ok_response : error_405
      when "/put"
        put? ? ok_response : error_405
      when "/patch"
        patch? ? ok_response : error_405
      when %r{^/status/[0-9]+$}
        status = path_info.split("/").last
        status_response status
      else
        error_404
      end
    end

    def headers
      http_headers = env.select { |k, _v| k.start_with?("HTTP_") }
      http_headers.transform_keys do |k|
        k.sub(/^HTTP_/, "").downcase.gsub(/(^|_)\w/, &:upcase).tr("_", "-")
      end
    end

    def json?
      content_type == "application/json"
    end

    def origin
      env["REMOTE_ADDR"]
    end

    def body
      @body ||= [].tap do |out|
        req.body.rewind
        out << req.body.read
        req.body.rewind
      end.first || ""
    end

    def files
      return nil unless post? && Rack::Multipart::MULTIPART.match?(content_type)

      @files ||= [].tap do |out|
        multipart = Rack::Multipart.parse_multipart(env)
        out << multipart.to_h.map do |k, v|
          [k, v[:tempfile].read]
        end.to_h
      rescue
        # do nothing
      end.first
    end

    def form
      Rack::Utils.parse_nested_query(body) if form_data?
    end

    def json
      JSON.parse(body) if json?
    end

    def data
      return "" if form_data? || !files.nil?

      body
    end

    def body_payload
      return {} if body.empty?

      {data:, files:, form:, json:}
    end

    def ok_response
      payload = body_payload.merge(args: query_string, headers:, origin:, url:)

      ["200", {"Content-Type" => "application/json"}, [JSON.generate(payload)]]
      ["200", {"Content-Type" => "text/plain"}, [JSON.generate(payload)]]
    end

    def status_response(status)
      [status, {"Content-Type" => "text/plain"}, [JSON.generate({})]]
    end

    def error_404
      ["404", {"Content-Type" => "application/json"}, [JSON.generate({})]]
    end

    def error_405
      ["405", {"Content-Type" => "application/json"}, [JSON.generate({})]]
    end
  end
end
