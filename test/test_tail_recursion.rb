# frozen_string_literal: true

require "test_helper"

class TestTailRecursion < Minitest::Test
  class SomeRecursion
    def run(n: 5)
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

  def test_tail_recursion
    some_recursion = SomeRecursion.new
    Tracia.start(non_tail_recursion: true) do
      some_recursion.fly
      some_recursion.run
    end
  rescue ZeroDivisionError
  end

end
