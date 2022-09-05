def capture_events(&block)
  events = Array(Wisper::EventTypes).new

  handler = ->(event : Wisper::EventTypes) do
    events << event
  end

  Wisper.listen(handler) do
    yield
  end

  events
end
