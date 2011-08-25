module CouchView
  class Config
    class Conditions
      attr_reader :conditions

      def initialize(*conditions)
        @conditions = {}
        add_condition_modules conditions
      end

      def add_conditions(*args)
        add_condition_modules args
      end

      alias :add_condition :add_conditions

      def method_missing(condition_name, *args, &block)
        super if block
        super unless args.count == 1

        add_condition_module condition_name, args.first
      end

      private
      def add_condition_modules(condition_modules)
        condition_modules.each do |condition_module|
          condition_name = condition_module.to_s.underscore.gsub(/^.*\/([^\/]+)$/) { $1 }
          add_condition_module condition_name, condition_module
        end
      end

      def add_condition_module(condition_name, condition_module)
        @conditions[condition_name.to_sym] = condition_module
      end
    end
  end
end
