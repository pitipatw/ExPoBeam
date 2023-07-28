using PlotlyJS
using DataFrames
using CSV
using Plot

data = CSV.read("output.csv", DataFrame)

mytrace = parcoords(;
             dimensions = [
               attr(range = [10,100]
                  , label = "x1"
                  , values = data.x1),
                attr(range = [0,1000]
                    , label = "x2"
                    , values = data.x2),
                attr(range = [0,500]
                    , label = "x3"
                    , values = data.x3),
                attr(range = [0,1000] 
                    , label = "x4"
                    , values = data.x4),
                attr(range = [0,1000]
                    , label = "x5"
                    , values = data.x5),
                attr(range = [0,1000]
                    , label = "x6"
                    , values = data.x6),
                attr(range = [0,1000]
                    , label = "x7"
                    , values = data.x7),
                attr(range = [0,1000]
                    , label = "x8"
                    , values = data.x8),
                attr(range = [0,1000]
                    , label = "x9"
                    , values = data.x9),
                attr(range = [0,1000]
                    , label = "x10"
                    , values = data.x10),
                attr(range = [0,1000]
                    , label = "x11"
                    , values = data.x11),
                attr(range = [0,1500]
                    , label = "x12"
                    , values = data.x12), 
                attr(range = [0,150]
                    , label = "x13"
                    , values = data.x13),
                attr(range = [0,1000]
                    , label = "x14"
                    , values = data.x14),
                attr(range = [0,1000]
                    , label = "x15"
                    , values = data.x15),
                ]);
layout = Layout(title_text="Parallel Coordinates Plot"
                , title_x=0.5 
                , title_y=0
                )
myplot = PlotlyJS.plot(mytrace,layout)
             
                    
              
               