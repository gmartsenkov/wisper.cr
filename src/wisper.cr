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
        (@subscriptions_for_{{event_name}} + GlobalListeners.subscriptions_for_{{event_name}}).each { |handler| handler.call(e) }
      end

    {%end%}

    module GlobalListeners
      {% for event in Events.all_subclasses %}
        {% event_name = event.stringify.underscore.gsub(/::/, "_").id %}

        @@subscriptions_for_{{event_name}} = Array(Proc({{event}}, Nil)).new

        def self.listen(e : {{event.class}}, handler : Proc({{event}}, Nil))
          @@subscriptions_for_{{event_name}}.push(handler)
        end

        def self.subscriptions_for_{{event_name}}
          @@subscriptions_for_{{event_name}}
        end
      {%end%}
    end
  end

  macro event(struct_name, *properties)
    class {{struct_name}} < Events
      {% for property in properties %}
        {% if property.is_a?(Assign) %}
          getter {{property.target.id}}
        {% elsif property.is_a?(TypeDeclaration) %}
          getter {{property.var}} : {{property.type}}
        {% else %}
          getter :{{property.id}}
        {% end %}
      {% end %}


      def initialize({{*properties.map do |field| "@#{field.id}".id end}})
      end
    end
  end
end
