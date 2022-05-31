require "yaml"

class Tracia
  module GemPaths
    ABSTRACTS = {}

    ::Gem.path.each_with_index { |path, i| ABSTRACTS["GemPath#{i}"] = path }

    class << self
      def shorten(location)
        return '' if location.nil?
        ABSTRACTS.each{ |name, path| location = location.gsub(path, "$#{name}") }
        location
      end
    end
  end
end
