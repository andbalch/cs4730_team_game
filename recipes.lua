
-- TODO: handle recipes where the result is an effect rather than a potion
-- TODO: populate with more recipes
-- TODO: possibly multiple pages
-- TODO: handle "discovering" recipes - simulation dependent so maybe someone else does this
-- TODO: maybe show name on hover on this page (and maybe shop as well)?

current_page = 1
max_page = 1

pg_fwd_box={x=119,y=116,w=8,h=8}
pg_fwd_hov=false

pg_bk_box={x=110,y=116,w=8,h=8}
pg_bk_hov=false

entries={}

function recipes_update()
    update_bubbles()
    
    -- Collect entries.
    entries={}
    for i=0,17 do
        if recipe_book[i]~=nil then
            for j=0,17 do
                local res=recipe_book[i][j]
                if res~=nil then
                    entry={c1=i,c2=j,c3=res}
                    add(entries,entry)
                end
            end
        end
    end
    max_page=ceil(#entries/8)

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
         mode="brew"
    end

    pg_bk_hov=coll(pg_bk_box,mx,my) and current_page > 1
    if pg_bk_hov and mp then
        current_page=current_page-1
    end

    pg_fwd_hov=coll(pg_fwd_box,mx,my) and current_page < max_page
    if pg_fwd_hov and mp then
        current_page=current_page+1
    end
end


function recipes_draw()
    draw_bubbles()

    local rb = {
        x = 20,
        y = 10,
        w = 80,
        h = 110
    }

    -- Draw book.
    -- This code sucks.
    rectfill(rb.x, rb.y - 1, rb.x + rb.w + 4, rb.y + rb.h + 4, 4)
    rectfill(rb.x + 2, rb.y + 2, rb.x + rb.w + 2, rb.y + rb.h + 2, 13)
    rectfill(rb.x + 1, rb.y + 1, rb.x + rb.w + 1, rb.y + rb.h + 1, 13)
    rectfill(rb.x, rb.y, rb.x + rb.w, rb.y + rb.h, 15)

    rectfill(0, 9, 19, 117, 4)
    rectfill(18, 9, 19, 124, 4)
    rectfill(0, 10, 20, 115, 15)

    line(0, 111, 20, 116, 15)
    line(0, 112, 20, 117, 15)
    line(0, 113, 20, 118, 15)
    line(0, 114, 20, 119, 15)
    line(0, 115, 20, 120, 15)
    line(0, 116, 20, 121, 13)
    line(0, 117, 20, 122, 4)
    line(0, 118, 20, 123, 4)

    line(0, 3, 20, 8, 4)
    line(0, 4, 20, 9, 15)
    line(0, 5, 20, 10, 15)
    line(0, 6, 20, 11, 15)
    line(0, 7, 20, 12, 15)
    line(0, 8, 20, 13, 15)
    line(0, 9, 20, 14, 15)

    for i = 0, 20 do
        line(18, i*5 + 12, 22, i*5 + 14, 13) -- book binding
    end

    -- Write recipe entries on page.
    print(#entries)
    local ps=1+(current_page-1)*8
    for i=ps,min(ps+7,#entries) do
        draw_entry(entries[i],i-ps)
    end


    -- Print page number on page.
    print(current_page, 95, 114, 13)

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end

    -- Draw page forward button.
    if current_page~=max_page then
        spr(28,pg_fwd_box.x,pg_fwd_box.y)
        if pg_fwd_hov then 
            draw_box_outline(pg_fwd_box)
        end
    end


    -- Draw page back button.
    if current_page~=1 then
        spr(27,pg_bk_box.x,pg_bk_box.y)
        if pg_bk_hov then 
            draw_box_outline(pg_bk_box)
        end
    end
end


-- Draws a single recipe entry.
function draw_entry(entry, index)
    local y=index*14
    -- Write ingredient 1.
    rect(30, 15+y, 36, 21+y, 13)
    local c1=entry.c1
    if c1==16 then
        c1=8+flr(rnd(3))
    end
    rectfill(31, 16+y, 35, 20+y, c1)
    
    -- Write ingredient 2.
    rect(50, 15+y, 56, 21+y, 13)
    local c2=entry.c2
    if c2==16 then
        c2=8+flr(rnd(3))
    end
    rectfill(51, 16+y, 55, 20+y, c2)

    -- Write result.
    rect(80, 15+y, 86, 21+y, 13)
    rectfill(81, 16+y, 85, 20+y, entry.c3)
    
    -- Plus sign.
    rectfill(43, 16+y, 43, 20+y, 13)
    rectfill(41, 18+y, 45, 18+y, 13)

    -- Equal sign.
    rectfill(66, 17+y, 70, 17+y, 13)
    rectfill(66, 19+y, 70, 19+y, 13)

end



-- Adds a new discovery to the recipe book.
function discover(c1,c2,c3)
    if c1>c2 then 
        local tmp=c1
        c1=c2
        c2=tmp
    end
    if recipe_book[c1]==nil then
        recipe_book[c1]={}
    end
    recipe_book[c1][c2]=c3
end