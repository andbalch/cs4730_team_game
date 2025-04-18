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

buttons={}
local c=0
for i=1,15 do
    if i~=13 then
        b={x=1,y=10+c*12,w=61,h=8,c=i,hov=false}
        if c>6 then -- Second column.
            b.x=65
            b.y=10+(c-7)*12
        end
        add(buttons, b)
        c=c+1
    end
end

function shop_update()
    for b in all(buttons) do
        b.hov=coll(b,mx,my)
        if b.hov and mp then
            buy_vial(b.c)
        end
    end
end


function shop_draw()
    -- Draw gold count.
	spr(4,0,0)
	oprint(gold,9,1,10)

    for b in all(buttons) do
        local r,d=b.x+b.w,b.y+b.h
        rectfill(b.x,b.y,r,d,4)
        if b.hov then -- Hover outline.
            if md then
                rectfill(b.x,b.y,r,d,15) 
            end
            rect(b.x-1,b.y-1,r+1,d+1,7)
        end

        rect(b.x+1,b.y+1,b.x+7,b.y+7,13)
        rectfill(b.x+2,b.y+2,b.x+6,b.y+6,b.c)
        oprint("$"..prices[b.c],r-12,b.y+2,10)
    end
end

-- Procedures.

function buy_vial(c)
    local p=prices[c]
    if gold>=p then
        gold=gold-prices[c]
    end
end