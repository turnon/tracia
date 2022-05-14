# frozen_string_literal: true

require "test_helper"

class TestBlockRecursion < Minitest::Test
  class BlockRecursion
    def run
      block = -> (n) do
        walk(n)
        1 / n
        block[n - 1]
      end

      block[5]
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
  end

  EXPECTED = <<EOS
TestBlockRecursion#block in test_tail_recursion #{__dir__}/test_block_recursion.rb:62
├─TestBlockRecursion::BlockRecursion#fly #{__dir__}/test_block_recursion.rb:17
│ └─{:msg=>"parallel call"}
└─TestBlockRecursion::BlockRecursion#run #{__dir__}/test_block_recursion.rb:7
  ├─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
  │ └─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
  │   └─walking 5
  ├─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
  │ └─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
  │   └─walking 4
  ├─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
  │ └─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
  │   └─walking 3
  ├─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
  │ └─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
  │   └─walking 2
  ├─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
  │ └─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
  │   └─walking 1
  └─TestBlockRecursion::BlockRecursion#block in run #{__dir__}/test_block_recursion.rb:9
    ├─TestBlockRecursion::BlockRecursion#walk #{__dir__}/test_block_recursion.rb:21
    │ └─walking 0
    └─divided by 0
EOS

  def test_tail_recursion
    block_recursion = BlockRecursion.new
    sio = StringIO.new

    begin
      Tracia.start(non_tail_recursion: true, logger: Tracia::DefaultLogger.new(out: sio)) do
        block_recursion.fly
        block_recursion.run
      end
    rescue ZeroDivisionError
    end

    sio.rewind
    assert_equal EXPECTED, sio.read
  end

end
