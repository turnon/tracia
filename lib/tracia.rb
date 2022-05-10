# frozen_string_literal: true

require_relative "tracia/version"
require "tracia/gem_paths"
require "tracia/default_logger"

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

  def initialize(**opt)
    @frames_to_reject = Array(opt[:reject])
    @logger = opt[:logger] || DefaultLogger.new

    @backtraces = []
    @level = 0
  end

  def add(backtrace, info)
    @backtraces << [backtrace, info]
  end

  def log
    @stack = []

    @backtraces.each do |backtrace, info|
      build_road_from_root_to_leaf(backtrace)
      @stack.last.children << @logger.info(info)
    end

    if error
      build_road_from_root_to_leaf(error.backtrace)
      @stack.last.children << @logger.info(error)
    end

    @logger.output(@stack[0])
  end

  private

  def build_road_from_root_to_leaf(backtrace)
    backtrace.reject!{ |raw_frame| reject?(raw_frame) }
    backtrace.reverse!
    backtrace.each_with_index do |raw_frame, idx|
      raw_frame = GemPaths.shorten(raw_frame)
      frame = @stack[idx]
      if frame == nil
        push_frame(raw_frame, idx)
      elsif frame.name != raw_frame
        @stack = @stack.slice(0, idx + 1)
        push_frame(raw_frame, idx)
      end
    end
  end

  def push_frame(raw_frame, idx)
    frame = @logger.frame(raw_frame)
    @stack[idx - 1].children << frame if idx > 0
    @stack[idx] = frame
  end

  def reject?(raw_frame)
    @frames_to_reject.any?{ |rj| rj =~ raw_frame }
  end
end
