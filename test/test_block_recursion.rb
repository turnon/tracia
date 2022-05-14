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

  def test_tail_recursion
    block_recursion = BlockRecursion.new
    Tracia.start(non_tail_recursion: true) do
      block_recursion.fly
      block_recursion.run
    end
  rescue ZeroDivisionError
  end

end
