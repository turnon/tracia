# frozen_string_literal: true

require "test_helper"

class TestTailRecursion < Minitest::Test
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
TestTailRecursion#block in test_tail_recursion #{__dir__}/test_tail_recursion.rb:71
├─TestTailRecursion::SomeRecursion#fly #{__dir__}/test_tail_recursion.rb:14
│ └─{:msg=>\"parallel call\"}
├─TestTailRecursion::SomeRecursion#run #{__dir__}/test_tail_recursion.rb:7
│ ├─TestTailRecursion::SomeRecursion#walk #{__dir__}/test_tail_recursion.rb:18
│ │ └─walking 3
│ ├─TestTailRecursion::SomeRecursion#swim #{__dir__}/test_tail_recursion.rb:22
│ │ └─swim
│ └─TestTailRecursion::SomeRecursion#jump #{__dir__}/test_tail_recursion.rb:26
│   └─jump
├─TestTailRecursion::SomeRecursion#run #{__dir__}/test_tail_recursion.rb:7
│ ├─TestTailRecursion::SomeRecursion#walk #{__dir__}/test_tail_recursion.rb:18
│ │ └─walking 2
│ ├─TestTailRecursion::SomeRecursion#swim #{__dir__}/test_tail_recursion.rb:22
│ │ └─swim
│ └─TestTailRecursion::SomeRecursion#jump #{__dir__}/test_tail_recursion.rb:26
│   └─jump
├─TestTailRecursion::SomeRecursion#run #{__dir__}/test_tail_recursion.rb:7
│ ├─TestTailRecursion::SomeRecursion#walk #{__dir__}/test_tail_recursion.rb:18
│ │ └─walking 1
│ ├─TestTailRecursion::SomeRecursion#swim #{__dir__}/test_tail_recursion.rb:22
│ │ └─swim
│ └─TestTailRecursion::SomeRecursion#jump #{__dir__}/test_tail_recursion.rb:26
│   └─jump
└─TestTailRecursion::SomeRecursion#run #{__dir__}/test_tail_recursion.rb:7
  ├─TestTailRecursion::SomeRecursion#walk #{__dir__}/test_tail_recursion.rb:18
  │ └─walking 0
  ├─TestTailRecursion::SomeRecursion#swim #{__dir__}/test_tail_recursion.rb:22
  │ └─swim
  └─divided by 0
EOS

  def test_tail_recursion
    some_recursion = SomeRecursion.new
    logger = Tracia::TestLogger.new

    begin
      Tracia.start(non_tail_recursion: true, logger: logger) do
        some_recursion.fly
        some_recursion.run
      end
    rescue ZeroDivisionError
    end

    assert_equal EXPECTED, logger.read
  end
end
