function menu_draw()
    print("press     to start", 30, 80, 6)
    print("❎", 56, 80, 11)
    print("place", 55, 65, 1)
    spr(192, 31, 30, 8, 4)
end

function update_menu()
    if btnp(5) then -- ❎ key
        cls()
        mode = "brew"
        setup_game()
        -- Initialize game state
    end
end