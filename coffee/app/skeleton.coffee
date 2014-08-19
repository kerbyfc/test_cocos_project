Skeleton =

  _initFsm: ->
    if @stateflow? and @state?

      @_states = []
      @stateflow = @stateflow() if _.isFunction @stateflow

      events = _.map @stateflow, (flow, event) =>

        # check to prevent bugs searching
        unless _.isString flow
          throw Error "fsm flow type error"

        # parse states
        [from, to] = flow.match(FSM.re).slice(1)
        from = from.split '/'

        # accumulate for events delegation
        @_states.push from, to
        name: event, from: from, to: to

      # create finite state machine
      @fsm = new StateMachine.create
        initial: @state
        events: events

      # map accumulated states to delegate events
      for state in (@_states = _.uniq _.flatten @_states)
        for type in ["Enter", "Leave"]
          if handler = @["on#{type}#{_.capitalize state}"]

            do (handler) =>
              # revert arguments order
              @fsm["on#{type + state}".toLowerCase()] = (event, from, to, args...) =>
                handler args.concat([event, from, to])...

  _delegateEvents: ->

    # for all known input methods...
    for inputMethod, eventTypes of EVENTS.mapping
      if cc.sys.capabilities[inputMethod]
        for type, events of eventTypes

          # search for event handlers
          handlers = _.reduce(events, (result, event) =>
            if @[event]
              result[event] = (e) =>
                @[event](e, e.getCurrentTarget())
            result
          , {})

          if _.size handlers
            cc.eventManager.addListener(
              _.extend {}, handlers, event: cc.EventListener[type]
            , @)
