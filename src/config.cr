require "log"

module Wisper
  module Config
    extend self

    @@logger : Log? = Log.for("Wisper")

    def logger=(logger)
      @@logger = logger
    end

    def logger
      @@logger
    end
  end
end
