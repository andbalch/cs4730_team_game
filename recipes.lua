
-- TODO: handle recipes where the result is an effect rather than a potion
-- TODO: populate with more recipes
-- TODO: possibly multiple pages


function init_recipes()

    recipe_book = {}
    recipe_book[1] = create_recipe(14, 15, 4, false)
    recipe_book[2] = create_recipe(12, 4, 5, false)

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
    rect(30, 15, 36, 21, 13)
    rectfill(31, 16, 35, 20, rp.ing_1)
    
    -- Write ingredient 2.
    rect(50, 15, 56, 21, 13)
    rectfill(51, 16, 55, 20, rp.ing_2)

    -- Write result, or question mark if recipe is not yet discovered.
    if rp.discovered then
        rect(80, 15, 86, 21, 13)
        rectfill(81, 16, 85, 20, rp.result)
    else
        print("?", 81, 16, 13)
    end
    
    -- Plus sign.
    rectfill(43, 16, 43, 20, 13)
    rectfill(41, 18, 45, 18, 13)


    -- Equal sign.
    rectfill(66, 17, 70, 17, 13)
    rectfill(66, 19, 70, 19, 13)

end


function recipes_update()

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
         mode="brew"
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
        write_recipe(recipe_book[i], i)
    end

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end
end