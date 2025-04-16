-- Game variables.
gold = 42

-- Mouse variables.
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
caul1_box={x=16,y=64,w=32,h=32}
caul2_box={x=72,y=64,w=32,h=32}
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
		local s=slots[i]
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
	if holding~=nil then
		transfer(caul1,caul1_box)
		transfer(caul2,caul2_box)
	end

	-- Update previous mouse down.
	mdp=md
end

function _draw()
	cls(0)

	draw_sim(caul1, 16, 64)
	draw_sim(caul2, 72, 64)
	
	-- Draw vials in slots.
	for i=0,7 do
		local s=slots[i]
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
	print(stat(7),112,0)

	-- Print UI.
	--spr(4,0,0)
	--oprint(gold,9,1,10)

	-- Draw mouse.
	ms=1
	if md or holding then ms=2 end
	spr(ms,mx,my)
end

-- Game Procedures --

-- Checks if vial is being pressed on cauldron and transfers pixels accordingly.
function transfer(caul, box)
	if coll(box,mx,my) and md then
		local cx=mx-box.x-1+flr(rnd(3)) -- Translate (mx,my) to simulation coordinates.
		local cy=my-box.y

		-- Iterate through cells in vial.
		local v=vials[holding]
		local cc=caul:g(cx,cy)
		for x=3,4 do
			for y=1,6 do
				-- If the vial cell isn't empty and the cauldron cell is, tranfer it over to the cauldron.
				local vc=v:g(x,y)
				if vc~=0 and cc==0 then
					v:s(x,y,0)
					caul:s(cx,cy,vc)
					goto transferred
				-- If the cauldron cell isn't empty and the vial cell is, tranfer it over to the vial.
				elseif vc==0 and cc~=0 then
					v:s(x,y,cc)
					caul:s(cx,cy,0)
					goto transferred
				end
			end
		end
		::transferred::

	end
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