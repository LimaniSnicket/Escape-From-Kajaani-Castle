pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--escape from kajaani castle--
--vera limani 2018--

scene=0
gamerun=true
cam={x=0,y=0}
snow={}
delay=560
start=false
shake=0
function _init()
	palt(0,false)
	palt(11,true)
	music(0)
	for i=0,400 do
		add(snow,{x=rnd(128),
		y=300-rnd(400),col=6})
	end
end

function _update60()
	
	if scene==0 and btnp(❎) then
		start=true
	end
	if start then delay-=1 end
	if delay<0 then scene=1 start=false delay=0 end
	
	if scene==1 then
		charselect()
		if btn(❎) then
			scene=2
			char_chosen=cursorpos
		end
	end
	if scene==2 then
		if gamerun and btnp(🅾️) then
			gamerun=false
			diaindex=ceil(rnd(#lf))
		elseif gamerun==false
		and btnp(🅾️) then
			gamerun=true
		end
		--if gamerun then
			if char_chosen==1 then
				game(p1,t2,equip1)
				weaponmanager(equip1,sword1)
			elseif char_chosen==2 then
				game(p2,t1,equip2)
				weaponmanager(equip2,axe1)
			end
			if not gamerun then
				runupgrades()
				inventorycursor()
			else 
				if char_chosen==1 then
				enemy(t2)
				else enemy(t1) end
				g.timer+=1/2
			end
		
	end

end

function _draw()
	cls()
	rectfill(cam.x,0,cam.x+128,128,2)
	for s in all(snow)do
			pset(s.x+cam.x,s.y,s.col)
			s.y+=1/4
			s.x+=(sin(-1+rnd(1)))/2
			if s.y>=130 then
				s.y=0-rnd(128)
			end
		end
	moon(cam.x+112,9,4)
	if scene==0 then
		drawtitle()
	elseif scene==1 then
		selectdraw()
	elseif scene==2 then
		if char_chosen==1 then
			drawgame(p1,t2,equip1,lf,lc)
			camlerp(p1,8)
		elseif char_chosen==2 then
			drawgame(p2,t1,equip2,jf,jc)
			camlerp(p2,8)
		end
	elseif scene==3 then
		gamewin(cam.x)
	elseif scene==4 then
		music(-1,300)
		flash=false
			if char_chosen==1 then
				gameover(cam.x+10,p1,t2,deadbois[1],deadbois[2],deadbois[3])
			else
				gameover(cam.x+10,p2,t1,deadbois[2],deadbois[1],deadbois[3])
			end
	end
	if flash then
		rectfill(cam.x,0,cam.x+128,128,8)
	end
	--debug()
end

function camlerp(pl,lerp)
	if cam.x<128 and (pl.x>=128 and pl.x<256) then
		cam.x+=lerp
	elseif (cam.x>=128 and cam.x<256)
	and pl.x>=256 then
		cam.x+=lerp
	elseif cam.x>0 and pl.x<128 then
		cam.x-=lerp
	elseif cam.x>128 and pl.x<256 then
		cam.x-=lerp
	end
	camera(cam.x+shake,cam.y+shake)
end


-->8
--player data--
p1={
	x=32,
	y=20,
	dx=0,
	dy=0,
	jump_v=3,
	jt=0,
	fr=true,
	grnd=false,
	atk=false,
	at=0,
	pow=6,
	s=0,
	js=2,
	ws=4,
	as=12,
	ds=212,
	inv=0,
	speed=2,
	hp=20,maxhp=20,
	sx=8,sy=32,wps=15,
	name="joachem",alive=true
}
p2={
	x=36,
	y=20,
	dx=0,
	dy=0,
	jump_v=2.5,
	jt=0,
	fr=true,
	grnd=false,
	atk=false,
	at=0,
	pow=7,
	s=32,
	js=34,
	ws=36,
	as=44,
	ds=196,
	inv=0,
	speed=1.5,
	hp=27,maxhp=27,
	sx=64,sy=32,wps=47,
	name="luukas",alive=true
}
g={
	gravity=0.25,
	timer=0,
	wave=0,
	exp=0,
	to_next=10,
	level=0,
	free=false,
	win=false,
	gameover=false,
	got=0
}

t1={x=333,y=64,s=2,fr=true,
	fatigue=500,frst=-300,mf=500,
	dur=0,pow=1,sx=8,sy=32,dx=0,dy=0,
	hp=3,inv=0,mh=3,alive=true,
	name="joachem"}

t2={x=333,y=64,s=34,fr=true,
	fatigue=600,frst=-300,mf=600,
	dur=0,pow=2,sx=64,sy=32,dx=0,dy=0,
	hp=4,inv=0,mh=4,alive=true,
	name="luukas"}

function jump(p)
	p.dy=-(p.jump_v+mod.jump)
	p.jt+=1 //increment jump counter
end
function cncljump(p)
	p.dy=-p.jump_v
end
function left(p,s)
	p.fr=false
	p.dx=-(s+mod.speed)
end
function right(p,s)
	p.fr=true
	p.dx=(s+mod.speed)
end
function updatepos(p)
	p.x+=p.dx
	p.dy+=g.gravity
	p.y+=p.dy
end
function attack(p)
	p.atk=true
	p.at=-30
end


function collide(p,e)	
	if p.atk then off=18
	else off=8 end
	if p.x<=e.x+off and p.x>=e.x-off then
		if (flr(p.y/8)*8)>=e.y-8
		and (flr(p.y/8)*8)<=e.y+8 then
			return true
		else return false end
	end 
end

//player,hp,attack,speed,
//exp needed,level
function levelup(pl,hp,atk,sp,e,ne,l)
	if g.exp>=e and
	g.exp<ne then
		pl.maxhp=hp
		pl.pow=atk
		pl.speed=sp
		g.level=l
		g.to_next=ne
	end
end

function enemyattack(p,e)
	local o=8
	if e.alive then
	if p.x<=e.x+o and p.x>=e.x-o then
		if (flr(p.y/8)*8)>=e.y-8
		and (flr(p.y/8)*8)<=e.y+8 then
			return true
		end
		else return false end
	end 
end
-->8
--draw methods--

flash=false
invx={19,44,69,94,19,44,69,94}
invy={80,80,80,80,93,93,93,93}
bcost={1,4,2,3,8,3,4,12}
icost={1,1,4,3,3,4,4,8}
fcost={0,0,0,2,3,4,10,12}
fecost={0,0,0,0,0,2,3,5}
function drawtitle()
	map(0,16,0,0,16,16)
	sspr(104,32,18,19,64,101,18,19)
	if not start then
		rectfill(0,57,128,64,13)
		rect(0,56,127,65,1)
		fancyprint(64,122,credit,7,5,true)
		fancyprint(60,58,title,7,5,true)
		fancyprint(63,72,st_str,7,5,true)
	else 
		rectfill(0,30,128,86,13)
		rect(0,30,127,87,1)
		fancyprint(12,32,intro,7,5,false)
	end
end

function selectdraw()
	rectfill(5,69,122,126,13)
	rect(5,69,122,126,1)
	rectfill(9,24,43,56,1)
	rectfill(85,24,119,56,1)
	rect(9,24,43,57,13)
	rect(85,24,119,57,13)
	sspr(p1.sx,p1.sy,32,32,10,25,32,32)
	sspr(p2.sx,p2.sy,32,32,86,25,32,32)
	rectfill(0,3,128,13,13)
	rect(0,3,127,13,1)
	rectfill(45,25,83,57,13)
	
		sp="speed:"
		h="health:"
		atk="power:"
	if cursorpos==1 then
		rect(9,24,43,57,7)
		fancyprint(63,6,name1,7,5,true)
		fancyprint(10,71,des1,7,5,false)
		print(h..p1.maxhp,47,28,7)
		print(atk..p1.pow,47,38,7)
		print(sp..p1.speed,47,48,7)
	else
		rect(85,24,119,57,7)
		fancyprint(64,6,name2,7,5,true)
		fancyprint(10,71,des2,7,5,false)
		print(h..p2.maxhp,47,28,7)
		print(atk..p2.pow,47,38,7)
		print(sp..p2.speed,47,48,7)
	end
	
end

function drawgame(pl,pl2,e,f,c)
	map(0,0,0,0,53,16)
	--drawing breakable walls--
	wall(walls.m1,walls.w1hp,344,72,80,103,119)
	wall(walls.m2,walls.w2hp,352,72,80,103,119)
	wall(walls.m3,walls.w3hp,360,72,80,103,119)
	if pl2.fatigue>0 then
		anim(pl2,pl2.s,10,2,pl2.fr)
	else
		spr(pl2.s,pl2.x,pl2.y+2,2,2,pl2.fr)
	end
	sspr(104,32,18,19,372,101,18,19)
	drawplayer(pl)
	for f in all(wave_zero) do
		drawenemy(f,4,false)
	end
	for h in all(wave_one)do
		drawenemy(h,10,false)
	end
	for c in all(centaur)do
		drawenemy(c,4,true)
	end
	if items!=nil then
		for i in all(items) do
			drawitems(i)
		end
	end
	
	if materials != nil then
		for m in all(materials) do
			drawitems(m)
		end
	end
	if alert then 
		print(centaurwarning,(cam.x+64)-(#centaurwarning*2),30,7)
	end
	if sdiplay then
		print(swarn,(cam.x+64)-(#swarn*2),30,7)
	end
	drawhud(cam.x,cam.y,pl,pl2,e,f,c) 
end

function debug()
	print(t2.inv,cam.x,14,7)
	print(distance,cam.x,7,7)
end
 
 diaindex=0
function drawhud(x,y,pl,tm,e,f,c)
	if mod.speed>0 then
		boost=" +boost!"
	else boost="" end

	if gamerun then
		rectfill(x,y,x+16,y+16,12)
		rect(x,y,x+16,y+16,1)
		sspr(pl.sx,pl.sy,32,32,x,y,16,16)
	tx=x+18
	tc=1 
	if pl.hp>5 then
		tc=12
		bl=13
		rectfill(x+17,y+1,x+(19+(pl.maxhp*2)),y+7,1)
	else
		tc=9
		bl=2
		rectfill(x+17,y+1,x+(19+(pl.maxhp*2)),y+7,8)
	end
		for i=0,(pl.hp-1) do
			print("|",tx,y+2,tc)
			tx+=2
		end	
		rectfill(x+16,y+9,x+24,y+16,0)
		sspr(tm.sx,tm.sy,32,32,x+16,y+9,8,8)
		rectfill(x+25,y+13,x+26+(ceil(tm.mf/30)),y+15,0)
		if tm.fatigue>=0 then
			line(x+25,y+14,x+25+(ceil(tm.fatigue/30)),y+14,14)
		end
		rectfill(x+25,y+9,x+27+(ceil(tm.mh*5)),y+11,1)		
		if tm.hp>0 then
			line(x+25,y+10,x+26+(ceil(tm.hp*5)),y+10,12)
		end
		
		print("lvl:"..(g.level+1),x+107,y+1,7)
	
	elseif not (collide(pl,tm)) then
		rectfill(x+10,y+10,x+118,y+108,13)
		rect(x+9,y+9,x+119,y+109,1)
		rect(x+12,y+12,x+116,y+52,1)
		sspr(pl.sx,pl.sy,32,32,x+12,y+12,32,32)
	
		rectfill(x+13,y+45,x+16+(#pl.name*4),y+51,1)
		print(pl.name,x+14,y+46,7)
		
		spr(pl.wps,x+44,y+13)
		print(wwrap(e.weapon_name..":"..e.pow.."-"..e.dur.."<-",16),x+54,y+14,7)
		
		print("♥ health:"..pl.hp.."/"..pl.maxhp,x+46,y+30,7)
		print("◆ power:"..pl.pow.." + "..mod.attack,x+46,y+38,7)		
		print("▤ speed:"..pl.speed..boost,x+46,y+46,7)
		drawslots(x+19,y+80,x+19,y+93,pl.wps)
	
		if char_chosen==1 then
			for i=0,9 do
				namedisplay(pl.wps,i,p1wpn[i+1],i,x+64,62)
			end
		else
			for i=0,9 do
				namedisplay(pl.wps,i,p2wpn[i+1],i,x+64,62)
			end
		end
		
		rect(x+invx[invcursor+1],y+invy[invcursor+1],
		x+15+invx[invcursor+1],y+10+invy[invcursor+1],7)
	else
		rectfill(x+2,y+10,x+125,y+54,13)
		rect(x+2,y+9,x+125,y+55,1)
		rect(x+5,y+12,x+121,y+52,1)
		sspr(tm.sx,tm.sy,32,32,x+5,y+20,32,32)
		rectfill(x+2,y+9,x+3+(#tm.name*4),y+18,1)
		print(tm.name,x+3,y+11,7)
		if tm.fatigue<0 then
		print(wwrap(f[diaindex],20),x+37,y+14,7)
		else
			print(wwrap(c[diaindex],20),x+37,y+14,7)
		end
	end
end

//icon,inventory item,cost,x,y
function printcost(ic,inv,co,x,y)
	local tc=8
	if inv>=co then tc=7
	else tc=8 end
	spr(ic,x,y)
	print(inv.."/"..co,x+9,y+4,tc)
end

function namedisplay(s,lvl,name,this,x,y)
	unknown="?????????"
	if invcursor==this then
		if lvl<=g.level then
			print(name,x-(#name*2),y,7)
			printcost(125,inventory.bones,bcost[invcursor+1],x-52,69)
			printcost(124,inventory.iron,icost[invcursor+1],x-27,69)
			printcost(126,inventory.fangs,fcost[invcursor+1],x,69)
			printcost(127,inventory.fire_essence,fecost[invcursor+1],x+25,69)
		elseif lvl>g.level then
			print(unknown,x-(#unknown*2),y,8) end
	end
end

function drawslots(x,y,x2,y2,s)
	for i=0,7 do
		if i<=3 then
			rectfill(x,y,x+15,y+10,12)
			rect(x,y,x+15,y+10,1)
			spr(s,x+4,y+2)
			x+=25
		elseif i>3 then
			rectfill(x2,y2,x2+15,y2+10,12)
			rect(x2,y2,x2+15,y2+10,1)
			spr(s,x2+4,y2+2)
			x2+=25
		end
	end
end

function drawenemy(p,frames,c)
	if p.alive then
		anim(p,p.ws,frames,2,p.fr,c)
	elseif not p.alive then
		spr(p.ds,p.x,p.y,2,2,p.fr)
	end
end

function drawitems(f)
	spr(f.is,f.x,f.y,1,1)
end



function drawplayer(p)
if p.alive then
	if p.grnd and p.dx==0
	and p.atk==false then
		spr(p.s,p.x,p.y,2,2,p.fr)
	elseif p.grnd and 
	(p.x>0 or p.x<0) and 
	p.atk==false then 
		anim(p,p.ws,8,3,p.fr)
	elseif p.atk then
		spr(p.as,p.x,p.y,3,2,p.fr)
	else
		spr(p.js,p.x,p.y,2,2,p.fr)
	end
else
	spr(p.ds,p.x,p.y+9,2,1,p.fr)
end
end

go="game over"
//team dead, player dead, both dead
function gameover(x,pl,tm,td,pd,bd)
	fancyprint(x+52,8,go,7,5,true)
	if not pl.alive and tm.alive then
		fancyprint(x,20,pd,7,5,false)
	elseif pl.alive and not tm.alive then
		fancyprint(x,20,td,7,5,false)
	else
		fancyprint(x,20,bd,7,5,false)
	end
	fancyprint(x,96,sum,7,5,false)
end

gw="you've escaped!"
function gamewin(x)
	map(0,16,x,0,16,16)
	sspr(104,32,18,19,x+64,101,18,19)
	fancyprint(x+64,8,gw,7,5,true)
	fancyprint(x+14,20,winstr,7,5,false)
	fancyprint(x+14,64,goodsum,7,5,false)
end

--anim method--
function anim(o,sf,nf,sp,fl,c)
  if(not o.a_ct) o.a_ct=0
  if(not o.a_st) o.a_st=0

  o.a_ct+=2

  if(o.a_ct%(60/sp)==0) then
    o.a_st+=2
    if(o.a_st==nf) o.a_st=0
  end

  o.a_fr=sf+o.a_st
  if not c then
  spr(o.a_fr,o.x,o.y,2,2,fl)
  else 
  spr(o.a_fr,o.x,o.y,2,3,fl)
  end
end

function fancyprint(x,y,str,c1,c2,cen)
	if cen then
		print(str,x-(#str*2),y+1,c2)
		print(str,x-(#str*2),y,c1)
	else  
		print(wwrap(str,28),x,y+1,c2)
		print(wwrap(str,28),x,y,c1)
	end
end

--word wrap (string, char width)
function wwrap(s,w)
 retstr = ""
 lines = strspl(s,"\n")
 for i=1,count(lines) do
  linelen=0
  wordso = strspl(lines[i]," ")
  for k=1, count(wordso) do
   wrd=wordso[k]
   if (linelen+#wrd>w)then
    retstr=retstr.."\n"
    linelen=0
   end
   retstr=retstr..wrd.." "
   linelen+=#wrd+1
  end
  retstr=retstr.."\n"
 end
 return retstr
end

function strspl(s,sep)
 ret = {}
 bffr=""
 for i=1, #s do
  if (sub(s,i,i)==sep)then
   add(ret,bffr)
   bffr=""
  else
   bffr = bffr..sub(s,i,i)
  end
 end
 if (bffr!="") add(ret,bffr)
 return ret
end

function moon(x,y,r)
	circfill(x,y,r,6)
	circfill((x-(r/2)),y+1,r/2,5)
end

function wall(m,hp,x,y,s1,s2,s3)
	if hp>0 then
		if hp<(m*(1/3)) then
			s=s3
		elseif hp>(m*(1/3)) and
		hp<(m*(2/3))then
			s=s2
		else s=s1 end
		spr(s,x,y)
		spr(s,x,y-8)
		spr(s,x,y-16)
	end
end
-->8
--game--
stattimer={spt=0,jmpt=0}
mod={speed=0,jump=0,attack=0}
inventory={bones=1,iron=1,
fangs=0,fire_essence=0}
distance=0
free=false
walls={w1hp=30,w2hp=40,w3hp=50,
broke1=false,broke2=false,broke3=false,
m1=30,m2=40,m3=50}
function game(pl,tm,equip)	
--ur fuckin dead kiddo--
	if pl.hp<=0 then pl.alive=false end
	if tm.hp<=0 then tm.alive=false end

--setting stats and timers--
if pl.alive==false or
tm.alive==false then
	g.gameover=true
end

if not g.gameover then
	if pl.hp>pl.maxhp then
		pl.hp=pl.maxhp
	end
	distance=calcdist(pl,tm)

	if stattimer.spt>0 then
		mod.speed=0.5
		stattimer.spt-=1
	else mod.speed=0 end
	if stattimer.jmpt>0 then
		mod.jump=0.7
		stattimer.jmpt-=1
	else mod.jump=0 end

--movement and collision--
	local plstart=pl.x
	pl.inv+=1
	tm.inv+=1
	if gamerun then
	if btn(2,0) and
	pl.grnd and 
	pl.jt==0 then
		jump(pl)
		sfx(7)
	end
	pl.dx=0
	if btn(0,0) then
		left(pl,pl.speed)
	end
	if btn(1,0) then
		right(pl,pl.speed)
	end
	
	updatepos(pl)
	
	pl.at+=1
	if pl.at>0 and
	pl.dx==0 and btn(❎) then
		attack(pl)
		sfx(5)
	elseif pl.at>-10 then 
		pl.atk=false
	end
	end
	
	local plxoff=0
	if pl.dx>0 and 
	pl.atk==false then
		plxoff=12
	elseif pl.dx>0 and 
	pl.atk then
		plxoff=18
	end
	
	local w = mget((pl.x + plxoff)/8,(pl.y+15)/8)

		if (fget(w)==1) then 
			pl.x = plstart
		end
		if not walls.broke1 and
		(fget(w)==2)then
			pl.x = plstart
		end
		if not walls.broke2 and
		(fget(w)==3)then
			pl.x = plstart
		end
		if not walls.broke3 and
		(fget(w)==4)then
			pl.x = plstart
		end

		
	local c1 = mget((pl.x)/8,(pl.y+15)/8)
	local c2 = mget((pl.x+12)/8,(pl.y+15)/8)
	
	if pl.dy>=0 then
		if (fget(c1)==1) or (fget(c2)==1) then
			pl.y = flr((pl.y)/8)*8
			pl.dy=0
			pl.grnd=true
			pl.jt=0 
		end
	else pl.grnd=false end
	if (fget(c1)==129) or (fget(c2)==129) 
	and pl.inv>0 then
		pl.hp-=3
		pl.inv=-100
		pl.y-=10
		pl.x+=10
		flash=true
		shake=2*cos(1/2)
		sfx(17)
	else flash=false 
	shake=0 end
	
	
--enemy collisions--
	
	for f in all(wave_zero) do
		battle(f,pl,equip)
		if enemyattack(tm,f) and
		tm.inv>0 then
			tm.hp-=1
			tm.inv=-100
		end
	end
	for h in all(wave_one) do
		battle(h,pl,equip)
		if enemyattack(tm,h) and
		tm.inv>0 then
			tm.hp-=1
			tm.inv=-100
		end
	end
	for c in all(centaur) do
		battle(c,pl,equip)
		if enemyattack(tm,c) and
		tm.inv>0 then
			tm.hp-=1
			tm.inv=-100
		end
	end
	
--inventory management--
	for i in all(items) do
		if collide(pl,i) then
			del(items,i)
			sfx(4)
			if i.id==1 then
				stattimer.jmpt+=300
				pl.hp+=3
			elseif i.id==2 then
				stattimer.spt+=300
				pl.hp+=5
			elseif i.id==3 then
				pl.hp+=9
			end
		end
	end
	for m in all(materials) do
		if collide(pl,m) then
			del(materials,m)
			sfx(6)
			if m.id==1 then
				inventory.bones+=1
			elseif m.id==2 then
				inventory.iron+=1
			elseif m.id==3 then
				inventory.fangs+=1
			elseif m.id==4 then
				inventory.fire_essence+=1
			end
		end
	end
	
--team mate fatigue & wall break--
	if gamerun then
	tm.fatigue-=1/4
	if tm.fatigue<=tm.frst then
		tm.fatigue=tm.mf
	end
	if tm.fatigue>0 and
	(tm.fatigue%50==0) then
		if distance<80 then
			sfx(16)
		end
		if walls.w1hp>0 then
			walls.w1hp-=tm.pow
		elseif walls.w1hp<=0 and
		walls.w2hp>0 then
			walls.w2hp-=tm.pow
			tm.x=344
		elseif walls.w2hp<=0 and
		walls.w3hp>0 then
			walls.w3hp-=tm.pow
			tm.x=352
		end
	end
	if walls.w1hp<=0 then walls.broke1=true end
	if walls.w2hp<=0 then walls.broke2=true end
	if walls.w3hp<=0 then walls.broke3=true g.free=true end
	end
--leveling up requirements--
	if char_chosen==1 then
		levelup(pl,21,6,2.05,10,20,1)
		levelup(pl,22,7,2.1,20,35,2)
		levelup(pl,23,7,2.15,35,50,3)
		levelup(pl,25,8,2.2,50,70,4)
		levelup(pl,27,8,2.25,70,95,5)
		levelup(pl,28,8,2.3,95,130,6)
		levelup(pl,29,9,2.35,130,190,7)
		levelup(pl,30,10,2.4,190,200,8)
	else
		levelup(pl,28,8,1.55,10,20,1)
		levelup(pl,29,8,1.6,20,35,2)
		levelup(pl,30,9,1.65,35,50,3)
		levelup(pl,31,9,1.7,50,70,4)
		levelup(pl,32,10,1.75,70,95,5)
		levelup(pl,34,10,1.8,95,130,6)
		levelup(pl,36,11,1.85,130,190,7)
		levelup(pl,37,12,1.9,190,200,8)
	end
	
	
	--end conditions--
	if g.free and collide(pl,tm) then
		g.win=true
		scene=3
	end
	else
		g.got+=1
		flash=false
	end
	if g.got>=240 then
		scene=4
		sfx(18)
	end

end

function calcdist(o1,o2)
	xc=(o2.x-o1.x)
	yc=(o2.y-o1.y)
	dist = sqrt(abs((xc*xc)+(yc*yc)))
	return flr(dist) 
end


char_chosen=0
cursorpos=1
function charselect()
	if btnp(➡️) then
		cursorpos=2
	elseif btnp(⬅️) then
		cursorpos=1
	end
end

function battle(f,pl,equip)
	if f.alive then	
			if collide(pl,f) and 
			pl.at==-20 then
				f.health-=(pl.pow+mod.attack)
				sfx(15)
				equip.dur-=1
			elseif collide(pl,f) and
			pl.atk==false
			and pl.inv>0 then
				pl.hp-=1
				pl.inv=-100
				flash=true
				shake=2*cos(1/2)
				sfx(17)
			else flash=false
			shake=0 end
		end
end



-->8
--data--

--title and credits--
title="░escape from kajaani castle░"
st_str="press ❎ to start"
credit="vera limani 2018"
intro="bards across the lands tell the tale of kajaani castle, a former prison infested with demons and the dead...but rich in treasures. many brave souls have entered the dungeon, but none have ever returned..."
--names & description--
name1="❎ joachem van jansen ❎"
name2="❎ luukas mannik ❎"

des1="joachem van jansen is the heir to the van jansen fortune. a pompous prince, joachem often goes out of his way to show off his adventuring skills; this usually lands him and his cousin, luukas, into peril..."
des2="luukas mannik is the only son of countess tarja van jansen and a common man. he grew up alongside his cousin joachem, and often gets dragged into the latter's dangerous stunts--despite his unwillingness..."
--weapons--
sword1={name="plain sword",
pow=0,dur=0}
sword2={name="plain sword but better",
pow=1,dur=5}
sword3={name="bone club",
pow=2,dur=5}
sword4={name="iron rapier",
pow=2,dur=7}
sword5={name="fortified claymore",
pow=3,dur=7}
sword6={name="skeletal saber",
pow=4,dur=6}
sword7={name="flaming broadsword",
pow=5,dur=5}
sword8={name="hellhound's razor",
pow=6,dur=5}
sword9={name="kajaani's firestrike",
pow=9,dur=3}



axe1={name="plain axe",
pow=0,dur=0}
axe2={name="plain axe but better",
pow=1,dur=2}
axe3={name="bone axe",
pow=2,dur=5}
axe4={name="iron greataxe",
pow=2,dur=7}
axe5={name="fortified war axe",
pow=3,dur=7}
axe6={name="skeletal maul",
pow=4,dur=6}
axe7={name="flaming chopper",
pow=5,dur=5}
axe8={name="hellhound's ravager",
pow=6,dur=5}
axe9={name="kajaani's firereaver",
pow=9,dur=3}

p1wpn={ 
"plain sword but better",
"bone club", 
"iron rapier", 
"fortified claymore",
"skeletal saber",
"flaming broadsword",
"hellhound's razor",
"kajaani's firestrike"}
p2wpn={
"plain axe but better",
"bone axe", 
"iron greataxe", 
"fortified war axe",
"skeletal maul",
"flaming chopper",
"hellhound's ravager",
"kajaani's firereaver"}

--warning--
centaurwarning="warning!! enemy approaching!!"
swarn="use x to attack and z to open the menu"
--dialogue linefeed--
//l=tm:fatigue
lf={
"joachem i'm exhausted...but this wall will give soon i know it...hold them off a little longer...",
"this wall is a sturdy bastard...im so tired...but it will give soon enough.",
"fret not cousin, we will escape this hell-hole, i promise you. we must..."
}
//l=tm:chipping
lc={
	"ugh...hgnn...rrrahh joachem i'm busy, focus on keeping the demons away while i break us out",
	"ggggrgggggahh...ugh joachem i swear if we get out of here, this wall won't be the only thing i break...",
	"ugh...joachem, cousin i love you but why do you always get us stuck in shit like this...?"
}
//j=tm:fatigue
jf={
"whoah...ah! luukas! i was just resting a moment...we'll be out of this dungeon shortly!",
"goodness...this wall is tough...but joachem van jansen is tougher! i will not yeild to brick and mortar!",
"by god, kajaani surely lives up to legend...but fear not luukas, no van jansen or kin shall fall here!"
}
//j=tm:chipping
jc={
"hah! yah! hahaha!! this is lightweight cousin i swear! you should leave the wall and the demons to me!",
"luukas! fear not dear cousin! this wall shall break or my name isn't joachem van jansen!", 
"we shall not fall! i swear on our grandfather's name! markus van jansen will not lose his kin!"
}
--game over lines--
deadbois={
//j alive l dead
"overwhelmed with grief and guilt after his cousin's demise on an adventure he forced luukas into, joachem lost his will to fight and succumbed to the demons of kajaani not long after his cousin...",
//j dead l alive
"after joachem fell to the demons, luukas managed to break the wall and escape kajaani...however, he could not leave his cousin and went back to retrieve joachem's body for a proper burial...",
//both dead
"the cousins were never seen again after they entered kajaani castle, adding to the list of adventurers who perished within the towers and leaving the van jansen family devastated"
}
winstr="against all odds, joachem van jansen and his cousin luukas mannik became the first people in ages to emerge from the demon infested kajaani castle alive..."

goodsum="the van jansen cousins live to fight another day and embark on another adventure; much to luukas's dismay"

sum="and so, kajaani castle claims its next victims...will anyone ever return alive?"
-->8
--enemies and items--

zn={
	x=240,
	y=-10,
	dx=0,
	dy=0,
	s=128,
	health=5
}

fs={x=240,y=-10,dx=0,dy=0,s=160,health=6}

cen={
	x=16,
	y=-10,
	ub=192,
	health=10,
	exp=10
}
clb={lb=208}

on={
	x=16,
	y=-10,
	dx=0,
	dy=0,
	s=134,
	health=7
}
materials={}
items={}
mat_spr={125,124,126,127}
potion_sprites={96,112,31,31,31}
wave_zero={}
wave_one={}
wave_two={}
wt=700
wo=400
wz=300
centaur={}
ct=1500
--wave zero= gt<100
--wave one= gt<300
--wave two=gt<500

function enemy(tm)
	
	if g.timer>20 then
		wz-=1
		sdisplay=false
	else sdisplay=true end
	if g.timer>300 then
		wo-=1
	end
	if g.timer>500 then
		wt-=1
	end
	if g.level>=5 then
		ct-=1
	end
	
	if wz<0 then
		addwz()
		wz=300+rnd(200)
	end
	if wo<0 then
		addwo()
		wo=400+rnd(200)
	end
	if wt<0 then
		addwt()
		wt=700+rnd(300)
	end
	if ct<0 then
		ct=1500+rnd(500)
		spawncentaur()
		sfx(18)
	end
	if ct<60 then alert=true else alert=false end
	
	for f in all(wave_zero) do	
		enemymove(f,.2,f.j+rnd(150),tm,15)
		if f.corpse_t>=300 then
			del(wave_zero,f)
			g.exp+=f.exp
			if f.drop<=20 then
				drop(f)
			elseif (f.drop>20 and f.drop<70) then 
				dropmaterial(f,1)
			else 
				dropmaterial(f,2)
			end
		end
	end
	
	for h in all(wave_one)do
		enemymove(h,.3,h.j+rnd(100),tm,15)
		if h.corpse_t>=300 then
			del(wave_one,h)
			g.exp+=h.exp
			if h.drop<=20 then
				drop(h)
			elseif (h.drop>20 and h.drop<70) then 
				dropmaterial(h,3)
			else 
				dropmaterial(h,4)
			end
		end
	end
	
	for c in all(centaur)do
		enemymove(c,.6,c.j+rnd(100),tm,23)
		if c.corpse_t>=300 then
			del(centaur,c)
			g.exp+=c.exp
			if c.drop<=100 then
				drop(c) end
			if (c.drop<50) then 
				dropmaterial(c,2)
			else 
				dropmaterial(c,2)
			end
		end
	end
	
end


function addwz()
	add(wave_zero,{x=(flr(rnd(zn.x))+20),
	y=zn.y,dx=0,dy=0,
	jump_v=3,jt=0,
	j=120,
	ws=128,ds=132,fr=true,
	grnd=false,
	health=5+ceil(g.level/2),
	alive=true,
	corpse_t=0,
	drop=flr(rnd(101)),exp=1})
end

function addwo()
	add(wave_one,{x=on.x+flr(rnd(30)),
	y=on.y,dx=0,dy=0,
	jump_v=3,jt=0,
	j=100,
	ws=134,ds=166,fr=true,
	grnd=false,
	health=7+ceil(g.level*3/4),
	alive=true,
	corpse_t=0,
	drop=flr(rnd(101)),exp=3})
end
function addwt()
add(wave_zero,{x=(flr(rnd(fs.x))+20),
	y=fs.y,dx=0,dy=0,
	jump_v=3,jt=0,
	j=200,
	ws=160,ds=164,fr=true,
	grnd=false,
	health=10+ceil(g.level/2),
	alive=true,
	corpse_t=0,
	drop=flr(rnd(101)),exp=2})
end
function spawncentaur()
	add(centaur,{x=(flr(rnd(cen.x))+20),
	y=cen.y,dx=0,dy=0,
	jump_v=2,jt=0,
	j=300,
	ws=192,ds=198,fr=true,
	grnd=false,
	health=20+ceil(g.level/2),
	alive=true,
	corpse_t=0,
	drop=flr(rnd(101)),exp=10})
end

index=0
function drop(f)
	index=ceil(rnd(#potion_sprites))
	add(items,{x=f.x,y=f.y+7,
	is=potion_sprites[index],id=index})
end 

function dropmaterial(f,num)
	index=ceil(rnd(#mat_spr))
	add(materials,{x=f.x,y=f.y+7,
	is=mat_spr[num],id=num})
end

//obj,movespeed,jump timer
function enemymove(f,sp,j,tm,yoff)
	local d = calcdist(f,tm)
	if f.alive and tm.x>f.x then
			local fstart=f.x
			f.dx=sp
			f.j-=1
			if f.j <=0 then
				jump(f)
				f.j=j
			end
			updatepos(f)
			local fxoff=0
				if f.dx>0 then
					fxoff=18
				end
	
		local w = mget((f.x + fxoff)/8,(f.y+15)/8)
			if fget(w,0) then
				f.x = fstart
			end
		local c1 = mget((f.x)/8,(f.y+yoff)/8)
		local c2 = mget((f.x+12)/8,(f.y+yoff)/8)
	
		if f.dy>=0 then
			if (fget(c1)==1) or (fget(c2)==1) 
			or (fget(c1)==129) or (fget(c2)==129)then
				f.y = flr((f.y)/8)*8
				f.dy=0
				f.grnd=true
				f.jt=0 
			end
		else f.grnd=false end
		
		end
	
	if f.health<=0 then
		f.alive=false
		f.corpse_t+=1
	end 
end
 
-->8
--weapons & upgrading--
equip1={
	pow=sword1.pow,
	dur=sword1.dur,
	weapon_name=sword1.name
	}
equip2={
	pow=axe1.pow,
	dur=axe1.dur,
	weapon_name=axe1.name
}
	
	invcursor=0
	
function weaponmanager(equip,basic)
	if equip.dur<=0 then
		equip.pow=basic.pow
		equip.dur=basic.dur
		equip.weapon_name=basic.name
		mod.attack=0
	else
		mod.attack=equip.pow
	end
end
//bones, iron, fangs, essence,
-- weapon,index,eq,level
function upgrade(nb,ni,nf,ne,wpn,thisindex,equip,lvl)
	local cancraft=false
	
	if (inventory.bones>=nb) and
	(inventory.iron>=ni)and
	(inventory.fangs>=nf)and
	(inventory.fire_essence>=ne)and
	g.level>=lvl then
		cancraft=true
	else
		cancraft=false
	end
	
	if (cancraft and invcursor==thisindex) then
		if btnp(❎) then
			inventory.bones-=nb
			inventory.iron-=ni
			inventory.fangs-=nf
			inventory.fire_essence-=ne
			
			equip.pow=wpn.pow
			equip.dur=wpn.dur
			equip.weapon_name=wpn.name
			sfx(8)
		end
	else
		if btnp(❎)then
			sfx(9)
		end
	end
end

function runupgrades()
	if char_chosen==1 then
		upgrade(1,1,0,0,sword2,0,equip1,0)
		upgrade(4,1,0,0,sword3,1,equip1,1)
		upgrade(2,4,0,0,sword4,2,equip1,2)
		upgrade(3,3,2,0,sword5,3,equip1,3)
		upgrade(8,3,3,0,sword6,4,equip1,4)
		upgrade(3,4,4,2,sword7,5,equip1,5)
		upgrade(4,4,10,3,sword8,6,equip1,6)
		upgrade(12,8,12,5,sword9,7,equip1,7)
		elseif char_chosen==2 then
		upgrade(1,1,0,0,axe2,0,equip2,0)
		upgrade(4,1,0,0,axe3,1,equip2,1)
		upgrade(2,4,0,0,axe4,2,equip2,2)
		upgrade(3,3,2,0,axe5,3,equip2,3)
		upgrade(8,3,3,0,axe6,4,equip2,4)
		upgrade(3,4,4,2,axe7,5,equip2,5)
		upgrade(4,4,10,3,axe8,6,equip2,6)
		upgrade(12,8,12,5,axe9,7,equip2,7)
	end
end

function inventorycursor()
	if invcursor==0 then
		if btnp(➡️) then
			invcursor=1
		elseif btnp(⬇️) then
			invcursor=4
		end
	elseif invcursor==1 then
		if btnp(➡️) then
			invcursor=2
		elseif btnp(⬇️) then
			invcursor=5
		elseif btnp(⬅️) then
			invcursor=0
		end	
	elseif invcursor==2 then
		if btnp(➡️) then
			invcursor=3
		elseif btnp(⬇️) then
			invcursor=6
		elseif btnp(⬅️) then
			invcursor=1
		end	
	elseif invcursor==3 then
		if btnp(⬅️) then
			invcursor=2
		elseif btnp(⬇️) then
			invcursor=7
		end	
	elseif invcursor==4 then
		if btnp(➡️) then
			invcursor=5
		elseif btnp(⬆️) then
			invcursor=0
		end	
	elseif invcursor==5 then
		if btnp(➡️) then
			invcursor=6
		elseif btnp(⬆️) then
			invcursor=1
		elseif btnp(⬅️) then
			invcursor=4
		end	
	elseif invcursor==6 then
		if btnp(➡️) then
			invcursor=7
		elseif btnp(⬆️) then
			invcursor=2
		elseif btnp(⬅️) then
			invcursor=5
		end	
	elseif invcursor==7 then
		if btnp(⬅️) then
			invcursor=6
		elseif btnp(⬆️) then
			invcursor=3
		end	
	end
end

--0,1,2,3
--4,5,6,7
__gfx__
bbbbbbbbb444bbbbbbbbbbbbbbb4bb4bbbbbbbbbb444bbbbbbbbbbb444b4bbbbbbbbb64444bbbbbbbbbbbbb444b4bbbbbbbbbbbbbbb444bbbbbbbbbb76bbbbbb
bbbbbbbb4ff44bbbbbbbbbbbb44444bbbbbbbbbb4ff44bbbbbbbbb4f444bbbbbbbbb64ff44bbbbbbbbbbbb4f444bbbbbbbbbbbbbbb4ff44bbbbbbbbb676bbbbb
bbbbbbbbb4f4fbbbbbbbbbbb4fff4bbbbbbbbbbbb4f4fbbbbbbbbbb4f4f4bbbbbbb6764f4fbbbbbbbbbbbbb4f4f4bbbbbbbbbbbbbbb4f4fbbbbbbbbbb676bb5b
bbbbbbbbbfff4bbbbbbbbbbbb4f4f4bbbbbbbbbbbfff4bbbbbbbbbbfff4bbbbbb5676bfff4bbbbbbbbbbbbbfff4bbbbb76bbbbbbbbbfff4bbbbbbbbbbb67655b
bbbbbbbbbcfcbbbbbb76bbbbbfff4bbbbbbbbbbbbcfcbbbbb76bbbbcfcbbbbbbb456bbcfcccbbbbbbb76bbbcfcbbbbbb676bbbbbbbbcfcbbbbbbbbbbbbb655bb
bbbbbbbc21c11cbbbb676bbbbcfcbbbbbbbbbbbbc1c1ccbbb676bbc1c1ccbbbbbf45bc1c1c111bbbbb676bc1c1ccbbbbb676bbbbbbc1c1cc11bbbbbbbbb554bb
bbbbbb1c02110c1bbbb676bc21c1cc1bbbbbbbbb21111c1bbb676b2111111bbb41bb1211110bb1bbbbb6762111111bbbbb6765bbbb21111cbb1bbbbbbb55bb4b
bbbbbb1b10201b1bbbbb676c12111c11bbbbbbbbb211011bbbb6765211011bbbbb11bb21101bbb1bbbbb67521101b1bbbbb654bbb1b21101bbb1bbbbbbbbbbb4
bbbbbb1bb112bb1bbbbbb65411200bb1bbbbbbbbb120121bbbbb654120121bbbbbbbbbb2212bbb1bbbbbb5f12012b1bbbbb54f111bbb2012bbb1bbbbbbb44bbb
bbbbbb14b2e2f1bbbbbbb54fb1012bb1bbbbb54f1bbef1bbbbbb54fbbe22fbbbbbbbbbbbe22bbbfbbbbbbbbbbe22bfbbbbbbbb4bbbbbbe22bbbfbbbbbb6667bb
bbbb54fbb111bbbbbbbbbbbb12e12bbfbbbbb654bbb100bbbbbbbbb11111bbbbbbbbbbbb111bbbbbbbbbbbbbb111bbbbbbbbbbbbbbbbb100bbbbbbbbbbb67bbb
bbbb654bb1b1bbbbbbbbbbbb11111bbbbbbb6765bb1111bbbbbbbbb1bb100bbbbbbbbbbb1b1bbbbbbbbbbbbbb11bbbbbbbbbbbbbbbbb1111bbbbbbbbbb6676bb
bbb6765bb1b1bbbbbbbbbbbb2bb2bbbbbbb676bbb11111bbbbbbbbb2bb12bbbbbbbbbbb1bb1120bbbbbbbbbbb1120bbbbbbbbbbbbbb11bb1bbbbbbbbb6ccc16b
bb676bbbb1b1bbbbbbbbbbb00b00bbbbbb676bbbb11b011bbbbbbb00bbbbbbbbbbbbbbb1bbbbb0bbbbbbbbbbb1bb0bbbbbbbbbbbbbb1bbb1bbbbbbbb6ccccc16
b676bbbbb2b2bbbbbbbbbbbbbbbbbbbbbb76bbbbbbbbbb2bbbbbbbbbbbbbbbbbbbbbbbb2bbbbbbbbbbbbbbbbb2bbbbbbbbbbbbbbbbb2bbb120bbbbbb6ccc1116
b76bbbbb00b00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbb00bbbbb0bbbbbbb666666b
bbbbbbbbb6666bbbbbb7bbbbbbbbbbbbbbbbbbbbb6666bbbbbbbbbbbb6666bbbbbbbbbbbb6666bbbbbbbbbbbb6666bbbbb7bbbbbbbb6666bbbbbbbbbbbb7bbbb
bbbbbbbb6fff6bbbbb76b6bbb6666bbbbbbbbbbb6fff6bbbbbbbbbbb6fff6bbbbbbbbbbb6fff6bbbbbbbbbbb6fff6bbbb76b6bbbbb6fff6bbbbbbbbbbb76b6bb
bbbbbbbbfdfdfbbbb766b1bb6fff6bbbbbbbbbbbfdfdfbbbbbbbbbbbfdfdfbbbbbbbbbbbfdfdfbbbbbbbbbbbfdfdfbbb766b1bbbbbfdfdfbbbbbbbbbb766b1bb
bbbbbbbbbfff6bbbb76664bbfdfdfbbbbbbbbbbbbfff6bbbbbbbbbbbbfff6bbbbbbbbbbbbfff6bbbbbbbbbbbbfff6bbb76664bbbbbbfff6bbbbbbbbbb76664bb
bbbbbbbbb9f9bbbbb766c4bbbfff6bbbbbbbbbbbb9f9bbbbbbbbbbbbb9f9bbbbbbbbbbbbb9f9bbbbbbbbbbbbb9f9bbbb766c4bbbbbb9f9bbbbbbbbbbb766c4bb
bbbbbbbcacacacbbb76cb9bbb9f9bbbbbbbbbbbcacacacbbbbbbbbbcacacacbbbbbbbbbcacacacbbbbbbbbbcacacacbb76cb9bbbbbccacacccbbbbbbb76cb9bb
bbbbbbcccacacccbbb7cb9bcacacaccbbbbbbbcccacacccbbbbbbbcccacacccbbbbbbbcccacacccbbbbbbbcccacacccbb7cb9bbbbbcacaccbbcbbbbbbb7cb9bb
bbbbbbcbcccccbcbbbb7b4bccacaccccbbbbbbcbcccccbcbb614499f44444f4bbbbbbbcbcccccbcbb614499f44444f4bbb7b4bbbbcbcacacbbbcbbbbbbb7b4bb
bbbbbbcbb9a9bbcbbbbbb4bccccccbbcbbbbbbcbb9a9bbcbbbb6cbbbba99bbbbbbbbbbcbba99bbcbbbb6cbbbb9a9bbbbbbbbfccccbbbccccbbbcbbbbbbbbbbbb
bbbbbbcbb111bcbbbbbbbfccb9a19bbcb614499f44444f4b76666cc71111bbbbb614499f44444f4b76666cc7b111bbbbbbbb4bbbbbbbba99bbbfbbbbbbbbbbbb
b614499f44444f4bbbbbb4bb11111bbfbbb6cbbbb111bbbbb76666711111bbbbbbb6cbbbb111bbbbb766667bb111bbbbbbbb4bbbbbbbb100bbbbbbbbbbbbbbbb
bbb6cbbbb1b1bbbbbbbbb4bb11111bbb76666cc71111bbbbbb7777b1bb144bbb76666cc71bb1bbbbbb7777bbb11bbbbbbbbb4bbbbbbb1111bbbbbbbbbbbbbbbb
76666cc7b1b1bbbbbbbbb4bb4bb4bbbbb76666711111bbbbbbbbbbb4bb14bbbbb766667b1bb1124bbbbbbbbbb1144bbbbbbb4bbbbbb11bb1bbbbbbbbbbbbbbbb
b766667bb1b1bbbbbbbbb4b44b44bbbbbb7777b11b011bbbbbbbbb44bbbbbbbbbb7777bb1bbbbb4bbbbbbbbbb1bb4bbbbbbb4bbbbbb1bbb1bbbbbbbbbbbbbbbb
bb7777bbb4b4bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4bbbbbbbbbbbbbbbbbbbbbbbbbbb4bbbbbbbbbbbbbbbb4bbbbbbbbbbbbbbbbb4bbb144bbbbbbbbbbbbbb
bbbbbbbb44b44bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb44bbbbbbbbbbbbbbbbbbbbbbbbbb44bbbbbbbbbbbbbbb44bbbbbbbbbbbbbbbb44bbbbb4bbbbbbbbbbbbbb
66666d66bbbbbbbbbbb2222b22222bbbbbbbbbbb555555555555555555550555bbbbbbbbbbbbbb5555555bbbbbbbbbbbbbbbbbb6bbb6b6bbbbbbbbbbbbbbbbbb
56d50555bbbbbbbb222222222442222bbbbbbbbb5dd5d5d5d5d5d5dd66660666bbbbbbbbbbb555555566655bbbbbbbbbbbbbbb6dbbbff6bbbbbbbbbbbbbbbbbb
00600000bbbbbbb224222442222442222bbbbbbb5d5d5d5d5d5d5dd500000000bbbbbbbbbb555555666666665bbbbbbbbbbbb6ddbb7666fbbbbbbbbbbbbbbbbb
55055555bbbbbb24424422224444444222bbbbbb55d5d5d5d5d5dd5d55055555bbbbbbbb555556666666666665bbbbbbbbbb676d776266fbfbbbbbbbbbbbbbbb
55055555bbbbb2444422422224224444222bbbbb5ddddddddddddddd55055555bbbbbbbb5555666666666666665bbbbbbbb6d6dd76666dffbbfbbbbbbbbbbbbb
66066666bbbbb44222222222244222444222bbbb555555555555555566066666bbbbbbb555556666666666665665bbbbbb66767dbbbdd6ffffbbbbbbbbbbbbbb
00000000bbbb2422222222442244422444222bbbddd5ddd5dd5ddd5d00000000bbbbbbb55555ffffffff66656565bbbbb6dd6d6dbbb666dffbbbbbbbbbbbbbbb
55550555bbbb4424444292444244442244422bbbdd5dd5ddd55d5dd555550555bbbbbb555599ffffffffff6656565bbb6ddd6dddbbb6666dfbbbbffbbfbbbbbb
05550550bbb242444429924442244442244222bbdddddddddd5ddddd9888a888bbbbbb555999fffffffffff665665bbbddddddddbbb66666666666fffbbbbbbb
01110110bb2442422299f92444224444244422bbdddddddddd5ddddd89a989a9bbbbbb559999ffffffffffff66665bbbddddddddbbb666666666666ffbbbbbbb
01110110bb242229999ff92444422444224422bb555555555555555588889888bbbbbb5599999ffffffffffff6665bbbddddddddbbbd666d6666666bffbbbbbb
01110110bb24422229fff924444224442244222b5555555555555555a889a99abbbbbb5555559fffffff555555665bbbddddddddbbbddd6d6666666bffbbbbbb
00000000bb24422222ffff92444424422444422bdddd5dddd5dddddd9a989888bbbbbb54555559ffff55555556655bbbddddddddbbbdbb6bdddb666bfbfbbbbb
05505550bbb2429222fff922244444442444422bd5ddddddd5dd5dd588888888bbbbbb54444455fff555599996555bbbddddddddbbbdbb6bbddbb66bbbbbbbbb
01101110bbb2494444fff922922444442444422bddddddddd5dddddda9a889a9bbbbb4949444454f95544499965fffbbddddddddbbbdbb6bbbdbbb6bbbbbbbbb
00000000bbbb2971744fff99717224442fff422bddddddddd5dddddd9888a888bbbbb9949717944f99471749965f9fbbddddddddbbbdbb6bbbdbbb6bbbbbbbbb
bbb44bbbbbb24471de4ffffe71d79242ff9ff2bb55555555555555550555b550bbbbb994971de44f99e71d9f965f9fbb6bbbbbbbbbbdbb6bbbdbbb6bbbb44bbb
bb6667bbbbb49499994ffffffffff922f99ff2bb5ddddddddddddddd5151b515bbbbb994999994ff9ffffffff94f9fbbd6bbbbbbbbbdbb6bbbdbbb6bbb5556bb
bbb67bbbbbb99499994ffff9f9fff92ff9ff2bbb5ddddddddddddddd0115b150bbbbb494999994fffff9f9f9ff49fbbb676bbbbbbbb4bb9bbb4bbb9bbbb56bbb
bb6676bbbbb9949994ffff9f9f9fff9ff99f2bbb5ddddddddddddddd0511b510bbbbbb49499994ffffff9f9fff4f5bbbd6d6bbbbbbbbbbbbbbbbbbbbbb5565bb
b682286bbbb4949994fffffffffffffffff2bbbb5ddddddddddddddd5bbbbbb5bbbbbbb449994fffffffffff9455bbbbd66d6bbbbbbbbbbbbbbbbbbbb555555b
68888e86bbb2449994fff4ffffffffff224bbbbb5555555555555555055b5550bbbbbbb544994ffff49ffff9945bbbbbd6d6d6bbbbbbbbbbbbbbbbbb55555555
68e8e8e6bbbb249994444ffffffffff422bbbbbb9888a8889888a888015b1510bbbbbbbb4999944449ffff99f45bbbbbdd6ddd6bbbbbbbbbbbbbbbbb55555555
b666666bbbbbb299999ffffff4fffff424bbbbbb89a989a989a989a950050005bbbbbbbb499999999fffffff42bbbbbbd6ddddd6bbbbbbbbbbbbbbbbb555555b
bbb44bbbbbbbbb499444444449ffff424bbbbbbbdddddddd22222222b505b55bbbbbbbbbb4994444444fffff42bbbbbbbbbbbbbbbbbbbb76bbbbbbbbbbbb8bbb
bb6667bbbbbbbb4999ffffffffffff42bbbbbbbb6d66d6d622222222515bb505bbbbbbbbb49999fffff4fff494bbbbbbbbbb7777bbbbbb77b222222bbbb898bb
bbb67bbbbbbbbbb4999444fffffff492bbbbbbbb64996999222222220015bb50bbbbbbbbb24999444fffff4994bbbbbbbbb77776bbbbb76bb22666bbbb89a88b
bb6676bbbbbbbbb499999fffffff4992bbbbbbbb494994942222222205bbb510bbbbbbbbb2949999fffff49994bbbbbbbb777766bbb776bbbb7666bbb29a7a82
b694496bbbbbbbbb499fffffff4499921111bbbb94944449222222225bbbbbb5bbbbbbbbb499499fffff499994bbbbbbb777766bbbb76bbbbb7766bbb297a882
69999a96bbbbbbbb1499ffff449999991ccc1bbb4949999422222222055b5b50bbbbbbbbb49994444444999f94bbbbbb777766bbbb76bbbbbbb776bbb2899a82
69a9a9a6bbbbbb11124444449999fff11cccc11b4444444922222222005b1510bbbbbbbb499f9999999999ff994bbbbb55556bbb776bbbbbbbbb77bbbb29992b
b666666bbbbb1cc19fffffffffffff11ccccccc1494494942222222250050005bbbbbb4499fffffffffffffff994bbbbbbbbbbbb67bbbbbbbbbbb7bbbbb222bb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb29bbbbbbbbbbbbbbbbbbbbb
bbb76b7776bbbbbbbbbbbb7776bbbbbbbbbbbbbbbbbbbbbbbbbb8bb8bbbbbbbbbbb8bb8bbb29bbbbbbbbbbbbbbbbbbbbbbbbbbbbb2a9bbbbbbbbbbbbbbbbbbbb
bb76bb7067bbbbbbbbbb767067bbbbbbbbbbbbbbbbbbbbbbbbbb82b8bbb9a9abbbb82b8bbb2a9bbbbb8bb8bbb9a9abbbb8bb8bbbb29a9bbbbb8bb8bbbbbbbbbb
b76bbb767bbbbbbbbbb76b767bbbbbbbbbbbbbbbbbbbbbbbbbbb98982bb29888bbb98982bb29a9bbbb82b8bbb29888bbb82b8bbbbb28aabbbb82b8bbb9a9abbb
b76bbbd76bbbbbbbbb76bb676bbbbbbbbbbbbbbbbbbbbbbbbbbb98988bbb2228bbb78788bbb28aabbb98982bbb2228bbb98982bbbbb288bbbb98982bb29888bb
b76bbbbb6bdbbbbbbb76bbbb6bdbbbbbbbbbbbbbbbbbbbbbbbb099988bbbb288bb099988bbbb288bbb78788bbbb288bbb78788bbbbb288bbbb78788bbb22288b
b76bbbd7d7b6bbbbbb76bbd7d7b666bbbbbbbbbbbbbbbbbbbbb2aa9828bbb288bb2aa9828bbb288bb099988bbbb288bb099988b2228888bbb099988bbbbb288b
b222b67b6b7b6bbbbb76bb7b6b7bbb6bbbbbbbbbbbbbbbbbbbbb89a888228888bbb89a888228888bb2aa9828228888bb2aa9828888888bbbb2aa98288228888b
bb7b7bb666bb6bbbbb222b6666bbbbb7bbbbbbbbbbbbbbbbbbbbb2888288288bbbbb2888888888bbbb89a88888888bbbb89a888828888bbbbb89a888888888bb
bb26bbbbdbbb7bbbbbb7b7bbdbbbbbbbbbbbbbd777bbbbbbbbbbb4a88288888bbbbb4a88882888bbbbb2888882888bbbbb28888828888bbbbbb28888882888bb
bbb2bbb767bbbbbbbbb26bb767bbbbbbbbbbbb7607bbbbbbbbbbb44a8888888bbbbb44882828888bbbb4a888828888bbbb4a88822888bbbbbbb4a8888828888b
bbbbbb7d6d7bbbbbbbbb2b7d6d7bbbbbbbbbbb6767b2bb2bbbbbbb4b8b24b28bbbb88888b2428888bbb44882242888bbbbb4a8228888bbbbbbb448822242888b
bbbbbbb6b6bbbbbbbbbbbbb67bbbbbbbbbbbd6bbdb7b22bbbbbbbb488bb4b288bb4844bbbb444888bb44b88244bbb8bbbbb4b844abbbbbbbbb88888b244bbb8b
bbbbbbb7b7bbbbbbbbbbbbbb7dbbbbbbbbb6bdb66b6772bbbbbbbb48bbb4bb28bb4abbbbbbbb4bb8b44b88bbb4bbb8bbbbb4b89bbbbbbbbbb4844bbbbb4bbb8b
bbbbbbb7b7bbbbbbbbbbbbbb76bbbbbbbb6767b7db766bbbbbbbb94abb94bbb8bb9bbbbbbbbb9bb894b88bbbb9bbbabbbb94b8bbbbbbbbbbb4abbbbbbb9bbbab
bbbbbb66b66bbbbbbbbbbbb66bbbbbbbbbbbbbbbbbbbb6bbbbbbbbbbbbbbbba8bbbbbbbbbbbbbbbabba8bbbbbbbbbbbbbbbba8bbbbbbbbbbb9bbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1cccccc100000000000000000000000000000000000000000000000000000000
bbba9baaa9bbbbbbbbbbbbaaa9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1ccccc100000000000000000000000000000000000000000000000000000000
bba9bba09abbbbbbbbbba9a09abbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1ccc1b00000000000000000000000000000000000000000000000000000000
ba9bbba9abbbbbbbbbba9ba9abbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1cc1b00000000000000000000000000000000000000000000000000000000
ba9bbb8a9bbbbbbbbba9bb9a9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1c1bb00000000000000000000000000000000000000000000000000000000
ba9bbbbb9b8bbbbbbba9bbbb9b8bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1c1bbb00000000000000000000000000000000000000000000000000000000
ba9bbb8a8ab9bbbbbba9bb8a8ab999bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb111bbbb00000000000000000000000000000000000000000000000000000000
b888b9ab9bab9bbbbba9bbab9babbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000000000000000000000000000000000000000000000000000000
bbababb999bb9bbbbb888b9999bbbbbabbbbbbbbbbbbbbbbbbbbbbbbbbbba9a90000000000000000000000000000000000000000000000000000000000000000
bb89bbbb8bbbabbbbbbababb8bbbbbbbbbbbbb8aaabbbbbbbb8bb8bbbbb888920000000000000000000000000000000000000000000000000000000000000000
bbb8bbba9abbbbbbbbb89bba9abbbbbbbbbbbba90abbbbbbbb82b8bbbbb8222b0000000000000000000000000000000000000000000000000000000000000000
bbbbbba898abbbbbbbbb8ba898abbbbbbbbbbb9a9ab8bb8bbb98982b222882bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbb9b9bbbbbbbbbbbbb9abbbbbbbbbbb89bb8bab88bbbb989882288882bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbababbbbbbbbbbbbbba8bbbbbbbbb9b8b99b9aa8bbb0999888288888bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbababbbbbbbbbbbbbba9bbbbbbbb9a9aba8ba99bbbb2aa98288828888b0000000000000000000000000000000000000000000000000000000000000000
bbbbbb99b99bbbbbbbbbbbb99bbbbbbbbbbbbbbbbbbbb9bbb9888882224288ab0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb1111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbbb1111bbbbbbbbbbb199911bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb199911bbbbbbbbbb119119bbbbbbbbbbbbcccccbbbbbbbbb1111bbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb119119bbbbbbbbbb199911bbbbbbb66f6ba9ccc11bbbbbb111111bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb199911bbbbbbbbbbb11111bbbbbbb6fdf9ca9c1110bbbbb119119bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbbb11111bbbbbbbb9b2919999bbbbbb6ffffac9c11100bbbb199911bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb2919999bbbbbbb9b92999999bbbbb6fdf9ca9c1b11144bb111111bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb92999999bbbbbbb9992001b9bbbbbb6fbbfbbfbbbbbb4bbb11119bbbbbbbb0000000000000000000000000000000000000000000000000000000000000000
9bb992001b9bbbbbbb9494220b9b0bbbbbbbbbbbbbbbbbbbbbb912099bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
b99494220b9b0bbbbbb949425090bbbbbbbbbbbbbbbbbbbbbbb494290bbbbbbb0000000000000000000000000000000000000000000000000000000000000000
bbb949425090bbbbbb944494650bbbbbbb4bbc1122bbbbbbbb99494949bbbbbb0000000000000000000000000000000000000000000000000000000000000000
bb944494650bbbbbbb4444467650bbbbb4f4bc101211bbbbbb94449944bbb11b0000000000000000000000000000000000000000000000000000000000000000
bb4444467650bbbbbb4444676444411b444fc11101110bbbbb444449444444110000000000000000000000000000000000000000000000000000000000000000
bb4444676444411bbb4446764444441144fffc11211100bbbb444444944444110000000000000000000000000000000000000000000000000000000000000000
bb44467644444411bb244764444444114f4fc11211b11120bb244444444444110000000000000000000000000000000000000000000000000000000000000000
bb24476444444411b224444444444411b44bbfbbfbbbbbb0bb244412244441110000000000000000000000000000000000000000000000000000000000000000
bb222444444444112244bbb222244411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4b222b44411244bbbb222244411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4bb22bb4411b42bbbbb222b4411000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4bbb2bbb4b1bb4bbbbbb22bb441000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4bbb2bbb4b1bbb1bbbbbb22bb41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4bbb2bbb4b1bbbbbbbbbbb2bb41000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb2bb4bbb2bbb4bbbbbbbbbbbbb2bb4b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb4bb1bbb4bbb1bbbbbbbbbbbbb4bb1b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
22622222222222222222222222222262222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222622222222222222222222222222222222222622222222222222222222
22222222222222222222222222222222222222222222222222622222222222222222222222222222222226222222222222222222226222622222222222222222
22222222222222222222222222222226222222222222222222222222222222222222222226222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222622222222222222222222222
22262222222222222222222226222222222222222222222222222222222222222262222222222222222222222222222222222222222226266622222222222222
22622222222222222222222222222222222222222262222222222222222222222222222222222222222222222222222266222222222226666666222222222222
22222222222222222222222222222222222222222222222222222222222222622222222222222222222222222222222222222222222226666666222262222222
22222222222222222222222222222222222222222222222222222222222222222262222222222222222222222222222222222222222265556666622222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222622222222255555666622222222222
22222222222222222222222222222222222222222222222222226222222222222222222222222222222222222222222222222222222255555666622222222222
26222222222226222222262222222222222222222222222222222222222222222222222222222222222222222222222222222222222255555666222222222222
22222222226222222222222222622222622222222222222222222222222222622222222222222222222222222222222222222222222225556666222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222266622222222222222
22222222222222222222622222222222222222222222222262222222222222222222222222222222262222222622222222226222222226222222222222222222
22222222222622222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222226222222222222
22222222055505502222222205550550222222220555055022222222055505502505255222222222055505506222222205550550222222220555055022222222
22222222011101102222222201110110222222220111011022222222011101105152250522222222011101102222222201110110222222220111011022222222
22262222011101102222222201110110222222220111011022222222011101100015225022222222011101102222226201110110222222220111011022222222
22222222011101106222222201110110222222220111011022222262011101100522251022222222011101102222222201110110222222220111011022222222
22222222000000002222222200000000222222220000000022222222000000005222222522222222000000002222222200000000262222220000000022262222
22222222055055506222222205505550222222220550555022222222055055500552525022222222055055502222222205505550222222220550555022222222
22222222011011102222222201101110222222220110111022222222011011100052151026222222011011102222222201101110222222220110111022222222
22222222000000002222222200000000222222220000000022222222000000005005000522222222000000002222222200000000222222220000000022222222
22222222055505500555055005550550222222220555055005550550055505500555055005550550055505502222222205550550055505500555055022222222
26222222011101100111011001110110222222220111011001110110011101100111011001110110011101102262222201110110011101100111011022222222
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022226222
22222222000000000000000000000000222222220000000000000000000000000000000000000000000000002222262200000000000000000000000022222222
22262262055055500550555005505550222222220550555005505550055055500550555005505550055055502222622205505550055055500550555022222222
22222222011011100110111001101110222222220110111001101110011011100110111001101110011011102222262201101110011011100110111022222222
22222222000000000000000000000000222222220000000000000000000000000000000000000000000000002222222200000000000000000000000022222222
22222222055505500555055005550550222222220555055005550550055505500555055005550550055505502222222205550550055505500555055022222222
22222262011101100111011001110110222222620111011001110110011101100111011001110110011101102222222201110110011101100111011026222622
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22262222000000000000000000000000222222220000000000000000000000000000000000000000000000002222222200000000000000000000000022222222
22222222055055500550555005505550222222220550555005505550055055500550555005505550055055502222222205505550055055500550555022222222
22222222011011100110111001101110222222220110111001101110011011100110111001101110011011102222222201101110011011100110111022222222
22222222000000000000000000000000222222220000000000000000000000000000000000000000000000002222222200000000000000000000000022222222
22222222055505500555055005550550222222220555055005550550055505500555055005550550055505502222222205550550055505500555055022222222
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22222222011101100111011001110110222222220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22222222011101100111011001110110222226220111011001110110011101100111011001110110011101102222222201110110011101100111011022222222
22222222000000000000000000000000222222220000000000000000000000000000000000000000000000002222222200000000000000000000000022222222
22222222055055500550555005505550222222220550555005505550055055500550555005505550055055502222262205505550055055500550555022222222
22226222011011100110111001101110222222220110111001101110011011100110111001101110011011102222222201101110011011100110111022222222
22222222000000000000000000000000262222220000000000000000000000000000000000000000000000002222222200000000000000000000000022222222
2222222205550550055505500555055066666d6605550550055505500555055025052552055505500555055066666d6605550550055505500555055022222222
2222222201110110011101100111011056d5055501110110011101100111011051522505011101100111011056d5055501110110011101100111011022222226
22622222011101100111011001110110006000000111011001110110011101100015225001110110011101100060000001110110011101100111011022222222
22222262011101100111011001110110550555550111011001110110011101100522251001110110011101105505555501110110011101100111011022222226
22222226000000000000000000000000550555550000000000000000000000005222222500000000000000005505555500000000000000000000000022222222
22222222055055500550555005505550660666660550555005505550055055500552525005505550055055506606666605505550055055500550555022222222
22222222011011100110111001101110000000000110111001101110011011100052151001101110011011100000000001101110011011100110111022222222
22222222000000000000000000000000555505550000000000000000000000005005000500000000000000005555055500000000000000000000000062222222
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
1dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1
1ddd7ddd7ddd777dd77dd77d777d777d777ddddd777d777dd77d777ddddd7d7d777d777d777d777d77dd777dddddd77d777dd77d777d7ddd777d7ddd7dddddd1
1ddd5d7d5d7d755d755d755d757d757d755ddddd755d757d757d777ddddd7d7d757d575d757d757d757d575ddddd755d757d755d575d7ddd755d5d7d5d7dddd1
1ddd7d5d7d5d77dd777d7ddd777d777d77dddddd77dd775d7d7d757ddddd775d777dd7dd777d777d7d7dd7dddddd7ddd777d777dd7dd7ddd77dd7d5d7d5dddd1
1ddd5d7d5d7d75dd557d7ddd757d755d75dddddd75dd757d7d7d7d7ddddd757d757dd7dd757d757d7d7dd7dddddd7ddd757d557dd7dd7ddd75dd5d7d5d7dddd1
1ddd7d5d7d5d777d775d577d7d7d7ddd777ddddd7ddd7d7d775d7d7ddddd7d7d7d7d77dd7d7d7d7d7d7d777ddddd577d7d7d775dd7dd777d777d7d5d7d5dddd1
1ddd5ddd5ddd555d55ddd55d5d5d5ddd555ddddd5ddd5d5d55dd5d5ddddd5d5d5d5d55dd5d5d5d5d5d5d555dddddd55d5d5d55ddd5dd555d555d5ddd5dddddd1
1dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
67622222011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011022222222
d6d62222011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011022222222
d66d6222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022622222
d6d6d622055055500550555005505550055055500550555005505550055055500550555005505550055055500550555005505550055055500550555022222222
dd6ddd62011011100110111001101110011011100110111001101110011011100110111001101110011011100110111001101110011011100110111022222222
d6ddddd6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
dddddddd055505500555255005550557775777577755775077550550777775500557775077550550775777577757775777550550055505500555055022222222
dddddddd011101105151251501110117571757175517551755110117757577100115751757110117551575175717571575110110011101100111011022222222
dddddddd011101100115215001110117771775177117771777110117775777100111711707110117771171177717751071110110011101100111011022222222
dddddddd011101100511251001110117551757175115571557110117757577100111711707110115571171175717571071110110011101100111011022222222
dddddddd000000005222222500000007000707077707750775000005777775000000700775000007750070070707070070000000000000000000000022222222
dddddddd055055500552555005505555055555555555555555505550555555500550555555505555555055550555555055505550055055500550555022222222
dddddddd011011100152151001101110011011100110111001101110011011100110111001101110011011100110111001101110011011100110111022222222
dddddddd000000005005000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222
dddddddd055505500555055005550550055505500555055005550550055505500555055005552550055505500555055005550550055505500555055022222222
dddddddd011101100111011001110110011101100111011001110110011101100111011051512515011101100111011001110110011101100111011022222222
dddddddd011101100111011001110110011101100111011001110110011101100111011001152150011101100111011001110110011101100111011022222226
dddddddd011101100111011001110110011101100111011001110110011101100111011005112510011101100111011001110110011101100111011022222222
dddddddd000000000000000000000000000000000000000000000000000000000000000052222225000000000000000000000000000000000000000022222222
dddddddd055055500550555005505550055055500550555005505550055055500550555005525550055055500550555005505550055055500550555022222222
dddddddd011011100110111001101110011011100110111001101110011011100110111001521510011011100110111001101110011011100110111022222222
dddddddd000000000000000000000000000000000000000000000000000000000000000050050005000000000000000000000000000000000000000022222222
dddddddd055505500555055005550550055505500555055005550550055505500555055005550550055505500555055005550550055505500555055022222226
dddddddd01110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101102222226d
dddddddd0111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110222226dd
dddddddd01110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101102222676d
dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002226d6dd
dddddddd05505550055055500550555005505550055055500550555005505550055055500550555005505550055055500550555005505550055055502266767d
dddddddd011011100110111001101110011011100110111001101110011011100110111001101110011011100110111001101110011011100110111026dd6d6d
dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006ddd6ddd
dddddddd0555055005550550055505500555055005550550055505500555055005550550055505500555055005550550055505500555055005550550dddddddd
dddddddd0111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110dddddddd
dddddddd0111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110dddddddd
dddddddd0111011001110110011101100111011001110110011101100111011001110110011101100111011001110110011101100111011001110110dddddddd
dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddd
dddddddd0550555005505550055055500550555005505550055055500550555005565650055055500550555005505550055055500550555005505550dddddddd
dddddddd01101110011011100110111001101110011011100110111001101110011ff610011011100110111001101110011011100110111001101110dddddddd
dddddddd00000000000000000000000000000000000000000000000000000000007666f0000000000000000000000000000000000000000000000000dddddddd
66666d6605550550055505500555055005550550055505500555055005550550776266f0f5550550055505500555055005550550055505500555055066666d66
56d505550111011001110110011101100111011001110110011101100111011076666dff01f10110011101100111011001110110011101100111011056d50555
0060000001110110011101100111011001110110011101100111011001110110011dd6ffff110110011101100111011001110110011101100111011000600000
5505555501110110011101100111011001110110011101100111011001110110011666dff1110110011101100111011001110110011101100111011055055555
55055555000000000000000000000000000000000000000000000000000000000006666df0000ff00f0000000000000000000000000000000000000055055555
660666660550555005505550055055500550555005505550055055500550555005566666666666fff55055500550555005505550055055500550555066066666
0000000001101110011011100110111001101110011011100110111001101110011666666666666ff11011100110111001101110011011100110111000000000
5555055500000000000000000000000000000000000000000000000000000000000d666d66666660ff0000000000000000000000000000000000000055550555
5555055555550555055505500555055005550550055505500555055005550550055ddd6d66666660ff5505500555055005550550055505505555055555550555
6666066666660666011101100111011001110110011101100111011001110110011d0160ddd16660f11101100111011001110110011101106666066666660666
0000000000000000011101100111011001110110011101100111011001110110011d01600dd10660011101100111011001110110011101100000000000000000
5505555555055555011101100111011001110110011101100111011001110110011d016001d10160011101100111011001110110011101105505555555055555
5505555555055555000000000000000000000000000000000000000000000000000d006000d00060000000000000000000000000000000005505555555055555
6606666666066666055055500550555005505550055055500550555005505550055d556005d05560055055500550555005505550055055506606666666066666
0000000000000000011011100110111001101110011011100110111001101110011d116001d01160011011100110111001101110011011100000000000000000
55550555555505550000000000000000000000000000000000000000000000000004009000400090000000000000000000000000000000005555055555550555
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
6d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d66d66d6d6
64996999649969996499699964996999747977797779777964997999777977797779779977796999777977797799777964996999649969996499699964996999
49499494494994944949949449499494797975547579757449497494575977747579757457599494557975745749757449499494494994944949949449499494
94944449949444499494444994944449747477497754777994947449979475797774747997944449777474799794777994944449949444499494444994944449
49499994494999944949999449499994777975947579757449497994474979747579797447499994755979744749757449499994494999944949999449499994
44444449444444494444444944444449575477797474747944447779777474797474747977744449777477797774777944444449444444494444444944444449
49449494494494944944949449449494454455545954545449445554555454545954545455549494555455545554555449449494494494944944949449449494

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000201000000000000010000000000000000010000000000008100000000000000000000000000000000000000000000000000000000000100000000000000000000
0000000003040000000000000000000000000000000000000000000000000000000000000304000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000670000000000000000000000000000000000000000000000670000000000773f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6767000067000000000067000067677700000000000000000000000067000000000000505077500000000077675000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050507700003f77505050505050670000000050507700007750505067a4a4a467505050505050505050505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5045464546454645464546454645464545464546454645464546454645464546454645464546454645464550505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5055565556555655565556555655565555565556555655565556555655565556555655565556555655565550505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5045464546454645464546454645464545464546454645464546454645464546454645464546454645464550505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505556555655565556555655565556555556555655565556555655565556555655565556555655565556553f848576767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
504546454645464546454645464546454546454645464546454645464546454645464546454645464546453f848576767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505556555655565556555655565556555556555655565556555655565556555655565556555655565556553f848576767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5045464546454645464546454645464545464546454645464546454645464546454645464546454645404050505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5055565556555655565556555655565555565556555655565556555655565556555655565556555640474750505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5045464546454645464546454645404040404546454645464546454645464546454645464546454047474750505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5055565556555655565556555640474747474056555655565556555655565556555655565556404747474750505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404040404040404040404047474747474740405066665040405065655040404040404040474747474750505076767676000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5047474747474747474747474747474747474747475057575047475057575047474747474747474747474750505075757575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000050500000000050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f503f503f503f50773f503f503f503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f5050503f5050505050503f5050503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f5050503f5050505050503f5050503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f5050503f5050505050503f5050503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f50505040505050775050405050503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f50506777505067505050505050503f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c50505050505050505050505050503f3f3f4c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c50675050505050505050505050503f3f4c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c50505050505050506750505050503f4c5c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c50505050505050505050505050504c5c5c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c50505050505050505050505050505c5c5c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
405050505050505050505050505050405c5c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
474750505050505050505050505047475c5c5c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7575757575757575757575757575757575757500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011a00000b1050415500155021210b141091550b1550915502155021550b15509155011510b1520b1520015502155001550415500155021550b15507155091550b15509155041550015202155041550015202155
011a00000015500000001550000000155000000215500155000000215500155000000215500155041550215500000041550215500000041550215505155021550000005155021550000004155001550415500155
011a00000415507152041550915207155041550000004155000000415500000041550000005155071550b15509155071550515205152021550415500000001550215500152021550015204152021550415202155
011a000006615046000661504600066150361506615066150a615086000a615076000a6150661508615086150161507600016150160001615006150261502615076150060007615006000761505615056150b615
010200002775127752277522d7522d7523b7520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101000011550105500d5500b550095500755006550045502150017500175001b500185001850017500185001550006500115000e5000b5000950008600086000000000000000000000000000000000000000000
010200001b0511b0521b05221052210522f0520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000009050090500905006050020500105001050010500205005050070500b0500f050150501c0502105024050290000000000000000000000000000000001250000000000000000000000000000000000000
010a00002703527000270352c0002703500000240350000027020270202a0202c0220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01040000270451b0451b0450f04500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00002770525705257052e7052c7022772225725257252f7252b7252a72527725257252c725257252572524722247222472526725297252472524722247222d7252f725297252772525725257252c72524725
011a00002672524000267252672524000247252672528725247252672528725240002872528725240002972528725267252400029725287252672524000247252472524000247252872526725287252972524725
011a000025725240002a7222a722240002a725240002a72525725240002c7222c722240002c725240002c72525725240002e7222e7222a72225722240002772525725240002e7252a725240002e7252c7222c725
011a00002a725277252672524722247222772225725257252f7252b7252a72527725257252c725257252572524722247222472526725297252472524722247222d7252f725297252772525725257252c72524725
011a0000257252c7222c7222b7252872526722267222472525725187252a7252a7222c72228725267252572524725187252f7252c7222c7222b725267252472224722257252b725217252d722297222a72525725
010000002b650256501f650126500f65016550165501655012550105500e5500a5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010000001f030190301f0301e0301b0302203022030220301e0301c0301a030220300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0107000017650156530f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000314402142011440314401144001440014200142001400013000120001100000001100011000210001100001000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01404040
00 000a4040
01 020b0340
00 010c0340
00 000d0340
02 020e0341
02 010c4040
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000
00 00000000

