require "capybara"
require "http"

RSpec.describe RSpec::HTTPBin do
  let!(:server) do
    server = Capybara::Server.new(described_class)
    server.boot
    server
  end

  it "has a version number" do
    expect(RSpec::HTTPBin::VERSION).not_to be_nil
  end

  describe ".get" do
    context "with 200" do
      it do
        res = HTTP.get("#{server.base_url}/get")
        json = JSON.parse(res.body.to_s)
        expect(json["headers"]["User-Agent"]).to start_with("http.rb/")
      end
    end

    context "with 404" do
      it do
        res = HTTP.get("#{server.base_url}/status/404")
        expect(res.status).to eq(404)
      end
    end

    context "with timeout" do
      it do
        expect do
          HTTP.timeout(-1).get("#{server.base_url}/get")
        end.to raise_error(::HTTP::TimeoutError)
      end
    end
  end

  describe ".post" do
    context "with application/x-www-form-urlencoded" do
      let!(:form) { {foo: "bar"} }
      let(:headers) { {"content-type": "application/x-www-form-urlencoded"} }

      it do
        res = HTTP.headers(headers).post("#{server.base_url}/post", form:)
        data = JSON.parse(res.body.to_s)
        expect(data.dig("form", "foo")).to eq("bar")
      end
    end

    context "with application/json" do
      let!(:json) { {foo: "bar"} }
      let(:headers) { {"content-type": "application/json"} }

      it do
        res = HTTP.headers(headers).post("#{server.base_url}/post", json:)
        data = JSON.parse(res.body.to_s)
        inner_data = JSON.parse(data["data"])
        expect(inner_data["foo"]).to eq("bar")
      end
    end

    context "with file" do
      it do
        res = HTTP.post("#{server.base_url}/post", form: {
          file: HTTP::FormData::File.new("README.md")
        })
        data = JSON.parse(res.body.to_s)
        expect(data.dig("files", "file")).not_to be_nil
      end
    end
  end
end

{
  "data" => "",
  "files" => nil,
  "form" => {"-----------------------615305f916e353d4c2545c7367992f123e79d82a35\r\nContent-Disposition: form-data; name" => "\"file\"; filename=\"README.md\"\r\nContent-Type: application/octet-stream\r\n\r\n# rspec-httpbin\n\nAn [httpbin](https://github.com/postmanlabs/httpbin) like Rack app for RSpec.\n\n> [!NOTE]\n> This implementation is forked from [weapp/foxyrb](https://github.com/weapp/foxyrb/).\n\n## Install\n\n```bash\ngem install rspec-httpbin\n```\n\n## Usage\n\n`RSpec::HTTPBin` is a Rack app. You can mount it like:\n\n```rb\nrequire 'capybara'\n\nlet!(:server) do\n  server = Capybara::Server.new(RSpec::HTTPBin)\n  server.boot\n  server\nend\n```\n\nAnd do a test:\n\n```rb\nrequire 'http'\n\nres = HTTP.get(\"\#{server.base_url}/get\")\njson = JSON.parse(res.body.to_s)\nexpect(json['headers']['User-Agent']).to start_with('http.rb/')\n```\n\nThe following API endpoints are supported:\n\n- `/get` (GET)\n- `/post` (POST)\n- `/put` (PUT)\n- `/delete` (DELETE)\n- `/patch` (PATCH)\n- `/status/{status}` (any HTTP method)\n\n`/get`, `/post`, `put`, `/delete` and `patch` return an HTTP response with the following fields.\n\n- `data`: Request body.\n- `files`: Not implemented. TBD.\n- `form`: Form data.\n- `json`: JSON data.\n- `args`: Parsed query strings.\n- `headers`: Headers.\n- `origin`: Origin.\n- `url`: URL.\n\r\n-----------------------615305f916e353d4c2545c7367992f123e79d82a35--\r\n"}, "json" => nil, "args" => "",
  "headers" => {"Connection" => "close", "Host" => "127.0.0.1:62952", "User-Agent" => "http.rb/5.2.0", "Version" => "HTTP/1.1"}, "origin" => "127.0.0.1", "url" => "http://127.0.0.1:62952/post"
}
