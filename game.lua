mode="brew"

-- Mouse variables.
poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0
md=false -- Mouse down.
mdp=false -- Mouse down previous.
mp=false -- Mouse pressed.

-- Sets up variables for a game.
function setup_game()
    -- Game variables.
    gold = 42
    holding=nil

	-- Vial variables.
	vox=0 -- Vial offset from the mouse.
	voy=0

	-- Create simulations.
	caul1_box={x=8,y=88,w=32,h=32}
	caul2_box={x=48,y=88,w=32,h=32}
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
end

setup_game()

function _update60()
    -- Get mouse input.
	mx=stat(32)
	my=stat(33)
	md=stat(34)==1
	mp=md and not mdp

	-- Update simulations.
    update_sim(caul1)
	update_sim(caul2)
	for i=0,7 do
		update_sim(vials[i])
	end

    -- Screen specific updates.
    if mode=="brew" then
        brew_update()
    elseif mode=="shop" then
        shop_update()
    end
end

function _draw()
    cls(0)

    -- Screen specific draws.
    if mode=="brew" then
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
            print(t,x+xx,y+yy,1)
        end      
    end
    print(t,x,y,c)
end