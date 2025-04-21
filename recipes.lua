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

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end
end