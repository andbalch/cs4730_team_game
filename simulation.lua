density={0,10,8,20,4,20,1,12,11,9,2,5,5,99,20,10,10,50,0}

function create_sim(x,y,w,h)
	-- Make 2D buffer.
	local b={} -- Cell buffer.
	
	for cx=0,w-1 do
		local col={}
		for cy=0,h-1 do
			col[cy]=sget(x+cx,y+cy)
		end
		b[cx]=col
	end

	-- Row changes and activity.
	local rc={} 
	local ra={}
	for ry=-1,h do 
		ra[ry]=0
	end

	return {
		x=x,
		y=y,
		w=w,
		h=h,
		b=b,
		rc=rc,
		ra=ra,
		t=0,
		inactivity=0,
		change=false,
		flipped=false,
		-- Gets cell (x,y).
		g=function(s,x,y)
			if (x>=0 and y>=0 and x<s.w and y<s.h) then
				return s.b[x][y]
			else
				return 0
			end
		end,
		-- Sets cell (x,y).
		s=function(s,x,y,c)
			local col=s.b[x]
			if(col~=nil) then
				col[y]=c
				s.change=true
				s.inactivity=0
				s.rc[y]=true
				s.ra[y]=0
				-- if react_timer < time() then
				-- 	react_timer = time() + 0.01
				-- 	-- Play sound effect if reaction occurs.
				-- 	if c~=0 and c~=13 and c~=6 then
				-- 		sfx(6)
				-- 	end
				-- end
			end
		end,
		-- Swaps (x1,y2) with (x2,y2).
		swap=function(s,x1,y1,x2,y2)
			local c=s:g(x2,y2)
			s:s(x2,y2,s:g(x1,y1))
			s:s(x1,y1,c)
		end,
		-- Checks is (x1,y1) is permeable by (x2,y2).
		perm=function(s,x1,y1,x2,y2)
			return density[s:g(x1,y1)+1]>density[s:g(x2,y2)+1]
		end,
		-- Try to move cell (x1,y1) into cell (x2,y2), checking for valid recipe/reaction
		try=function(s,x1,y1,x2,y2)
			local c1,c2=s:g(x1,y1),s:g(x2,y2)	

			if c2~=13 and c1~=c2 then
				if c1~=0 and c2~=0 and c1~=6 and c2~=6 then
					-- Check if c1 and c2 make a recipe or reaction
					prod=check_recipe(c1, c2, s.r)
					if prod~=nil then 
						s:s(x1,y1,prod)
						s:s(x2,y2,prod)
						return true
					end
				end
				if density[c1+1]>density[c2+1] then -- Check for permeability, and swap if it works.
					s:s(x1,y1,c2)
					s:s(x2,y2,c1)
					return true
				end
			end
			return false
		end,
		neigh=function(s,x,y,c)
			local cnt=0
			for dx=-1,1 do
				for dy=-1,1 do
					if s:g(x+dx,y+dy)==c then cnt=cnt+1 end
				end
			end
			return cnt
		end,
		flip=function(s)
			sfx(16)
			s.flipped=not s.flipped
			
			for x=0,flr((s.w-1)/2) do
				local ox=s.w-1-x
				for y=0,s.h-1 do
					local tmp=s.b[ox][y]
					s.b[ox][y]=s.b[x][y]
					s.b[x][y]=tmp
				end
			end
			for y=0,flr((s.h-1)/2) do
				local oy=s.h-1-y
				for x=0,s.w-1 do	
					local tmp=s.b[x][oy]
					s.b[x][oy]=s.b[x][y]
					s.b[x][y]=tmp
				end
			end

			s.inactivity=0
			for y=-1,s.h do
				s.ra[y]=0
			end
		end,
	}
end

function update_sim(s)
	s.t=s.t+1
	s.change=false
	for y=-1,s.h do 
		s.rc[y]=false
	end

	if s.inactivity<60 then
		for x=0,s.w-1 do
			s.r=flr(rnd(10)) 
			-- Materials that move down.
			for y=s.h-1,0,-1 do
				if s.ra[y]<60 or s.ra[y+1]<60 or s.ra[y-1]<60 then -- If the row is active.
					local c=s:g(x,y)
					if c~=0 and c~=13 and c~=6 and c~=17 then
						-- Random movement for dreamwood spore.
						if c==10 then
							if s.r > 7 then
								local dx=-1+flr(rnd(3))
								local dy=-1+flr(rnd(3))
								local m=s:perm(x,y,x,y+dy) and s:try(x,y,x+dx,y+dy)
							end
						-- Random jumping for miasma.
						elseif c==1 and s.r>5 and y~=0 then
							local dx=-1+flr(rnd(3))
							local dy=-flr(rnd(2))
							local m=s:perm(x,y,x,y+dy) and s:try(x,y,x+dx,y+dy)
						elseif c==3 then -- Fenwick tree.
							local dissolve=false
							if s:neigh(x,y,12)>=2 then -- Dissolve in water.
								s:s(x,y,12)
								dissolve=true
								discover(3,12,0)
							end
	
							-- Try falling if there is no support.
							local fell=false
							if not dissolve and s:perm(x,y,x,y+1) and s:perm(x,y,x-1,y+1) and s:perm(x,y,x+1,y+1) then
								fell=s:try(x,y,x,y+1)
							end
	
							-- Fenwick tree growing.
							if not fell and s.r>8 then
								local dx=-1+flr(rnd(3))
								if s:perm(x,y,x,y-1) and s:perm(x,y,x+dx,y-1) and s:neigh(x+dx,y-1,3)<=1 then 
									s:s(x+dx,y-1,3)
								end
							end
	
						elseif c==16 then -- Magic flame.
							-- Convert all non-glass non-steam into more magic flame.
							local sc=s:neigh(x,y,6)
							for dx=-1,1 do
								for dy=-1,1 do
									local nc=s:g(x+dx,y+dy)	
									if sc==0 and nc~=13 and nc~=6 and nc~=16 then 
										s:s(x+dx,y+dy,16)
										discover(16,nc,16)
									end
								end
							end
	
							-- Randomly dissapear.
							if (s.r+x+y)%2==0 then
								s:s(x,y,6)
							end
	
						-- Basic behaviours.
						else
							-- Basic falling.
							local fell=s:try(x,y,x,y+1)
							if c~=14 then 
								fell=fell or (s:perm(x,y,x+1,y) and s:try(x,y,x+1,y+1)) or 
								(s:perm(x,y,x-1,y) and s:try(x,y,x-1,y+1))
							end
	
							-- Liquid horizontal movement.
							local mov=false
							if not fell and c~=4 and c~=5 and c~=14 then
								local d=1
								if (y+s.r)%2==0 then d=-1 end
								mov=s:try(x,y,x+d,y,c) or s:try(x,y,x-d,y,c)
							end 
						end
					end
				end				
			end
			
			-- Materials that move up.
			local sim_steam=s.t%2==0
			for y=0,s.h-1 do
				if s.ra[y]<60 or s.ra[y+1]<60 or s.ra[y-1]<60 then -- If the row is active.
					local c=s:g(x,y)
					if sim_steam and c==6 then
						local d=-1+((s.r+x+y)%3)
						-- Steam falls up.
						local float=s:try(x,y,x,y-1) or 
						(s:perm(x,y,x+1,y) and s:try(x,y,x+1,y-1)) or 
						(s:perm(x,y,x-1,y) and s:try(x,y,x-1,y-1))
	
						if not float then
							local d=1
							if y%2==0 then d=-1 end
							local m=s:try(x,y,x+d,y,c) or s:try(x,y,x-d,y,c)
						end 
					end
				end
			end
		end
		
		-- Update row activity.
		for y=0,s.h-1 do 
			if not s.rc[y] then
				s.ra[y]=s.ra[y]+1
			end
		end

		-- Update simulation activity.
		if not s.change then
			s.inactivity=s.inactivity+1
		end
	end
end

function draw_sim(s,dx,dy)
	for y=0,s.h-1 do
		for x=0,s.w-1,2 do
			local c1=m2c(x,y,s.b[x][y])
			local c2=m2c(x+1,y,s.b[x+1][y])

			-- Writes to screen.
			local addr=0x6000+flr((x+dx)/2)+(y+dy)*64
			local prev=peek(addr)
			if c1==0 then c1=prev & 0x0f end
			if c2==0 then c2=(prev & 0xf0) >> 4 end
			local byte = (c2<<4) | c1
    		poke(addr, byte)
		end
	end

end

-- Compares cell colors and see if their mixing causes a reaction.
function check_recipe(c1, c2, r)
	-- crimstone = water + dragon's blood
	if cmp(c1,c2,12,8) then
		discover(c1,c2,5)
		return 5
	-- fenwick tree = dragon's blood + fairy dust
	elseif cmp(c1,c2,8,14) then
		discover(c1,c2,3)
		return 3
	-- caustic dreams = fairy dust + sweat of newt 
	elseif cmp(c1,c2,14,9) then
		discover(c1,c2,2)
		return 2
	-- fortified runes = crimstone + sweat of newt 
	elseif cmp(c1,c2,5,9) then
		discover(c1,c2,4)
		return 4
	-- acid = dragon's blood + sweat of newt 
	elseif cmp(c1,c2,9,8) then
		discover(c1,c2,11)
		return 11
	-- dreamroot spore = fenwick tree + caustic dreams 
	elseif cmp(c1,c2,2,3) then
		discover(c1,c2,10)
		return 10
	-- moonlight = acid + fairy dust 
	elseif cmp(c1,c2,11,14) then
		discover(c1,c2,7)
		return 7
	-- wyrmwood oil = fortified runes + moonlight
	elseif cmp(c1,c2,4,7) then
		discover(c1,c2,15)
		return 15
	-- miasma = moonlight + caustic dreams
	elseif cmp(c1,c2,7,2) then
		discover(c1,c2,1)
		return 1
	-- chromacrystal = crimstone + caustic dreams
	elseif cmp(c1,c2,5,2) then
		discover(c1,c2,17)
		return 17
	-- water = chromacrystal + water
	elseif cmp(c1,c2,17,12) then
		discover(c1,c2,12)
		return 12
	-- explosion = water + fairy dust
	elseif cmp(c1, c2, 12, 14) then
		discover(c1,c2,16)
		return 16
	-- acid destroys everything except itself, glass, dragon's blood, sweat of newt, moonlight, and steam
	elseif c1~=c2 and (c1==11 or c2 ==11) and not acid_proof(c1) and not acid_proof(c2) and r>7 then		
		discover(c1,c2,6)
		return 6

	-- Explosion: dragon's blood (8) + spesi cola (2) 
	--elseif cmp(c1, c2, 8, 2) then
		-- screen flashes and everything in the cauldron is gone?
		--return 17
	
	-- Double time: holy tears (1) + spesi cola (2)
	--elseif cmp(c1, c2, 2, 1) then
		-- change time_mod parameter to 2, make sure to change back!
	
	-- Half profit: dew of miasma (6) + gaseous materia (5)
	--elseif cmp(c1, c2, 6, 5) then
		-- exactly what it sounds, need some sort of a global profit var to modify
	
	-- invalid recipe -> do nothing
	else
		return nil
	end
end

-- Returns if a material is acid-proof.
function acid_proof(c) 
	return c==11 or c==9 or c==8 or c==6 or c==7 
end

-- Helper code to check if some combination of c1 and c2 are equal to v1 and v2
function cmp(c1, c2, v1, v2)
	return (c1==v1 and c2==v2) or (c1==v2 and c2==v1)
end

function m2c(x,y,c)
	if c<16 then return c else
		local cs=multicol[c]
		return cs[1+((flr(time()*200)+x+y)%#cs)]
	end
end