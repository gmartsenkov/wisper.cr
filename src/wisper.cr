# TODO: Write documentation for `Wisper`

require "./config"
require "./publisher"

module Wisper
  VERSION = "1.0.2"

  class Events
  end

  macro finished
    {% events = Wisper::Events.all_subclasses.reject { |k| k.stringify == "Wisper::Publisher::Events" } %}
    {% if events.size > 0 %}
      alias EventTypes = {{ Wisper::Events.all_subclasses.reject { |k| k.stringify == "Wisper::Publisher::Events" }.join(" | ").id }}
    {% else %}
      alias EventTypes = Nil
    {% end %}

    @@global_subs = Array(Proc(Wisper::EventTypes, Nil)).new

    def self.subscriptions
      @@global_subs
    end

    def self.listen(handler : Proc(Wisper::EventTypes, Nil))
      @@global_subs << handler
    end
  end

  def self.default_logger(event : Wisper::EventTypes)
    attributes = event.attributes
    message = "Published - #{event.class.name}"
    message += " - #{attributes}" unless attributes.empty?
    Log.for("Wisper").info { message }
  end
end
