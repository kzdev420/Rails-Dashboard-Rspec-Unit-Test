module DropdownFields
  class Base
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def search
      execute.map { |element|  { value: element[value_attr], label: element[label_attr] } }
    end

    def execute
      fail NotImplementedError
    end

    def value_attr
      fail NotImplementedError
    end

    def label_attr
      fail NotImplementedError
    end

  end
end
