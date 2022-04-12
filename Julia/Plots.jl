### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ba502542-c9ec-4255-a334-047dca9455d6
begin
ROOT = @__DIR__

# Activate the local environment
using Pkg
Pkg.activate(ROOT, io = devnull)

# Load the packages
using Statistics
using Plots
using PlutoUI
using GraphRecipes
using StatsPlots

md"This is a Pluto notebook for showing off some `Plots.jl` goodness and preparing plots for publication."
end

# ╔═╡ 80d8f718-1ffe-4ed0-aefb-2e4cd476997c
@bind params confirm(
    PlutoUI.combine() do Child
        md"""
        Backend: $(Child("backend", Select(
            [:GR, :PGFPlotsX, :PlotlyJS, :PyPlot],
            default = :GR
        )))
         DPI: $(Child("dpi", NumberField( 
            120:1:400,
            default = 300,
        )))
         Size factor: $(Child("size_factor", NumberField( 
            1:0.1:10,
            default = 5,
        )))\
        Base size: $(Child("size_x", NumberField( 
            50:600,
            default = 120,
        )))
        $(Child("size_y", NumberField( 
            50:600,
            default = 80,
        )))\

        """
    end
)

# ╔═╡ d356cab0-f755-41f0-9d3b-4f291f822822
begin
# Unpack some the parameters
backend = params.backend
dpi = params.dpi

# Define the path to the plots directory
PLOTS = joinpath(ROOT, "plots", "$(backend)")
mkpath(PLOTS)

# Compute the plot size
size = params.size_factor * [params.size_x, params.size_y]

"Enable the backend"
function enable(backend)
    if backend == :GR
        gr()
    elseif backend == :PGFPlotsX
        pgfplotsx()
    elseif backend == :PlotlyJS
        plotlyjs()
    elseif backend == :PyPlot
        pyplot()
    end
end

"Save the plot"
function save(figure, backend)
    if backend == :PGFPlotsX
        savefig(joinpath(PLOTS, figure * ".pdf"))
    else
        savefig(joinpath(PLOTS, figure * ".png"))
    end
end

# Print the info
md"""
Plot size: $(size[1]), $(size[2]) px
  Final size: $(size[1] * dpi / 100), $(size[2] * dpi / 100) px
"""
end

# ╔═╡ 40983e0a-1340-4b66-bb84-c0da12c6da25
@bind plots confirm(
    MultiCheckBox(
        [
            "lines" => "Lines",
            "histogram" => "Histogram",
            "parametric" => "Parametric",
            "polar" => "Polar plots",
            "markers" => "Markers",
            "colors" => "Colors",
            "global" => "Global",
            "group" => "Group and Subplots",
            "contours" => "Contours",
            "heatmap" => "Heatmap",
            "histogram2d" => "Histogram2D",
            "3D" => "3D",
            "surface" => "3D surface",
            "heart" => "Animation (Heart)",
            "waves" => "Animation (Waves)",
            "graph" => "Graph",
            "AST" => "AST",
            "marginalkde" => "Marginal KDE",
        ],
        orientation=:column,
        select_all=true,
    )
)

# ╔═╡ b0b2cc0f-b7d1-4a41-84e0-4bc99a33aa3d
md"#### Lines"

# ╔═╡ 10c757b6-7719-45e1-8ecc-eb79de3f0e86
begin
if "lines" in plots
enable(backend)

# Plot some fake data
p_lines = plot(Plots.fakedata(50, 5); linewidth=3, legend=:topright, dpi, size)

# Save the plot
save("lines", backend)

p_lines
end
end

# ╔═╡ 9d0c5a15-874a-4cc3-a81b-7026c23b1f3f
md"#### Histogram"

# ╔═╡ 14d54583-ca41-4daf-83e7-4dc26eeac93f
begin
if "histogram" in plots
enable(backend)

# Plot a histogram
p_histogram = histogram(
    randn(1000);
    bins=:scott,
    weights=repeat(1:5, outer = 200),
    dpi,
    size,
)

# Save the plot
save("histogram", backend)

p_histogram
end
end

# ╔═╡ f2b8a98f-8815-4ecf-b726-8de0b5ef52b6
md"#### Parametric plots"

# ╔═╡ 6b5e1ed3-5936-44d2-8acb-ce10ed61a529
begin
if "parametric" in plots
enable(backend)

# Plot a parametric plot
p_parametric = plot(
    sin,
    x -> sin(2x),
    0,
    2π;
    lw=4,
    legend=false,
    fill=(0, :orange),
    dpi,
    size,
)

# Save the plot
save("parametric", backend)

p_parametric
end
end

# ╔═╡ b6f1a674-88cc-4e3d-9bef-b73de6126f1b
md"#### Polar plots"

# ╔═╡ bd7a3e17-054f-4bf5-b4e9-8b41ca038b35
begin
if "polar" in plots
enable(backend)

# Generate data
Θ = range(0, 1.5π, length = 100)
r = abs.(0.1 * randn(100) + sin.(3Θ))

# Plot a polar plot
p_polar = plot(Θ, r; proj=:polar, m=2, dpi, size)

# Save the plot
save("polar", backend)

p_polar
end
end

# ╔═╡ f0565d5a-5ab1-4dfd-9097-4543bb3ed621
md"#### Markers"

# ╔═╡ 39238fb7-c2c3-435c-a26f-b3eaf3f6c9ae
begin
if "markers" in plots
enable(backend)

# Get the markers
markers = filter((m -> m in Plots.supported_markers()), Plots._shape_keys)
markers = permutedims(markers)

# Generate a pseudo-grid
n_markers = length(markers)
x_markers = (range(0, stop = 10, length = n_markers + 2))[2:end - 1]
y_markers = repeat(reshape(reverse(x_markers), 1, :), n_markers, 1)

# Plot the markers
p_markers = scatter(
    x_markers,
    y_markers;
    m=markers,
    markersize=7,
    label=map(string, markers),
    bg=:linen,
    xlim=(0, 10),
    ylim=(0, 10),
    legend=:topright,
    legendfontsize=8,
    dpi,
    size,
)

# Save the plot
save("markers", backend)

p_markers
end
end

# ╔═╡ c5a83092-6494-4f76-8e43-66c0449c8e44
md"#### Colors"

# ╔═╡ dbc6f8a2-1e55-4eb4-b163-d5050b135ce5
begin
if "colors" in plots
enable(backend)

# Plot four random lines
p_colors = plot(
    0:10:100,
    rand(11, 4);
    w=3,
    palette=cgrad(:inferno),
    fill=0,
    α=0.6,
    legend=false,
    dpi,
    size,
)

# Plot a bunch of random points
y_colors = rand(100)
scatter!(
    y_colors,
    zcolor=abs.(y_colors .- 0.5),
    m=(:heat, 0.8, Plots.stroke(1, :green)),
    ms=10 * abs.(y_colors .- 0.5) .+ 4,
    colorbar=:best,
)

# Save the plot
save("colors", backend)

p_colors
end
end

# ╔═╡ ab076971-1f57-4193-a347-926d4004c78b
md"#### Global"

# ╔═╡ 4ad6f925-9512-4724-9ee1-d0a02b06c430
begin
if "global" in plots
enable(backend)

# Generate data
y_global = rand(20, 3)

# Plot the data
p_global = plot(
    y_global;
    xaxis=("XLABEL", (-5, 30), 0:2:20, :flip),
    background_color=RGB(0.2, 0.2, 0.2),
    legend=false,
    dpi,
    size,
)

# Mutate the plot
hline!(
    mean(y_global, dims = 1) + rand(1, 3);
    line=(4, :dash, 0.6, [:lightgreen :green :darkgreen]),
)
vline!([5, 10])
title!("TITLE")
yaxis!("YLABEL", :log10, minorgrid=true)

# Save the plot
save("global", backend)

p_global
end
end

# ╔═╡ 813396bf-f8a9-4f5c-8498-cdd770183273
md"#### Groups and Subplots"

# ╔═╡ fd5bd4ff-812b-47e4-b0b0-257b6636e5e9
begin
if "group" in plots
enable(backend)

# Generate random group associations
group = rand(map(i -> "group $(i)", 1:4), 100)

# Group some random data
p_group = plot(
    rand(100);
    layout=@layout([a b; c]),
    group,
    linetype=[:bar :scatter :steppre],
    linecolor=:match,
    legend=:topright,
    dpi,
    size,
)

# Save the plot
save("group", backend)

p_group
end
end

# ╔═╡ e9f22891-bd49-489d-8799-c48c20eae540
md"#### Contours"

# ╔═╡ 4036bb6c-9ced-4811-943b-0cccdf121a8b
begin
if "contours" in plots
enable(backend)

# Prepare data
x_contours = 1:0.5:20
y_contours = 1:0.5:10
f(x, y) = (3x + y ^ 2) * abs(sin(x) + cos(y))
X = repeat(reshape(x_contours, 1, :), length(y_contours), 1)
Y = repeat(y_contours, 1, length(x_contours))
Z = map(f, X, Y)
p1 = contour(x_contours, y_contours, f; fill=true)
p2 = contour(x_contours, y_contours, Z)

# Plot the contours
p_contours = plot(p1, p2; layout=(2, 1), dpi, size)

# Save the plot
save("contours", backend)

p_contours
end
end

# ╔═╡ 9e8e2f58-894d-46ba-9390-dbd0edfae4b0
md"#### Heatmap"

# ╔═╡ 5e32d1ce-2534-4a83-897a-be6369c50d1f
begin
if "heatmap" in plots
enable(backend)

# Prepare data
xs_histogram = [string("x", i) for i = 1:10]
ys_histogram = [string("y", i) for i = 1:4]
z_histogram = float((1:4) * reshape(1:10, 1, :))

# Plot a heatmap
p_heatmap = heatmap(
    xs_histogram,
    ys_histogram,
    z_histogram;
    aspect_ratio=1,
    dpi,
    size,
)

# Save the plot
save("heatmap", backend)

p_heatmap
end
end

# ╔═╡ 321184c0-415c-4c8f-b94c-3492d6f8782c
md"#### Histogram2D"

# ╔═╡ 42a45eea-cd2d-4953-9266-6d30e91efd82
begin
if "histogram2d" in plots
enable(backend)

# Compute the data
n_histogram2d = 10000
x_histogram2d = exp.(0.1 * randn(n_histogram2d) .+ randn(n_histogram2d) .* im)

# Plot the 2D-histogram
p_histogram2d = histogram2d(
    x_histogram2d;
    nbins=(20, 40),
    show_empty_bins=true,
    normed=true,
    aspect_ratio=1,
    dpi,
    size,
)

# Save the plot
save("histogram2d", backend)

p_histogram2d
end
end

# ╔═╡ d89da106-72d1-4579-b9f6-f044e1eee554
md"#### 3D"

# ╔═╡ 8c7bc68d-ffee-4ec8-b8bb-3c081ac193f3
begin
if "3D" in plots
enable(backend)

# Generate the data for the spiral
n_3D = 100
ts = range(0, stop = 8π, length = n_3D)
x_3D = ts .* map(cos, ts)
y_3D = (0.1ts) .* map(sin, ts)
z_3D = 1:n_3D

# Plot the spiral
p_3D = plot(
    x_3D,
    y_3D,
    z_3D;
    camera=(30, 30),
    zcolor=reverse(z_3D),
    marker=(10, 0.8, :blues, Plots.stroke(0)),
    legend=false,
    cbar=true,
    w=5,
    dpi,
    size,
)

# Plot the line
plot!(zeros(n_3D), zeros(n_3D), 1:n_3D, w = 10)

# Save the plot
save("3D", backend)

p_3D
end
end

# ╔═╡ 22c30b75-1106-426c-9a45-93b4f58a9c8d
md"#### 3D surface"

# ╔═╡ 2d129cdb-108a-4b7d-995f-33b5d5eb62d6
begin
if "surface" in plots
enable(backend)

# Generate data
x_surface = 0:π/20:4π
y_surface = 0:π/20:4π
z_surface = 5 .* sin.(x_surface) * cos.(y_surface)'

# Plot the surface
p_surface = plot(
    x_surface,
    y_surface,
    z_surface;
    st=:surface,
    dpi,
    size,
)

# Save the plot
save("surface", backend)

p_surface
end
end

# ╔═╡ e3bee7b1-9dcd-4568-b735-2051e9630243
md"#### Animation (Heart)"

# ╔═╡ 713db5a1-6c2f-43be-b041-fe74b95f3b0c
begin
if "heart" in plots
gr()

# Create a recipe for a custom type
@userplot CirclePlot
@recipe function f(cp::CirclePlot)
    x, y, i = cp.args
    n = length(x)
    inds = circshift(1:n, 1 - i)
    linewidth --> range(0, 10, length = n)
    seriesalpha --> range(0, 1, length = n)
    aspect_ratio --> 1
    label --> false
    x[inds], y[inds]
end

# Generate data for the heart
n_animation = 400
t_animation = range(0, 2π, length = n_animation)
x_animation = 16sin.(t_animation).^3
y_animation = 13cos.(t_animation) .- 5cos.(2t_animation) .-
              2cos.(3t_animation) .- cos.(4t_animation)

# Create an animation
animation = @animate for i ∈ 1:n_animation
    circleplot(
        x_animation,
        y_animation,
        i;
        line_z=1:n_animation,
        cbar=false,
        c=:reds,
        framestyle=:none,
        dpi,
        size,
    )
end when mod1(i, 10) == 5

# Create a GIF
gif(animation, joinpath(ROOT, "plots", "heart.gif"), fps=10, show_msg=false)
end
end

# ╔═╡ bccb93e1-5d66-4fc5-9da8-c6386b065a98
md"#### Animation (Waves)"

# ╔═╡ 2c556d8e-3c9f-4cba-b60a-45bc2dbe24c1
begin
if "waves" in plots
gr()

# Prepare data
x = y = range(-5, 5, length = 40)
zs = zeros(0, 40)
n = 100

# Create an animation
anim_waves = @animate for i in range(0, 2π; length = n)
    f(x, y) = sin(x + 10sin(i)) + cos(y)

    # Create a plot with 3 subplots and a custom layout
    l = @layout [a{0.7w} b; c{0.2h}]
    p = plot(x, y, f; st=[:surface, :contourf], layout=l, legend=false)

    # Induce a slight oscillating camera angle sweep, in degrees (azimuth, altitude)
    plot!(p[1], camera = (10 * (1 + cos(i)), 40))

    # Add a tracking line
    fixed_x = zeros(40)
    z = map(f, fixed_x, y)
    plot!(p[1], fixed_x, y, z, line = (:black, 5, 0.2))
    vline!(p[2], [0], line = (:black, 5))

    # Add to and show the tracked values over time
    global zs = vcat(zs, z')
    plot!(p[3], zs, α=0.2, palette=cgrad(:blues).colors, legend=false)
end

# Create a GIF
gif(anim_waves, joinpath(ROOT, "plots", "waves.gif"), fps=15, show_msg=false)
end
end

# ╔═╡ 1b04c4d4-8fc9-4cb2-afea-99c0d9f56c73
md"#### Graph `(GraphRecipes)`"

# ╔═╡ 07e936fd-d277-4e1d-be2c-51070918d226
begin
if "graph" in plots
enable(backend)

# Generate data
n_graph= 15
A = Float64[rand() < 0.5 ? 0 : rand() for i=1:n_graph, j=1:n_graph]
for i=1:n_graph
    A[i, 1:i-1] = A[1:i-1, i]
    A[i, i] = 0
end

# Plot the graph
p_graph = graphplot(
    A;
    markersize=0.2,
    node_weights=1:n_graph,
    markercolor=range(colorant"yellow", stop=colorant"red", length=n_graph),
    names=1:n_graph,
    fontsize=10,
    linecolor=:darkgrey,
    dpi,
    size,
)

# Save the plot
save("graph", backend)

p_graph
end
end

# ╔═╡ 24b90639-fdb8-4bc4-b316-f75c375e2c96
md"#### AST `(GraphRecipes)`"

# ╔═╡ f572e4c4-5fab-44c0-b8ff-0b2689aaea20
begin
if "AST" in plots
enable(backend)

# Prepare an expression
code = :(
function mysum(list)
    out = 0
    for value in list
        out += value
    end
    out
end
)

# Plot the AST
p_ast = plot(
    code;
    fontsize=12,
    shorten=0.01,
    axis_buffer=0.15,
    nodeshape=:rect,
    dpi,
    size,
)

# Save the plot
save("ast", backend)

p_ast
end
end

# ╔═╡ 900c5ddc-40b6-4415-8bf2-929c7490bd74
md"#### Marginal KDE `(StatsPlots)`"

# ╔═╡ 7189bccd-f128-41cc-b7c9-6b81796df1b5
begin
if "marginalkde" in plots
enable(backend)

# Generate some random data
x_marginalkde = randn(1024)
y_marginalkde = randn(1024)

# Plot a marginal kernel density estimation
p_marginalkde = marginalkde(x_marginalkde, x_marginalkde + y_marginalkde; dpi, size)

# Save the plot
save("marginalkde", backend)

p_marginalkde
end
end

# ╔═╡ Cell order:
# ╟─ba502542-c9ec-4255-a334-047dca9455d6
# ╟─80d8f718-1ffe-4ed0-aefb-2e4cd476997c
# ╟─d356cab0-f755-41f0-9d3b-4f291f822822
# ╟─40983e0a-1340-4b66-bb84-c0da12c6da25
# ╟─b0b2cc0f-b7d1-4a41-84e0-4bc99a33aa3d
# ╠═10c757b6-7719-45e1-8ecc-eb79de3f0e86
# ╟─9d0c5a15-874a-4cc3-a81b-7026c23b1f3f
# ╠═14d54583-ca41-4daf-83e7-4dc26eeac93f
# ╟─f2b8a98f-8815-4ecf-b726-8de0b5ef52b6
# ╟─6b5e1ed3-5936-44d2-8acb-ce10ed61a529
# ╟─b6f1a674-88cc-4e3d-9bef-b73de6126f1b
# ╠═bd7a3e17-054f-4bf5-b4e9-8b41ca038b35
# ╟─f0565d5a-5ab1-4dfd-9097-4543bb3ed621
# ╟─39238fb7-c2c3-435c-a26f-b3eaf3f6c9ae
# ╟─c5a83092-6494-4f76-8e43-66c0449c8e44
# ╟─dbc6f8a2-1e55-4eb4-b163-d5050b135ce5
# ╟─ab076971-1f57-4193-a347-926d4004c78b
# ╟─4ad6f925-9512-4724-9ee1-d0a02b06c430
# ╟─813396bf-f8a9-4f5c-8498-cdd770183273
# ╟─fd5bd4ff-812b-47e4-b0b0-257b6636e5e9
# ╟─e9f22891-bd49-489d-8799-c48c20eae540
# ╟─4036bb6c-9ced-4811-943b-0cccdf121a8b
# ╟─9e8e2f58-894d-46ba-9390-dbd0edfae4b0
# ╟─5e32d1ce-2534-4a83-897a-be6369c50d1f
# ╟─321184c0-415c-4c8f-b94c-3492d6f8782c
# ╟─42a45eea-cd2d-4953-9266-6d30e91efd82
# ╟─d89da106-72d1-4579-b9f6-f044e1eee554
# ╟─8c7bc68d-ffee-4ec8-b8bb-3c081ac193f3
# ╟─22c30b75-1106-426c-9a45-93b4f58a9c8d
# ╟─2d129cdb-108a-4b7d-995f-33b5d5eb62d6
# ╟─e3bee7b1-9dcd-4568-b735-2051e9630243
# ╟─713db5a1-6c2f-43be-b041-fe74b95f3b0c
# ╟─bccb93e1-5d66-4fc5-9da8-c6386b065a98
# ╟─2c556d8e-3c9f-4cba-b60a-45bc2dbe24c1
# ╟─1b04c4d4-8fc9-4cb2-afea-99c0d9f56c73
# ╟─07e936fd-d277-4e1d-be2c-51070918d226
# ╟─24b90639-fdb8-4bc4-b316-f75c375e2c96
# ╟─f572e4c4-5fab-44c0-b8ff-0b2689aaea20
# ╟─900c5ddc-40b6-4415-8bf2-929c7490bd74
# ╟─7189bccd-f128-41cc-b7c9-6b81796df1b5
