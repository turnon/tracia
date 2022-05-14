# frozen_string_literal: true

require "test_helper"

class TestNormal < Minitest::Test
  class Something
    class ErrTest < StandardError; end

    def run
      usual_call
      trace_in_different_levels
      recursive_call
      loop_call
      call_dynamic_methods
      call_undefined_method
      self.class.call_singleton_lv1
      raise_error
    end

    def fly
      Tracia.add({msg: 'parallel call'})
    end

    def usual_call
      usual_call_deep
    end

    def usual_call_deep
      Tracia.add({msg: 'usual_call'})
    end

    def trace_in_different_levels
      trace_in_different_levels_lv1
    end

    def trace_in_different_levels_lv1
      Tracia.add({msg:'trace_in_different_levels_lv1 - 1'})
      trace_in_different_levels_lv2
      Tracia.add({msg: 'trace_in_different_levels_lv1 - 2'})
    end

    def trace_in_different_levels_lv2
      Tracia.add({msg: 'trace_in_different_levels_lv2'})
    end

    def recursive_call(n = 5)
      Tracia.add({msg: "recursive_call #{n}"})
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
      Tracia.add({msg: 'loop_call'})
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
      Tracia.add({msg: 'call_dynamic_methods'})
    end

    def method_missing(method_name, *args, &block)
      method_not_found(method_name, *args)
    end

    def method_not_found(method_name, *args)
      Tracia.add({msg: "method_not_found #{method_name}(*#{args})"})
    end

    def raise_error
      raise_error_lv1
    end

    def raise_error_lv1
      raise_error_lv2
    end

    def raise_error_lv2
      raise ErrTest, 'something wrong !'
    end

    class << self
      def call_singleton_lv1
        call_singleton_lv2
      end

      def call_singleton_lv2
        Tracia.add({msg: 'call_singleton'})
      end
    end
  end

  def test_normal
    something = Something.new
    Tracia.start(out: STDOUT) do
      something.fly
      something.run
    end
  rescue Something::ErrTest
  end

end
