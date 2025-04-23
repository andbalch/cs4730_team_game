density={0,10,8,9,4,10,1,12,11,20,20,5,5,99,20,10,10,0,0}

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
	for ry=0,h-1 do 
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
					-- Acid destroys.
					if (c1==11 or c2==11) then
						s:s(x1,y1,6)
						local tc=11
						if s.r>7 then tc=6 end
						s:s(x2,y2,tc)
						discover(c1,c2,6)
						return true
					-- Check if c1 and c2 make a recipe or reaction
					else
						prod=check_recipe(c1, c2)
						if prod~=nil then 
							s:s(x1,y1,prod)
							s:s(x2,y2,prod)
							return true
						end
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
		end
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
				if s.ra[y]<60 then -- If the row is active.
					local c=s:g(x,y)
					if c~=0 and c~=13 and c~=6 then
						-- Random movement for liquid algorithms.
						if c==10 then
							local dx=-1+2*(s.r%2)
							local dy=((x-y-s.r)%2)
							local m=s:try(x,y,x+dx,y+dy)
						elseif c==9 then -- Fenwick tree growth.
							local dissolve=false
							if s:neigh(x,y,12)>=2 then -- Dissolve in water.
								s:s(x,y,12)
								dissolve=true
								discover(9,12,0)
							end
	
							-- Try falling if there is no support.
							local fell=false
							if not dissolve and s:perm(x,y,x,y+1) and s:perm(x,y,x-1,y+1) and s:perm(x,y,x+1,y+1) then
								fell=s:try(x,y,x,y+1)
							end
	
							-- Fenwick tree growing.
							if not fell and s.r>8 then
								local dx=-1+flr(rnd(3))
								if s:perm(x,y,x,y-1) and s:perm(x,y,x+dx,y-1) and s:neigh(x+dx,y-1,9)<=1 then 
									s:s(x+dx,y-1,9)
								end
							end
	
						elseif c==16 then -- Fire.
							-- Convert all non-glass non-steam into more fire.
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
							if not fell and c~=10 and c~=14 then
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
				if s.ra[y]<60 then -- If the row is active.
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
			local c1 = s.b[x][y]
			local c2 = s.b[x+1][y]

			-- handle fire (16)
			if c1==16 then c1=8 +(s.t+x+y)%3 end
			if c2==16 then c2=8 +(s.t+x+1+y)%3 end

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

function mat_to_col(m)
	if m<16 then
		sset(s.x+x,s.y+y,c)
	elseif c==16 then -- Draw fire.
		sset(s.x+x,s.y+y,8+(s.t+x+y)%3)
	end
end

-- Compares cell colors and see if their mixing causes a reaction.
function check_recipe(c1, c2)
	-- caustic dreams
	if cmp(c1, c2, 12, 15) then
		discover(c1,c2,7)
		return 7
	-- fortified runes
	elseif cmp(c1, c2, 15, 14) then
		discover(c1,c2,4)
		return 4
	-- gaseous materia
	elseif cmp(c1, c2, 12, 4) then
		discover(c1,c2,5)
		return 5
	-- dragon's blood
	elseif cmp(c1, c2, 7, 14) then
		discover(c1,c2,6)
		return 8
	-- spesi cola
	elseif cmp(c1, c2, 4, 7) then
		discover(c1,c2,2)
		return 2
	-- sweat of newt
	elseif cmp(c1, c2, 15, 5) then
		discover(c1,c2,3)
		return 3
	-- dew of miasma
	elseif cmp(c1, c2, 7, 5) then
		discover(c1,c2,6)
		return 6
	-- fenwick tree
	elseif cmp(c1, c2, 2, 4) then
		discover(c1,c2,9)
		return 9
	-- holy tears
	elseif cmp(c1, c2, 3, 4) then
		discover(c1,c2,1)
		return 1
	-- liquid algorithms
	elseif cmp(c1, c2, 9, 1) then
		discover(c1,c2,10)
		return 10

	-- TODO: expand to include dangerous reactions. Can indicate these with a global or by returning a val > 15?
	-- Overflow: water (12) + fairy dust (14)
	elseif cmp(c1, c2, 12, 14) then
		-- cauldron is completely filled with fairy dust (or water? whichever)
		return 16
	
		-- Explosion: dragon's blood (8) + spesi cola (2) 
	elseif cmp(c1, c2, 8, 2) then
		-- screen flashes and everything in the cauldron is gone?
		return 17
	
		-- Double time: holy tears (1) + spesi cola (2)
	elseif cmp(c1, c2, 2, 1) then
		-- change time_mod parameter to 2, make sure to change back!
	
		-- Half profit: dew of miasma (6) + gaseous materia (5)
	elseif cmp(c1, c2, 6, 5) then
		-- exactly what it sounds, need some sort of a global profit var to modify
	
	-- invalid recipe -> do nothing
	else
		return nil
	end
end

-- Helper code to check if some combination of c1 and c2 are equal to v1 and v2
function cmp(c1, c2, v1, v2)
	return (c1==v1 and c2==v2) or (c1==v2 and c2==v1)
end

-- overwrites every cell in the current simulation to color c, useful for overflow and explosion effects
function overwrite(s, c)
	for x=0,s.w-1 do
		for y=s.h,0,-1 do
			local cur_c=s:g(x,y)
			if cur_c ~= 13 then
				s:s(x,y,c)
			end 
		end 
	end
end