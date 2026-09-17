pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
	gave_over = false
	make_cave()
	make_player()
end

function _update()
	update_cave()
	move_player()
end

function _draw()
	cls()
	draw_cave()
	draw_player()
end

-->8
function make_player()
	player={}
 player.x = 24 --position
 player.y = 60
 player.dy = 0 -- fall speed
 player.rise= 1 --assign sprites
 player.fall= 2
 player.dead= 3
 player.speed= 0.5 -- fly speed
 player.score = 0
end

function draw_player()
	if (game_over) then
	 spr(player.dead,player.x,player.y)
	elseif (player.dy<0) then
	 spr(player.rise, player.x,player.y)
	else
	 spr(player.fall,player.x,player.y)
	end
end 

function move_player()
	gravity=0.8
	player.dy+=gravity
	
	if (btn(2))then
	player.dy-=2
	end
	
	player.y+=player.dy
end
-->8
function make_cave()
	cave={{["top"]=5,["btm"]=119}}
	top = 45 --low point for ceiling
	btm = 85 --high point for floor
end

function update_cave()
 --del cave
 if (#cave>player.speed) then
 	for i=1, player.speed do
 		del(cave,cave[1])
 	end
	end
 
 --add cave	
	while (#cave<120) do
 	local col={}
 	local up=flr(rnd(7)-3) --rand int (-3,3)
 	local dwn=flr(rnd(7)-3) --rand int (-3,3)
 	col.top=mid(3,cave[#cave].top+up,top)
 	col.btm=mid(btm,cave(#cave).btm+dwn,124)
 	add(cave,col)
	end
end

function draw_cave()
	top_color=5
	btm_color=5
	for i=1,#cave do
	 line(i-1,0,i-1,cave[i].top,top_color)
	 line(i-1,127,i-1,cave[i].btm,btm_color)
 end
end
__gfx__
00000000000ee000000ee00000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000eeee0000eeee0000222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000eeeeee00eeeeee002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000e0ee0e00e0ee0e002822820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000eeeeee00e8888e002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ebeebe00e8888e002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eebbee00e8888e002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000eeeeee00eeeeee002222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
