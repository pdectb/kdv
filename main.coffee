class Movie

    # helper functions
    zeros = (x) -> nm.zeros(1, x.length)[0]  # Zero vector same length as x
    sech = (x) -> 2 / (exp(x) + exp(-x))
    soliton = (A, x1, x) -> A*(sech(sqrt(A/12)*(x-x1))).pow(2)

    constructor: ->
        params = $blab.Parameters # import parameters
        N = params.N # No. of x-axis grid points.
        h = params.h # Time step
        M = 64 # No. of points for ETDRK4 complex means.
        @numStrobes = 10 # number of strobes
        @yMax = 1000 # maximum vertical extent of soliton plot
        @numSnapshots = 1000 # number of time steps
        @strobeInterval = Math.floor(@numSnapshots / @numStrobes)
        
        @x = 2*pi/N * linspace(-N/2, N/2-1, N)
        @count = 0
        @u0 = zeros(@x) # Solution initial condition.
        @u = zeros(@x) # Solution.

        @etdrk4 = new $blab.Etdrk4 # Imported time-step method.
            N: N
            h: h
            M: M
            dispersion: (z) -> j*z.pow(3) # KdV uxxx dispersion
                
        @lineChart = new $blab.LineChart
            id: "solitons"
            xLabel: ""
            yLabel: ""
            xLim: [-pi, pi]
            yLim: [0, @yMax]
            xTicks: 7
            yTicks: 5
            click: (x, y) => @initSoliton(x, y)
            x0: 50
            y0: 50

        @stack = new $blab.LineChart
            id: "stack"
            xLabel: ""
            yLabel: ""
            xLim: [-pi, pi]
            yLim: [0, @yMax*@numStrobes]
            xTicks: 7
            yTicks: 0
            click: ->
            x0: 50
            y0: 50

        @kdv = new $blab.BasicAnimation
            numSnapshots: @numSnapshots
            delay: 10
            strobeInterval: @strobeInterval
            snapshotFunction: ->
            strobeFunction: ->

        $("#kdv-stop-button").on "click", => @kdv.stopAnimation()

    initSoliton: (xS, yS) ->
        @kdv.stopAnimation()
        @count++
        @u0 = zeros(@x) if @count is 1
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
            @stack.plot(@x, @u+@kdv.n/@numSnapshots*@yMax*(@numStrobes-1), color="green", hold=true)
        @kdv.animate()


new Movie
