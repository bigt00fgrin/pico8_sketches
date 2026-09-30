-- ========== INIT ========== -- 
function seating.init()
    seating.make_guests()
    seating.make_seats()
    seating.make_rules()
end

function seating.make_guests()
    dragging_guest = nil 

    seating.guests = {
        {
            seat = 0,
            sprite = 1,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            seat = 0,
            sprite = 2,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            seat = 0,
            sprite = 3,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            seat = 0,
            sprite = 4,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            seat = 0,
            sprite = 5,
            x = 0,
            y = 0,
            dragging = false
        },

        {
            seat = 0,
            sprite = 6,
            x = 0,
            y = 0,
            dragging = false
        } 
    }
end

function seating.make_seats()
    seats = {
        {x = 38, y = 60},
        {x = 56, y = 80},
        {x = 72, y = 80},
        {x = 90, y = 60},
        {x = 72, y = 40},
        {x = 56, y = 40}
    }
end

function seating.make_rules()
    seating_win = false 

    head = seating.guests[flr(rnd(#seating.guests)) + 1]

    adj1 = seating.guests[flr(rnd(#seating.guests)) + 1]

    repeat
        adj2 = seating.guests[flr(rnd(#seating.guests)) + 1]
    until adj1 != adj2
end

-- ========== UPDATE ========== -- 
function seating.update()
    seating.update_guests()
    seating.check_rules()

    if seating_win then 
        win_game()
    end
end

function seating.update_guests()
    if mouse_pressed() and dragging_guest == nil then 
        local g = guest_at_mouse()
    
        if g != nil then 
            dragging_guest = g
            g.dragging = true
            g.x = mouse_x - 4
            g.y = mouse_y - 4
        end
    end

    if dragging_guest != nil then 
        dragging_guest.x = mouse_x - 4
        dragging_guest.y = mouse_y - 4

        if mouse_released() then
            local seat = closest_seat(
                dragging_guest.x,
                dragging_guest.y
            )

            if seat != 0 then
                if move_guest(dragging_guest, seat) then
                    sfx(0)
                else
                    restore_guest()
                end
            else
                restore_guest()
            end

            dragging_guest.dragging = false
            dragging_guest = nil
        end
    end
end



function seating.check_rules()
    set_adjacent = false 
    set_head = false
    set_all_seats = true

    for g in all(seating.guests) do 
        if g.seat == 0 then 
            set_all_seats = false
        break
        end
    end

    if adj1.seat > 0 and adj2.seat > 0 then 
        set_adjacent = is_adjacent(adj1.seat, adj2.seat)
    end

    if head.seat > 0 then 
        set_head = is_head(head.seat)
    end

    local was_win = seating_win 
    seating_win = set_adjacent and set_head and set_all_seats

    if seating_win and not was_win then sfx(1) end
end
-- ========== DRAW ========== -- 
function seating.draw()
    seating.draw_guests()
    seating.draw_guest_ui()
    seating.draw_ui()
    draw_seats()
end

function seating.draw_guests()
    for g in all(seating.guests) do 
        if g.dragging then 
            spr(g.sprite, g.x, g.y)
        elseif g.seat>0 then 
            spr(g.sprite, g.x, g.y)
        end
    end
end

function seating.draw_guest_ui()
    local x = 14
    local y = 20

    for i,g in ipairs(seating.guests) do 
        x += 14
        
        if g.seat == 0 and not g.dragging then 
            spr(g.sprite, x, y)
        end
    end
end

function seating.draw_ui()
    if not seating_win then 
        spr(24, 52, 50, 4, 3)
    else 
        spr(17, 52, 50 ,4, 3)

    print("rules", 10, 94, 7)
    end

    -- adjacent rule
    spr(adj1.sprite, 10, 102)
    print("must sit next to", 20, 104, 7)
    spr(adj2.sprite, 86, 102)
    if set_adjacent then

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

    -- head rule
    spr(head.sprite, 10, 112)
    print("is the host", 20, 114, 7)
    if set_head then

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

end

function draw_seats()
    for s in all (seats) do 
        spr(11,s.x,s.y,1,1)
    end
end

-- ========== HELPER ========== -- 
function get_guest_at_seat(seat)
    for g in all(seating.guests) do 
        if g.seat == seat then 
            return g
        end
    end
    return nil 
end

function is_adjacent(adj1,adj2)
    local distance = abs(adj1 - adj2)
    if distance == 1 or distance == 5 then 
        return true 
    end 
    return false
end

function is_head(seat)
    if seat == 1 or seat == 4 then 
        return true
    end
    return false
end

function guest_at_mouse()
    local x = 14
    local y = 20

    for i,g in ipairs(seating.guests) do 
        x += 14
        if mouse_x >= x and mouse_x < x+8 and 
        mouse_y >= y and mouse_y < y+8 then 
            return g
        end
    end

    for g in all(seating.guests) do
        if g.seat > 0 then 
            local s = seats[g.seat]
            if mouse_x >= s.x and mouse_x < s.x + 8 
            and mouse_y >= s.y and mouse_y <s.y+8 then 
                return g
            end
        end
    end
    return nil 
end 

function closest_seat(x,y)
    local best_seat = 0 
    local best_dist = 999

    for i,s in ipairs(seats) do
        local dx = x - s.x
        local dy = y - s.y 
        local dist = dx*dx + dy*dy 

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

function move_guest(g, new_seat)
    local occupant = get_guest_at_seat(new_seat)
    if occupant == nil or occupant == g then 
        g.seat = new_seat

        local s = seats[new_seat]
        g.x = s.x
        g.y = s.y  
        
        return true
    end
    return false
end