potions = {
	-- Roughly ordered by difficulty
	-- 1st order potion: Req. only primary ingredients (water and fairy dust)
	{c=15, n="Wyrmwood Oil"},		-- <- water (12) + fairy dust (14)

	-- 2nd order potion: Req. primary ingredients and 1st order potion
	{c=7, n="Caustic Dreams"},		-- <- water (12) + wyrmwood oil (15)
	{c=4, n="Fortified Runes"},		-- <- fairy dust (14) + wyrmwood oil (15)

	-- 3rd order potion: Req. primary ingredients and 2nd order potion
	{c=5, n="Gaseous Materia"},		-- <- water (12) + fortified runes (4)
	{c=8, n="Dragon's Blood"},		-- <- fairy dust (14) + caustic dreams (7)
	{c=2, n="Spesi Cola"},			-- <- water (12) + caustic dreams (7)

	-- 4th order potion: No primary ingredients
	{c=3, n="Sweat of Newt"},		-- <- wyrmwood oil (15) + gaseous materia (5)
	{c=6, n="Dew of Miasma"},		-- <- caustic dreams (7) + gaseous materia (5)
	{c=9, n="Fenwick Tree"},		-- <- fortified runes (4) + spesi cola (2)
	{c=1, n="Holy Tears"},			-- <- fortified runes (4) + sweat of newt (3)
	{c=10, n="Liquid Algorithms"},	-- <- fenwick tree (9) + holy tears (1)
}

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
	-- local ws=7+4*(flr(t()*2)%2)
	-- spr(ws,8,8,4,4)
	-- spr(ws,8,48,4,4)
	-- spr(ws,48,8,4,4)
	-- spr(ws,48,48,4,4)

	-- Big wizard?
	local ws=56+32*(flr(t()*2)%2)
	sspr(ws, 0, 32, 32, 12, 12, 64, 64)
	-- He's in a window!
	sspr(64, 64, 32, 32, 12, 12, 64, 64)

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
	oprint("0:52", 54, 1, 6)
	-- spr(192, 0, 16, 4, 4)
	sspr(64, 96, 32, 32, 0, 9, 44, 44)
	oprint("Placeholder\nText", 3, 16, 11)
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
