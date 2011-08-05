module CouchView
  module Map
    class Proxy
      extend Forwardable
      
      attr_reader :_model, :_map
      attr_writer :_query_options
      
      # Supported CouchDB Query Options
      def_delegators :@_query_options, 
        :limit,          :limit!,                         
        :skip,           :skip!,
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
        @_query_options = CouchView::QueryOptions.new self
      end

      def _options
        @_query_options.to_hash
      end

      def _map
        map_name = [@_map.to_s, @_conditions.sort.join("_")]
        puts map_name.inspect
        map_name.reject! &:blank?
        map_name.join("_").to_sym
      end

      def _query_options
        @_query_options
      end

      def method_missing(condition, *args, &block)
        condition = remove_exclamation(condition)
        @_conditions << condition
        self
      end

      private
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
end
