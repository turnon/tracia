# frozen_string_literal: true

require "test_helper"

class TestBlockRecursion < Minitest::Test
  class BlockRecursionTest
    def run
      block = -> (n) do
        walk(n)
        1 / n
        block[n - 1]
      end

      block[5]
    end

    def walk(n)
      Tracia.add("walking #{n}")
    end

    def swim
      Tracia.add('swim')
    end
  end

  def test_tail_recursion
    Tracia.start(non_tail_recursion: true) do
      BlockRecursionTest.new.run
    end
  rescue ZeroDivisionError
  end

end
