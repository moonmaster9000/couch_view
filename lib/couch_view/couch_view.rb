module CouchView
  extend ActiveSupport::Concern

  module ClassMethods
    def map(*args, &block)
      couch_view do
        map *args, &block
      end
    end

    def couch_view(name=nil, &block) 
      view_config = CouchView::Config.new self
      view_config.instance_eval &block
      view_config.base_view_name name if name
      base_view_name = view_config.base_view_name

      if view_configs[base_view_name]
        view_configs[base_view_name].conditions.each do |condition_name, condition_module|
          view_config.conditions_config.send condition_name, condition_module
        end
        view_configs[base_view_name] = view_config
      else
        view_configs[base_view_name] = view_config
      end

      view_config.views.each do |view_name, view|  
        view_by view_name, :map => view[:map], :reduce => view[:reduce]
      end

      instance_eval <<-METHODS
        def map_#{base_view_name}!
          generate_view_proxy_for("#{base_view_name}").get!
        end

        def map_#{base_view_name}
          generate_view_proxy_for "#{base_view_name}"
        end

        def reduce_#{base_view_name}!
          generate_view_proxy_for("#{base_view_name}").reduce(true).get!
        end

        def reduce_#{base_view_name}
          generate_view_proxy_for("#{base_view_name}").reduce(true)
        end
      METHODS
      
      if view_config.reduce == "_count"
        instance_eval <<-METHODS
          def count_#{base_view_name}!
            generate_count_proxy_for("#{base_view_name}").get!
          end

          def count_#{base_view_name}
            generate_count_proxy_for "#{base_view_name}"
          end
        METHODS
      end
    end

    private
    def generate_count_proxy_for(view)
      CouchView::Count::Proxy.new self, "by_#{view}".to_sym
    end

    def generate_view_proxy_for(view)
      CouchView::Proxy.new self, "by_#{view}".to_sym
    end

    def view_configs
      @view_configs ||= {}
    end
  end
end
