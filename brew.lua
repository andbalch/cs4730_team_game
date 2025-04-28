-- Constants.
caul1_box={x=8,y=80,w=32,h=32}
caul2_box={x=48,y=80,w=32,h=32}
caul1_flip_box={x=39,y=108,w=8,h=8}
caul2_flip_box={x=79,y=108,w=8,h=8}
shop_box={x=119,y=1,w=7,h=8}
recipes_box={x=108,y=1,w=9,h=8}
can_box={x=99,y=1,w=8,h=8}

-- Variables.
viewing=nil
shop_hov=false
transfer_mode=nil

-- Timer for sound effects.
sand_sound_timer=0

-- Timer for selling potions
sell_timer=0

function brew_update()
	viewing=nil

	-- Update simulations.
	update_sim(caul1)
	update_sim(caul2)
	for i=0,7 do
		update_sim(vials[i])
	end

	-- Picking, placing, and serving vials.
	for i=0,7 do
		local s=slots[i]
		if coll(s,mx,my) then -- If hovering over a slot:
			if vials[s.v]~=nil then viewing=vials[s.v]:g(mx-s.x,my-s.y) end
			if msp then -- If pressing slot:
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
		elseif holding~=nil and coll(cust,mx,my) and mp then 
			-- If a vial is pressing over a customer, serve it.
			-- Triggerable when holding an empty vial
			serve()
		end
	end

	-- Vial-cauldron transfer.
	transfer(caul1,caul1_box)
	transfer(caul2,caul2_box)
	if not md then 
		transfer_mode=nil
	end

	-- Clicking the cauldron flip buttons.
	c1fhov=coll(caul1_flip_box,mx,my)
	if c1fhov and mp then
		caul1:flip()
	end
	c2fhov=coll(caul2_flip_box,mx,my)
	if c2fhov and mp then
		caul2:flip()
	end

	-- Clicking shop button.
	shop_hov=coll(shop_box, mx, my)
	if mp and shop_hov then
		mode="shop"
		sfx(5)
	end

	-- Clicking recipes button.
	recipes_hov=coll(recipes_box, mx, my)
	if mp and recipes_hov then
		mode="recipes"
		sfx(4)
	end

	-- Emptying vial.
	can_hov=coll(can_box, mx, my)
	if mp and can_hov and holding~=nil then
		empty_vial(0)
	end
end

function brew_draw()
	-- Draw wizard.
	-- local ws=7+4*(flr(t()*2)%2)
	-- spr(ws,8,8,4,4)
	-- spr(ws,8,48,4,4)
	-- spr(ws,48,8,4,4)
	-- spr(ws,48,48,4,4)

	-- Big wizard!

	-- swap palette to draw different wizards with different color robes.
	-- color on sprite sheet is 1.
	pal(1, cust.robe_col)

	-- main wizard draw.
	sspr(56, 0, 32, 32, cust.x, cust.y, cust.w, cust.h)

	-- periodically move eyes.
	if (flr(t()*2)%2) == 0 then
		sspr(11*8, 0, 16, 8, cust.x + 16, cust.y + 16, 32, 16)
	end

	-- draw long nose.
	if (cust.long_nose) then
		sspr(13*8, 0, 8, 8, cust.x + 16, cust.y + 32, 16, 16)
	end
	
	-- return palette to normal after drawing wizard.
	pal()

	-- He's in a window!
	sspr(64, 64, 32, 32, cust.x, cust.y, cust.w, cust.h)

	-- Draw shop button.
	spr(49,shop_box.x,shop_box.y)
	if shop_hov then draw_box_outline(shop_box) end

	-- Draw recipes button.
	spr(38,recipes_box.x,recipes_box.y)
	if recipes_hov then draw_box_outline(recipes_box) end

	-- Draw rubbish can.
	if holding then
		spr(43, can_box.x, can_box.y)
		if can_hov then 
			draw_box_outline(can_box) 
		end
	end

	-- Draw cauldrons.
	draw_sim(caul1, caul1_box.x, caul1_box.y)
	draw_sim(caul2, caul2_box.x, caul2_box.y)

	-- Draw fire under cauldron.
	--if not caul1.flipped then draw_fire(caul1_box) end
	--if not caul2.flipped then draw_fire(caul2_box) end
	
	-- Draw cauldron flip buttons.
	spr(6,caul1_flip_box.x,caul1_flip_box.y)
	spr(6,caul2_flip_box.x,caul2_flip_box.y)
	if c1fhov then draw_box_outline(caul1_flip_box) end
	if c2fhov then draw_box_outline(caul2_flip_box) end

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
		x_bound = max(mx+vox, 0)
		x_bound = min(x_bound, 120)
		y_bound = max(my+voy, 0)
		draw_sim(vials[holding],x_bound,y_bound)
	end

	-- Draw gold count.
	spr(4,1,1)
	oprint(gold,10,2,10)

	-- Draw rep.
	oprint("rep",24,2,11)
	spr(59+failure_count,37,1)

	-- Display current order
	-- spr(192, 0, 16, 4, 4)
	sspr(64, 96, 32, 32, 0, 9, 44, 44)
	local oy=17
	local os=potions[order_i].n
	if #os<=9 then oy=21 end
	oprint(os, 4, oy, m2c(mx,my,potions[order_i].c))

	-- Timer countdown until penalty occurs
	local time_str = ""
	local d_t = flr((t() - pot_timer) * 0.75 * time_mod) -- '*1.5' roughly controls for how pico8 handles time, given update runs 30 times per sec
	if (d_t < time_lim) then
		d_t = time_lim - d_t
		time_c = 6
	else
		-- out of time!!
		d_t = d_t - time_lim
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
	if viewing~=nil then
		oprint(names[viewing+1],2,121,m2c(mx,my,viewing))
	end
	-- print(stat(7),2,121,7)


	-- Draw transfer mode.
	if transfer_mode=="pour" then
		oprint("pouring...",88,121,7)
		if sand_sound_timer<time() then
			sfx(0)
			sand_sound_timer=time() + 0.3
		end
	elseif transfer_mode=="collect" then
		oprint("collecting...",76,121,7)
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
						if vc~=0 and cc==0 and (transfer_mode==nil or transfer_mode=="pour") then
							v:s(x,y,0)
							caul:s(cx,cy,vc)
							transfer_mode="pour"
							goto transferred
						-- If the cauldron cell isn't empty and the vial cell is, tranfer it over to the vial.
						elseif vc==0 and cc~=0 and cc~=13 and (transfer_mode==nil or transfer_mode=="collect") then
							v:s(x,y,cc)
							caul:s(cx,cy,0)
							transfer_mode="collect"
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
	if sell_timer > time() then
		return -- Don't serve if not enough time has passed.
	end
	sell_timer = time() + 0.2
	-- Empty vial and calc. score
	-- TODO: inc. points based on potion difficulty?
	local score = flr(empty_vial(potions[order_i].c) * prices[potions[order_i].c])

	if score < 10 then
		sfx(2)
		failure_count = failure_count + 1
		if failure_count >= 5 then
			mode = "failure"
			music(4)
		end
	else
		sfx(3)
		failure_count = failure_count - 1
		if failure_count < 0 then
			failure_count = 0
		end
	end
	sell_sound_timer = time() + 0.5

	-- Penalty if time limit exceeded
	if time_c == 8 then 
		score = score * (1 - time_penalty)
	end

	-- Increase score.
	gold = flr(gold + score)
	if gold > 2000 then
		mode = "success"
	end

	-- Transition to next order
	order_i = new_order()

	-- Generate a new customer.
	cust = gen_cust()
	
	-- Set timer
	-- TODO: variable time limits?
	pot_timer = t()

	-- TODO: New wizard?
end

-- Empties the currently-held vial, returns float representing recipe purity (number of target cells over total vial space).
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

-- Generates a customer.
robe_cols={1,2,3,4,5,8,12,14}
function gen_cust()
	local nose=true
	if(rnd(1)>0.5) then nose=false end
	return {
		x=12,
		y=12,
		w=64,
		h=64,
		robe_col=robe_cols[1+flr(rnd(#robe_cols))],
		long_nose=nose
	}
end