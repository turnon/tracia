require "tree_graph"

class Tracia
  class Frame
    include TreeGraph

    attr_reader :klass, :call_sym, :method_name, :children, :file

    def initialize(klass, call_sym, method_name, file, lineno)
      @klass = klass
      @call_sym = call_sym
      @method_name = method_name
      @file = file
      @lineno = lineno
      @children = []
    end

    def same_klass_and_method?(other_frame)
      klass == other_frame.klass &&
        call_sym == other_frame.call_sym &&
        method_name == other_frame.method_name
    end

    def label_for_tree_graph
      "#{klass}#{call_sym}#{method_name} #{GemPaths.shorten(@file)}:#{@lineno}"
    end

    def children_for_tree_graph
      children
    end
  end
end
