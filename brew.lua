-- Constants.
caul1_box={x=8,y=80,w=32,h=32}
caul2_box={x=48,y=80,w=32,h=32}
shop_box={x=82,y=4,w=32,h=16}

-- Variables.
viewing=nil

function brew_update()
	viewing=nil

	-- Picking, placing, and serving vials.
	for i=0,7 do
		local s=slots[i]
		if coll(s,mx,my) then -- If hovering over a slot:
			if vials[s.v]~=nil then viewing=vials[s.v]:g(mx-s.x,my-s.y) end
			if mp then -- If pressing slot:
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
		elseif holding~=nill and coll(cust,mx,my) and mp then -- If a vial is pressing over a customer, serve it.
			-- POTENTIAL BUG: Triggerable when holding an empty vial, observed a few instances when serve() is called more than once on click
			serve()
		end
	end

	-- Vial-cauldron transfer.
	transfer(caul1,caul1_box)
	transfer(caul2,caul2_box)

	-- Clicking shop button.
	if mp and coll(shop_box, mx, my) then
		mode="shop"
	end
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
	sspr(ws, 0, 32, 32, cust.x, cust.y, cust.w, cust.h)
	-- He's in a window!
	sspr(64, 64, 32, 32, cust.x, cust.y, cust.w, cust.h)

	-- Draw shop button.
	spr(132,shop_box.x,shop_box.y,4,2)

	-- Draw cauldrons.
	draw_sim(caul1, caul1_box.x, caul1_box.y)
	draw_sim(caul2, caul2_box.x, caul2_box.y)

	-- Draw fire under cauldron.
	draw_fire(caul1_box)
	draw_fire(caul2_box)
	
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

	-- Draw gold count.
	spr(4,0,0)
	oprint(gold,9,1,10)

	-- Display current order
	-- spr(192, 0, 16, 4, 4)
	sspr(64, 96, 32, 32, 0, 9, 44, 44)
	oprint(potions[order_i].n, 3, 16, potions[order_i].c)

	-- Timer countdown until penalty occurs
	time_str = ""
	local d_t = flr((t() - pot_timer) * 3) -- '*3' roughly controls for how pico8 handles time, given update runs 30 times per sec
	if (d_t < time_lim) then
		d_t = time_lim - d_t
		time_c = 6
	else
		-- out of time!!
		time_str = time_str .. "-"
		time_c = 8
	end
	local min = flr(d_t / 60)
	local sec = d_t % 60
	time_str = time_str .. min .. ":"
	if (sec < 10) then
		time_str = time_str .. "0"
	end
	time_str = time_str .. sec
	oprint(time_str, 54, 1, time_c)

	-- Draw currently viewed cell.
	rectfill(0,119,128,128,2)
	print(viewing)
	if viewing~=nil then
		oprint(names[viewing+1],2,121,viewing)
	end
end

-- Procedures --

-- Checks if vial is being pressed on cauldron and transfers cells accordingly.
function transfer(caul, box)
	if coll(box,mx,my) then
		viewing=caul:g(mx-box.x,my-box.y)
		if holding~=nil and md then
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
					elseif wc==1 then -- Ensure the cells are in the vial (i.e. wall count = 1).
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
end

function serve()
	-- Empty vial and calc. score
	-- TODO: inc. points based on potion difficulty?
	local score = flr(empty_vial(potions[order_i].c) * 100)

	-- Penalty if time limit exceeded
	if time_c == 8 then 
		score = score * (1 - time_penalty)
	end

	-- Inc. score
	gold = gold + score

	-- Transition to next order
	order_i = new_order()
	
	-- Set timer
	-- TODO: variable time limits?
	pot_timer = t()

	-- TODO: New wizard?
end

-- Sets cells in the currently-held vial to 0, Returns % purity (number of target cells over total vial space).
function empty_vial(c)
	-- Empty vial by slightly modifying the code used for transfer().
	local v=vials[holding]
	local total = 0
	local target = 0
	for y=0,v.h-1 do
		local wc=0 -- Wall count.
		for x=0,v.w-1 do
			local vc=v:g(x,y)
			if vc==13 then 
				wc=wc+1
			elseif wc==1 then -- Ensure the cells are in the vial (i.e. wall count = 1).
				-- If the vial cell is target, count
				if vc == c then
					target=target+1
				end 
				v:s(x,y,0) -- Empty the cell.
				total=total+1
			end 
		end
	end 

	count=max(1,count) -- Avoids divide by zero.
	return target/total
end

-- Draws fire under a given cauldron box.
function draw_fire(box)
	local xo=box.x+box.w/4
	local yo=box.y+box.h
	for i=0,20 do
		local x=xo+rnd(box.w/2)
		local y=yo+rnd(3)
		local r=1+flr(rnd(2))
		local c=8+flr(rnd(3))
		circfill(x,y,r,c)
	end
end
