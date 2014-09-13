# Smart-proxy Chef plugin 

This a plugin for foreman smart-proxy allowing uploading facts and reports
from chef-client to a foreman and provides API for foreman to communicate
with chef-server.

## Installation

Add this line to your smart proxy bundler.d/chef.rb gemfile:

```ruby
gem 'smart_proxy_chef'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smart-proxy-chef

## Usage

To configure this plugin you can use template from settings.d/chef.yml.example.
You must place chef.yml config file (based on this template) to your 
smart-proxy config/settings.d/ directory.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/smart-proxy-chef/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
