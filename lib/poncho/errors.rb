module Poncho
  class Errors
    def initialize(base)
      @base   = base
      @errors = []
    end

    def add(type)
      @errors << type
    end

    def empty?
      @errors.empty?
    end
  end
end