pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 game_over=false
 win=false
 g=0.025 --gravity
 make_player()
 make_ground()
end

function _update()
 if (not game_over)then
  move_player()
  check_land()
 else
  if (btnp(5)) _init()	
 end
end

function _draw()
 cls()
 draw_stars()
 draw_ground()
 draw_player()
 draw_ui()
 
 if (game_over) then
 	if (win) then
 		print("★success",48,48,11)
 	else
 	 print("failure",48,48,8)
 	 end
 	print("press ❎ to restart",24,70,5)
 	end
end



-->8
function make_player()
 p={}
 p.x=60
 p.y=8
 p.dx=0
 p.dy=0
 p.sprite=1
 p.alive=true
 p.thrust=0.075
end

function draw_player()
 spr(p.sprite,p.x,p.y)
 if (game_over and win) then
  spr(4,p.x,p.y-8)
 elseif (game_over) then
  spr(5,p.x,p.y)
 end
end

function move_player()
 p.dy+=g
 thrust()
 p.x+=p.dx
 p.y+=p.dy
 stay_on_screen()
end



-->8
function thrust()
 if (btn(0)) p.dx-=p.thrust
 if (btn(1)) p.dx+=p.thrust
 if (btn(2)) p.dy-=p.thrust
 
 if (btn(0) or btn (1) or btn(2)) sfx(0)
end

function stay_on_screen()
 if (p.x<0) then
  p.x=0
  p.dx=0
 end
 if (p.x>119) then
  p.x=119
  p.dx=0
 end
 if (p.y<0) then
 p.y=0
 p.dy=0
 end
end

function check_land()
 l_x=flr(p.x)
 r_x=flr(p.x+7)
 b_y=flr(p.y+7)
 
 over_pad=l_x>=pad.x and r_x<=pad.x+pad.width
 on_pad=b_y>=pad.y-2
 slow=p.dy<1.5
 
 if (over_pad and on_pad and slow) then
  end_game(true)
 elseif (over_pad and on_pad) then
  end_game(false)
 else
  for i=l_x,r_x do
   if (gnd[i]<=b_y) end_game(false)
  end
 end
end

function end_game(won)
 game_over=true
 win=won
 
 if(win) then
  sfx(1)
 else
  sfx(2)
 end
end
-->8
function rndb(low,high)
 return flr(rnd(high-low+1)+low)
end

function draw_stars()
 srand(1)
 for i=1,50 do
  pset(rndb(0,127),rndb(0,127),rndb(5,7))
  end
  srand(time())
 end
 
function make_ground()
 gnd={}
 local top=96
 local btm=120
 
 pad={}
 pad.width=15
 pad.x=rndb(0,126-pad.width)
 pad.y=rndb(top,btm)
 pad.sprite=2
 
 --create pad
 for i=pad.x,pad.x+pad.width do
  gnd[i]=pad.y
 end
 
 --create right of pad
 for i=pad.x+pad.width+1,127 do
  local h=rndb(gnd[i-1]-3,gnd[i-1]+3)
  gnd[i]=mid(top,h,btm)
 end
 
 --create left of pad
 for i=pad.x-1,0,-1 do
  local h=rndb(gnd[i+1]-3,gnd[i+1]+3)
  gnd[i]=mid(top,h,btm)
 end
end

function draw_ground()
 for i=0,127 do
  line(i,gnd[i],i,127,5)
 end
 spr(pad.sprite,pad.x,pad.y-1,2,1)
end
-->8
function draw_ui()

 if (slow) then
  speed_color=11
 else
  speed_color=8
 end
 
 print("speed < 1.5 for safe landing",10,0,5)
 print(p.dy,10,6,speed_color)
end


__gfx__
000000000002000008a7a7a7a7a7a780000bb0008880000800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000011000860006066060006800bbb0000099a09900000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000051150060000600006000060bbbb0000009aa9800000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000051111500000000000000000bbbbb0000aaccaa000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700051148a1500000000000000000000600089aaca0000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000011110000000000000000000000600000aaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000011111100000000000000000000060000a90aa9900000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000909909000000000000000000000600088900a8900000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000025050240501e0501d05018050170502305023050000002105027050270500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000300602a060250501f0501d040190401504013040100300d0300a030080300702005020030200202001020010100101000010000000000000000000000000000000000000000000000000000000000000
