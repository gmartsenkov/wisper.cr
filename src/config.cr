require "log"

module Wisper
  module Config
    extend self

    @@logger : Log? = Log.for("Wisper")
    @@broadcast_history : Bool = false

    def broadcast_history=(bool)
      @@broadcast_history = bool
    end

    def broadcast_history
      @@broadcast_history
    end

    def logger=(logger)
      @@logger = logger
    end

    def logger
      @@logger
    end
  end
end
