# frozen_string_literal: true

require "test_helper"

class TestTailRecursion < Minitest::Test
  class SomeRecursionTest
    def run(n: 5)
      walk(n)
      swim
      1 / n
      jump(n - 1)
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

  def test_tail_recursion
    Tracia.start(non_tail_recursion: true) do
      SomeRecursionTest.new.run
    end
  rescue ZeroDivisionError
  end

end
