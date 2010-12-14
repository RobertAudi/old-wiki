module Wiki
  module UserHelper
    
    def encrypt(user_config)
      encrypted = Digest::SHA2.new << "|[({<=-#{user_config[:salt1].reverse}--#{user_config[:id]}::#{user_config[:username]}::#{user_config[:password]}--#{user_config[:salt2].reverse}-=>})]|"
      encrypted.to_s
    end

    def generate_id
      char_list = [('a'..'z'),('A'..'Z'),(0..9)].map { |r| r.to_a }.flatten
      id = ""
      42.times do
        key = rand(char_list.length)
        id << char_list[key].to_s
        char_list.slice!(key)
      end
      id
    end
  end
end