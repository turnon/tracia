# frozen_string_literal: true

require_relative "tracia/version"

class Tracia
  class Error < StandardError; end

  attr_accessor :level, :error

  # Your code goes here...
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
    attr_reader :name, :children

    def initialize(name, level)
      @name = name
      @level = level
      @children = []
      @data = []
    end

    def inspect
      spaces = ' ' * @level
      @children.empty? ? "#{@name}\n" : "#{@name} ->\n#{spaces}#{@children}"
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
    frames = []
    @stacks.each do |stack, data|
      stack.reverse.each_with_index do |raw_frame, idx|
        frame = frames[idx]
        if frame == nil
          frame = Frame.new(raw_frame, idx)
          frames[idx - 1].children << frame if idx > 0
          frames[idx] = frame
        elsif frame.name != raw_frame
          frame = Frame.new(raw_frame, idx)
          frames[idx - 1].children << frame if idx > 0
          frames[idx] = frame
          frames = frames.slice(0, idx + 1)
        end
      end
    end
    p frames
  end
end
