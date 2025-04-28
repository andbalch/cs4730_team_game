y_scroll = 128
start = 0

function setup_intro()
    start = t()
end

function intro_draw()
    draw_bubbles()
    print("you have inherited the\nstruggling family potion\nbusiness, and have turned it\ninto the first-of-its-kind\npotion drive-through. but to do\nso, you had to take out a shady\nloan... \n\nwith only 42 gold on-hand, you\nmust quickly and accurately\nconjure potions that satisfy\nyour customers. serving\nincorrect orders will hurt your\nreputation and put you out of\nbusiness...\n\nget cooking! ❎", 3, y_scroll, 7)
    -- print(y_scroll, 116, 122, 12)
end

function intro_update()
    update_bubbles()
    if (y_scroll > 8) then
        y_scroll = y_scroll - (((t() - start) * 10) - (128-y_scroll))
    end
    if (btnp(❎) or mp) then
        setup_game()
        mode = "brew"
    end
end