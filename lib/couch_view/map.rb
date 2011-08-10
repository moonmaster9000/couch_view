module CouchView
  module Map
    attr_accessor :model

    def initialize(model=nil, *properties)
      @model = model
      @properties = properties.empty? ? ["_id"] : properties 
    end

    def map
      if conditions != "true"
        "
          function(doc){
            if (#{conditions})
              emit(#{key}, null)  
          }
        "
      else
        "
          function(doc){
            emit(#{key}, null)
          }
        "
      end
    end

    def conditions
      if @model
        "doc['couchrest-type'] == '#{@model}'" 
      else
        "true"
      end
    end
    
    private
    def key
      properties = @properties.map {|p| "doc.#{p}"}.join ","

      if properties.length == 1
        properties
      else
        "[#{properties}]"
      end
    end
  end
end
