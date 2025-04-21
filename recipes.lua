function recipes_update()

    back_hov=coll(back_box,mx,my)
    if back_hov and mp then
         mode="brew"
    end
end

function recipes_draw()

    -- Draw back button.
    spr(3,back_box.x,back_box.y)
    if back_hov then 
        draw_box_outline(back_box)
    end
end