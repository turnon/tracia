require "tree_graph"

class Tracia
  class DefaultLogger
    class Frame
      include TreeGraph

      attr_reader :name, :children

      def initialize(name)
        @name = name
        @children = []
      end

      def label_for_tree_graph
        name
      end

      def children_for_tree_graph
        children
      end
    end

    NO_CHILD = []

    class Data
      include TreeGraph

      def initialize(data)
        @data = data
      end

      def label_for_tree_graph
        @data
      end

      def children_for_tree_graph
        NO_CHILD
      end

      def children
        NO_CHILD
      end
    end

    def initialize(out: STDOUT)
      @out = out
    end

    def frame(name)
      Frame.new(name)
    end

    def info(data)
      Data.new(data)
    end

    def output(root)
      @out.puts root.tree_graph
    end
  end
end
