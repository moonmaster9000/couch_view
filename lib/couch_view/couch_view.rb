module CouchView
  extend ActiveSupport::Concern

  module ClassMethods
    def map(*args)
      map_class       = args.first
      map_function    = map_class.new(self).map
      map_method_name = map_class.to_s.underscore

      view_by map_method_name, :map => map_function, :reduce => "_count"

      instance_eval <<-METHOD
        def map_#{map_method_name}!
          generate_view_proxy_for("#{map_method_name}").get!
        end

        def map_#{map_method_name}
          generate_view_proxy_for "#{map_method_name}"
        end
        
        def count_#{map_method_name}!
          generate_count_proxy_for("#{map_method_name}").get!
        end

        def count_#{map_method_name}
          generate_count_proxy_for "#{map_method_name}"
        end
      METHOD
    end

    private
    def generate_count_proxy_for(view)
      CouchView::Count::Proxy.new self, "by_#{view}".to_sym
    end

    def generate_view_proxy_for(view)
      CouchView::Proxy.new self, "by_#{view}".to_sym
    end
  end
end
