require "./wisper"

module Wisper::Publisher
  abstract class Events < Wisper::Events
    abstract def attributes : String
  end

  macro finished
    {% event_classes = Events.all_subclasses %}
    {% if event_classes.size > 0 %}
        alias EventTypes = {{ event_classes.join(" | ").id }}
    {% else %}
        alias EventTypes = Nil
    {% end %}

    {% for event in Events.all_subclasses %}
      {% event_name = event.stringify.underscore.gsub(/::/, "_").id %}

      @subscriptions_for_{{event_name}} = Array(Proc({{event}}, Nil)).new

      def on(e : {{event.class}}, async = false, &block : {{event}} -> Nil)
        if async
          @subscriptions_for_{{event_name}}
            .push(->(e : {{event}}) { spawn { block.call(e) } })
        else
          @subscriptions_for_{{event_name}}.push(block)
        end

        return self
      end

      def broadcast(e : {{event}})
        (
          @subscriptions_for_{{event_name}} +
          GlobalListeners.subscriptions_for_{{event_name}} +
          Wisper.temporary_subscriptions +
          Wisper.subscriptions
        ).each { |handler| handler.call(e) }
      end
    {% end %}

    module GlobalListeners
      {% for event in Events.all_subclasses %}
        {% event_name = event.stringify.underscore.gsub(/::/, "_").id %}

        @@subscriptions_for_{{event_name}} = Array(Proc({{event}}, Nil)).new

        def self.listen(e : {{event.class}}, handler : Proc({{event}}, Nil), async = false)
          if async
            @@subscriptions_for_{{event_name}}
              .push(->(e : {{event}}) { spawn { handler.call(e) } })
          else
            @@subscriptions_for_{{event_name}}.push(handler)
          end
        end

        def self.subscriptions_for_{{event_name}}
          @@subscriptions_for_{{event_name}}
        end
      {% end %}
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


      def initialize({{*properties.map do |field|
                         "@#{field.id}".id
                       end}})
      end

      {% if properties.size == 0 %}
        def attributes : String
          ""
        end
      {% else %}
        def attributes : String
          [{{*properties.map do |field|
               [field.var.stringify, "@#{field.var}".id]
             end}}].map { |pair| pair.join(": ") }.join(", ")
        end
      {% end %}
    end
  end
end
