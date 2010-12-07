# Add the current directory to the
# load path unless it's already in there
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'erb'
require 'yaml'
require 'digest/sha2'

module Wiki
end

require 'wiki/user'
require 'wiki/app'

