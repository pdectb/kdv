class Movie

    # helper functions
    zeros = (x) -> nm.zeros(1, x.length)[0]  # Zero vector same length as x
    sech = (x) -> 2 / (exp(x) + exp(-x))
    soliton = (A, x1, x) -> A*(sech(sqrt(A/12)*(x-x1))).pow(2)

    constructor: ->

        N = 256 # No. of x-axis grid points.
        h = 4e-5 # Time step
        M = 64 # No. of points for ETDRK4 complex means.
        
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
            xLabel: "x"
            yLabel: "u"
            xLim: [-pi, pi]
            yLim: [0, 1000]
            xTicks: 7
            yTicks: 5
            click: (x, y) => @initSoliton(x, y) 

        @stack = new $blab.LineChart
            id: "stack"
            xLabel: "x"
            yLabel: "u"
            xLim: [-pi, pi]
            yLim: [0, 1000]
            xTicks: 7
            yTicks: 5
            click: ->

        @kdv = new $blab.BasicAnimation
            numSnapshots: 1000
            delay: 10
            strobeInterval: 100
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
            @stack.plot(@x, @u+(@kdv.n-1)/2, color="green", hold=true)
        @kdv.animate()

new Movie
