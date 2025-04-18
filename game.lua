mode="title"

-- Mouse variables.
poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0
md=false -- Mouse down.
mdp=false -- Mouse down previous.
mp=false -- Mouse pressed.

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
	{c=15, n="Wyrmwood\nOil"},		-- <- water (12) + fairy dust (14)

	-- 2nd order potion: Req. primary ingredients and 1st order potion
	{c=7, n="Caustic\nDreams"},		-- <- water (12) + wyrmwood oil (15)
	{c=4, n="Fortified\nRunes"},		-- <- fairy dust (14) + wyrmwood oil (15)

	-- 3rd order potion: Req. primary ingredients and 2nd order potion
	{c=5, n="Gaseous\nMateria"},		-- <- water (12) + fortified runes (4)
	{c=8, n="Dragon's\nBlood"},		-- <- fairy dust (14) + caustic dreams (7)
	{c=2, n="Spesi\nCola"},			-- <- water (12) + caustic dreams (7)

	-- 4th order potion: No primary ingredients
	{c=3, n="Sweat of\nNewt"},		-- <- wyrmwood oil (15) + gaseous materia (5)
	{c=6, n="Dew of\nMiasma"},		-- <- caustic dreams (7) + gaseous materia (5)
	{c=9, n="Fenwick\nTree"},		-- <- fortified runes (4) + spesi cola (2)
	{c=1, n="Holy\nTears"},			-- <- fortified runes (4) + sweat of newt (3)
	{c=10, n="Liquid\nAlgorithms"},	-- <- fenwick tree (9) + holy tears (1)
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
    gold = 42
    holding=nil

	-- Vial variables.
	vox=0 -- Vial offset from the mouse.
	voy=0

	-- Create simulations.
	caul1 = create_sim(0, 32,32,32)
	caul2 = create_sim(32,32,32,32)

	-- Vials and vial slots.
    vials={}
    slots={}
	for i=0,7 do
		v=create_sim(64+i*8,32,8,16)
		vials[i]=v
		slots[i]={v=i,x=88+(i%2)*12,y=32+flr(i/2)*24,w=v.w,h=v.h}
	end

	-- generate order
	order_i = new_order()
	pot_timer = t()
end

function _update60()
    -- Get mouse input.
	mx=stat(32)
	my=stat(33)
	md=stat(34)==1
	mp=md and not mdp

    -- Screen specific updates.
	if mode=="title" then
		title_update()
    elseif mode=="brew" then
		-- Update simulations.
        brew_update()
    elseif mode=="shop" then
        shop_update()
    end
end

function _draw()
    	cls(0)

    -- Screen specific draws.
	if mode=="title" then	
		title_draw()
    elseif mode=="brew" then
        brew_draw()
    elseif mode=="shop" then
        shop_draw()
    end

	-- Draw mouse.
	ms=1
	if md or holding then ms=2 end
	spr(ms,mx,my)
end

-- Utility Functions --

-- Checks if a point is within a box.
function coll(b,x,y)
	return x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h
end

-- Prints a string with an outline.
function oprint(t,x,y,c)
    for xx=-1,1 do
        for yy=-1,1 do
            print(t,x+xx,y+yy,0)
        end      
    end
    print(t,x,y,c)
end