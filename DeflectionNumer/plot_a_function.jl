using PlotlyJS
function plot_a_function(x,y)
    trace1 = scatter(;x=x, y=y,
                      mode="markers+lines", name="Test1")
    trace1["marker"] = Dict(:size => 5)

    data = [trace1]
    layout = Layout(;title="Test plot function")
    plot(data, layout)
end


# x1 = 0:0.0001:0.005
# y1 = getfc.(x1)
# plot_a_function( x1,y1)

# x2 = 0:0.0001:0.1
# y2 = getfps.(x2)
# plot_a_function( x2,y2)

