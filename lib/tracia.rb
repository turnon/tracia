# frozen_string_literal: true

require "tracia/version"
require "tracia/gem_paths"
require "tracia/default_logger"

require "binding_of_callers"

class Tracia
  class Error < StandardError; end

  SRC_LOC_SEPERATOR = ':'
  SRC_LOC_MATCHER = /(.*):in `(.*)'/

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
      return unless trc

      backtrace = caller
      full_callers = []

      frames = convert_to_frames(binding.of_callers)
      frames.reverse_each do |frame|
        loop do
          backtrace_frame = backtrace.pop
          break unless backtrace_frame
          m = backtrace_frame.match(SRC_LOC_MATCHER)
          break if frame.binding_source_location == m[1] && frame.method_name == m[2]
          full_callers << Frame.new(nil, nil, m[2], m[1], m[1])
        end
        full_callers << frame
      end
      full_callers.pop

      trc.add(full_callers, info)
    end

    private

    def convert_to_frames(callers)
      callers.map! do |c|
        _binding = c._binding
        klass = c.klass
        call_symbol = c.call_symbol
        frame_env = c.frame_env

        binding_source_location = _binding.source_location.join(SRC_LOC_SEPERATOR)

        real_source_location =
          if _binding.frame_type == :method
            meth = call_symbol == '#' ? klass.instance_method(frame_env) : klass.method(frame_env)
            meth.source_location.join(SRC_LOC_SEPERATOR)
          else
            binding_source_location
          end

        Frame.new(klass, call_symbol, frame_env, binding_source_location, real_source_location)
      end

      callers
    end
  end

  class Frame
    include TreeGraph

    attr_reader :binding_source_location, :klass, :call_sym, :method_name, :children

    def initialize(klass, call_sym, method_name, binding_source_location, real_source_location)
      @binding_source_location = binding_source_location
      @real_source_location = real_source_location
      @klass = klass
      @call_sym = call_sym
      @method_name = method_name
      @children = []
    end

    def same_klass_and_method?(other_frame)
      klass == other_frame.klass &&
        call_sym == other_frame.call_sym &&
        method_name == other_frame.method_name
    end

    def diff_method_src_loc?(other_frame)
      method_name != other_frame.method_name &&
        binding_source_location != other_frame.binding_source_location
    end

    def label_for_tree_graph
      "#{klass}#{call_sym}#{method_name} #{GemPaths.shorten(@real_source_location)}"
    end

    def children_for_tree_graph
      children
    end
  end

  def initialize(**opt)
    @frames_to_reject = Array(opt[:reject])
    @non_tail_recursion = opt[:non_tail_recursion]
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
      build_road_from_root_to_leaf(backtrace) do |sibling_frame, current_frame|
        !sibling_frame.same_klass_and_method?(current_frame)
      end
      @stack.last.children << @logger.info(info)
    end

    if error
      err_backtrace = error.backtrace.reverse_each.map do |bt|
        m = bt.match(SRC_LOC_MATCHER)
        Frame.new(nil, nil, m[2], m[1], m[1])
      end
      build_road_from_root_to_leaf(err_backtrace) do |sibling_frame, current_frame|
        sibling_frame.diff_method_src_loc?(current_frame)
      end
      @stack.last.children << @logger.info(error)
    end

    root = @stack[0]
    if root
      non_tail_recursion!([root]) if @non_tail_recursion
      @logger.output(root)
    end
  end

  private

  def non_tail_recursion!(stack)
    current_frame = stack.last
    last_idx = current_frame.children.count - 1

    current_frame.children.each_with_index do |child, idx|
      next non_tail_recursion!([child]) if last_idx != idx
      next unless Frame === child

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

  def build_road_from_root_to_leaf(backtrace, &diff)
    backtrace.reject!{ |raw_frame| reject?(raw_frame) }
    backtrace.each_with_index do |raw_frame, idx|
      frame = @stack[idx]
      if frame == nil
        push_frame(raw_frame, idx)
      elsif diff[frame, raw_frame]
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
    @frames_to_reject.any?{ |rj| rj =~ raw_frame.source_location }
  end
end
