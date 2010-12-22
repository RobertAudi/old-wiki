# Add the current directory to the
# load path unless it's already in there
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'sinatra/base'
require 'erb'
require 'maruku'
require 'sanitize'
require 'yaml'
require 'digest/sha2'

require File.join(File.dirname(__FILE__), 'wiki', 'helpers', 'application_helper')

require 'ap'
require 'pp'

module Wiki
  # TODO: Verify that the Application Helper is working properly
  include ApplicationHelper
  
  # Default options.
  DEFAULTS = {
    :data_dir  => 'data',
    
    # Include the . !!!
    :extension => '.markdown',
    
    # If the user creates a page with an empty content
    #  and the "Index Page?" checkbox is checked
    #  then instead of an error message, an index page
    #  with a default content will be created.
    # The index template can be found in 'templates/index.tpl.markdown'
    :enable_index_template => true
  }
end

require 'wiki/user'
require 'wiki/page'
require 'wiki/app'