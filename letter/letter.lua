function _init()
    make_pen()
    make_greeting()

    mouse_x = 0
    mouse_y = 0

    prev_mouse_x = 0
    prev_mouse_y = 0

    is_clicking = false

    strokes = {}
    stroke_count = 0

    accurate_strokes = 0
    covered_targets = 0


    won = false
end



function _update()
    update_cursor_pen()

    if not won and is_clicking then

        sfx(0)

        -- add current mouse position
        add(strokes, {mouse_x, mouse_y})
        stroke_count += 1

        -- check accuracy once
        if point_on_target(mouse_x, mouse_y) then
            accurate_strokes += 1
        end

        -- check the line between the previous
        -- mouse position and the current one
        cover_segment(
            prev_mouse_x,
            prev_mouse_y,
            mouse_x,
            mouse_y
        )


        -- check win
        if check_win() then
            won = true
            _init()
        end
    end

    -- remember mouse position for next frame
    prev_mouse_x = mouse_x
    prev_mouse_y = mouse_y
end


function _draw()
    cls()

    draw_greeting()
    draw_pen()
    draw_cursor()
    draw_ui()
end


-- INIT --

function make_pen()
    poke(0x5f2d,1)
end

function make_greeting()

    greetings = {
        {
            name = "Thank You",
            sx = 8,
            sy = 0,
            sw = 48,
            sh = 32
        },

        {
            name = "Happy Birthday",
            sx = 56,
            sy = 0,
            sw = 40,
            sh = 32
        },

        {
            name = "I'm Sorry",
            sx = 96,
            sy = 0,
            sw = 32,
            sh = 32
        }
    }

    rnd_greeting_num = flr(rnd(#greetings)) + 1

    g = get_greeting(
        greetings[rnd_greeting_num].name
    )

    make_target()
end


function get_greeting(name)

    for greeting in all(greetings) do

        if greeting.name == name then
            return greeting
        end

    end

end

-- TARGET --

grid_size = 8
tolerance = 4

function grid_key(x,y)

    local gx = flr(x/grid_size)
    local gy = flr(y/grid_size)

    return gx..","..gy
end


function make_target()

    target_points = {}
    target_grid = {}

    covered_targets = 0
    accurate_strokes = 0

    local scale = 2.4

    local ox = 15
    local oy = 25

    for y = 0,g.sh-1 do

        for x = 0,g.sw-1 do

            -- color 8 is the greeting
            if sget(g.sx+x,g.sy+y) == 8 then

                local px =
                    ox + x*scale + scale/2

                local py =
                    oy + y*scale + scale/2

                -- {x,y,covered}
                local target = {
                    px,
                    py,
                    false
                }

                add(target_points,target)

                -- add target to spatial grid
                local key = grid_key(px,py)

                if target_grid[key] == nil then
                    target_grid[key] = {}
                end

                add(
                    target_grid[key],
                    target
                )
            end
        end
    end
end


function get_nearby_targets(x,y)

    local result = {}

    local gx = flr(x/grid_size)
    local gy = flr(y/grid_size)

    -- Check surrounding cells
    -- because tolerance can cross
    -- cell boundaries.
    for ox = -1,1 do

        for oy = -1,1 do

            local key =
                (gx+ox)..","..(gy+oy)

            local cell =
                target_grid[key]

            if cell then

                for t in all(cell) do
                    add(result,t)
                end

            end
        end
    end

    return result
end


function point_on_target(x,y)

    local tolerance2 =
        tolerance*tolerance

    local nearby =
        get_nearby_targets(x,y)

    for t in all(nearby) do

        local dx = x-t[1]
        local dy = y-t[2]

        if dx*dx+dy*dy <= tolerance2 then
            return true
        end

    end

    return false
end


function calculate_accuracy()

    if stroke_count == 0 then
        return 0
    end

    return accurate_strokes / stroke_count
end


function point_to_segment_dist2(
    px,py,
    x1,y1,
    x2,y2
)

    local dx = x2-x1
    local dy = y2-y1

    -- zero length segment
    if dx == 0 and dy == 0 then

        local ox = px-x1
        local oy = py-y1

        return ox*ox+oy*oy
    end

    -- project point onto line
    local t =
        (
            (px-x1)*dx +
            (py-y1)*dy
        )
        /
        (dx*dx+dy*dy)

    -- clamp to segment
    t = max(0,min(1,t))

    local closest_x =
        x1+t*dx

    local closest_y =
        y1+t*dy

    local ox =
        px-closest_x

    local oy =
        py-closest_y

    return ox*ox+oy*oy
end


function cover_segment(
    x1,y1,
    x2,y2
)

    local tolerance2 =
        tolerance*tolerance

    -- Find bounding box around segment
    -- and expand it by tolerance.
    local min_x =
        min(x1,x2)-tolerance

    local max_x =
        max(x1,x2)+tolerance

    local min_y =
        min(y1,y2)-tolerance

    local max_y =
        max(y1,y2)+tolerance


    -- Convert bounding box to grid cells
    local min_gx =
        flr(min_x/grid_size)

    local max_gx =
        flr(max_x/grid_size)

    local min_gy =
        flr(min_y/grid_size)

    local max_gy =
        flr(max_y/grid_size)


    -- Only inspect target points
    -- in cells touched by segment.
    for gx = min_gx,max_gx do

        for gy = min_gy,max_gy do

            local key =
                gx..","..gy

            local cell =
                target_grid[key]

            if cell then

                for t in all(cell) do

                    -- Ignore already covered targets
                    if not t[3] then

                        local dist2 =
                            point_to_segment_dist2(
                                t[1],
                                t[2],
                                x1,
                                y1,
                                x2,
                                y2
                            )

                        if dist2 <= tolerance2 then

                            t[3] = true

                            covered_targets += 1

                        end
                    end
                end
            end
        end
    end
end


function calculate_coverage()

    if #target_points == 0 then
        return 0
    end

    return covered_targets/#target_points
end


-- =========================================
-- WIN
-- =========================================

function check_win()

    local accuracy =
        calculate_accuracy()

    local coverage =
        calculate_coverage()

    return accuracy >= 0.60
       and coverage >= 0.60
end

-- UPDATE --
function update_cursor_pen()

    mouse_x = stat(32)
    mouse_y = stat(33)

    is_clicking =
        stat(34) == 1
end

-- DRAW --
function draw_greeting()

    sspr(
        g.sx,g.sy,
        g.sw,g.sh,
        15,25,
        g.sw*2.4,
        g.sh*2.4
    )
end


function draw_pen()

    for s in all(strokes) do

        circfill(
            s[1]+3,
            s[2]+3,
            3,
            5
        )

    end
end


function draw_cursor()

    spr(
        0,
        mouse_x+4,
        mouse_y+4
    )
end


function draw_ui()
    local accuracy = calculate_accuracy()
    local coverage = calculate_coverage()

    print("accuracy: "..accuracy, 10, 100, 5)
    print("coverage: "..coverage, 10, 110, 5)

end