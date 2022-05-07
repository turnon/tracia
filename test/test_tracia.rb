# frozen_string_literal: true

require "test_helper"

class TestTracia < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tracia::VERSION
  end

  class SomeTest
    def run
      usual_call
      trace_in_different_levels
      recursive_call
      loop_call
      call_dynamic_methods
      call_undefined_method
      self.class.call_singleton_lv1
    end

    def usual_call
      usual_call_deep
    end

    def usual_call_deep
      Tracia.add('usual_call')
    end

    def trace_in_different_levels
      trace_in_different_levels_lv1
    end

    def trace_in_different_levels_lv1
      Tracia.add('trace_in_different_levels_lv1 - 1')
      trace_in_different_levels_lv2
      Tracia.add('trace_in_different_levels_lv1 - 2')
    end

    def trace_in_different_levels_lv2
      Tracia.add('trace_in_different_levels_lv2')
    end

    def recursive_call(n = 5)
      Tracia.add("recursive_call #{n}")
      if n <= 0
        return
      end
      recursive_call(n - 1)
    end

    def loop_call
      3.times do
        loop_call_lv1
      end
    end

    def loop_call_lv1
      loop_call_lv2
    end

    def loop_call_lv2
      Tracia.add('loop_call')
    end

    def call_dynamic_methods
      call_dynamic_method_1
    end

    (1..5).each do |n|
      define_method("call_dynamic_method_#{n}") do
        send("call_dynamic_method_#{n + 1}")
      end
    end

    def call_dynamic_method_6
      Tracia.add('call_dynamic_methods')
    end

    def method_missing(method_name, *args, &block)
      method_not_found(method_name, *args)
    end

    def method_not_found(method_name, *args)
      Tracia.add("method_not_found #{method_name}(*#{args})")
    end

    class << self
      def call_singleton_lv1
        call_singleton_lv2
      end

      def call_singleton_lv2
        Tracia.add('call_singleton')
      end
    end
  end

  def test_add
    Tracia.start do
      SomeTest.new.run
    end
  end

end
