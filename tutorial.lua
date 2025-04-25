tutorial_step = 1
tutorial_string =
    {
        "test",
        "test2",
    }


function tutorial_update()
    if (btnp(❎) or mp) and tutorial_step < #tutorial_string then -- ❎ key
        tutorial_step = tutorial_step + 1
    elseif btnp(🅾️) and tutorial_step > 1 then 
        tutorial_step = tutorial_step - 1
    end
end

function tutorial_draw()
    pal(1, cust.robe_col)

	-- main wizard draw.
	sspr(56, 0, 32, 32, cust.x, cust.y, cust.w, cust.h)

	-- periodically move eyes.
	if (flr(t()*0.5)%2) == 0 then
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
	-- draw_fire(caul1_box)
	-- draw_fire(caul2_box)
	
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
	oprint("0:00", 54, 1, time_c)

    -- Draw tutorial string
    print(tutorial_string[tutorial_step],2,121,7)
end