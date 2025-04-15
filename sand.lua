function create_sim(x,y,w,h)
	local b={}
	for cx=0,w-1 do
		col={}
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
		g=function(s,x,y)
			if (x>=0 and y>=0 and x<s.w and y<s.h) then
				return s.b[x][y]
			else
				return 0
			end
		end,
		s=function(s,x,y,c)
			col=s.b[x]
			if(col~=null) then
				col[y]=c
			end
		end,
		-- Swaps (x1,y2) with (x2,y2).
		sw=function(s,x1,y1,x2,y2)
			c=s:g(x2,y2)
			s:s(x2,y2,s:g(x1,y1))
			s:s(x1,y1,c)
		end,
		-- Checks if (x,y) is permeable by material c.
		p=function(s,x,y,c) 
			oc=s:g(x,y)
			return oc==0 or (c==10 and oc==12)
		end,
		update=function(s)
			
		end
	}
end

function update_sim(s) 
	for x=0,s.w do
		for y=s.h,0,-1 do
			c=s:g(x,y)
			if c~=0 and c~=13 then
				-- Basic falling.
				if s:p(x,y+1,c) then
					s:sw(x,y,x,y+1)
                elseif s:p(x-1,y+1,c) and s:p(x-1,y,c) then
					s:sw(x,y,x-1,y+1)
				elseif s:p(x+1,y+1,c) and s:p(x+1,y,c) then
					s:sw(x,y,x+1,y+1)
				-- Liquid horizontal movement.
                elseif c==12 then
					d=1
					--if y%2==0 then d=-1 end
					if s:p(x+d,y,c) then
						s:sw(x,y,x+d,y,c)
					elseif s:p(x-d,y,c) then
						s:sw(x,y,x-d,y,c)
					end
				end 
			end
		end
	end
end

function draw_sim(s,dx,dy)
	for x=0,s.w do
		for y=0,s.h do
			c=s:g(x,y)
			sset(s.x+x,s.y+y,c)
		end
	end
	sspr(s.x,s.y,s.w,s.h,dx,dy,s.w,s.h)
end