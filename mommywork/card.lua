-- ========== INIT ========== -- 
function card.init()
    make_greeting()
    strokes = {}
    stroke_count = 0 
    acc_strokes = 0
    covered_targets = 0
    drawing = false
    card_won = false

    prev_mouse_x = mouse_x
    prev_mouse_y = mouse_y
end

function make_greeting()
    greetings = {
        {
            name = "Thank You",

            sx = 8,
            sy = 32,

            sw = 48,
            sh = 32
        },

        {
            name = "Happy Birthday",

            sx = 56,
            sy = 32,

            sw = 40,
            sh = 32
        },

        {
            name = "I'm Sorry",

            sx = 96,
            sy = 32,

            sw = 32,
            sh = 32
        }
    }

    rnd_greeting_index = flr(rnd(#greetings)) + 1
    greeting = get_greeting(greetings[rnd_greeting_index].name)
    make_target()
end

function get_greeting(name)
    for g in all(greetings) do
        if g.name == name then 
            return g
        end
    end
    return nil
end

-- ========== UPDATE ========== -- 
function card.update()
    if mouse_pressed() then 
        drawing = true
    end

    if mouse_released() then 
        drawing = false
    end

    if drawing and not card_won then 
        add(strokes, {mouse_x,mouse_y})
        stroke_count += 1
        if point_on_target(mouse_x, mouse_y) then 
            acc_strokes +=1 
        end
        cover_segment(prev_mouse_x, prev_mouse_y, mouse_x, mouse_y)
        if card.check_win() then 
            card_won = true 
            win_game()
            return 
        end
        prev_mouse_x = mouse_x
        prev_mouse_y = mouse_y
    end 
end

grid_size = 8
tolerance = 4

function grid_key(x,y)
    local gx = flr(x / grid_size)
    local gy = flr (y / grid_size)
    return gx..","..gy
end

function make_target()
    target_points = {}
    target_grid = {}
    local scale = 2.4 
    local ox = 15
    local oy = 25

    for y = 0, greeting.sh - 1 do 
        for x = 0, greeting.sw - 1 do 
            if sget(greeting.sx + x, greeting.sy + y) == 8 then 
                    local px = ox + x * scale + scale/2
                    local py = oy + y * scale + scale/2
                    local target = {px, py}
                    add(target_points, target)
                    local key = grid_key(px,py)

                    if target_grid[key] == nil then 
                        target_grid[key] = {}
                    end
                    add(target_grid[key], target)
            end
        end
    end
end

function get_nearby_targets(x,y)
    local result ={}
    local gx = flr(x / grid_size)
    local gy = flr(y / grid_size)

    for ox = -1,1 do 
        for oy = -1,1 do 
            local key = (gx + ox)..","..(gy + oy)
            local cell = target_grid[key]
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
    local tolerance2 = tolerance * tolerance 
    local nearby = get_nearby_targets(x,y)
    for t in all(nearby) do 
        local dx = x - t[1]
        local dy = y - t[2]

        if dx*dx + dy*dy <= tolerance2 then 
            return true 
        end
    end
    return false 
end

function calculate_accuracy()
    if stroke_count == 0 then 
        return 0
    end
    return acc_strokes/stroke_count
end

function point_to_segment_dist2(px,py,x1,y1,x2,y2)
    local dx = x2 - x1
    local dy = y2 - y1 

    if dx == 0 and dy == 0 then 
        local ox = px-x1
        local oy = py-y1
        return ox*ox + oy*oy
    end

    local t =
        ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)
        
    t =
        max(0,min(1,t))

    local closest_x = x1 + t * dx
    local closest_y = y1 + t * dy
    local ox = px - closest_x
    local oy = py - closest_y
    return ox * ox + oy * oy
end 

function cover_segment(x1,y1,x2,y2)
    local tolerance2 = tolerance*tolerance 
    local min_x = min(x1,x2) - tolerance
    local max_x = max(x1,x2) + tolerance
    local min_y = min(y1,y2) - tolerance
    local max_y = max(y1,y2) + tolerance

    local min_gx = flr(min_x / grid_size)
    local max_gx = flr(max_x / grid_size)
    local min_gy = flr(min_y / grid_size)
    local max_gy = flr(max_y / grid_size)

    for gx = min_gx,max_gx do
        for gy = min_gy,max_gy do
            local key = gx .."," ..gy
            local cell = target_grid[key]
            if cell then
                for t in all(cell) do
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
    return covered_targets / #target_points
end

function card.check_win()
    local acc = calculate_accuracy()
    local cov = calculate_coverage()

    return acc >= 0.60 and cov >= 0.75
end


-- ========== DRAW ========== -- 
function card.draw()
    draw_greeting()
    draw_pen()
end

function draw_greeting()
    sspr(
        greeting.sx,
        greeting.sy,

        greeting.sw,
        greeting.sh,

        15,
        25,

        greeting.sw * 2.4,
        greeting.sh * 2.4
    )
end

function draw_pen()
    for s in all(strokes) do 
        circfill(s[1], s[2], 3, 14)
    end
end
-- ========== HELPER ========== -- 

