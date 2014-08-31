
class Movie

    # helper functions
    zeros = (x) -> nm.zeros(1, x.length)[0]  # Zero vector same length as x
    sech = (x) -> 2 / (exp(x) + exp(-x))
    soliton = (A, x1, x) -> A*(sech(sqrt(A/12)*(x-x1))).pow(2)
    
    constructor: ->

        N = 256
        @x = 2*pi/N * linspace(-N/2, N/2-1, N)
        @count = 0
        @u0 = null
        @animateId = null
                
        @etdrk4 = new $blab.Etdrk4
            N: 256
            h: 4e-5
            M: 64 # no. pts for complex means
            dispersion: (z) -> j*z.pow(3)

        @lineChart = new $blab.LineChart
            id: "solitons"
            xLabel: "x"
            yLabel: "u"
            xLim: [-pi, pi]
            yLim: [0, 1000]
            xTicks: 7
            yTicks: 5
            click: (x, y) => @initSoliton(x, y) 

        $("#kdv-stop-button").on "click", => @stopAnimation()

    stopAnimation: () ->
        clearTimeout @animateId if @animateId
        @animateId = null

    initSoliton: (xS, yS) ->
        @stopAnimation()
        @count++
        @u0 = zeros(@x) if @count is 1
        @u0 += soliton(yS, xS, @x)
        @lineChart.plot(@x, @u0)
        if @count is 2
            @count = 0
            @animateSolitons(@u0)

    animateSolitons: (u0) ->
        v = @etdrk4.fft u0
        snapshot = =>
            {u, v} = @etdrk4.computeUV(v)        
            @lineChart.plot(@x, u)
        @animate snapshot, 1000, 10

    animate: (snapshotFunction, numSnapshots, delay=10) ->
        @stopAnimation()
        n = 1
        frame = ->
            snapshotFunction()
            n++
            @stopAnimation() if n>numSnapshots
        @animateId = setInterval (-> frame()), delay

new Movie

    
# Run: two solitons
#initSoliton(-1, 800)
#initSoliton(0, 200)  #;
