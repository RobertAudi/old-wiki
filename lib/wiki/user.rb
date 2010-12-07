module Wiki
  class User

    def get
      unless @user
        user = YAML::load(File.open('config/user.yml'))
        @user = user[:user]
      end

      @user
    end

    def authenticate(user = {:username => '', :password => ''})
      get unless @user

      user[:username] == @user[:username] && user[:password] == @user[:password]
    end
    
    private
      def encrypt(user_config)
        Digest::SHA2.new << "|[({<#{user_config['salt1'].reverse}--#{user_config['username']}::#{user_config['password']}--#{user_config['salt2'].reverse}>})]|"
      end
  end
end