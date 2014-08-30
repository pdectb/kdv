
etdrk4 = new $blab.Etdrk4
    N: 256
    h: 4e-5
    M: 64 # no. pts for complex means
    dispersion: (z) -> j*z.pow(3)

# helper functions
zeros = (x) -> nm.zeros(1, x.length)[0]  # Zero vector same length as x
sech = (x) -> 2 / (exp(x) + exp(-x))
soliton = (A, x1, x) -> 3*A.pow(2) * (sech(.5*A*(x+x1))).pow(2)

# Set up grid and two-soliton initial data:
N = 256
x = 2*pi/N * linspace(-N/2, N/2-1, N)
u = soliton(4.5, 1.5, x)+soliton(2.9, -1.5, x)

lineChart = new $blab.LineChart
    id: "solitons"
    xLabel: "x"
    yLabel: "u"
    xLim: [-pi, pi]
    yLim: [0, 1000]
    xTicks: 7
    yTicks: 5
    click: (x, y) -> initSoliton(x, y) 

# Initial soliton plot
count = 0
u0 = null
initSoliton = (xS, yS) ->
    stopAnimation()
    count++
    u0 = zeros(x) if count is 1
    x1 = -xS
    A = sqrt(yS/3)
    u0 += soliton(A, x1, x)
    lineChart.plot(x, u0)
    if count is 2
        count = 0
        animateSolitons(u0)

stopAnimation = (animateId) ->
    clearTimeout animateId if animateId
    animateId = null

animateId = null

animate = (snapshotFunction, numSnapshots, delay=10) ->
    stopAnimation()
    n = 1
    snapshot = ->
        snapshotFunction()
        n++
        stopAnimation() if n>numSnapshots
    animateId = setInterval (-> snapshot()), delay

$("#kdv-stop-button").on "click", -> stopAnimation(animateId)
#d3.selectAll("#kdv-start-button").on "click", => start()

# Animated soliton plot
animateSolitons = (u) ->
    # Solve PDE and plot results.
    # u: initial conditions
    v = etdrk4.fft u
    snapshot = ->
        {u, v} = etdrk4.computeUV(v)        
        lineChart.plot(x, u)
    animate snapshot, 1000, 10
    
# Run: two solitons
#initSoliton(-1, 800)
#initSoliton(0, 200)  #;

