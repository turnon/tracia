# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "tracia"
require "pry"

Tracia::DefaultLogger.tree_graph_everything!

require "minitest/autorun"
