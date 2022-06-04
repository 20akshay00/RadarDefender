using GLMakie

function makefig(x, y)
    ball = Observable([Point2f(x, y)])
    fig = Figure(); display(fig)
    ax = Axis(fig[1, 1])
    ax.aspect = DataAspect()
    
    xlims!(ax, -5., 5.)
    ylims!(ax, -5., 5.)
    
    scatter!(ax, ball; marker = :circle, strokewidth = 2, strokecolor = :black, color = :white, markersize = 100)
    
    return fig, ball
end


# GLOBAL CONSTANTS

fig, ball = makefig(0, 0)

dirs = Dict(Keyboard.w => [0, 1], 
            Keyboard.a => [-1, 0], 
            Keyboard.s => [0, -1], 
            Keyboard.d => [1, 0])

on(events(fig).keyboardbutton) do event
    print(dump(event))
    if event.key in keys(dirs) && event.action in [Keyboard.press, Keyboard.repeat]
        ball[] = ball[] + 0.2 * [Point2f(dirs[event.key]...)]        
    end
end
