module CouchView
  class Config
    attr_reader :map_class, :model, :properties

    def initialize(options)
      @model     = options[:model]
      @map_class, @properties = extract_map_class_data options[:map]
    end

    def view_names 
      if @properties.empty?
        base_name = @map_class.to_s.underscore
      else
        base_name = "by_" + @properties.map(&:to_s).map(&:underscore).join("_and_")
      end

      [base_name]
    end

    private
    def extract_map_class_data(map)
      if map.class == Symbol || map.kind_of?(Array)
        properties = [map].flatten
        return CouchView::Map::Property, properties 
      else
        return map, []
      end
    end
  end
end
