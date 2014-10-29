movie = new $blab.Movie
    aniId: "solitons"
    stackId: "stack"
    N: 256
    h: 4e-5
    dispersion: (z) -> j*z.pow(3)
	#- z.pow(2)
#.

setTimeout (->
    movie.initSoliton(-1, 800)
    movie.initSoliton(1, 200)
    ), 3000
