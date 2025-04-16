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

-- Vials and vial slots.
vials={}
slots={}
for i=0,7 do
	v=create_sim(64+i*8,32,8,8)
	vials[i]=v
	slots[i]={v=i,x=16+i*12,y=32,w=v.w,h=v.h}
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

	-- Picking and placing vials.
	for i=0,7 do
		s=slots[i]
		if coll(s,mx,my) and mp then -- If pressing over a slot.
			if holding~=nil then -- Place vial into a slot.
				s.v=holding
				holding=nil
			else -- Pick up vial from slot.
				holding=i
				vox=s.x-mx
				voy=s.y-my 
				s.v=nil
			end
		end
	end

	-- Vial-cauldron transfer.
	b={x=16,y=64,w=32,h=32}
	if col(b,mx,my)

	-- Update previous mouse down.
	mdp=md
end

function _draw()
	cls(0)

	draw_sim(caul1, 16, 64)
	draw_sim(caul2, 72, 64)
	
	-- Draw vials in slots.
	for i=0,7 do
		s=slots[i]
		if s.v~=nil then
			draw_sim(vials[s.v],s.x,s.y)
		else 
			spr(3,s.x,s.y)
		end		
	end

	-- Draw the held vial near the mouse.
	if holding~=nil then
		draw_sim(vials[holding],mx+vox,my+voy)
	end

	-- Draw frame rate.
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