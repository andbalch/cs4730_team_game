prices={
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
    10,
}

-- Buttons.
buttons={}
local c=0
for i=1,15 do
    if i~=13 then
        b={x=1,y=11+c*12,w=61,h=8,c=i,hov=false}
        if c>6 then -- Second column.
            b.x=65
            b.y=11+(c-7)*12
        end
        add(buttons, b)
        c=c+1
    end
end

-- Back button.
back_box={x=119,y=1,w=8,h=8}
back_hov=false

function shop_update()
    for b in all(buttons) do
        b.hov=coll(b,mx,my)
        if b.hov and mp then
            buy_vial(b.c)
        end
    end

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
         mode="brew"
    end
end


function shop_draw()
    -- Draw gold count.
	spr(4,0,0)
	oprint(gold,9,1,10)

    -- Draw buttons.
    for b in all(buttons) do
        local r,d=b.x+b.w,b.y+b.h
        rectfill(b.x,b.y,r,d,4)
        if b.hov then -- Hover outline.
            if md then
                rectfill(b.x,b.y,r,d,15) 
            end
            draw_box_outline(b)
        end

        rect(b.x+1,b.y+1,b.x+7,b.y+7,13)
        rectfill(b.x+2,b.y+2,b.x+6,b.y+6,b.c)
        oprint("$"..prices[b.c],r-12,b.y+2,10)
    end

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
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
        error("no space!")
    else
        error("too poor!")
    end
end
