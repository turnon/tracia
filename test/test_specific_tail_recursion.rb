# frozen_string_literal: true

require "test_helper"

class TestSpecificTailRecursion < Minitest::Test
  class SomeRecursion
    def run(n: 3)
      walk(n)
      swim
      1 / n
      jump(n - 1)
    end

    def fly
      Tracia.add({msg: 'parallel call'})
    end

    def walk(n)
      Tracia.add("walking #{n}")
    end

    def swim
      Tracia.add('swim')
    end

    def jump(num)
      Tracia.add('jump')
      run(n: num)
    end
  end

  EXPECTED = <<EOS
TestSpecificTailRecursion#block in test_specific_tail_recursion #{__dir__}/test_specific_tail_recursion.rb:70
├─TestSpecificTailRecursion::SomeRecursion#fly #{__dir__}/test_specific_tail_recursion.rb:14
│ └─{:msg=>\"parallel call\"}
└─TestSpecificTailRecursion::SomeRecursion#run #{__dir__}/test_specific_tail_recursion.rb:7
  ├─TestSpecificTailRecursion::SomeRecursion#walk #{__dir__}/test_specific_tail_recursion.rb:18
  │ └─walking 3
  ├─TestSpecificTailRecursion::SomeRecursion#swim #{__dir__}/test_specific_tail_recursion.rb:22
  │ └─swim
  ├─TestSpecificTailRecursion::SomeRecursion#jump #{__dir__}/test_specific_tail_recursion.rb:26
  │ ├─jump
  │ └─TestSpecificTailRecursion::SomeRecursion#run #{__dir__}/test_specific_tail_recursion.rb:7
  │   ├─TestSpecificTailRecursion::SomeRecursion#walk #{__dir__}/test_specific_tail_recursion.rb:18
  │   │ └─walking 2
  │   └─TestSpecificTailRecursion::SomeRecursion#swim #{__dir__}/test_specific_tail_recursion.rb:22
  │     └─swim
  ├─TestSpecificTailRecursion::SomeRecursion#jump #{__dir__}/test_specific_tail_recursion.rb:26
  │ ├─jump
  │ └─TestSpecificTailRecursion::SomeRecursion#run #{__dir__}/test_specific_tail_recursion.rb:7
  │   ├─TestSpecificTailRecursion::SomeRecursion#walk #{__dir__}/test_specific_tail_recursion.rb:18
  │   │ └─walking 1
  │   └─TestSpecificTailRecursion::SomeRecursion#swim #{__dir__}/test_specific_tail_recursion.rb:22
  │     └─swim
  └─TestSpecificTailRecursion::SomeRecursion#jump #{__dir__}/test_specific_tail_recursion.rb:26
    ├─jump
    └─TestSpecificTailRecursion::SomeRecursion#run #{__dir__}/test_specific_tail_recursion.rb:7
      ├─TestSpecificTailRecursion::SomeRecursion#walk #{__dir__}/test_specific_tail_recursion.rb:18
      │ └─walking 0
      ├─TestSpecificTailRecursion::SomeRecursion#swim #{__dir__}/test_specific_tail_recursion.rb:22
      │ └─swim
      └─divided by 0
EOS

  def test_specific_tail_recursion
    some_recursion = SomeRecursion.new
    logger = Tracia::TestLogger.new

    begin
      Tracia.start(non_tail_recursion: {klass: SomeRecursion, call_sym: '#', method_name: 'jump'}, logger: logger) do
        some_recursion.fly
        some_recursion.run
      end
    rescue ZeroDivisionError
    end

    assert_equal EXPECTED, logger.read
  end
end
