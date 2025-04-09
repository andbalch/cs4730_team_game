
mx=64
my=64
sand=true

prev_b5 = false

px=10



function _init()
	
end
function _update60()
	if(btn(0))then mx-=1 end
	if(btn(1))then mx+=1 end
	if(btn(2))then my-=1 end
	if(btn(3))then my+=1 end
    if(not btn(5) and prev_b5)then sand=not sand end
    prev_b5=btn(5)
end

function _draw()
	cls(0)
	
	if(btn(4))then
        c=12
        if(sand)then c=10 end
		circfill(mx,my,8,c)
	end

	for i=0,10 do
		if rnd()>0.8 then
			x=rnd(64)
			y=rnd(64)
			rc=12
			if(rnd()>0.5) rc=10
			if(sget(x,y)==0) sset(x,y,rc)
		end
	end

	r=rnd()>0.5
	
	for x=0,32 do
		for y=32,0,-1 do
			c=sget(x,y)
			if c!=0 and c!=13 then
				if perm(x,y+1,c) then
					move(x,y,x,y+1)
                elseif perm(x-1,y+1,c) then
					move(x,y,x-1,y+1)
				elseif perm(x+1,y+1,c) then
					move(x,y,x+1,y+1)
                elseif c==12 then
					d=1
					if(y%2==0)d=-1
					if perm(x+d,y,c) then
						move(x,y,x+d,y,c)
					elseif perm(x-d,y,c) then
						move(x,y,x-d,y,c)
					end
				end 
			end
		end
	end

	sspr(0,0,32,32,64,80,48,48)
	sspr(0,0,32,32,0,80,48,48)
	print(stat(7))
end

function move(x1,y1,x2,y2)
	c=sget(x2,y2)
	sset(x2,y2,sget(x1,y1))
	sset(x1,y1,c)
end

function perm(x,y,c)
	oc=sget(x,y)
	return oc==0 or (c==10 and oc==12)
end