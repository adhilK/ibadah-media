// Theme "mizan" (two words light on the tongue, heavy on the Scale; Qur'an 21:47).
// 10 hook: night sky, a golden balance draws in and tips          11 light: gold motes drifting upward (light on the tongue)
// 12 heavy: gold grains falling and gathering into a glowing heap   13 the Scales of justice: dusk horizon, vast balance in the sky, a glowing mustard seed
// 14 tasbih: a ring of 33 beads lighting one by one (keep saying them)
float seg(vec2 p,vec2 a,vec2 b){vec2 pa=p-a,ba=b-a;float h=clamp(dot(pa,ba)/dot(ba,ba),0.,1.);return length(pa-ba*h);}
float motes(vec2 p,float tt,float dir,float dens){float a=0.;
 for(int k=0;k<3;k++){float fk=float(k),sc=14.+fk*10.;
  vec2 q=p*sc+vec2(sin(tt*.3+fk*2.)*.5,-dir*tt*(.18+fk*.08)*sc*.08);
  vec2 g=floor(q),f=fract(q)-.5;float r=h1(g+fk*7.);vec2 o=vec2(h1(g+1.3),h1(g+2.7))-.5;
  float tw=.6+.4*sin(tt*2.+r*30.);
  a+=r>dens?smoothstep(.16,0.,length(f-o*.6))*tw*(.4+.6*h1(g+5.))/(1.+fk*.5):0.;}
 return a;}
// balance: pivot c, size s, tilt (rad, >0 = left pan lower), on = 0..1 draw-in
vec3 balance(vec2 p,vec2 c,float s,float tilt,float on,float seed){
 vec2 q=(p-c)/s;float d=seg(q,vec2(0.,.12),vec2(0.,-1.));
 d=min(d,seg(q,vec2(-.32,-1.),vec2(.32,-1.)));
 vec2 dr=vec2(cos(tilt),sin(tilt));vec2 L=-dr,Rr=dr;d=min(d,seg(q,L,Rr));
 float pan=1e3,seedG=0.;
 for(int i=0;i<2;i++){vec2 e=i==0?L:Rr;vec2 pc=e+vec2(0.,-.62);
  d=min(d,seg(q,e,pc+vec2(-.26,0.)));d=min(d,seg(q,e,pc+vec2(.26,0.)));
  vec2 b=(q-pc)*vec2(1.,2.4);pan=min(pan,q.y<pc.y+.01?abs(length(b)-.27):abs(length(vec2(abs(b.x)-.27,b.y))));
  if(i==0)seedG=exp(-length(q-(pc+vec2(0.,-.03)))*s*90.)*seed;}
 d=min(d,pan);float pv=length(q);
 float g=smoothstep(.010,.003,d*s)*1.15+.22*exp(-d*s*55.)+smoothstep(.07,.04,pv)*.9+.3*exp(-pv*s*40.);
 return GOLD*g*on+GOLD*1.6*seedG;}
vec3 night(vec2 p,float y){vec3 c=mix(vec3(.05,.12,.10),vec3(.006,.025,.022),smoothstep(0.,.9,y));
 return c+stars(p,80.)*vec3(1.,.95,.85)+stars(p*1.6+2.,120.)*.5;}
vec3 hook(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 vec3 c=night(p,uv.y);c+=vec3(.10,.08,.04)*exp(-pow((uv.y-.14)*7.,2.));
 float on=smoothstep(.2,2.,ts);float tilt=.16*smoothstep(1.2,3.6,ts)+.05*sin(ts*3.)*exp(-max(ts-3.,0.)*1.2)*smoothstep(2.,3.,ts);
 return c+balance(p,vec2(0.,.37),.16,tilt,on,smoothstep(1.,3.,ts));}
vec3 light(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 vec3 c=mix(vec3(.04,.14,.11),vec3(.006,.03,.025),smoothstep(0.,1.,uv.y));
 c+=vec3(.05,.12,.09)*smoothstep(.45,.8,fbm(vec2(p.x*3.+T*.05,p.y*2.-T*.06)));
 float band=smoothstep(.18,.24,uv.y)*(1.-smoothstep(.37,.43,uv.y));
 c+=GOLD*motes(p,T,1.,.80)*(.9-.6*band)*smoothstep(0.,1.5,ts);return c;}
vec3 heavy(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 vec3 c=mix(vec3(.03,.11,.09),vec3(.005,.025,.02),smoothstep(0.,1.,uv.y));
 float band=smoothstep(.18,.24,uv.y)*(1.-smoothstep(.37,.43,uv.y));
 c+=GOLD*motes(p*vec2(1.,.35),T*2.6,-1.,.84)*(1.-.7*band)*smoothstep(0.,1.,ts);
 float hh=.012+.075*smoothstep(0.,5.,ts)*exp(-p.x*p.x*22.)+.006*fbm(vec2(p.x*30.,T*.3));
 float dh=uv.y-hh;
 c=mix(c,vec3(.32,.22,.09)*(.6+.8*fbm(p*60.))+GOLD*.5*exp(dh*30.),smoothstep(.003,-.003,dh));
 c+=GOLD*.5*exp(-abs(dh)*80.)+GOLD*.2*exp(-max(dh,0.)*12.)*smoothstep(0.,6.,ts);return c;}
vec3 scales(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.13;
 if(uv.y<hz){float y=hz-uv.y;vec3 c=mix(vec3(.10,.12,.07),vec3(.01,.03,.025),smoothstep(0.,.1,y));return c+GOLD*.25*exp(-y*60.);}
 float y=uv.y-hz;vec3 c=mix(vec3(.30,.22,.10),vec3(.03,.11,.09),smoothstep(0.,.18,y));c=mix(c,vec3(.006,.025,.022),smoothstep(.18,.7,y));
 c+=stars(p,80.)*smoothstep(.2,.5,y)*.8;
 float band=smoothstep(.18,.24,uv.y)*(1.-smoothstep(.37,.43,uv.y));c*=1.-.35*band;
 float tilt=.10*sin(ts*.5);
 return c+balance(p,vec2(0.,.93),.22,tilt,.75*smoothstep(0.,2.,ts),.9+.3*sin(ts*2.5));}
vec3 tasbih(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 vec3 c=mix(vec3(.04,.13,.10),vec3(.006,.028,.024),smoothstep(0.,1.,uv.y));
 c+=stars(p,70.)*.5*smoothstep(.5,.9,uv.y);
 vec2 q=p-vec2(0.,.56);float rr=.135;float ring=abs(length(q)-rr);c+=GOLD*.18*exp(-ring*400.);
 float lit=ts*3.2;
 for(int i=0;i<33;i++){float fi=float(i);float a=1.5708-fi*6.2832/33.;vec2 b=rr*vec2(cos(a),sin(a));
  float d=length(q-b);float on=smoothstep(fi,fi+.6,lit);float just=exp(-max(lit-fi,0.)*1.2)*on;
  vec3 bead=mix(vec3(.16,.11,.05),GOLD*1.3,on)*(1.+just*.8);
  c=mix(c,bead*(1.-.5*smoothstep(0.,.011,d)),smoothstep(.012,.0095,d));
  c+=GOLD*(.10*on+.5*just)*exp(-d*90.);}
 c+=GOLD*.18*exp(-length(q)*8.)*smoothstep(0.,10.,lit);
 return c;}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return hook(uv,ts);if(s==11)return light(uv,ts);if(s==12)return heavy(uv,ts);if(s==13)return scales(uv,ts);return tasbih(uv,ts);}
