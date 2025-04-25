-- Initialize bubbles.
bubbles={}
bubble_spd=1
for i=1,400 do
    bubbles[i]={x=rnd(128),y=rnd(128),r=4+rnd(16),c=1+flr(rnd(2)),s=0.2+rnd(0.8)}
end

function title_update()
    update_bubbles()

    -- Go to game.
    if btnp(5) or md then -- ❎ key
        music(0)
        setup_game()
        -- TODO: Transition to (skippable) intro first, then go into brew mode
        mode = "brew"
    elseif btnp(🅾️) then
        -- Pressing "O" key goes to tutorial screen
        setup_tutorial()
        mode = "tutorial"
    end
end


function title_draw()
    draw_bubbles()

    print("press     to start", 30, 80, 6)
    print("❎", 56, 80, 11)
    print("place", 55, 65, 10)
    spr(192, 31, 30, 8, 4)

    print("press 🅾️ for tutorial", 24, 88, 6)
end

function update_bubbles()
    for b in all(bubbles) do
        b.y=b.y-b.s
        if b.y<-b.r then
            b.y=128+b.r
        end 
    end
end

function draw_bubbles()
    for b in all(bubbles) do
        circfill(b.x,b.y,b.r,b.c)
    end
end