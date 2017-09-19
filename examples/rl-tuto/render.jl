### Rendering function for the Mars Exploration Problem

using Cairo, Colors

const WALLE_IMG = read_from_png("wall_e.png")
const PLANT_IMG = read_from_png("plant.png")
const EVE_IMG = read_from_png("eve.png")


mutable struct GridDraw
    x0::Int64
    y0::Int64
    cell_width::Float64
    cell_height::Float64
    n_cells::Int64
    line_width::Float64
    function GridDraw(;x0=50, y0=50, cell_width=50., cell_height=50., n_cells=10, line_width=1.)
        return new(x0, y0, cell_width, cell_height, n_cells, line_width)
    end
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

function paint_cell(ctx::CairoContext, cell::Int64, color::RGB{Float64},
                    grid::GridDraw = GridDraw())
    save(ctx)
    set_source_rgb(ctx, color.:r, color.:g, color.:b)
    # bottom left corner of the cell
    x = grid.x0+ (cell-1)*grid.cell_width
    y = grid.y0 - grid.cell_height/2
    rectangle(ctx, x, y, grid.cell_width, grid.cell_height) # background
    fill(ctx)
    restore(ctx)
end

function render_action_value(ctx::CairoContext, action::Symbol, value::Float64, cell::Int64,
                       grid::GridDraw = GridDraw())
    save(ctx)
    select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL,
                 Cairo.FONT_WEIGHT_NORMAL)
    font_size = 20.
    set_font_size(ctx, font_size)
    move_to(ctx, grid.x0 +(cell - 0.5)*grid.cell_width - 10, grid.y0)
    if action == :left
        str = @sprintf("← ")
    elseif action == :right
        str = @sprintf("→ ")
    end
    show_text(ctx, str)
    move_to(ctx, grid.x0 +(cell - 0.5)*grid.cell_width - 25, grid.y0 + font_size)
    val_str = @sprintf("%2.2f", value)
    show_text(ctx, val_str)
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


function colorval(policy::ValuePolicy, val, cmap)
    N = length(cmap)
    max_val = max(policy.mdp.r_left, policy.mdp.r_right)
    val_res = max_val/N
    val_ind = Int(floor(val/val_res)) + 1
    return cmap[val_ind]
end

function render_cell(cell::Int64)
    ctx, c = set_context_and_surface()
    bg_col = RGB(1., 1., 1.)
    render_background(ctx, bg_col)
    paint_cell(ctx, cell, RGB(1.,0.,0.))
    render_grid(ctx)
    render_action_value(ctx, :left, 1., cell)
    c
end



function render_policy(policy::ValuePolicy)
    ctx, c = set_context_and_surface()
    bg_col = RGB(1., 1., 1.)
    render_background(ctx, bg_col)

    cmap = colormap("Greens", 1000)
    for (i, s) in enumerate(ordered_states(policy.mdp))
        val = maximum(policy.value_table[i, :])
        a = action(policy, s)
        color = colorval(policy, val, cmap)
        paint_cell(ctx, s, color)
        render_action_value(ctx, a, val, s)
    end
    render_grid(ctx)
    c
end
