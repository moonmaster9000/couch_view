module CouchView
  class Config
    attr_reader :map_class, :model, :properties, :conditions

    def initialize(options)
      @model     = options[:model]
      @map_class, @properties = extract_map_class_data options[:map]
      @conditions = []
    end

    def reduce(function=nil)
      if function
        @reduce = function
      else
        @reduce ||= "_count"
      end
    end

    def conditions(*args)
      if args.empty?
        @conditions
      else
        @conditions += args
      end
    end

    def view_names 
      if @properties.empty?
        base_name = @map_class.to_s.underscore
      else
        base_name = "by_" + @properties.map(&:to_s).map(&:underscore).join("_and_")
      end

      [base_name] + @conditions.all_combinations.reject {|subset| subset == []}.map do |subset| 
        "#{base_name}_" + (subset.map do |condition|
          condition.to_s.underscore
        end.join("_"))
      end
    end

    private
    def extract_map_class_data(map)
      if map.first.class == Symbol
        properties = [map].flatten
        return CouchView::Map::Property, properties 
      else
        return map.first, []
      end
    end
  end
end
