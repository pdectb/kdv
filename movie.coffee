class $blab.Movie

    # helper functions
    sech = (x) -> 2 / (exp(x) + exp(-x))
    soliton = (A, x1, x) -> A*(sech(sqrt(A/12)*(x-x1))).pow(2)
    zeros = (x) -> nm.zeros(1, x.length)[0]
    
    constructor: (@spec) ->

        @spec.dispersion ?= (z) -> j*z.pow(3)        
        
        @M = 64 # No. of points for ETDRK4 complex means.
        @numStrobes = 10 # Number of strobes displayed in stack plot.
        @yMax = 1000 # Maximum vertical extent of soliton plot.
        @numSnapshots = 1000 # Number of time steps.
        @strobeInterval = Math.floor(@numSnapshots / @numStrobes)
        @count = 0 # Number of solitons placed in plot.

        @lineChart = new $blab.LineChart
            id: @spec.aniId
            xLabel: ""
            yLabel: ""
            xLim: [-pi, pi]
            yLim: [0, @yMax]
            xTicks: 7
            yTicks: 5
            click: (x, y) => @initSoliton(x, y)
            x0: 50
            y0: 50
            background: "transparent"

        @stack = new $blab.LineChart
            id: @spec.stackId
            xLabel: ""
            yLabel: ""
            xLim: [-pi, pi]
            yLim: [0, @yMax*(@numStrobes+1)]
            xTicks: 7
            yTicks: 0
            click: ->
            x0: 50
            y0: 50
            background: "transparent"

        @kdv = new $blab.BasicAnimation
            numSnapshots: @numSnapshots
            delay: 10
            strobeInterval: @strobeInterval
            snapshotFunction: ->
            strobeFunction: ->

        #$("#kdv-stop-button").on "click", => @kdv.stopAnimation()

    initetdrk4: ->
        N = @spec.N # No. x-axis grid points.
        h = @spec.h # Time step.
        
        @x = 2*pi/N * linspace(-N/2, N/2-1, N)
        @u0 = zeros(@x) # Initial condition.
        @u = zeros(@x) # Solution.

        @etdrk4 = new $blab.Etdrk4 # Imported time-step method.
            N: N
            h: h
            M: @M
            dispersion: @spec.dispersion # (z) -> j*z.pow(3)
        
    initSoliton: (xS, yS) ->
        @kdv.stopAnimation()
        @count++
        if @count is 1
            @initetdrk4()
            @stack.clear()
            @kdv.n = 0
        @u0 += soliton(yS, xS, @x)
        @lineChart.plot(@x, @u0)
        if @count is 2
            @count = 0
            @animateSolitons(@u0)

    animateSolitons: (u0) ->
        v = @etdrk4.fft u0
        @kdv.snapshotFunction = =>
            {@u, v} = @etdrk4.computeUV(v)        
            @lineChart.plot(@x, @u)
        @kdv.strobeFunction = =>
            @stack.plot(@x, 100+@u+@kdv.n/@numSnapshots*@yMax*@numStrobes, color="green", hold=true)
        @kdv.animate()
