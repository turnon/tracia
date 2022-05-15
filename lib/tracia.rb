# frozen_string_literal: true

require "tracia/version"
require "tracia/gem_paths"
require "tracia/frame"
require "tracia/default_logger"

require "binding_of_callers"

class Tracia
  class Error < StandardError; end

  INSTANCE_METHOD_SHARP = '#'

  attr_accessor :level, :error, :depth

  class << self
    def start(**opt)
      trc = (Thread.current[:_tracia_] ||= new(**opt))
      trc.level += 1
      trc.depth = binding.frame_count + 1
      yield
    rescue StandardError => e
      trc.error = e
      raise e
    ensure
      trc.level -= 1
      if trc.error || trc.level == 0
        Thread.current[:_tracia_] = nil
        trc.disable_trace_point
      end
      trc.log if trc.level == 0
    end

    def add(info)
      trc = Thread.current[:_tracia_]
      return unless trc

      backtrace = binding.partial_callers(-trc.depth)
      backtrace.reverse!
      backtrace.pop
      trc.add(backtrace, info)
    end
  end

  def initialize(**opt)
    @frames_to_reject = Array(opt[:reject])
    @non_tail_recursion = opt[:non_tail_recursion]
    @logger = opt[:logger] || DefaultLogger.new

    @backtraces = []
    @level = 0

    enable_trace_point
  end

  def enable_trace_point
    current_thread = Thread.current
    @trace_point = TracePoint.new(:raise) do |point|
      bd = point.binding
      next unless current_thread == bd.eval('Thread.current')
      backtrace = bd.eval("binding.partial_callers(-#{depth})")
      raiser = backtrace[0]
      next if raiser.klass == Tracia && raiser.frame_env == 'rescue in start'
      backtrace.reverse!
      backtrace.pop
      backtrace.pop
      add(backtrace, point.raised_exception)
    end
    @trace_point.enable
  end

  def disable_trace_point
    @trace_point.disable
  end

  def add(backtrace, info)
    backtrace = convert_to_frames(backtrace)
    @backtraces << [backtrace, info]
  end

  def log
    @stack = []

    @backtraces.each do |backtrace, info|
      build_road_from_root_to_leaf(backtrace)
      @stack.last.children << info
    end

    root = @stack[0]
    if root
      non_tail_recursion!([root]) if @non_tail_recursion
      @logger.call(root)
    end
  end

  private

  def non_tail_recursion!(stack)
    current_frame = stack.last
    last_idx = current_frame.children.count - 1

    current_frame.children.each_with_index do |child, idx|
      next unless Frame === child
      next non_tail_recursion!([child]) if last_idx != idx

      recursion_idx = stack.index{ |frame| frame.same_klass_and_method?(child) }
      if recursion_idx
        parent = stack[recursion_idx - 1]
        parent.children << child
        current_frame.children.pop
        non_tail_recursion!([parent, child])
      else
        stack.push(child)
        non_tail_recursion!(stack)
      end
    end
  end

  def build_road_from_root_to_leaf(backtrace)
    backtrace.reject!{ |raw_frame| reject?(raw_frame) }
    backtrace.each_with_index do |raw_frame, idx|
      frame = @stack[idx]
      if frame == nil
        push_frame(raw_frame, idx)
      elsif !frame.same_klass_and_method?(raw_frame)
        @stack = @stack.slice(0, idx + 1)
        push_frame(raw_frame, idx)
      end
    end

    @stack = @stack.slice(0, backtrace.size) if @stack.size > backtrace.size
  end

  def push_frame(frame, idx)
    @stack[idx - 1].children << frame if idx > 0
    @stack[idx] = frame
  end

  def reject?(raw_frame)
    @frames_to_reject.any?{ |rj| rj =~ raw_frame.file }
  end

  def convert_to_frames(callers)
    callers.map! do |c|
      _binding = c._binding
      klass = c.klass
      call_symbol = c.call_symbol
      frame_env = c.frame_env

      source_location =
        if _binding.frame_type == :method
          meth = call_symbol == INSTANCE_METHOD_SHARP ? klass.instance_method(frame_env) : klass.method(frame_env)
          meth.source_location
        else
          _binding.source_location
        end

      Frame.new(klass, call_symbol, frame_env, source_location[0], source_location[1])
    end

    callers
  end
end
