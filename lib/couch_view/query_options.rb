module CouchView
  class QueryOptions
    attr_reader :options
    
    def initialize(view_proxy, options={})
      @view_proxy = view_proxy
      @options    = options
    end
    
    def method_missing(option_name, *args, &block)
      set_query_option option_name.to_s, args.first
    end

    def to_hash
      @options
    end
    
    private
    def ends_in_exclamation?(option_name="")
      option_name.to_s[-1..-1] == "!"
    end

    def set_query_option(option_name, option_value)
      if ends_in_exclamation? option_name 
        destructively_update_option option_name, option_value
      else
        update_option_and_return_new_proxy option_name, option_value
      end
    end

    def destructively_update_option(option_name, option_value)
      @options[option_name[0...-1]] = option_value
      @view_proxy
    end

    def update_option_and_return_new_proxy(option_name, option_value)
      new_proxy                = @view_proxy.dup
      new_options              = @options.dup.merge option_name => option_value
      new_proxy._query_options = CouchView::QueryOptions.new new_proxy, new_options
      new_proxy
    end
  end
end
