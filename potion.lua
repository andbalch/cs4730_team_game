poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0
md=false -- Mouse down.
mdp=false -- Mouse down previous.
mp=false -- Mouse pressed.
holding=nil

-- Vial variables.
vox=0 -- Vial offset from the mouse.
voy=0

-- Create simulations.
caul1 = create_sim(0, 32,32,32)
caul2 = create_sim(32,32,32,32)

vials={}
for i=0,7 do
	vials[i]=create_sim(64+i*8,32,8,8)
end

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

	-- Vial movement.
	for i=0,7 do
		v=vials[i]
		b={x=16+i*12,y=32,w=v.w,h=v.h} -- Collision box for vial in static position.
		if coll(b,mx,my) and mp then -- Picking up vials.
			if holding~=nil then holding=nil
			else 
				holding=i
				vox=b.x-mx
				voy=b.y-my 
			end
		end
	end

	mdp=md
end

function _draw()
	cls(0)

	draw_sim(caul1, 16, 64)
	draw_sim(caul2, 72, 64)
	for i=0,7 do
		vx=16+i*12 -- Vial slot location.
		vy=32
		spr(88,vx,vy)
		if holding==i then -- Draw vial near mouse if it's being held.
			draw_sim(vials[i],mx+vox,my+voy)
		else -- Otherwise, draw it in its slot.
			draw_sim(vials[i],vx,vy)
		end		
	end
	
	print(stat(7))

	-- Draw mouse.
	ms=1
	if md or holding then ms=2 end
	spr(ms,mx,my)
end

-- Utility functions.

-- Checks if a point is within a box.
function coll(b,x,y)
	return x>=b.x and x<=b.x+b.w and y>=b.y and y<=b.y+b.h
end