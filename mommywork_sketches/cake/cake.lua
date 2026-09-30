function _init()
    make_guests()
    make_mouse()
    make_rules()
end

function _update()
    update_mouse()
    ask_family()
    check_center()
end

function _draw()
    cls()
    draw_family()
    draw_ui()
    draw_mouse()
    draw_debugger()

end

-- INIT -- 
function make_guests()
 guests = {
  {name="a", sprite=1, x=0, y=0, truth = false, cake = false, onus = nil},
  {name="e", sprite=2, x=0, y=0, truth = false, cake = false, onus = nil},
  {name="i", sprite=3, x=0, y=0, truth = false, cake = false, onus = nil},
  {name="o", sprite=4, x=0, y=0, truth = false, cake = false, onus = nil},
  {name="u", sprite=5, x=0, y=0, truth = false, cake = false, onus = nil},
  {name="y", sprite=6, x=0, y=0, truth = false, cake = false, onus = nil},
 }

 selected_guest = nil
end

function make_rules()
    chef = flr(rnd(#guests) + 1)
    truth1 = flr(rnd(#guests) + 1)
    repeat
        truth2 = flr(rnd(#guests) + 1)
    until truth2 != truth1

    guests[chef].cake = true
    guests[truth1].truth = true
    guests[truth2].truth = true
end

function make_mouse()
 cake = 7 
 hat = 8
 selected_mouse = cake
 center_sprite = hat
 poke(0x5f2d,1)
 mouse_prev = 0
end

-- UPDATE -- 
function update_mouse()
 mouse_x = stat(32)
 mouse_y = stat(33)
 mouse_prev = is_clicking or 0
 is_clicking = stat(34)
end

function check_center()
    if mouse_pressed() 
    and mouse_x >= 56 and mouse_x < 72
    and mouse_y >= 56 and mouse_y <72 then
        local temp = selected_mouse
        selected_mouse = center_sprite
        center_sprite = temp
    end
end

-- DRAW --
function draw_mouse() 
    spr(selected_mouse,mouse_x-4,mouse_y-4)
end

function draw_family()
    local cx = 64
    local cy = 64
    local radius = 36
    local count = #guests

    for i,g in ipairs(guests) do
        local angle = (i - 1) / count - 0.25
        local x = cx - cos(angle) * radius
        local y = cy - sin(angle) * radius

        g.x = x
        g.y = y

        spr(g.sprite, x, y)
        print(g.name, x + 3, y - 8, 5)
    end
end

function draw_ui()
    print("who's bringing the cake?", 20,4,7)
    spr(center_sprite,64,64)
    if selected_guest != nil and selected_mouse == cake then
        if selected_guest.truth == false then 
            spr(23, selected_guest.x + 6, selected_guest.y - 6)
        else
            spr(guests[chef].sprite, selected_guest.x + 6, selected_guest.y - 6)
        end
    end
end

function draw_debugger()
end

--OTHER--

function family_at_mouse()
    for g in all(guests) do 
        if mouse_x >= g.x and mouse_x < g.x+8
        and mouse_y >= g.y and mouse_y < g.y+8 then
            return g
        end
    end
end

function ask_family()
    local guest = family_at_mouse()
    if mouse_pressed() and guest != nil then
        selected_guest = guest
    end
end


function mouse_pressed()
 return is_clicking != 0 and mouse_prev == 0
end


function mouse_released()
 return is_clicking == 0 and mouse_prev != 0
end
