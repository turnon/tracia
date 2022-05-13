class Tracia
  class DefaultLogger
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
    end

    def initialize(out: STDOUT)
      @out = out
    end

    def info(data)
      Data.new(data)
    end

    def output(root)
      @out.puts root.tree_graph
    end
  end
end
