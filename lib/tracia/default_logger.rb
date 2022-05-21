class Tracia
  class DefaultLogger
    def initialize(out: STDOUT, html: false)
      @out = out
      @html = html
    end

    def call(root)
      content = @html ? root.tree_html_full : root.tree_graph
      @out.puts content
    end
  end
end
