mode="title"

-- Mouse variables.
poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0
md=false -- Mouse down.
mdp=false -- Mouse down previous.
mp=false -- Mouse pressed.
msp=false -- Mouse started pressing.

-- Error variables.
error_str=nil
error_timer=0

-- Potion variables.

-- TOOD: Variable profits, time limits?
potions = {
	{c=12, n="water", p=5},
	{c=9, n="sweat of\nnewt", p=20},
	{c=8, n="dragon's\nblood", p=30},
	{c=14, n="fairy\ndust", p=30},
	{c=3, n="fenwick\ntree", p=60},
	{c=5, n="crimstone", p=70},
	{c=2, n="caustic\ndreams", p=80},
	{c=16, n="magic\nflame", p=100},
	{c=4, n="fortified\nrunes", p=120},
	{c=11, n="acid", p=130},
	{c=7, n="moonlight", p=200},
	{c=17, n="chroma-\ncrystal", p=210},
	{c=10, n="dreamroot\nspore", p=220},
	{c=1, n="miasma", p=300},
	{c=15, n="wyrmood\noil", p=300},
}

names={
	"",
	"miasma",
	"caustic dreams",
	"fenwick tree",
	"fortified runes",
	"crimstone",
	"steam",
	"moonlight",
	"dragon's blood",
	"sweat of newt",
	"dreamroot spore",
	"acid",
	"water",
	"",
	"fairy dust",
	"wyrmwood oil",
	"magic flame",
	"chromacrystal",
}

prices={
	0,
	300,
	80,
	60,
	120,
	70,
	0,
	200,
	30,
	20,
	220,
	130,
	5,
	0,
	30,
	300,
	100,
	210
}


multicol = {}
multicol[16]={8,9,10}
multicol[17]={2,14,12,11,3}

-- Order variables.
pot_lim = #potions
time_lim = 60
time_penalty = 0.10
-- Modify this to change how fast the timer counts down (greater -> faster)!
time_mod = 1

pot_timer = 0;
time_str = ""
time_c = 6

order_i = -1
-- Generates a new order randomly
function new_order()
	return flr(rnd(pot_lim)) + 1
end

tutorial_flag = false

-- Sets up variables for a game.
function setup_game()
    -- Game variables.
    gold=42
    holding=nil
	cust=gen_cust()

	-- Vial variables.
	vox=0 -- Vial offset from the mouse.
	voy=0

	-- Recipe book.
	recipe_book={}

	-- Create simulations.
	caul1=create_sim(0, 32,32,32)
	caul2=create_sim(32,32,32,32)

	-- Vials and vial slots.
    vials={}
    slots={}
	for i=0,7 do
		v=create_sim(64+i*8,32,8,16)
		vials[i]=v
		slots[i]={v=i,x=96+(i%2)*12,y=24+flr(i/2)*24,w=v.w,h=v.h}
	end

	-- generate order
	order_i = new_order()
	pot_timer = t()
end

setup_game()
music(4)

function _update60()
    -- Get mouse input.
	mx=mid(0,stat(32),127)
	my=mid(0,stat(33),127)
	md=stat(34)==1
	mp=mdp and not md
	msp=md and not mdp
	mdp = not mp

	-- Update error timer.
	error_timer=error_timer-1
		
    -- Screen specific updates.
	if mode=="title" then
		title_update()
    elseif mode=="brew" then
		-- Update simulations.
        brew_update()
    elseif mode=="shop" then
        shop_update()
	elseif mode=="recipes" then
		recipes_update()
	elseif mode=="intro" then
		-- TODO introduction
		intro_update()
	elseif mode=="tutorial" then
		-- display optional tutorial screen
		tutorial_update()
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
	elseif mode=="recipes" then
		recipes_draw()
	elseif mode=="intro" then
		-- TODO introduction
		intro_draw()
	elseif mode=="tutorial" then
		tutorial_draw()
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

	-- Draw frame count.
	--oprint(stat(7),116,121,7)
end


-- Utility Functions --

-- Sets an error message for a second.
function err(str)
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

function draw_box_outline(b)
	rect(b.x-1,b.y-1,b.x+b.w,b.y+b.h,7) 
end
