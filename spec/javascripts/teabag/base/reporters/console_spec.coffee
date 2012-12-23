describe "Teabag.Reporters.Console", ->

  beforeEach ->
    @logSpy = spyOn(window.console, "log")
    spyOn(Date, "now").andReturn(666)

    @spec =
      fullDescription: "_spec_description_"
      description: "_spec_name_"
      suiteName: "_suite_name_"
      link: "?grep=_spec_description_"
      result: -> {status: "passed", skipped: false}
      errors: -> [{message: "_message_", trace: {stack: "_stack_"}}]
      getParents: -> [{fullDescription: "_suite_full_description", description: "_suite_description_"}]

    @reporter = new Teabag.Reporters.Console()
    @reporter.spec = @spec
    @normalizeSpy = spyOn(Teabag, "Spec").andReturn(@spec)


  describe "constructor", ->

    it "tracks failures, pending, total, and start time", ->
      expect(@reporter.start).toBeDefined()


  describe "#reportRunnerStarting", ->

    it "logs the information", ->
      spy = spyOn(@reporter, "log")
      spyOn(JSON, 'parse').andReturn('_date_time_')
      @reporter.reportRunnerStarting({total: 42})
      expect(spy).toHaveBeenCalledWith
        type:  "runner"
        total: 42
        start: "_date_time_"


  describe "#reportSuites", ->

    it "logs the information", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportSuites()
      expect(spy).toHaveBeenCalledWith
        type:  "suite"
        label: "_suite_description_"
        level: 0

    it "doesn't log the suite more than once.", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportSuites()
      @reporter.reportSuites()
      expect(spy.callCount).toBe(1)


  describe "#reportSpecResults", ->

    it "normalizes the spec", ->
      @reporter.reportSpecResults()
      expect(@normalizeSpy).toHaveBeenCalled()

    it "logs the information", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportSpecResults()
      expect(spy).toHaveBeenCalledWith
        type:    "spec"
        suite:   "_suite_name_"
        label:   "_spec_name_"
        status:  "passed"
        skipped: false

    describe "pending tests", ->

      beforeEach ->
        @trackSpy = spyOn(@reporter, "trackPending")
        @spec.result = -> {status: "pending", skipped: false}

      it "tracks that it was pending", ->
        @reporter.reportSpecResults()
        expect(@trackSpy).toHaveBeenCalled()

    describe "failing tests", ->

      beforeEach ->
        @trackSpy = spyOn(@reporter, "trackFailure")
        @spec.result = -> {status: "failed", skipped: false}

      it "tracks the failure", ->
        @reporter.reportSpecResults()
        expect(@trackSpy).toHaveBeenCalled()


  describe "#trackPending", ->
    beforeEach ->
      @reporter.spec = @spec
      @spec.result = -> {status: "pending", skipped: false}

    it "logs the status as 'pending'", ->
      spy = spyOn(@reporter, "log")
      @reporter.trackPending()
      expect(spy).toHaveBeenCalledWith
        type:    "spec"
        suite:   "_suite_name_"
        label:   "_spec_name_"
        status:  "pending"
        skipped: false


  describe "#trackFailure", ->
    beforeEach ->
      @reporter.spec = @spec
      @spec.result = -> {status: "failed", skipped: false}

    it "logs the status as 'failed'", ->
      spy = spyOn(@reporter, "log")
      @reporter.trackFailure()
      expect(spy).toHaveBeenCalledWith
        type:    "spec"
        suite:   "_suite_name_"
        label:   "_spec_name_"
        status:  "failed"
        skipped: false
        link:    "?grep=_spec_description_"
        message: "_message_"
        trace:   "_message_"


  describe "#reportRunnerResults", ->

    it "logs the results", ->
      spy = spyOn(@reporter, "log")
      @reporter.reportRunnerResults()
      Teabag.finished = false
      args = spy.mostRecentCall.args[0]
      expect(args["type"]).toEqual("result")
      expect(args["elapsed"]).toBeDefined()

    it "tells Teabag that we're finished", ->
      @reporter.reportRunnerResults()
      expect(Teabag.finished).toEqual(true)
      Teabag.finished = false


  describe "#log", ->

    it "logs the JSON of the object passed (with an additional _teabag property)", ->
      @reporter.log(foo: true)
      expect(@logSpy).toHaveBeenCalledWith('{"foo":true,"_teabag":true}')
