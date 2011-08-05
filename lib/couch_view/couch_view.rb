module CouchView
  extend ActiveSupport::Concern

  module ClassMethods
    def map(*args)
      map_class       = args.first
      map_function    = map_class.new(self).map
      map_method_name = map_class.to_s.underscore

      view_by map_method_name, :map => map_function

      instance_eval <<-METHOD
        def map_#{map_method_name}!
          by_#{map_method_name}
        end

        def map_#{map_method_name}
        end
      METHOD
    end
  end
end
