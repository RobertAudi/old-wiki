module Wiki
  class App < Sinatra::Base
    
    # -Configuration----------------------------------------------------------------
    configure do
      enable :sessions

      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      set :app_file, __FILE__
      set :port, 4567

      # NOTE: is that the right way to do it?
      # Right now `bool` can be anything, it's
      #  just there to avoid a nasty error message
      set :auth do |bool|
        condition do
          redirect '/login' unless is_user?
        end
      end
    end

    # Config specific to the dev environment
    configure :development do
      enable :show_exceptions
    end
    # ------------------------------------------------------------------------------
    
    # -Helpers----------------------------------------------------------------------
    helpers do

      def is_user?
        @user != nil
      end
    end
    # ------------------------------------------------------------------------------

    before do
      @user = session[:user]
    end

    get '/' do
      erb :index
    end

    get '/login/?' do
      erb :login
    end

    post '/login' do
      user = User.new
      if user.authenticate(params)
        session[:user] = user.get
      end

      redirect '/'
    end

    get '/logout/?' do
      session[:user] = nil
      redirect '/'
    end

    post '/user/new/results/?' do
      # Validations
      error_messages = {}

      # Thought: use Sanitize: https://github.com/rgrove/sanitize/

      # params.each do |key, value|
      #   if value.empty?
      #     error_message = "The #{key.capitalize} cannot be empty"
      #     break
      #   end
      #
      # end
      erb "<%= params.inspect %>"
    end

    get '/user/new/?' do
      erb :"user/new"
    end
  end
end
