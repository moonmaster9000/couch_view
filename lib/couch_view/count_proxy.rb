module CouchView
  module Count
    class Proxy < CouchView::Proxy
      def each(&block)
        raise "You can't call 'each' on a count proxy that doesn't set 'group' to 'true'." unless _options[:group]
        results = self.get!['rows']
        results.each do |row|
          block.call row['key'], row['value']
        end
      end

      def get!
        if _options[:group]
          super
        else
          result = super['rows'].first
          result ? result['value'] : 0
        end
      end

      private
      def default_query_options
        CouchView::QueryOptions.new self, :reduce => true
      end
    end
  end
end
