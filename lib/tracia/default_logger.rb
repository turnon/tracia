require "tree_graph"

class Tracia
  module DefaultLogger
    class Frame
      include TreeGraph

      attr_reader :name, :children

      def initialize(name)
        @name = name
        @children = []
        @data = []
      end

      def label_for_tree_graph
        name
      end

      def children_for_tree_graph
        children
      end
    end

    NO_CHILD = []

    class Info
      include TreeGraph

      def initialize(info)
        @info = info
      end

      def label_for_tree_graph
        @info
      end

      def children_for_tree_graph
        NO_CHILD
      end
    end

    class Error
      include TreeGraph

      def initialize(error)
        @error_msg = error.message
      end

      def label_for_tree_graph
        @error_msg
      end

      def children_for_tree_graph
        NO_CHILD
      end
    end

    class << self
      def output(root)
        puts root.tree_graph
      end
    end
  end
end
