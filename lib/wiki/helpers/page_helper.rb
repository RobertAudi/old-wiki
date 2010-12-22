module Wiki
  module PageHelper
    # The rpartition method, which is used in several
    # methods of this helper, is only available in 1.9
    #  and will supposedly be implemented in 1.8.8
    
    def page_list(filepath)
      path, slash, file = filepath.rpartition('/')
      files, dirs = [], []
      Dir.new(File.dirname(filepath)).each do |f|
        unless ['.', '..', file].include?(f)
          if File.directory?(File.join(path, f))
            dirs << f
          else
            files << f
          end
        end
      end
      
      # remove the data dir from the path to have a valid url
      path = path.gsub(/^#{DEFAULTS[:data_dir]}/, '')
      
      list  = "\n<ul class=\"page-list\">\n"
      dirs.each  { |d| list << %Q(\t<li class="directory"><a href="/#{path}#{d}">#{d}</a></li>\n) }
      files.each { |f| list << %Q(\t<li class="file"><a href="/#{path}#{f}">#{f}</a></li>\n) }
      list << "</ul>\n"
      list
    end
  end
end