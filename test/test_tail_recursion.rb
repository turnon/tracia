# frozen_string_literal: true

require "test_helper"

class TestTailRecursion < Minitest::Test
  class SomeRecursionTest
    def run(n: 5)
      walk(n)
      swim
      jump(n - 1) if n > 0
    end

    def walk(n)
      Tracia.add("walking #{n}")
    end

    def swim
      Tracia.add('swim')
    end

    def jump(num)
      run(n: num)
    end
  end

  def test_tail_recursion
    Tracia.start(non_tail_recursion: true) do
      SomeRecursionTest.new.run
    end
  end

end
