module Browbeat
  class CollectionBase
    include Enumerable
    extend Forwardable
    delegate [:each, :length, :empty?, :<<, :[]] => :@members

    def initialize(members = [])
      @members = members
    end

    # wrapper for Array#select that returns instance of this class
    def select(&block)
      self.class.new @members.select(&block)
    end

    # wrapper for Array#group_by; returned hash's values are instances of this class (instead of Arrays)
    def group_by(*args, &block)
      @members.group_by(*args, &block).map do |key, array|
        [key, self.class.new(array)]
      end.to_h
    end

    def sort_by(&block)
      self.class.new @members.sort_by(&block)
    end
  end
end
