module CouchView
  class Config
    attr_reader :map_class, :model, :properties, :conditions

    def initialize(model_class)
      @model     = model_class
      @conditions = CouchView::Config::Conditions.new
    end

    def map(*args, &block)
      @map_class, @properties = extract_map_class_data args
      self.instance_eval &block if block
    end

    def reduce(function=nil)
      if function
        @reduce = function
      else
        @reduce ||= "_count"
      end
    end
    
    def conditions_config
      @conditions
    end

    def conditions(*args, &block)
      if args.empty? && block.nil?
        @conditions.conditions
      else
        @conditions.add_conditions *args
        @conditions.instance_eval &block if block
      end
    end

    def view_names 
      views.keys.map &:to_s
    end
    
    def views
      all_views = {}
      all_views[base_view_name.to_sym] = {
        :map => @map_class.new(@model, *@properties).map,
        :reduce => reduce
      }
      all_views.merge! condition_views
      all_views
    end

    def base_view_name(name=nil)
      if name
        @base_view_name = name
      elsif @base_view_name
        @base_view_name
      elsif @properties.empty?
        @base_view_name = @map_class.to_s.underscore
      else
        @base_view_name = "by_" + @properties.map(&:to_s).map(&:underscore).join("_and_")
      end
    end

    private
    def condition_views
      all_condition_subsets = @conditions.conditions.keys.all_combinations.reject &:empty?

      all_condition_subsets.reject(&:empty?).inject({}) do |result, condition_combination|
        condition_combination.sort! {|a,b| a.to_s <=> b.to_s}
        
        view_name = 
          "#{base_view_name}_" + 
          condition_combination.map {|condition| condition.to_s}.join("_")

        map_instance = @map_class.new @model, *@properties
        condition_combination.map { |condition| map_instance.extend @conditions.conditions[condition] }

        result[view_name.to_sym] = {
          :map => map_instance.map,
          :reduce => reduce
        }

        result
      end
    end

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
