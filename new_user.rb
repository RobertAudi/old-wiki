# This script generates a new user config file.
# It's purposefully completely seperate from
#   the rest of the application.
# It can be used to create a new user or
#   to change the user password.
#
# TODO: convert to a thor task
# TODO: Add the -np option to just change the password
# TODO: Enable cli options (-f, --fullname, -u, -username, -p, --password)
# TODO: Maybe some minimal input validation (ie: username should not contain whitespace)
# FIXME: I need to redirect $stderr to /dev/null or something equivalent
#

require 'digest/sha2'
require 'yaml'
require 'ap' # DEBUG

# include the Gencryptor
require File.join(File.expand_path(File.dirname(__FILE__)), 'lib', 'wiki', 'modules', 'gencryptor')
include Wiki::Gencryptor

# ------------------------------------------------------------------------------

puts "A new user will now be generated. Press Ctrl-C at any time to stop the process."

temp_user = {}
[:id, :salt1, :salt2].each do |key|
  temp_user[key] = generate_id
end

# -User Input-------------------------------------------------------------------
print "Full Name (Optional): "
temp_user[:fullname] = gets.chomp

print "Username: "
temp_user[:username] = gets.chomp
if temp_user[:username].empty?
  puts "\nERROR: Username can't be blank"
  exit
end
temp_user[:fullname] = temp_user[:username] if temp_user[:fullname].empty?

system 'stty -echo' # Typed characters won't appear
print "Password: "
temp_user[:password] = gets.chomp
system 'stty echo' # Revert to default.
if temp_user[:password].empty?
  puts "\nERROR: Password can't be blank"
  exit
end
print "[Password]\n----\n"
# ------------------------------------------------------------------------------

password = encrypt(temp_user)

user = {
  :id       => temp_user[:id],
  :fullname => temp_user[:fullname],
  :username => temp_user[:username],
  :password => password,
  :salt1    => temp_user[:salt1],
  :salt2    => temp_user[:salt2]
}

# DEBUG: display the whole thing
# puts "\n"
# user.each do |key, value|
#   puts "#{key}: #{value}"
# end
# puts "\n"

# Create the temporary config file
f = File.new('config/user.sample.yml', 'w')
f.puts user.to_yaml
f.close

puts "\n\t[New File] config/user.sample.yml\n\n"
puts "Please review the file and rename it to user.yml"
# ------------------------------------------------------------------------------

