require File.join(File.dirname(__FILE__), 'modules', 'gencryptor')

module Wiki
  class User
    include Wiki::Gencryptor
    
    def get
      unless @user
        @user = YAML::load(File.open('config/user.yml'))
      end

      @user
    end

    def authenticate(user = {:username => '', :password => ''})
      return false unless user[:username] != nil && user[:password] != nil
      
      get unless @user
      
      # the encrypt method needs the user id and the salts
      [:id, :salt1, :salt2].each { |key| user[key] = @user[key] }
      
      user[:username] == @user[:username] && encrypt(user) == @user[:password]
    end
        
  end
end