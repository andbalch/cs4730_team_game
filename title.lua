-- Initialize bubbles.
bubbles={}
bubble_spd=1
for i=1,100 do
    bubbles[i]={x=rnd(128),y=rnd(128),r=10+rnd(10),c=1+flr(rnd(2)),s=rnd(1)}
end


function title_update()
    -- Update bubbles.
    for b in all(bubbles) do
        b.y=b.y-b.s
        if b.y<-b.r then
            b.y=128+b.r
        end 
    end

    -- Go to game.
    if btnp(5) or md then -- ❎ key
        mode = "brew"
        setup_game()
    end
end


function title_draw()
    for b in all(bubbles) do
        circfill(b.x,b.y,b.r,b.c)
    end

    print("press     to start", 30, 80, 6)
    print("❎", 56, 80, 11)
    print("place", 55, 65, 10)
    spr(192, 31, 30, 8, 4)
end

