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
      Tracia.add{{msg: 'usual_call'}}
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

  EXPECTED = <<EOS
TestNormal#block in test_normal #{__dir__}/test_normal.rb:172
├─TestNormal::Something#fly #{__dir__}/test_normal.rb:20
│ └─{:msg=>"parallel call"}
└─TestNormal::Something#run #{__dir__}/test_normal.rb:9
  ├─TestNormal::Something#usual_call #{__dir__}/test_normal.rb:24
  │ └─TestNormal::Something#usual_call_deep #{__dir__}/test_normal.rb:28
  │   └─{:msg=>"usual_call"}
  ├─TestNormal::Something#trace_in_different_levels #{__dir__}/test_normal.rb:32
  │ └─TestNormal::Something#trace_in_different_levels_lv1 #{__dir__}/test_normal.rb:36
  │   ├─{:msg=>"trace_in_different_levels_lv1 - 1"}
  │   ├─TestNormal::Something#trace_in_different_levels_lv2 #{__dir__}/test_normal.rb:42
  │   │ └─{:msg=>"trace_in_different_levels_lv2"}
  │   └─{:msg=>"trace_in_different_levels_lv1 - 2"}
  ├─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │ ├─{:msg=>"recursive_call 5"}
  │ └─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │   ├─{:msg=>"recursive_call 4"}
  │   └─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │     ├─{:msg=>"recursive_call 3"}
  │     └─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │       ├─{:msg=>"recursive_call 2"}
  │       └─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │         ├─{:msg=>"recursive_call 1"}
  │         └─TestNormal::Something#recursive_call #{__dir__}/test_normal.rb:46
  │           └─{:msg=>"recursive_call 0"}
  ├─TestNormal::Something#loop_call #{__dir__}/test_normal.rb:54
  │ └─TestNormal::Something#block in loop_call #{__dir__}/test_normal.rb:56
  │   └─TestNormal::Something#loop_call_lv1 #{__dir__}/test_normal.rb:60
  │     └─TestNormal::Something#loop_call_lv2 #{__dir__}/test_normal.rb:64
  │       ├─{:msg=>"loop_call"}
  │       ├─{:msg=>"loop_call"}
  │       └─{:msg=>"loop_call"}
  ├─TestNormal::Something#call_dynamic_methods #{__dir__}/test_normal.rb:68
  │ └─TestNormal::Something#block (2 levels) in <class:Something> #{__dir__}/test_normal.rb:74
  │   └─TestNormal::Something#block (2 levels) in <class:Something> #{__dir__}/test_normal.rb:74
  │     └─TestNormal::Something#block (2 levels) in <class:Something> #{__dir__}/test_normal.rb:74
  │       └─TestNormal::Something#block (2 levels) in <class:Something> #{__dir__}/test_normal.rb:74
  │         └─TestNormal::Something#block (2 levels) in <class:Something> #{__dir__}/test_normal.rb:74
  │           └─TestNormal::Something#call_dynamic_method_6 #{__dir__}/test_normal.rb:78
  │             └─{:msg=>"call_dynamic_methods"}
  ├─TestNormal::Something#method_missing #{__dir__}/test_normal.rb:82
  │ └─TestNormal::Something#method_not_found #{__dir__}/test_normal.rb:86
  │   └─{:msg=>"method_not_found call_undefined_method(*[])"}
  ├─TestNormal::Something.call_singleton_lv1 #{__dir__}/test_normal.rb:103
  │ └─TestNormal::Something.call_singleton_lv2 #{__dir__}/test_normal.rb:107
  │   └─{:msg=>"call_singleton"}
  └─TestNormal::Something#raise_error #{__dir__}/test_normal.rb:90
    └─TestNormal::Something#raise_error_lv1 #{__dir__}/test_normal.rb:94
      └─TestNormal::Something#raise_error_lv2 #{__dir__}/test_normal.rb:98
        └─something wrong !
EOS

  def test_normal
    something = Something.new
    logger = Tracia::TestLogger.new

    begin
      Tracia.start(logger: logger) do
        something.fly
        something.run
      end
    rescue Something::ErrTest
    end

    assert_equal EXPECTED, logger.read
  end

end
