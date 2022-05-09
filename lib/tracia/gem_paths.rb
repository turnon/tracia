require "yaml"

class Tracia
  module GemPaths
    ABSTRACTS = {}

    ::YAML.load(`gem env`.gsub(/=>/, ':'))['RubyGems Environment']
      .detect{ |hash| hash.has_key?('GEM PATHS') }['GEM PATHS']
      .each_with_index { |path, i| ABSTRACTS["GemPath#{i}"] = path }

    class << self
      def shorten(location)
        return '' if location.nil?
        ABSTRACTS.each{ |name, path| location = location.gsub(path, "$#{name}") }
        location
      end
    end
  end
end
