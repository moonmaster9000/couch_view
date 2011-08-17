module CouchView
  class Proxy
    extend Forwardable
    
    attr_reader   :_model, :_map
    attr_accessor :_query_options
    
    # Supported CouchDB Query Options
    def_delegators :@_query_options, 
      :limit,          :limit!,                         
      :skip,           :skip!,
      :key,            :key!,
      :startkey,       :startkey!,
      :endkey,         :endkey!,
      :startkey_docid, :startkey_docid!,
      :endkey_docid,   :endkey_docid!,
      :stale,          :stale!,
      :descending,     :descending!,
      :group,          :group!,
      :group_level,    :group_level!,
      :reduce,         :reduce!,
      :include_docs,   :include_docs!,
      :update_seq,     :update_seq!
      
    def initialize(model, map)
      @_model         = model
      @_map           = map
      @_conditions    = []
      @_query_options = default_query_options
    end

    def _options
      @_query_options.to_hash
    end

    def _map
      map = [@_map.to_s, @_conditions.sort.join("_")]
      map.reject! &:blank?
      map.join("_").to_sym
    end

    def method_missing(condition, *args, &block)
      condition = remove_exclamation(condition)
      @_conditions << condition
      self
    end

    def each(&block)
      _model.send(_map, _options).each &block
    end

    def get!
      _model.send _map, _options
    end

    private
    def default_query_options
      CouchView::QueryOptions.new self, :reduce => false
    end

    def remove_exclamation(condition)
      condition = condition.to_s

      if condition[-1..-1] == "!"
        condition[0...-1]
      else
        condition
      end
    end
  end
end
