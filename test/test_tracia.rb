# frozen_string_literal: true

require "test_helper"

class TestTracia < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Tracia::VERSION
  end

  class SomeTest
    def a
      b
    end

    def b
      c1
      c2
      c3
      c4
      c5
    end

    def c1
      d
    end

    def d
      Tracia.add('i am in d')
    end

    def c2
      e
    end

    def e
      f
    end

    def f
      Tracia.add('i am in f')
    end

    def c3(n = 5)
      if n <= 0
        Tracia.add('i am in c3')
        return
      end
      c3(n - 1)
    end

    def c4
      3.times do
        g
      end
    end

    def g
      h
    end

    def h
      Tracia.add('i am in h')
    end

    def c5
      k1
    end

    (1..5).each do |n|
      define_method("k#{n}") do
        send("k#{n + 1}")
      end
    end

    def k6
      Tracia.add('i am in k6')
    end
  end

  def test_add
    Tracia.start do
      SomeTest.new.a
    end
  end

end
