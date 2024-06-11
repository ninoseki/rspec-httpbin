# rspec-httpbin

An [httpbin](https://github.com/postmanlabs/httpbin) like Rack app for RSpec.

> [!NOTE]
> This implementation is forked from [weapp/foxyrb](https://github.com/weapp/foxyrb/).

## Install

```bash
gem install rspec-httpbin
```

## Usage

`RSpec::HTTPBin` is a Rack app. You can mount it like:

```rb
require 'capybara'
require 'rspec/httpbin'

let!(:server) do
  server = Capybara::Server.new(RSpec::HTTPBin)
  server.boot
  server
end
```

And do a test:

```rb
require 'http'

res = HTTP.get("#{server.base_url}/get")
json = JSON.parse(res.body.to_s)
expect(json['headers']['User-Agent']).to start_with('http.rb/')
```

The following API endpoints are supported:

- `/get` (GET)
- `/post` (POST)
- `/put` (PUT)
- `/delete` (DELETE)
- `/patch` (PATCH)
- `/status/{status}` (any HTTP method)

`/get`, `/post`, `put`, `/delete` and `patch` return an HTTP response with the following fields.

- `data`: Request body.
- `files`: Not implemented. TBD.
- `form`: Form data.
- `json`: JSON data.
- `args`: Parsed query strings.
- `headers`: Headers.
- `origin`: Origin.
- `url`: URL.
