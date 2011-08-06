module CouchView
  class QueryOptions
    attr_reader :options
    
    def initialize(view_proxy, options={})
      @view_proxy = view_proxy
      @options    = options
    end
    
    def method_missing(option_name, *args, &block)
      option_name = option_name.to_s

      if is_exclamatory? option_name 
        @options[option_name[0...-1]] = args.first
        @view_proxy
      else
        new_proxy                = @view_proxy.dup
        new_options              = @options.dup.merge option_name => args.first
        new_proxy._query_options = CouchView::QueryOptions.new new_proxy, new_options
        new_proxy
      end
    end

    def to_hash
      @options
    end
    
    private
    def is_exclamatory?(option_name="")
      option_name.to_s[-1..-1] == "!"
    end
  end
end
