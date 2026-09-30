cake = {}
seating = {}
card = {}
-- ========== INIT ========== -- 
function _init()
    games = {
        { 
            init = cake.init,
            update = cake.update,
            draw = cake.draw,
            instruction = "decide baker!"
       },

       { 
            init = seating.init,
            update = seating.update,
            draw = seating.draw,
            instruction = "assign seating!"
       },

        {
            init = card.init,
            update = card.update,
            draw = card.draw,
            instruction = "sign card"
       }
    }

    score = 0
    game_duration = 480
    state = "transition"
    state_timer = 60
    current_game = nil

    make_mouse()
    choose_game()
end

function choose_game()
    local next_game_index 

    repeat
        next_game_index = flr(rnd(#games)) + 1
    until next_game_index != current_game_index

    current_game_index = next_game_index
    current_game = games[current_game_index]

    current_game.init()
end

function start_game()
    state = "game"
    state_timer = game_duration
    win = false
end

function end_game()
    state = "transition"
    state_timer = 30
    choose_game()
end

function win_game()
    score +=1    
    state = "transition"
    state_timer = 30
    choose_game()
end


-- ========== UPDATE ========== -- 
function _update()
    update_mouse()

    if state == "transition" then 
        state_timer -=1

        if state_timer <=0 then 
            start_game()
        end

    elseif state == "game" then 
        current_game.update()

        if state != "game" then 
            return 
        end 

        state_timer -= 1

        if state_timer <= 0 then 
            end_game()
        end
    end
end 


-- ========== UPDATE ========== -- 
function _draw()
    cls()
    if state == "transition" then 
        draw_transition()
    elseif state == "game" then 
        current_game.draw()
        draw_game_ui()
    end
    draw_mouse()
end


-- ========== DRAW ========== -- 

function draw_transition()
    
    print(
        current_game.instruction,
        64 - (#current_game.instruction * 2),
        60,
        7
    )

    print(
        "score: "..score,
        64 - (#"score: 0" * 2),
        70,
        7
    )

end

function draw_game_ui()
    local w = state_timer * (128 / game_duration)

    rectfill (
        0,124,
        w,127,
        8
    )
end

-- ========== INPUT ========== -- 

function make_mouse()
    poke(0x5f2d,1)

    mouse_x = 0
    mouse_y = 0 

    prev_mouse_x = 0 
    prev_mouse_y = 0

    mouse_state_prev = 0
    mouse_is_clicking = 0
end

function update_mouse()
    mouse_x = stat(32)
    mouse_y = stat(33)

    mouse_state_prev = is_clicking

    is_clicking = stat(34)
end


function mouse_pressed()

    return is_clicking != 0
       and mouse_state_prev == 0
end


function mouse_released()

    return is_clicking == 0
       and mouse_state_prev != 0
end


function draw_mouse()

    spr(
        12,
        mouse_x,
        mouse_y
    )
end



