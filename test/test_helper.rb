require "test/unit"
$: << File.join(File.dirname(__FILE__), '..', 'lib')
require "mocha/setup"
require "rack/test"
require 'smart_proxy_for_testing'

logdir = File.join(File.dirname(__FILE__), '..', 'logs')
FileUtils.mkdir_p(logdir) unless File.exists?(logdir)
