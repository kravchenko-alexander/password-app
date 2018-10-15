module Result
  class Base
    def initialize(data = {})
      @data = data

      define_accessors
    end

    def errors
      @errors ||= []
    end

    def self.inherited(child)
      return if child.name == nil
      child_class_name_as_predicate = "#{child.name.split('::').last.downcase}?"

      add_predicate_method_to_class(Result::Base, child_class_name_as_predicate, false)
      add_predicate_method_to_class(child, child_class_name_as_predicate, true)
    end

    protected

    def define_accessors
      self.class.class_exec(@data) do |_data|
        _data.each_key do |key|
          next if key.to_s == 'errors'
          next if instance_methods(false).include?(key.to_sym)

          define_method key do
            @data[key]
          end
        end
      end
    end

    def self.add_predicate_method_to_class(klass, method_name, method_value)
      unless klass.instance_methods(false).include?(method_name)
        klass.class_eval do
          define_method method_name do
            method_value
          end
        end
      end
    end
  end
end
