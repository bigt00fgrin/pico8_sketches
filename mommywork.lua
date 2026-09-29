--=====================================================--
-- GAME MANAGER
--=====================================================--

function _init()

    games = {
        {
            init = dinner_init,
            update = dinner_update,
            draw = dinner_draw,
            msg = "assign the seats!"
        },

        {
            init = letter_init,
            update = letter_update,
            draw = letter_draw,
            msg = "sign the card!"
        },

        {
            init = cake_init,
            update = cake_update,
            draw = cake_draw,
            msg ="decide the baker!"
        }
    }

    score = 0

    game_duration = 480

    sys_state = "transition"
    state_timer = 60

    current_game = nil

    make_mouse()

    choose_random_game()
end


function choose_random_game()

    local next_idx

    repeat
        next_idx =
            flr(rnd(#games)) + 1
    until next_idx != current_game_index

    current_game_index =
        next_idx

    current_game =
        games[next_idx]

    current_game.init()
end


function start_game()

    sys_state = "game"
    state_timer = game_duration
end


function win_game()

    score += 1

    sys_state = "transition"
    state_timer = 60

    choose_random_game()
end


function finish_game()

    sys_state = "transition"
    state_timer = 60

    choose_random_game()
end


function _update()

    update_mouse()

    if sys_state == "transition" then

        state_timer -= 1

        if state_timer <= 0 then
            start_game()
        end

    elseif sys_state == "game" then

        current_game.update()

        -- The minigame may have ended itself
        -- by calling win_game().
        if sys_state != "game" then
            return
        end

        state_timer -= 1

        if state_timer <= 0 then
            finish_game()
        end

    end
end


function _draw()

    cls()

    if sys_state == "transition" then

        draw_transition()

    elseif sys_state == "game" then

        current_game.draw()

        draw_game_ui()
    end

    draw_mouse()
end


function draw_transition()

    rectfill(
        14,44,
        114,84,
        0
    )

    print(
        current_game.msg,
        64 - (#current_game.msg * 2),
        60,
        7
    )

    print(
        "score: "..score,
        48,70,
        7
    )
end


function draw_game_ui()

    local width =
        state_timer * (128 / game_duration)

    rectfill(
        0,124,
        width,127,
        8
    )
end


--=====================================================--
-- INPUT
--=====================================================--

function make_mouse()

    poke(0x5f2d,1)

    mouse_x = 0
    mouse_y = 0

    mouse_prev = 0
    is_clicking = 0
end


function update_mouse()

    mouse_x = stat(32)
    mouse_y = stat(33)

    mouse_prev = is_clicking

    is_clicking = stat(34)
end


function mouse_pressed()

    return is_clicking != 0
       and mouse_prev == 0
end


function mouse_released()

    return is_clicking == 0
       and mouse_prev != 0
end


function draw_mouse()

    spr(
        12,
        mouse_x,
        mouse_y
    )
end


--=====================================================--
-- DINNER
--=====================================================--

function dinner_init()

    dinner_make_guests()
    dinner_make_seats()
    dinner_make_rules()
end


function dinner_update()

    dinner_update_guests()
    dinner_check_rules()

    if dinner_win then
        win_game()
    end
end


function dinner_draw()

    dinner_draw_guest_ui()
    dinner_draw_ui()
    dinner_draw_guests()
    dinner_draw_seats()
end


--=====================================================--
-- DINNER INIT
--=====================================================--

function dinner_make_guests()

    dinner_dragging_guest = nil

    dinner_guests = {
        {
            name = "a",
            seat = 0,
            sprite = 1,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            name = "e",
            seat = 0,
            sprite = 2,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            name = "i",
            seat = 0,
            sprite = 3,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            name = "o",
            seat = 0,
            sprite = 4,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            name = "u",
            seat = 0,
            sprite = 5,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            name = "y",
            seat = 0,
            sprite = 6,
            x = 0,
            y = 0,
            dragging = false
        }
    }
end


function dinner_make_seats()

    dinner_seats = {
        {x = 38, y = 60},
        {x = 56, y = 80},
        {x = 72, y = 80},
        {x = 90, y = 60},
        {x = 72, y = 40},
        {x = 56, y = 40}
    }
end


function dinner_make_rules()

    dinner_win = false

    local guest_names = {
        "a",
        "e",
        "i",
        "o",
        "u",
        "y"
    }

    -- Pick guest C.
    local random_c =
        flr(rnd(#guest_names)) + 1

    dinner_guest_c =
        guest_names[random_c]

    -- Pick guest A.
    local random_a =
        flr(rnd(#guest_names)) + 1

    dinner_guest_a =
        guest_names[random_a]

    -- Remove A so B can't be the same guest.
    del(
        guest_names,
        dinner_guest_a
    )

    -- Pick guest B.
    local random_b =
        flr(rnd(#guest_names)) + 1

    dinner_guest_b =
        guest_names[random_b]
end


--=====================================================--
-- DINNER UPDATE
--=====================================================--

function dinner_update_guests()

    -- Start dragging.
    if mouse_pressed()
    and dinner_dragging_guest == nil then

        local g =
            dinner_guest_at_mouse()

        if g != nil then

            dinner_dragging_guest = g

            g.dragging = true

            g.x = mouse_x - 4
            g.y = mouse_y - 4
        end
    end


    -- Continue dragging.
    if dinner_dragging_guest != nil then

        dinner_dragging_guest.x =
            mouse_x - 4

        dinner_dragging_guest.y =
            mouse_y - 4


        -- Drop guest.
        if mouse_released() then

            local seat =
                dinner_closest_seat(
                    dinner_dragging_guest.x,
                    dinner_dragging_guest.y
                )

            if seat != 0 then

                dinner_move_guest(
                    dinner_dragging_guest,
                    seat
                )

                sfx(0)
            end

            dinner_dragging_guest.dragging =
                false

            dinner_dragging_guest =
                nil
        end
    end
end


function dinner_check_rules()

    local a =
        dinner_get_guest(
            dinner_guest_a
        )

    local b =
        dinner_get_guest(
            dinner_guest_b
        )

    local c =
        dinner_get_guest(
            dinner_guest_c
        )


    dinner_adjacent = false
    dinner_host = false

    local all_filled = true


    -- Check whether everyone has a seat.
    for g in all(dinner_guests) do

        if g.seat == 0 then

            all_filled = false

            break
        end
    end


    -- Check A next to B.
    if a != nil
    and b != nil
    and a.seat > 0
    and b.seat > 0 then

        dinner_adjacent =
            dinner_is_adjacent(
                a.seat,
                b.seat
            )
    end


    -- Check whether C is at a head seat.
    if c != nil
    and c.seat > 0 then

        dinner_host =
            dinner_is_head(
                c.seat
            )
    end


    local was_win =
        dinner_win


    dinner_win =
        dinner_adjacent
        and dinner_host
        and all_filled


    -- Play success sound only once.
    if dinner_win
    and not was_win then

        sfx(1)
    end
end


--=====================================================--
-- DINNER DRAW
--=====================================================--

function dinner_draw_guests()

    for g in all(dinner_guests) do

        if g.dragging then

            -- Guest being dragged.
            spr(
                g.sprite,
                g.x,
                g.y
            )

            print(
                g.name,
                g.x + 3,
                g.y - 8,
                5
            )


        elseif g.seat > 0 then

            -- Guest sitting in a seat.
            local s =
                dinner_seats[g.seat]

            spr(
                g.sprite,
                s.x,
                s.y
            )

            print(
                g.name,
                s.x + 3,
                s.y - 8,
                5
            )
        end
    end
end


function dinner_draw_seats()

    for s in all(dinner_seats) do

        spr(
            11,
            s.x,
            s.y,
            1,
            1
        )
    end
end


function dinner_draw_guest_ui()

    local x = 14
    local y = 20

    for i,g in ipairs(dinner_guests) do

        x += 14

        if g.seat == 0
        and not g.dragging then

            spr(
                g.sprite,
                x,
                y
            )

            print(
                g.name,
                x + 3,
                y - 8,
                5
            )
        end
    end
end


function dinner_draw_ui()

    if not dinner_win then

        spr(
            24,
            52,
            50,
            4,
            3
        )
    end


    -- print(
    --     "assign the seats!",
    --     20,
    --     4,
    --     7
    -- )


    print(
        "rules:",
        10,
        94,
        7
    )


    print(
        dinner_guest_a ..
        " must sit next to " ..
        dinner_guest_b,
        10,
        104,
        7
    )


    print(
        dinner_guest_c ..
        " is the host",
        10,
        114,
        7
    )


    -- A/B adjacency indicator.
    if dinner_adjacent then

        spr(
            13,
            100,
            104
        )

    else

        spr(
            14,
            100,
            104
        )
    end


    -- Host indicator.
    if dinner_host then

        spr(
            13,
            100,
            114
        )

    else

        spr(
            14,
            100,
            114
        )
    end


    -- Success graphic
    if dinner_win then

        spr(
            17,
            52,
            50,
            4,
            3
        )
    end
end


--=====================================================--
-- DINNER HELPERS
--=====================================================--

function dinner_get_guest(name)

    for g in all(dinner_guests) do

        if g.name == name then
            return g
        end
    end

    return nil
end


function dinner_get_guest_at_seat(seat)

    for g in all(dinner_guests) do

        if g.seat == seat then
            return g
        end
    end

    return nil
end


function dinner_is_adjacent(
    seat_a,
    seat_b
)

    local distance =
        abs(seat_a - seat_b)

    if distance == 1
    or distance == 5 then

        return true
    end

    return false
end


function dinner_is_head(seat)

    if seat == 1
    or seat == 4 then

        return true
    end

    return false
end


function dinner_guest_at_mouse()

    local x = 14
    local y = 20


    -- Guests in the top UI.
    for i,g in ipairs(dinner_guests) do

        x += 14

        if mouse_x >= x
        and mouse_x < x + 8
        and mouse_y >= y
        and mouse_y < y + 8 then

            return g
        end
    end


    -- Guests already sitting.
    for g in all(dinner_guests) do

        if g.seat > 0 then

            local s =
                dinner_seats[g.seat]


            if mouse_x >= s.x
            and mouse_x < s.x + 8
            and mouse_y >= s.y
            and mouse_y < s.y + 8 then

                return g
            end
        end
    end


    return nil
end


function dinner_closest_seat(x,y)

    local best_seat = 0
    local best_dist = 999


    for i,s in ipairs(dinner_seats) do

        local dx =
            x - s.x

        local dy =
            y - s.y

        local dist =
            dx * dx +
            dy * dy


        if dist < best_dist then

            best_dist = dist
            best_seat = i
        end
    end


    if best_dist < 100 then
        return best_seat
    end


    return 0
end


function dinner_move_guest(
    g,
    new_seat
)

    local occupant =
        dinner_get_guest_at_seat(
            new_seat
        )


    if occupant == nil
    or occupant == g then

        g.seat = new_seat
    end
end


--=====================================================--
-- LETTER
--=====================================================--

function letter_init()
    letter_make_greeting()

    letter_mouse_x = 0
    letter_mouse_y = 0

    letter_prev_mouse_x = 0
    letter_prev_mouse_y = 0

    letter_strokes = {}

    letter_stroke_count = 0

    letter_accurate_strokes = 0

    letter_covered_targets = 0

    letter_drawing = false

    letter_won = false
end


function letter_update()

    letter_update_cursor_pen()

    if mouse_pressed() then

        letter_drawing = true

        letter_prev_mouse_x = mouse_x
        letter_prev_mouse_y = mouse_y
    end


    if mouse_released() then

        letter_drawing = false
    end


    if letter_drawing
    and not letter_won then

        add(
            letter_strokes,
            {
                mouse_x,
                mouse_y
            }
        )

        letter_stroke_count += 1

        if letter_point_on_target(
            mouse_x,
            mouse_y
        ) then

            letter_accurate_strokes += 1
        end

        letter_cover_segment(
            letter_prev_mouse_x,
            letter_prev_mouse_y,
            mouse_x,
            mouse_y
        )

        if letter_check_win() then

            letter_won = true

            win_game()

            return
        end

        letter_prev_mouse_x = mouse_x
        letter_prev_mouse_y = mouse_y
    end
end



function letter_draw()

    letter_draw_greeting()

    letter_draw_pen()

    letter_draw_ui()
end


--=====================================================--
-- LETTER INIT
--=====================================================--
function letter_make_greeting()

    letter_greetings = {

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


    letter_rnd_greeting_num =
        flr(rnd(#letter_greetings)) + 1


    letter_g =
        letter_get_greeting(
            letter_greetings[
                letter_rnd_greeting_num
            ].name
        )


    letter_make_target()
end


function letter_get_greeting(name)

    for greeting in all(letter_greetings) do

        if greeting.name == name then
            return greeting
        end
    end

    return nil
end


--=====================================================--
-- LETTER TARGET
--=====================================================--

letter_grid_size = 8
letter_tolerance = 4


function letter_grid_key(x,y)

    local gx =
        flr(x / letter_grid_size)

    local gy =
        flr(y / letter_grid_size)

    return gx .. "," .. gy
end


function letter_make_target()

    letter_target_points = {}

    letter_target_grid = {}

    letter_covered_targets = 0

    letter_accurate_strokes = 0


    local scale = 2.4

    local ox = 15
    local oy = 25


    for y = 0,letter_g.sh - 1 do

        for x = 0,letter_g.sw - 1 do

            -- Color 8 is the greeting.
            if sget(
                letter_g.sx + x,
                letter_g.sy + y
            ) == 8 then


                local px =
                    ox +
                    x * scale +
                    scale / 2


                local py =
                    oy +
                    y * scale +
                    scale / 2


                local target = {
                    px,
                    py,
                    false
                }


                add(
                    letter_target_points,
                    target
                )


                local key =
                    letter_grid_key(
                        px,
                        py
                    )


                if letter_target_grid[key]
                == nil then

                    letter_target_grid[key] = {}
                end


                add(
                    letter_target_grid[key],
                    target
                )
            end
        end
    end
end


function letter_get_nearby_targets(x,y)

    local result = {}


    local gx =
        flr(x / letter_grid_size)

    local gy =
        flr(y / letter_grid_size)


    -- Check surrounding cells.
    for ox = -1,1 do

        for oy = -1,1 do

            local key =
                (gx + ox) ..
                "," ..
                (gy + oy)


            local cell =
                letter_target_grid[key]


            if cell then

                for t in all(cell) do
                    add(result,t)
                end
            end
        end
    end


    return result
end


function letter_point_on_target(x,y)

    local tolerance2 =
        letter_tolerance *
        letter_tolerance


    local nearby =
        letter_get_nearby_targets(
            x,
            y
        )


    for t in all(nearby) do

        local dx =
            x - t[1]

        local dy =
            y - t[2]


        if dx * dx +
           dy * dy <= tolerance2 then

            return true
        end
    end


    return false
end


function letter_calculate_accuracy()

    if letter_stroke_count == 0 then
        return 0
    end


    return
        letter_accurate_strokes /
        letter_stroke_count
end


function letter_point_to_segment_dist2(
    px,py,
    x1,y1,
    x2,y2
)

    local dx =
        x2 - x1

    local dy =
        y2 - y1


    -- Zero-length segment.
    if dx == 0
    and dy == 0 then

        local ox =
            px - x1

        local oy =
            py - y1


        return
            ox * ox +
            oy * oy
    end


    -- Project point onto line.
    local t =
        (
            (px - x1) * dx +
            (py - y1) * dy
        )
        /
        (dx * dx + dy * dy)


    -- Clamp to segment.
    t =
        max(
            0,
            min(1,t)
        )


    local closest_x =
        x1 + t * dx

    local closest_y =
        y1 + t * dy


    local ox =
        px - closest_x

    local oy =
        py - closest_y


    return
        ox * ox +
        oy * oy
end


function letter_cover_segment(
    x1,y1,
    x2,y2
)

    local tolerance2 =
        letter_tolerance *
        letter_tolerance


    -- Bounding box around segment.
    local min_x =
        min(x1,x2) -
        letter_tolerance

    local max_x =
        max(x1,x2) +
        letter_tolerance

    local min_y =
        min(y1,y2) -
        letter_tolerance

    local max_y =
        max(y1,y2) +
        letter_tolerance


    -- Convert bounding box to grid cells.
    local min_gx =
        flr(
            min_x /
            letter_grid_size
        )

    local max_gx =
        flr(
            max_x /
            letter_grid_size
        )

    local min_gy =
        flr(
            min_y /
            letter_grid_size
        )

    local max_gy =
        flr(
            max_y /
            letter_grid_size
        )


    -- Inspect only target points
    -- in touched cells.
    for gx = min_gx,max_gx do

        for gy = min_gy,max_gy do

            local key =
                gx ..
                "," ..
                gy


            local cell =
                letter_target_grid[key]


            if cell then

                for t in all(cell) do

                    if not t[3] then

                        local dist2 =
                            letter_point_to_segment_dist2(
                                t[1],
                                t[2],
                                x1,
                                y1,
                                x2,
                                y2
                            )


                        if dist2 <= tolerance2 then

                            t[3] = true

                            letter_covered_targets += 1
                        end
                    end
                end
            end
        end
    end
end


function letter_calculate_coverage()

    if #letter_target_points == 0 then
        return 0
    end


    return
        letter_covered_targets /
        #letter_target_points
end


--=====================================================--
-- LETTER WIN
--=====================================================--

function letter_check_win()

    local accuracy =
        letter_calculate_accuracy()

    local coverage =
        letter_calculate_coverage()


    return
        accuracy >= 0.60
        and
        coverage >= 0.75
end


--=====================================================--
-- LETTER UPDATE
--=====================================================--

function letter_update_cursor_pen()

    letter_mouse_x =
        mouse_x

    letter_mouse_y =
        mouse_y
end


--=====================================================--
-- LETTER DRAW
--=====================================================--

function letter_draw_greeting()

    sspr(
        letter_g.sx,
        letter_g.sy,

        letter_g.sw,
        letter_g.sh,

        15,
        25,

        letter_g.sw * 2.4,
        letter_g.sh * 2.4
    )
end


function letter_draw_pen()

    for s in all(letter_strokes) do

        circfill(
            s[1] + 3,
            s[2] + 3,
            1,
            14
        )
    end
end



function letter_draw_ui()

    -- print(
    --     "sign the card!",
    --     20,
    --     4,
    --     7
    -- )

    local accuracy =
        letter_calculate_accuracy()

    local coverage =
        letter_calculate_coverage()


    -- print(
    --     "accuracy: "..accuracy,
    --     10,
    --     100,
    --     5
    -- )


    -- print(
    --     "coverage: "..coverage,
    --     10,
    --     110,
    --     5
    -- )
end


--=====================================================--
-- CAKE
--=====================================================--

function cake_init()

    cake_make_guests()
    cake_make_mouse()
    cake_make_rules()
end


function cake_update()

    cake_update_family_positions()

    cake_ask_family()

    cake_check_center()

        if cake_win() then
        win_game()
    end
end


function cake_draw()

    cake_draw_family()

    cake_draw_ui()
end


--=====================================================--
-- CAKE INIT
--=====================================================--

function cake_make_guests()

    cake_guests = {

        {
            name = "a",
            sprite = 1,

            x = 0,
            y = 0,

            cake = false,
            info = false, 
            truth = true,
        },

        {
            name = "e",
            sprite = 2,

            x = 0,
            y = 0,
            
            cake = false,
            info = false, 
            truth = true,
        },

        {
            name = "i",
            sprite = 3,

            x = 0,
            y = 0,

            cake = false,
            info = false, 
            truth = true,
        },

        {
            name = "o",
            sprite = 4,

            x = 0,
            y = 0,

            cake = false,
            info = false, 
            truth = true,
        },

        {
            name = "u",
            sprite = 5,

            x = 0,
            y = 0,

            cake = false,
            info = false, 
            truth = true,
        },

        {
            name = "y",
            sprite = 6,

            x = 0,
            y = 0,

            cake = false,
            info = false, 
            truth = true,
        }
    }


    cake_selected_guest = nil
end


function cake_make_rules()

    cake_chef =
        flr(rnd(#cake_guests)) + 1
    repeat 
        not_cake_chef = 
            flr(rnd(#cake_guests)) + 1
    until not_cake_chef != cake_chef


    cake_info1 =
        flr(rnd(#cake_guests)) + 1
    repeat
        cake_info2 =
            flr(rnd(#cake_guests)) + 1
    until cake_info2 != cake_info1
    repeat 
        cake_info3 = 
            flr(rnd(#cake_guests))+1
    until cake_info3 != cake_info1 and cake_info3 != cake_info2


    cake_guests[cake_chef].cake =
        true

    cake_guests[cake_info1].info =
        true

    cake_guests[cake_info2].info =
        true

    cake_guests[cake_info3].info =
        true

    cake_guests[cake_info3].truth =
        false

    

end


function cake_make_mouse()

    cake_sprite = 7

    cake_hat_sprite = 8

    cake_selected_sprite =
        cake_sprite

    cake_center_sprite =
        cake_hat_sprite
end


--=====================================================--
-- CAKE UPDATE
--=====================================================--

function cake_update_family_positions()

    local cx = 64
    local cy = 64

    local radius = 36

    local count =
        #cake_guests


    for i,g in ipairs(cake_guests) do

        local angle =
            (i - 1) / count -
            0.25


        g.x =
            cx -
            cos(angle) *
            radius

        g.y =
            cy -
            sin(angle) *
            radius
    end
end


function cake_check_center()

    if mouse_pressed()
    and mouse_x >= 56
    and mouse_x < 72
    and mouse_y >= 56
    and mouse_y < 72 then


        local temp =
            cake_selected_sprite


        cake_selected_sprite =
            cake_center_sprite


        cake_center_sprite =
            temp
    end
end


function cake_ask_family()

    local guest =
        cake_family_at_mouse()


    if mouse_pressed()
    and guest != nil then

        cake_selected_guest =
            guest
    end
end

function cake_win()
    if mouse_pressed()
    and cake_selected_guest == cake_guests[cake_chef]
    and cake_selected_sprite == cake_hat_sprite then

        return true
    end

    return false
end



--=====================================================--
-- CAKE DRAW
--=====================================================--

function cake_draw_family()

    for i,g in ipairs(cake_guests) do

        spr(
            g.sprite,
            g.x,
            g.y
        )

        print(
            g.name,
            g.x + 3,
            g.y - 8,
            5
        )
    end
end


function cake_draw_ui()

    -- print(
    --     "decide the baker!",
    --     20,
    --     4,
    --     7
    -- )


    -- Center object.
    spr(
        cake_center_sprite,
        64,
        64
    )


    -- Draw selected cake result.
    if cake_selected_guest != nil
    and cake_selected_sprite == cake_sprite then


        if cake_selected_guest.info and cake_selected_guest.truth then
            spr(
                cake_guests[cake_chef].sprite,
                cake_selected_guest.x + 6,
                cake_selected_guest.y - 6
            )

        elseif not cake_selected_guest.info then
            spr(
                23,
                cake_selected_guest.x + 6,
                cake_selected_guest.y - 6
            )

        elseif not cake_selected_guest.truth then
            spr(
                cake_guests[not_cake_chef].sprite,
                cake_selected_guest.x + 6,
                cake_selected_guest.y - 6
            )
        end
        
    end
    


    -- Draw the player's mouse object.
    spr(
        cake_selected_sprite,
        mouse_x - 4,
        mouse_y - 4
    )
end


--=====================================================--
-- CAKE HELPERS
--=====================================================--

function cake_family_at_mouse()

    for g in all(cake_guests) do

        if mouse_x >= g.x
        and mouse_x < g.x + 8
        and mouse_y >= g.y
        and mouse_y < g.y + 8 then

            return g
        end
    end


    return nil
end