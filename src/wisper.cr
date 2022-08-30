# TODO: Write documentation for `Wisper`

module Wisper
  VERSION = "0.1.0"

  class Events
  end

  macro finished
    alias EventTypes = {{ Events.all_subclasses.join(" | ").id }}

    {% for event in Events.all_subclasses %}
      {% event_name = event.stringify.underscore.gsub(/::/, "_").id %}

      @subscriptions_for_{{event_name}} = Array(Proc({{event}}, Nil)).new

      def on(e : {{event.class}}, &block : {{event}} -> Nil)
        @subscriptions_for_{{event_name}}.push(block)
      end

      def broadcast(e : {{event}})
        @subscriptions_for_{{event_name}}.each { |handler| handler.call(e) }
      end
    {%end%}
  end

  macro event(struct_name)
    class {{struct_name}} < Events
      property x, y

      def initialize(@x : Int32, @y : Int32)
      end
    end
  end
end
