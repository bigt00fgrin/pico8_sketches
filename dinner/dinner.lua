 function _init()
 init_mouse()
 make_guests()
 make_seats()
 make_rules()
end


function _update()
 update_mouse()
 update_guests()
 check_rules()
 if (btnp(5)) then 
  _init()
 end
end


function _draw()
 cls()
 draw_guest_ui()
 draw_ui()
 draw_guests()
 draw_mouse()
 draw_seats()
end

-- INIT FUNCTIONS --

function init_mouse()
 poke(0x5f2d,1)
 mouse_prev = 0
end

function make_guests()
 dragging_guest = nil
 guests = {
  {name="a", seat=0, sprite=1, x=0, y=0, dragging=false},
  {name="e", seat=0, sprite=2, x=0, y=0, dragging=false},
  {name="i", seat=0, sprite=3, x=0, y=0, dragging=false},
  {name="o", seat=0, sprite=4, x=0, y=0, dragging=false},
  {name="u", seat=0, sprite=5, x=0, y=0, dragging=false},
  {name="y", seat=0, sprite=6, x=0, y=0, dragging=false},
 }
end

function make_seats()
 seats = {
  {x=38,y=60},
  {x=56,y=80},
  {x=72,y=80},
  {x=90,y=60},
  {x=72,y=40},
  {x=56,y=40},
 }
end

function make_rules()
    win = false
    max_int = 6
    guest_names = {"a","e","i","o","u","y"}

    local random_c = flr(rnd(#guest_names)) + 1
    guest_c = guest_names[random_c]

    local random_a = flr(rnd(#guest_names)) + 1
    guest_a = guest_names[random_a]

    del(guest_names, guest_a)

    local random_b = flr(rnd(#guest_names)) + 1
    guest_b = guest_names[random_b]
end
--- UPDATE FUNCTIONS ---
function update_mouse()
 mouse_x = stat(32)
 mouse_y = stat(33)
 mouse_prev = is_clicking or 0
 is_clicking = stat(34)
end

function update_guests()
 if mouse_pressed() and dragging_guest == nil then
  local g=guest_at_mouse()

  if g != nil then
   dragging_guest=g
   g.dragging=true
   g.x=mouse_x-4
   g.y=mouse_y-4

  end
 end

 if dragging_guest != nil then

  dragging_guest.x=mouse_x-4
  dragging_guest.y=mouse_y-4

  if mouse_released() then

   local seat=closest_seat(
    dragging_guest.x,
    dragging_guest.y
   )

   if seat != 0 then
    move_guest(dragging_guest,seat)
    sfx(0)
   end

   dragging_guest.dragging=false
   dragging_guest=nil

  end
 end
end

function check_rules()
 local a = get_guest(guest_a)
 local b = get_guest(guest_b)
 local c = get_guest(guest_c)

 adjacent = false
 host = false
 all_filled = true

 for g in all(guests) do
  if g.seat == 0 then
   all_filled = false
   break
  end
 end

 if a.seat > 0 and b.seat > 0 then
  adjacent = is_adjacent(a.seat,b.seat)
 end

 if c.seat > 0 then
  host = is_head(c.seat)
 end

 -- remember whether we were already winning
 local was_win = win

 -- calculate new win state
 win = adjacent and host and all_filled

 -- play song only when we FIRST win
 if win and not was_win then
  sfx(1)
 end
end

-- DRAW FUNCTIONS --
function draw_mouse()
 spr(12,mouse_x,mouse_y)
end

function draw_guests()
 for g in all(guests) do

  if g.dragging then

   -- draw guest under mouse
   spr(g.sprite,g.x,g.y,1,2)
   print(g.name,g.x+3,g.y-8,5)

  elseif g.seat > 0 then

   -- draw guest in chair
   local s = seats[g.seat]
   spr(g.sprite,s.x,s.y,1,2)
   print(g.name,s.x+3,s.y-8,5)

  end
 end
end

function draw_seats()
 for s in all(seats) do
  spr(11,s.x,s.y,1,1)
 end
end

function draw_guest_ui()

 local x=14
 local y=20

 for i,g in ipairs(guests) do
  x += 14

  if g.seat == 0 and not g.dragging then
   spr(g.sprite,x,y,1,2)
   print(g.name,x+3,y-8,5)
  end

 end
end

function draw_ui()
  if win == false then 
   spr(7,52,50,4,4) -- table
  end
  print("dinner",56, 0 ,7)
  print("rules:",10,100,7)
  print(guest_a .. " must sit next to " .. guest_b,10,110,7)
  print(guest_c .. " is the host",10,120,7)
  
  if adjacent then 
    spr(13,100,110)
  else
    spr(14,100,110)
  end

  if host then 
   spr(13,100,120)
  else
   spr(14,100,120)
  end

  if win then
   spr(65,52,50,4,4)
   print("press X to play again",30,10,7)
  end

  
end
--- OTHER FUNCTIONS ---
function get_guest(name)
 for g in all(guests) do
  if g.name == name then
   return g
  end
 end

 return nil
end

function get_guest_at_seat(seat)
 for g in all(guests) do
  if g.seat == seat then
   return g
  end
 end

 return nil
end


function is_adjacent(seat_a,seat_b)
  local distance = abs(seat_a- seat_b)
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

 local x=14
 local y=20

 for i,g in ipairs(guests) do
  x += 14

  if mouse_x >= x
  and mouse_x < x+8
  and mouse_y >= y
  and mouse_y < y+8 then

   return g
  end
 end

 for g in all(guests) do

  if g.seat > 0 then

   local s=seats[g.seat]

   if mouse_x >= s.x
   and mouse_x < s.x+8
   and mouse_y >= s.y
   and mouse_y < s.y+8 then

    return g
   end
  end
 end


 return nil
end

function closest_seat(x,y)

 local best_seat=0
 local best_dist=999

 for i,s in ipairs(seats) do

  local dx=x-s.x
  local dy=y-s.y
  local dist=dx*dx+dy*dy

  if dist < best_dist then
   best_dist=dist
   best_seat=i
  end

 end

 if best_dist < 100 then
  return best_seat
 end

 return 0
end


function move_guest(g,new_seat)
 local occupant = get_guest_at_seat(new_seat)

 if occupant == nil or occupant == g then
  g.seat=new_seat
 end
end

function mouse_pressed()
 return is_clicking != 0 and mouse_prev == 0
end


function mouse_released()
 return is_clicking == 0 and mouse_prev != 0
end


