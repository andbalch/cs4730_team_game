function menu_draw()
    print("My Cool Game", 40, 40, 7)
    print("Press ❎ to Start", 34, 60, 6)
end

function update_menu()
    if btnp(5) then -- ❎ key
        cls()
        mode = "brew"
        setup_game()
        -- Initialize game state
    end
end