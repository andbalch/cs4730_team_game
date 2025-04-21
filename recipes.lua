
-- TODO: handle recipes where the result is an effect rather than a potion
-- TODO: populate with more recipes
-- TODO: possibly multiple pages
-- TODO: handle "discovering" recipes - simulation dependent so maybe someone else does this
-- TODO: maybe show name on hover on this page (and maybe shop as well)?

current_page = 1
max_page = 2

pg_fwd_box={x=119,y=119,w=8,h=8}
pg_fwd_hov=false

pg_bk_box={x=110,y=119,w=8,h=8}
pg_bk_hov=false

function init_recipes()

    recipe_book = {}
    recipe_book[1] = create_recipe(12, 15, 7, true)
    recipe_book[2] = create_recipe(14, 15, 4, true)
    recipe_book[3] = create_recipe(12, 4, 5, false)
    recipe_book[4] = create_recipe(14, 7, 8, false)
    recipe_book[5] = create_recipe(4, 7, 2, false)
    recipe_book[6] = create_recipe(15, 5, 3, false)
    recipe_book[7] = create_recipe(7, 5, 6, false)

    recipe_book[8] = create_recipe(4, 2, 9, false)
    recipe_book[9] = create_recipe(4, 3, 1, false)
    recipe_book[10] = create_recipe(9, 1, 10, false)

end

function create_recipe(ing_1, ing_2, result, discovered)

    local recipe = {}
    recipe.ing_1 = ing_1
    recipe.ing_2 = ing_2
    recipe.result = result
    recipe.discovered = discovered
    return recipe

end

function write_recipe(rp, index)

    -- Write ingredient 1.
    rect(30, 15+(index*14), 36, 21+(index*14), 13)
    rectfill(31, 16+(index*14), 35, 20+(index*14), rp.ing_1)
    
    -- Write ingredient 2.
    rect(50, 15+(index*14), 56, 21+(index*14), 13)
    rectfill(51, 16+(index*14), 55, 20+(index*14), rp.ing_2)

    -- Write result, or question mark if recipe is not yet discovered.
    if rp.discovered then
        rect(80, 15+(index*14), 86, 21+(index*14), 13)
        rectfill(81, 16+(index*14), 85, 20+(index*14), rp.result)
    else
        print("?", 81, 16+(index*14), 13)
    end
    
    -- Plus sign.
    rectfill(43, 16+(index*14), 43, 20+(index*14), 13)
    rectfill(41, 18+(index*14), 45, 18+(index*14), 13)


    -- Equal sign.
    rectfill(66, 17+(index*14), 70, 17+(index*14), 13)
    rectfill(66, 19+(index*14), 70, 19+(index*14), 13)

end


function recipes_update()

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
         mode="brew"
    end

    pg_bk_hov=coll(pg_bk_box,mx,my) and current_page > 1
    if pg_bk_hov and mp then
         current_page -= 1
    end

    pg_fwd_hov=coll(pg_fwd_box,mx,my) and current_page < max_page
    if pg_fwd_hov and mp then
         current_page += 1
    end
end


function recipes_draw()

    rb = {
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


    -- Write recipes on page.
    for i = 1,#recipe_book do
        write_recipe(recipe_book[i], i-1)
    end

    -- Print page number on page.
    print(current_page, 95, 114, 13)

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end

    -- Draw page forward button.
    spr(28,pg_fwd_box.x,pg_fwd_box.y)
    if pg_fwd_hov then 
        draw_box_outline(pg_fwd_box)
    end

    -- Draw page back button.
    spr(27,pg_bk_box.x,pg_bk_box.y)
    if pg_bk_hov then 
        draw_box_outline(pg_bk_box)
    end
end