-- ========== INIT ========== --

function cake.init()
    cake.make_guests()
    cake.make_rules()

    cake_sprite = 7
    hat_sprite = 8
    selected_sprite = cake_sprite
    center_sprite = hat_sprite
end


function cake.make_guests()
    cake.guests = {
        {
            sprite = 1,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        },

        {
            sprite = 2,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        },

        {
            sprite = 3,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        },

        {
            sprite = 4,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        },

        {
            sprite = 5,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        },

        {
            sprite = 6,

            x = 0,
            y = 0,

            cake = false,
            info = false,
            truth = true,
        }
    }

    selected_guest = nil
end


function cake.make_rules()
    chef = flr(rnd(#cake.guests)) + 1

    repeat
        not_chef = flr(rnd(#cake.guests)) + 1
    until not_chef != chef

    info1 = flr(rnd(#cake.guests)) + 1

    repeat
        info2 = flr(rnd(#cake.guests)) + 1
    until info2 != info1

    repeat
        info3 = flr(rnd(#cake.guests)) + 1
    until info3 != info1 and info3 != info2

    cake.guests[chef].cake = true

    cake.guests[info1].info = true
    cake.guests[info2].info = true
    cake.guests[info3].info = true

    cake.guests[info3].truth = false
end


-- ========== UPDATE ========== --

function cake.update()
    update_family_pos()

    -- Find the guest currently under the mouse.
    local clicked_guest = family_at_mouse()

    ask_family()
    check_center()

    -- Only win if the player actually clicked the chef.
    if cake.win(clicked_guest) then
        win_game()
    end
end


function update_family_pos()
    local cx = 64
    local cy = 64

    local radius = 36

    local count = #cake.guests

    for i,g in ipairs(cake.guests) do

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


function check_center()
    if mouse_pressed()
    and mouse_x >= 56 and mouse_x < 72
    and mouse_y >= 56 and mouse_y < 72 then

        local temp = selected_sprite

        selected_sprite = center_sprite
        center_sprite = temp
    end
end


function ask_family()
    local guest = family_at_mouse()

    if mouse_pressed() and guest != nil then
        selected_guest = guest
    end
end


function cake.win(clicked_guest)
    return mouse_pressed()
        and clicked_guest == cake.guests[chef]
        and selected_sprite == hat_sprite
end


-- ========== DRAW ========== --

function cake.draw()
    draw_family()
    cake.draw_ui()
end


function draw_family()
    for i,g in ipairs(cake.guests) do

        spr(
            g.sprite,
            g.x,
            g.y
        )

    end
end


function cake.draw_ui()
    spr(
        center_sprite,
        64,
        64
    )

    if selected_guest != nil
    and selected_sprite == cake_sprite then

        if selected_guest.info and selected_guest.truth then

            spr(
                cake.guests[chef].sprite,
                selected_guest.x + 6,
                selected_guest.y - 6
            )

        elseif not selected_guest.info then

            spr(
                23,
                selected_guest.x + 6,
                selected_guest.y - 6
            )

        elseif not selected_guest.truth then

            spr(
                cake.guests[not_chef].sprite,
                selected_guest.x + 6,
                selected_guest.y - 6
            )
        end
    end

    spr(
        selected_sprite,
        mouse_x - 4,
        mouse_y - 4
    )
end



-- ========== HELPER ========== --

function family_at_mouse()
    for g in all(cake.guests) do

        if mouse_x >= g.x
        and mouse_x < g.x + 8
        and mouse_y >= g.y
        and mouse_y < g.y + 8 then

            return g
        end
    end

    return nil
end
