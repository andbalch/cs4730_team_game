function brew_update()

	-- Picking and placing vials.
	for i=0,7 do
		local s=slots[i]
		if coll(s,mx,my) and mp then -- If pressing over a slot.
			if holding~=nil and s.v==nil then -- Place vial into a slot.
				s.v=holding
				holding=nil
			elseif holding==nil and s.v~=nil then -- Pick up vial from slot.
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

function brew_draw()
	-- Draw wizard.
	local ws=7+4*(flr(t()*2)%2)
	spr(ws,8,8,4,4)
	spr(ws,8,48,4,4)
	spr(ws,48,8,4,4)
	spr(ws,48,48,4,4)

	-- Draw shop button.
	spr(132,84,8,4,2)

	-- Draw cauldrons.
	draw_sim(caul1, caul1_box.x, caul1_box.y)
	draw_sim(caul2, caul2_box.x, caul2_box.y)

	-- Draw fire under cauldron.
	--draw_fire(caul1_box)
	--draw_fire(caul2_box)
	
	-- Draw vials in slots.
	for i=0,7 do
		local s=slots[i]
		if s.v~=nil then
			draw_sim(vials[s.v],s.x,s.y)
		else 
			spr(5,s.x,s.y,1,2)
		end		
	end

	-- Draw shelves
	for i=0,7,2 do
		spr(160,slots[i].x - 6,slots[i].y + 2,4,2)
	end

	-- Draw the held vial near the mouse.
	if holding~=nil then
		draw_sim(vials[holding],mx+vox,my+voy)
	end



	-- Draw frame rate.
	print(stat(7),112,0)

	-- Print UI.
	spr(4,0,0)
	oprint(gold,9,1,10)
end

-- Procedures --

-- Checks if vial is being pressed on cauldron and transfers pixels accordingly.
function transfer(caul, box)
	if coll(box,mx,my) and md then
		local cx=mx-box.x-1+flr(rnd(3)) -- Translate (mx,my) to simulation coordinates.
		local cy=my-box.y

		-- Iterate through cells in vial.
		local v=vials[holding]
		local cc=caul:g(cx,cy)
		for y=0,v.h-1 do
			local wc=0 -- Wall count.
			for x=0,v.w-1 do
				local vc=v:g(x,y)
				if vc==13 then 
					wc=wc+1
				elseif wc==1 then -- Ensure the pixels are in the vial (i.e. wall count = 1).
					-- If the vial cell isn't empty and the cauldron cell is, tranfer it over to the cauldron.
					if vc~=0 and cc==0 then
						v:s(x,y,0)
						caul:s(cx,cy,vc)
						goto transferred
					-- If the cauldron cell isn't empty and the vial cell is, tranfer it over to the vial.
					elseif vc==0 and cc~=0 and cc~=13 then
						v:s(x,y,cc)
						caul:s(cx,cy,0)
						goto transferred
					end
				end
			end
		end
		::transferred::
	end
end

-- Draws fire under a given cauldron box.
function draw_fire(box)
	local xo=box.x+box.w/4
	local yo=box.y+box.h
	for i=0,10 do
		local x=xo+rnd(box.w/2)
		local y=yo+rnd(4)
		local r=1+flr(rnd(2))
		local c=8+flr(rnd(3))
		circfill(x,y,r,c)
	end
end
