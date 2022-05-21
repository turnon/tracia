require "tree_graph"
require "tree_html"
require "cgi"

class Tracia
  class Frame
    include TreeGraph
    include TreeHtml

    attr_reader :klass, :call_sym, :method_name, :children, :file, :lineno

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
      "#{class_and_method} #{source_location}"
    end

    def children_for_tree_graph
      children
    end

    def label_for_tree_html
      "<span class='hl'>#{CGI::escapeHTML(class_and_method)}</span> #{CGI::escapeHTML(source_location)}"
    end

    def children_for_tree_html
      children
    end

    def css_for_tree_html
      '.hl{color: #a50000;}'
    end

    private

    def class_and_method
      "#{klass}#{call_sym}#{method_name}"
    end

    def source_location
      "#{GemPaths.shorten(@file)}:#{@lineno}"
    end
  end
end
