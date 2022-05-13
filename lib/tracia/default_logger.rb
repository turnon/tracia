class Tracia
  class DefaultLogger
    NO_CHILD = []

    class << self
      def tree_graph_everything!
        Object.define_method(:label_for_tree_graph) do
          to_s
        end

        Object.define_method(:children_for_tree_graph) do
          NO_CHILD
        end
      end
    end

    def initialize(out: STDOUT)
      @out = out
    end

    def call(root)
      @out.puts root.tree_graph
    end
  end
end
