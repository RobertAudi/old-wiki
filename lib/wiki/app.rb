module Wiki
  class App < Sinatra::Base
    use Rack::MethodOverride
    
    # -Configuration----------------------------------------------------------------
    configure do
      enable :sessions

      set :root, File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
      set :app_file, __FILE__

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

      # Used to check if a user is logged in
      def is_user?
        @user != nil
      end

      # minimalist partial helper
      def partial(template, options={})
        erb "partials/_#{template.to_s}".to_sym, options.merge(:layout => false)
      end
    end
    # ------------------------------------------------------------------------------

    before do
      @user = session[:user]
    end

    # -Authentication---------------------------------------------------------------
    get '/login/?' do
      erb :"user/login"
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

    # -Pages------------------------------------------------------------------------
    # TODO: Try to merge the to edit GET routes
    get '/edit' do
      redirect '/edit/'
    end
    
    # "Edit page" form
    get '/edit/*' do
      if params[:splat][0].empty?
        # TODO: add flash message
        # redirect '/'
        
        erb "Empty splat"
      else
        # check if page exists first
        page = Page.new(params[:splat][0])
        folder, slash, file = params[:splat][0].rpartition("/")
        
        if page.exists?
          # Edit Existing page
          @contents = page.get
          @title    = page.title
          
          index_checkbox = false
          
          if @contents.empty?
            # Normally there will never be an empty file
            #  unless it's a file that the user created manually
            
            @method = 'post'
          else
            index_checkbox = false
              
            @method = 'put'
          end
        else
          # Create new page
          index_checkbox = !(params[:splat][0][-1] == '/' || file == 'index' || file == 'index' + DEFAULTS[:extension])
          
          @title    = ""
          @contents = ""
          @method   = 'post'
        end
        
        erb :edit, :locals => { :index_checkbox => index_checkbox }
      end
    end
    
    # Create new page
    post '/edit' do
      if params[:contents].empty?
        # TODO: Rack::Flash -> error message -> contents of file can't be empty
        # redirect "/edit/#{params[:path]}"
      end
      
      # - create folder structure
      # - save
      
      erb 'POST!'
      
      # redirect to the newly created page
    end
    
    # Edit existing page
    put '/edit' do
      if params[:contents].empty?
        # TODO: Rack::Flash -> error message -> contents of file can't be empty
        redirect "/edit/#{@path}"
      end
      
      page = Page.new(params[:path])
      page.write(params[:contents])
      
      # TODO: Rack::Flash !
      redirect "/#{params[:path]}"
    end
    
    # Display a page
    # The user can still create pages named login, logout or edit
    #  but to access them, he has to prepend the name of the page
    #  with "p/". ie: /p/edit => page named "edit".
    get %r{\/(?:p\/)?(.*)} do |path|
      page = Page.new(path)
      
      if page.exists?
        @contents = page.render
        if @contents.empty?
          redirect "/edit/#{path}"
        else
          @edit_link = File.join('/edit', path)
          erb :page
        end
      else
        redirect "/edit/#{path}"
      end
    end
  end
end