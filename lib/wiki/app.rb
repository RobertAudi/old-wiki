module Wiki
  class App < Sinatra::Base
    
    # -Configuration----------------------------------------------------------------
    configure do
      enable :sessions

      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      set :app_file, __FILE__

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
      else
        # Tell the user to fuck off, FAILED TO LOG IN!
      end

      redirect '/'
    end

    get '/logout/?' do
      session[:user] = nil
      redirect '/'
    end

    post '/user/new/results/?' do
      # TODO: Form Validations
      # Create a user only if there isn't one already
    end

    get '/user/new/?' do
      erb :"user/new"
    end
    
    get '/test' do
      # placeholder test page
      
      redirect '/'
    end
  end
end
