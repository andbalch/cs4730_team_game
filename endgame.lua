function success_update()
    update_bubbles()
    if btnp(5) or md then -- ❎ key
        run()
    end
end

function success_draw()
    draw_bubbles()
    
    print("congratulations!", 34, 40, 11)
    print("you have become", 35, 50, 10)
    print("the potion master", 31, 60, 10)
    print("press    to explore more", 17, 80, 6)
    print("❎", 41, 80, 11)
end


function failure_update()
    update_bubbles()
    if btnp(5) or md then -- ❎ key
        run()
    end
end

function failure_draw()
    draw_bubbles()
    
    print("your reputation is ruined", 16, 40, 8)
    print("no one comes to", 33, 50, 10)
    print("buy your potions", 31, 60, 10)
    print("press    to restart", 25, 80, 6)
    print("❎", 49, 80, 11)
end