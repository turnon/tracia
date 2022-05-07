# frozen_string_literal: true

require_relative "tracia/version"
require "tree_graph"

class Tracia
  class Error < StandardError; end

  attr_accessor :level, :error

  class << self
    def start
      trc = (Thread.current[:_tracia_] ||= new)
      trc.level += 1
      yield
    rescue StandardError => e
      trc.error = e
      raise e
    ensure
      trc.level -= 1
      Thread.current[:_tracia_] = nil if trc.error || trc.level == 0
      trc.log if trc.level == 0 && trc.error.nil?
    end

    def add(attrs)
      trc = Thread.current[:_tracia_]
      trc.add(caller, attrs) if trc
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

  def initialize
    @stacks = []
    @level = 0
  end

  def add(stack, data)
    @stacks << [stack, data]
  end

  def log
    @frames = []
    @stacks.each do |stack, data|
      stack.reverse.each_with_index do |raw_frame, idx|
        frame = @frames[idx]
        if frame == nil
          push_frame(raw_frame, idx)
        elsif frame.name != raw_frame
          push_frame(raw_frame, idx)
          @frames = @frames.slice(0, idx + 1)
        end
      end
    end
    puts @frames[0].tree_graph
  end

  private

  def push_frame(raw_frame, idx)
    frame = Frame.new(raw_frame)
    @frames[idx - 1].children << frame if idx > 0
    @frames[idx] = frame
  end
end
