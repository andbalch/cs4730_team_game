


function endday_update()

    earned_gold = ending_gold - starting_gold

    if btnp(5) then
        customers_served = 0
        starting_gold = gold
        mode = "brew"
    end
end

function endday_draw()
    print("day complete", 37, 20, 6)
    print("gold earned: ", 28, 35, 6)
    print(earned_gold, 87, 35, 10)
    print("press     to continue", 23, 80, 6)
    print("❎", 49, 80, 11)
end