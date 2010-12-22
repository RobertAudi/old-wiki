require File.join(File.dirname(__FILE__), 'helpers', 'page_helper')

module Wiki
  class Page
    include Wiki::PageHelper

    attr_reader :path, :type, :file, :contents, :raw_contents
    
    # Description of the instance variables:
    # - path: The path retrieved from the uri
    # - file: The full path to the file, including the extension
    #         If the path given points to a folder, then index.markdown
    #         will be present in the file variable.
    # - type: File or Folder. This is not the actual file type,
    #         it's the file type deducted by the uri.
    # - raw_contents: The raw contents of the file in markdown;
    #                 also includes the calls to list_pages.
    # - contents: The contents of the page, rendered in HTML.
    def initialize(path)
      @path = process(path)
    end

    # FIXME: This method should check for both file and folder
    #   There shouldn't be a file and a folder with the same name
    #   (not taking the file extension in condideration)
    def exists?
      if file?
        file = has_extension?(@path) ? @path : @path + DEFAULTS[:extension]
        if check_for_file(file)
          @file = file
          return true
        end
        
        file = File.join(@path, "index" + DEFAULTS[:extension])
        if check_for_folder(file)
          @file = file
          return true
        end
      elsif folder?
        file = File.join(@path, "index" + DEFAULTS[:extension])
        if check_for_folder(file)
          @file = file
          return true
        end
        
        file = @path + DEFAULTS[:extension]
        if check_for_file(file)
          @file = file
          return true
        end
      end
      
      @file = ""
      return false
    end

    def create
      # Can't create a page that already exists!
      return false if exists?
    end

    # Attribute Reader method used to generate and return a
    #  help message if there is the need for one.
    def help
      
    end
    

    # Get the title of a page (if it has one)
    # The title retrieved is the contents of the h1 tag
    #
    # Notes on this method:
    #  Extracting the title of a page written in markdown can be a pain in the ass
    #  So, I set one rule that would make the whole process a little bit easier:
    #
    #   The title should be at the top of the file, spread over one or two lines
    #    depending on what format it is in - more info on that here:
    #    http://daringfireball.net/projects/markdown/syntax#header
    #
    # There may be more efficient ways to do it, but that's not a priority
    def title
      get if @raw_contents.nil? || @raw_contents.empty?

      # A maximum of two lines should be passed to Maruku
      title = @raw_contents.split("\n", 3)
      lc = title.length
      if lc == 2
        title.pop unless title[1][0] == "="
      elsif lc > 2
        title.pop
        title.pop unless title[1][0] == "="
      end
      title = title.join("\n")
      
      # Finally get the title
      title = Maruku.new(title).to_html
      title  = title.match(/\<h1(?:[ \t]*(?:.{2,}=["'].*["'])*[ \t]*)\>(?<title>.*)\<\/h1\>/)
      if title.nil?
        @title = ""
      else
        @title = title[:title]
      end
      
      @title
    end

    # Get the raw contents of a page
    def get
      return @raw_contents unless @raw_contents.nil? || @raw_contents.empty?
      exists? if @file == nil
      return "" if @file.empty?

      file          = File.join(DEFAULTS[:data_dir], @file)
      @raw_contents = File.read(file)
      @raw_contents
    end

    def write(contents)
      # TODO: raise error instead!
      return false if contents.nil? || contents.empty?
      return false unless exists?
      
      File.open(File.join(DEFAULTS[:data_dir], @file), 'w') do |f|
        f.write(contents)
      end
      
      true
    end
    
    # Render a page in HTML
    def render
      @raw_contents = get
      file          = File.join(DEFAULTS[:data_dir], @file)
      contents      = @raw_contents.gsub(/^[ \t]*\{{2}\s*list_pages\s*\}{2}[ \t]*$/, page_list(file))
      
      @contents     = Maruku.new(contents).to_html
      @contents
    end
    
    def file?
      @type == 'file'
    end
    
    def folder?
      @type == 'folder'
    end
    
    private
      
      # Process the given path, checks if it's a file or a folder
      #  and sets the @type instance variable accordingly.
      def process(path)
        if has_extension?(path)
          @type = 'file'
        else
          @type = (path[-1] == '/') ? 'folder' : 'file'
        end
        
        path.chomp('/')
      end
      
      def has_extension?(path)
        path, slash, file = path.rpartition('/')
        file, dot, extention = file.rpartition('.')
        !dot.empty?
      end
      
      def check_for_file(path)
        return File.exists?(File.join(DEFAULTS[:data_dir], path))
      end
      
      def check_for_folder(path)
        return File.directory?(File.join(DEFAULTS[:data_dir], @path)) && File.exists?(File.join(DEFAULTS[:data_dir], path))
      end
      
  end
end
