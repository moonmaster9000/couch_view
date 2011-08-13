module CouchView
  extend ActiveSupport::Concern

  module ClassMethods
    def map(*args, &block)
      view_config = CouchView::Config.new :model => self, :map => args
      view_config.instance_eval &block if block
      view_config.views.each do |view_name, view|  
        view_by view_name, :map => view[:map], :reduce => view[:reduce]
      end

      base_view_name = view_config.base_view_name

      instance_eval <<-METHOD
        def map_#{base_view_name}!
          generate_view_proxy_for("#{base_view_name}").get!
        end

        def map_#{base_view_name}
          generate_view_proxy_for "#{base_view_name}"
        end
        
        def count_#{base_view_name}!
          generate_count_proxy_for("#{base_view_name}").get!
        end

        def count_#{base_view_name}
          generate_count_proxy_for "#{base_view_name}"
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
