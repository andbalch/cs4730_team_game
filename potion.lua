poke(0x5F2D, 1) -- Activate mouse.
mx=0 -- Mouse coordinates.
my=0

-- Create simulations.
caul1 = create_sim(0, 32,32,32)
caul2 = create_sim(32,32,32,32)

vials={}
for i=0,7 do
	vials[i]=create_sim(64+i*8,32,8,8)
end

function _update60()
	mx=stat(32)
	my=stat(33)

    update_sim(caul1)
	update_sim(caul2)
	for i=0,7 do
		update_sim(vials[i])
	end
end

function _draw()
	cls(0)

	--for i=0,10 do
	--	if rnd()>0.8 then
	--		x=rnd(64)
	--		y=rnd(64)
	--		rc=12
	--		if(rnd()>0.5) rc=10
	--		if(sim:g(x,y)==0) sim:s(x,y,rc)
	--	end
	--end

	draw_sim(caul1, 16, 64)
	draw_sim(caul2, 72, 64)
	for i=0,7 do
		draw_sim(vials[i],16+i*12,32)
	end
	
	print(stat(7))

	-- Draw mouse.
	ms=1
	if stat(34)==1 then ms=2 end
	spr(ms,mx,my)
end
