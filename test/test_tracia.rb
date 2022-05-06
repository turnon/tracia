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
  end

  def test_add
    Tracia.start do
      SomeTest.new.a
    end
  end

end
