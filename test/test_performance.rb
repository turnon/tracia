# frozen_string_literal: true

require "test_helper"

class TestPerformance < Minitest::Test
  class Perf
    def run
      500.times do |n|
        Tracia.add(n)
        level_500
      end
    end

    (1..500).reverse_each do |n|
      # meth =
      #   if n % 10 == 0
      #     "def level_#{n}; Tracia.add('lvl #{n}'); level_#{n - 1}; end"
      #   else
      #     "def level_#{n}; level_#{n - 1}; end"
      #   end
      meth = "def level_#{n}; level_#{n - 1}; end"
      eval(meth)
    end

    def level_0
      Tracia.add('lvl 0')
    end
  end

  def test_performance
    skip unless ENV['PERF']

    if RUBY_VERSION < '3.0.0'
      puts Process.pid
      spawn("sudo rbspy record --pid #{Process.pid}")
      sleep 1
    end

    perf = Perf.new

    begin_trace = Time.now
    Tracia.start(logger: ->(_){}) do
      perf.run
    end
    puts Time.now - begin_trace
  end
end
