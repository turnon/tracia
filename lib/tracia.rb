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
    attr_reader :children

    def initialize
      @name = nil
      @children = []
      @data = []
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
    puts @stacks
  end
end
