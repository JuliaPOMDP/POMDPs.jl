### Rendering function for the Mars Exploration Problem

using Cairo, Colors, Parameters, Reel

const WALLE_IMG = read_from_png("wall_e.png")
const PLANT_IMG = read_from_png("plant.png")
const EVE_IMG = read_from_png("eve.png")


@with_kw mutable struct GridDraw
    x0::Int64 = 50
    y0::Int64 = 50
    cell_width::Int64 = 50
    cell_height::Int64 = 50
    n_cells::Int64 = 10
    line_width::Float64 = 1.
end


function render_line{T<:Real}(
    ctx        :: CairoContext,
    pts        :: Matrix{T}, # 2×n
    color      :: RGB{Float64},
    line_width :: Real = 1.0,
    line_cap   :: Integer=Cairo.CAIRO_LINE_CAP_ROUND, # CAIRO_LINE_CAP_BUTT, CAIRO_LINE_CAP_ROUND, CAIRO_LINE_CAP_SQUARE
    )

    line_width = user_to_device_distance!(ctx, [line_width,0])[1]

    save(ctx)
    set_source_rgb(ctx, color.:r, color.:g, color.:b)
    set_line_width(ctx,line_width)
    set_line_cap(ctx, line_cap)

    move_to(ctx, pts[1,1], pts[2,1])
    for i = 2 : size(pts,2)
        line_to(ctx, pts[1,i], pts[2,i])
    end
    stroke(ctx)
    restore(ctx)
end

function set_context_and_surface(canvas_width::Int=600, canvas_height::Int=100)
    c = CairoRGBSurface(canvas_width, canvas_height)
    ctx = creategc(c)
    ctx, c
end

function render_background(ctx::CairoContext, color::RGB{Float64})
    save(ctx)

    set_source_rgb(ctx, color.:r, color.:g, color.:b)

    rectangle(ctx, 0., 0., ctx.surface.width, ctx.surface.height) # background
    fill(ctx)
    restore(ctx)
end

function render_grid(ctx::CairoContext,
                     grid::GridDraw = GridDraw())

    #draw upper and lower line
    save(ctx)
    upper_pts = [grid.x0 grid.y0+grid.cell_height/2;
                 grid.x0 + grid.n_cells*grid.cell_width grid.y0 + grid.cell_height/2]'
    render_line(ctx, upper_pts, RGB(0.,0.,0.), grid.line_width)

    lower_pts = [grid.x0  grid.y0 - grid.cell_height/2;
                 grid.x0 + grid.n_cells*grid.cell_width grid.y0 - grid.cell_height/2]'
    render_line(ctx, lower_pts, RGB(0.,0.,0.), grid.line_width)

    # draw vertical separation
    for i = 0:grid.n_cells
        pts = [grid.x0+ i*grid.cell_width grid.y0 - grid.cell_height/2;
               grid.x0 + i*grid.cell_width grid.y0 + grid.cell_height/2]'
        render_line(ctx, pts, RGB(0.,0.,0.), grid.line_width)
    end
    restore(ctx)
end

function render_rewards(ctx::CairoContext, grid::GridDraw = GridDraw())
    render_agent(ctx, 10, grid, PLANT_IMG)
    render_agent(ctx, 1, grid, EVE_IMG)
end

function render_agent(ctx::CairoContext, cell::Int64,
                      grid::GridDraw = GridDraw(),
                      img::CairoSurface = WALLE_IMG)
    save(ctx)
    w = img.width
    h = img.height
    translate(ctx, grid.x0 +(cell - 0.5)*grid.cell_width, grid.y0)
    scale(ctx, grid.cell_width/w, grid.cell_height/h)
    translate(ctx, -0.5*w, -0.5*h)
    set_source_surface(ctx, img, 0, 0)
    paint(ctx)
    restore(ctx)
end

function render_state(s::Int64)
    ctx, c = set_context_and_surface()
    bg_col = RGB(1., 1., 1.)
    render_background(ctx, bg_col)
    render_grid(ctx)
    render_rewards(ctx)
    render_agent(ctx, s)
    c
end
