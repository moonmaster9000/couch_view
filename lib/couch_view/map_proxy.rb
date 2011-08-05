module CouchView
  module Map
    class Proxy
      attr_accessor :_model, :_map

      def initialize(model, map)
        @_model = model
        @_map   = map
      end
    end
  end
end
