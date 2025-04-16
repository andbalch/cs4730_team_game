density={0,10,10,10,4,10,10,10,10,10,10,5,5,99,10,10}

function create_sim(x,y,w,h)
	-- Make 2D array.
	local b={}
	for cx=0,w-1 do
		local col={}
		for cy=0,h-1 do
			col[cy]=sget(x+cx,y+cy)
		end
		b[cx]=col
	end
	return {
		x=x,
		y=y,
		w=w,
		h=h,
		b=b,
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
			if(col~=null) then
				col[y]=c
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
		-- Try to move cell (x1,y1) into cell (x2,y2)
		try=function(s,x1,y1,x2,y2)
			local c1,c2=s:g(x1,y1),s:g(x2,y2)	

			if c2~=13 and c1~=c2 then
				-- Acid destroys.
				if (c1==11 or c2==11) and (c1~=0 and c2~=0) then
					s:s(x1,y1,0)
					s:s(x2,y2,0)
					return true
				elseif density[c1+1]>density[c2+1] then -- Check for permeability, and swap if it works.
					s:s(x1,y1,c2)
					s:s(x2,y2,c1)
					return true
				end
			end

			return false
		end
	}
end

function update_sim(s) 
	for x=0,s.w do
		for y=s.h,0,-1 do
			local c=s:g(x,y)
			if c~=0 and c~=13 then
				-- Basic falling.
				local fell=s:try(x,y,x,y+1) or 
					(s:perm(x,y,x+1,y) and s:try(x,y,x+1,y+1)) or 
					(s:perm(x,y,x-1,y) and s:try(x,y,x-1,y+1))

				-- Liquid horizontal movement.
                if not fell and c~=10 then
					local d=1
					if y%2==0 then d=-1 end
					moved=s:try(x,y,x+d,y,c) or s:try(x,y,x-d,y,c)
				end 
			end
		end
	end
end

function draw_sim(s,dx,dy)
	for x=0,s.w do
		for y=0,s.h do
			local c=s:g(x,y)
			sset(s.x+x,s.y+y,c)
		end
	end
	sspr(s.x,s.y,s.w,s.h,dx,dy,s.w,s.h)
end