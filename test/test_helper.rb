# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)


require "tracia"
require "pry"

class Tracia
  class TestLogger
    TMP_DIR = File.expand_path("../tmp", __dir__)
    Dir.mkdir(TMP_DIR) unless File.directory?(TMP_DIR)

    def initialize
      @sio = StringIO.new
    end

    def call(root)
      @sio.puts root.tree_graph
      write_tree_html(root)
    end

    def read
      @sio.rewind
      @sio.read
    end

    private

    def write_tree_html(root)
      name = root.klass.to_s.gsub(/([A-Z])/, '_\1').sub(/^_/, '').downcase
      File.open(File.join(TMP_DIR, "#{name}_#{Time.now.to_i}.html"), 'w+') do |f|
        f.puts root.tree_html_full
      end
    end
  end
end

require "minitest/autorun"
