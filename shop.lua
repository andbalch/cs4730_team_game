options={12,9,8,14}

-- Buttons.
buttons={}
for i=1,#options do
    b={x=1,y=11+(i-1)*12,w=126,h=9,c=options[i],hov=false}
    
    --if c>6 then -- Second column.
    --    b.x=65
    --    b.y=11+(i-7)*12
    --end
    add(buttons, b)
end

-- Back button.
back_box={x=119,y=1,w=8,h=8}
back_hov=false

function shop_update()
    update_bubbles()

    for b in all(buttons) do
        b.hov=coll(b,mx,my)
        if b.hov and mp then
            buy_vial(b.c)
        end
    end

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
        if tutorial_flag then
            mode = "tutorial"
        else
            mode = "brew"
        end
    end

    if tutorial_flag then
        if (btnp(❎) or mp) and tutorial_step < #tutorial_string then
            tutorial_step = tutorial_step + 1
        elseif btnp(🅾️) and tutorial_step > 1 then
            tutorial_step = tutorial_step - 1
        elseif btnp(❎) and tutorial_step == #tutorial_string then
            mode = "title"
            tutorial_step = 1
            tutorial_flag = false
        end
    end
end


function shop_draw()
    draw_bubbles()

    -- Draw gold count.
	spr(4,1,1)
	oprint(gold,10,2,10)

    -- Draw buttons.
    for b in all(buttons) do
        local r,d=b.x+b.w-1,b.y+b.h-1
        rectfill(b.x,b.y,r,d,4)
        if b.hov then -- Hover outline.
            if md then
                rectfill(b.x,b.y,r,d,15) 
            end
            draw_box_outline(b)
        end

        rect(b.x+1,b.y+1,b.x+7,b.y+7,13)
        rectfill(b.x+2,b.y+2,b.x+6,b.y+6,b.c)
        oprint(names[b.c+1],b.x+10,b.y+2,b.c)
        oprint("$"..prices[b.c+1],r-12,b.y+2,10)
    end

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end

    if tutorial_flag then
        -- Draw tutorial string
        rectfill(0,119,128,128,2)
        print(tutorial_string[tutorial_step],2,121,7)
    end
end

-- Procedures.

function buy_vial(c)
    local p=prices[c]
    if gold>=p then
        for i=0,7 do
            v=vials[i]
            local empty=true
            for y=0,v.h-1 do
                for x=0,v.w-1 do
                    local vc=v:g(x,y)
                    if vc~=0 and vc~=13 then empty=false end
                end
            end 

            -- If the vial is empty, fill it in.
            if empty then
                for y=0,v.h-1 do
                    local wc=0 -- Wall count.
                    for x=0,v.w-1 do
                        local vc=v:g(x,y)
                        if vc==13 then 
                            wc=wc+1
                        elseif wc==1 then
                            v:s(x,y,c) -- Fill in cell.
                        end 
                    end
                end 
                
                gold=gold-prices[c]
                return
            end
        end
        err("no space!")
    else
        err("too poor!")
    end
end
