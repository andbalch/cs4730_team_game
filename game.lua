mode="title"

-- Mouse variables.
poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0
md=false -- Mouse down.
mdp=false -- Mouse down previous.
mp=false -- Mouse pressed.

-- Error variables.
error_str=nil
error_timer=0

-- Customer region, used for painting sprite and serving potions
cust = {
	x=12,
	y=12,
	w=64,
	h=64
}

potions = {
	-- Roughly ordered by difficulty
	-- 1st order potion: Req. only primary ingredients (water and fairy dust)
	{c=15, n="wyrmwood\noil"},		-- <- water (12) + fairy dust (14)

	-- 2nd order potion: Req. primary ingredients and 1st order potion
	{c=7, n="caustic\ndreams"},		-- <- water (12) + wyrmwood oil (15)
	{c=4, n="fortified\nrunes"},		-- <- fairy dust (14) + wyrmwood oil (15)

	-- 3rd order potion: Req. primary ingredients and 2nd order potion
	{c=5, n="gaseous\nmateria"},		-- <- water (12) + fortified runes (4)
	{c=8, n="dragon's\nBlood"},		-- <- fairy dust (14) + caustic dreams (7)
	{c=2, n="spesi\nCola"},			-- <- water (12) + caustic dreams (7)

	-- 4th order potion: No primary ingredients
	{c=3, n="sweat of\nnewt"},		-- <- wyrmwood oil (15) + gaseous materia (5)
	{c=6, n="dew of\nmiasma"},		-- <- caustic dreams (7) + gaseous materia (5)
	{c=9, n="fenwick\ntree"},		-- <- fortified runes (4) + spesi cola (2)
	{c=1, n="holy\ntears"},			-- <- fortified runes (4) + sweat of newt (3)
	{c=10, n="liquid\nalgorithms"},	-- <- fenwick tree (9) + holy tears (1)
}

names={
	"",
	"dark blue",
	"dark purple",
	"dark green",
	"oil",
	"rock",
	"steam",
	"white",
	"blood",
	"orange",
	"sand",
	"acid",
	"water",
	"glass",
	"pink",
	"tan",
}

pot_lim = 11
time_lim = 60
time_penalty = 0.10

pot_timer = 0;
time_str = ""
time_c = 6
-- Generates a new order randomly
function new_order()
	return flr(rnd(pot_lim)) + 1
end

-- Sets up variables for a game.
function setup_game()
    -- Game variables.
    gold=42
    holding=nil

	-- Vial variables.
	vox=0 -- Vial offset from the mouse.
	voy=0

	-- Create simulations.
	caul1=create_sim(0, 32,32,32)
	caul2=create_sim(32,32,32,32)

	-- Vials and vial slots.
    vials={}
    slots={}
	for i=0,7 do
		v=create_sim(64+i*8,32,8,16)
		vials[i]=v
		slots[i]={v=i,x=88+(i%2)*12,y=24+flr(i/2)*24,w=v.w,h=v.h}
	end

	-- generate order
	order_i = new_order()
	pot_timer = t()
end

setup_game()

function _update60()
    -- Get mouse input.
	mx=stat(32)
	my=stat(33)
	md=stat(34)==1
	mp=mdp and not md

	-- Update error timer.
	error_timer=error_timer-1

	-- Update simulations.
	update_sim(caul1)
	update_sim(caul2)
	for i=0,7 do
		update_sim(vials[i])
	end
		
    -- Screen specific updates.
	if mode=="title" then
		title_update()
    elseif mode=="brew" then
		-- Update simulations.
        brew_update()
    elseif mode=="shop" then
        shop_update()
    end

	-- Update mouse down previous.
	mdp=md
end

function _draw()
    cls()

    -- Screen specific draws.
	if mode=="title" then	
		title_draw()
    elseif mode=="brew" then
        brew_draw()
    elseif mode=="shop" then
        shop_draw()
    end

	-- Draw error.
	if error_timer>=0 then
		rectfill(0,119,128,128,8)
		print(error_str,2,121,15)
	end
	-- Draw mouse.
	ms=1
	if md or holding then ms=2 end
	spr(ms,mx,my)

end

-- Utility Functions --

function error(str)
	error_str=str
	error_timer=30
end

-- Checks if a point is within a box.
function coll(b,x,y)
	return x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h
end

-- Prints a string with an outline.
function oprint(t,x,y,c)
	oc=0
	if c==0 then oc=1 end
    for xx=-1,1 do
        for yy=-1,1 do
            print(t,x+xx,y+yy,oc)
        end      
    end
    print(t,x,y,c)
end