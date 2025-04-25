tutorial_step = 1
tutorial_string =
    {
        "welcome to the game! ❎",
		"press ❎ or click to continue",
		"if you loose your place...",
		"press 🅾️ to go back a step!",
		"let's begin! ❎",
		"this is your order ❎",
        "these are your ingredients ❎",
		"you can grab one by clicking!",
		"drag it to the cauldron... ❎",
		"...then click and hold to pour!",
		"now, replace the vial",
		"click here to buy ingredients",
		"your cash is displayed here ❎",
		"purchase this ingredient",
		"now, exit the shop",
		"select the new ingredient...",
		"and add it to the cauldron...",
		"you've made a potion! ❎",
		"hover over the potion... ❎",
		"click and hold to collect it",
		"click on customer to serve!",
		"profit is based on purity... ❎",
		"...and speed! ❎",
		"one last thing... ❎",
		"click on your recipies",
		"the potion is here! ❎",
		"it was saved upon discovery ❎",
		"that's all! exit with ❎",
    }

function setup_tutorial()
	-- Game variables.
	gold=42
	holding=nil
	cust=gen_cust()

	-- Vial variables.
	vox=0 -- Vial offset from the mouse.
	voy=0

	-- Recipe book.
	recipe_book={}

	-- Create simulations.
	caul1=create_sim(0, 32,32,32)
	caul2=create_sim(32,32,32,32)

	-- Vials and vial slots.
	vials={}
	slots={}
	for i=0,7 do
		v=create_sim(64+i*8,32,8,16)
		vials[i]=v
		slots[i]={v=i,x=96+(i%2)*12,y=24+flr(i/2)*24,w=v.w,h=v.h}
	end

	-- generate order
	order_i = 6
	pot_timer = t()
end

function tutorial_update()
    if (btnp(❎) or mp) and tutorial_step < #tutorial_string then
        tutorial_step = tutorial_step + 1
    elseif btnp(🅾️) and tutorial_step > 1 then
        tutorial_step = tutorial_step - 1
	elseif btnp(❎) and tutorial_step == #tutorial_string then
		mode = "title"
		tutorial_step = 1
		tutorial_flag = false
    end

	brew_update()
	pot_timer = t()
end

function tutorial_draw()
    brew_draw()

    -- Draw tutorial string
	rectfill(0,119,128,128,2)
    print(tutorial_string[tutorial_step],2,121,7)
end