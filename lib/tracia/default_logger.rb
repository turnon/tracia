class Tracia
  class DefaultLogger
    def initialize(out: STDOUT)
      @out = out
    end

    def call(root)
      @out.puts root.tree_graph
    end
  end
end
