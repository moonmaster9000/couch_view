module CouchView
  module Map
    attr_accessor :model

    def initialize(model=nil)
      @model = model
    end

    def map
      if conditions != "true"
        "
          function(doc){
            if (#{conditions})
              emit(doc._id, null)
          }
        "
      else
        "
          function(doc){
            emit(doc._id, null)
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
  end
end
