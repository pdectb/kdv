# Load text

txt = $blab.resource "page1.txt"
$("#page1").html txt

txt = $blab.resource "page2.txt"
$("#page2").html txt

# Play movie

movie = new $blab.Movie "solitons", {N:256, h:4e-5}

setTimeout (->
    movie.initSoliton(-1, 800)
    movie.initSoliton(1, 200)
    ), 3000
