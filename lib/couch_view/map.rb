module CouchView
  module Map
    attr_accessor :model

    def initialize(model=nil)
      @model = model
    end

    def map
      if conditions
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
      "doc['couchrest-type'] == '#{@model}'" if @model
    end
  end
end
