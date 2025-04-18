shop_prices={
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
        b={x=1,y=1+c*12,w=61,h=8,c=i}
        if c>6 then -- Second column.
            b.x=64
            b.y=1+(c-7)*12
        end
        add(buttons, b)
        c=c+1
    end
end

function shop_update()

end

function shop_draw()

    for b in all(buttons) do
        local r,d=b.x+b.w,b.y+b.h
        rectfill(b.x,b.y,r,d,4)
        if coll(b,mx,my) then -- Hover outline.
            rect(b.x-1,b.y-1,r+1,d+1,7)
        end

        rect(b.x+1,b.y+1,b.x+7,b.y+7,13)
        rectfill(b.x+2,b.y+2,b.x+6,b.y+6,b.c)
        oprint("$"..shop_prices[b.c],r-12,b.y+2,10)
    end
end