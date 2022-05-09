# frozen_string_literal: true

require_relative "tracia/version"
require "tree_graph"
require "tracia/gem_paths"

class Tracia
  class Error < StandardError; end

  attr_accessor :level, :error

  class << self
    def start(**opt)
      trc = (Thread.current[:_tracia_] ||= new(**opt))
      trc.level += 1
      yield
    rescue StandardError => e
      trc.error = e
      raise e
    ensure
      trc.level -= 1
      Thread.current[:_tracia_] = nil if trc.error || trc.level == 0
      trc.log if trc.level == 0
    end

    def add(info)
      trc = Thread.current[:_tracia_]
      trc.add(caller, info) if trc
    end
  end

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

  class Info
    include TreeGraph

    NO_CHILD = []

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

  def initialize(**opt)
    @opt = opt
    @opt_reject = Array(@opt[:reject])

    @stacks = []
    @level = 0
  end

  def add(stack, info)
    @stacks << [stack, info]
  end

  def log
    @frames = []
    @stacks << [error.backtrace, error.message] if error
    @stacks.each do |stack, info|
      stack.reject!{ |raw_frame| reject?(raw_frame) }.reverse!
      stack.each_with_index do |raw_frame, idx|
        raw_frame = GemPaths.shorten(raw_frame)
        frame = @frames[idx]
        if frame == nil
          push_frame(raw_frame, idx)
        elsif frame.name != raw_frame
          push_frame(raw_frame, idx)
          @frames = @frames.slice(0, idx + 1)
        end
      end
      @frames.last.children << Info.new(info)
    end
    @opt[:out].puts @frames[0].tree_graph
  end

  private

  def push_frame(raw_frame, idx)
    frame = Frame.new(raw_frame)
    @frames[idx - 1].children << frame if idx > 0
    @frames[idx] = frame
  end

  def reject?(raw_frame)
    @opt_reject.any?{ |rj| rj =~ raw_frame }
  end
end
