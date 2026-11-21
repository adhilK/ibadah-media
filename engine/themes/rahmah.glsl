// Theme "rahmah" (Qur'an 39:53-54: do not despair of the mercy of Allah; return to your Lord).
// 10 storm: heavy clouds and rain over a dark plain; far away a closed door with a thin seam of light
// 11 parting: the clouds part, soft light breaks through in slanting rays, rain thins out
// order in the reel: 10 hook, 11 verse 53, 13 verse 54, 12 Ibn Kathir, 14 door wide + CTA/end
// 12 foam: a night sea whose white foam crests dissolve into rising gold light ("even if like the foam of the sea")
// 13 return: a path of light leads to the door, its two leaves swing open and light pours out (the door of repentance is wide)
// 14 dawn: open door glowing at the horizon under a clearing dawn sky (end card)
float rain(vec2 p,float tt,float dens,float slant){float a=0.;
 for(int k=0;k<3;k++){float fk=float(k),sc=40.+fk*30.;
  vec2 q=vec2((p.x+p.y*slant)*sc,p.y*sc*.12+tt*(2.2+fk*.6));
  vec2 g=floor(q),f=fract(q);float r=h1(g+fk*3.1);
  a+=r>dens?smoothstep(.06,0.,abs(f.x-.5))*smoothstep(0.,.3,f.y)*smoothstep(1.,.6,f.y)/(1.+fk*.7):0.;}
 return a;}
float clouds(vec2 p,float tt,float open){
 float c=fbm(vec2(p.x*2.2+tt*.04,p.y*3.)+fbm(p*1.3-tt*.02));
 float gap=exp(-pow(p.x*1.6,2.))*open;  // a widening gap above the centre
 return smoothstep(.35+gap*.55,.75+gap*.55,c);}
// door: centre-bottom c, half width w, height h, open 0..1 (leaves swing inward)
vec3 door(vec2 p,vec2 c,float w,float h,float open,float glow){
 vec2 q=p-c;float arch=q.y<h-w?abs(q.x)-w:length(q-vec2(0.,h-w))-w;  // round-topped doorway
 float inside=smoothstep(.002,-.002,arch)*step(0.,q.y);
 float frame=exp(-abs(arch)*400.)*step(-.004,q.y);
 float gapw=w*open;float seam=exp(-abs(q.x)*(900.-850.*open));
 float lit=inside*(open>.01?smoothstep(gapw+.002,gapw-.002,abs(q.x)):0.)+inside*seam*.6;
 vec3 col=vec3(.05,.04,.025)*inside*(1.-lit);
 col+=GOLD*1.5*lit*(1.-.3*q.y/h)+GOLD*.7*frame;
 float r=length((q-vec2(0.,h*.45))*vec2(1.,.7));
 col+=GOLD*glow*(.35*exp(-r*14.)+.12*exp(-r*4.))*(.3+open);
 // light spilling out on the ground in front of the door
 if(q.y<0.)col+=GOLD*.9*open*exp(-abs(q.x)*(18.+q.y*-60.)/(1.-q.y*8.))*exp(q.y*12.);
 return col;}
vec3 plain(vec2 uv,vec2 p,float hz,vec3 sky){if(uv.y>hz)return sky;float y=hz-uv.y;
 return mix(vec3(.04,.09,.07),vec3(.008,.025,.02),smoothstep(0.,.12,y))*(.8+.2*fbm(vec2(p.x*20.,y*60.)));}
vec3 storm(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.10;
 vec3 sky=mix(vec3(.05,.09,.08),vec3(.01,.025,.025),smoothstep(.1,.9,uv.y));
 float cl=clouds(p,T,0.);sky=mix(sky,vec3(.07,.10,.09)*(.6+.5*fbm(p*5.+T*.05)),cl*.85);
 float fl=pow(max(0.,sin(ts*1.7+1.)),40.)*.25;sky+=vec3(.6,.6,.5)*fl*cl*smoothstep(.4,1.,uv.y);
 vec3 c=plain(uv,p,hz,sky);
 c+=door(p,vec2(0.,hz-.002),.03,.09,0.,.6*smoothstep(0.,3.,ts));
 c+=vec3(.55,.65,.6)*rain(p,T,.80,.18)*.22;return c;}
vec3 parting(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.10;
 float op=smoothstep(0.,7.,ts);
 vec3 sky=mix(vec3(.07,.13,.11),vec3(.01,.03,.028),smoothstep(.1,.9,uv.y));
 vec2 lp=p-vec2(0.,1.05);float ang=atan(lp.x,-lp.y);
 float rays=pow(.5+.5*sin(ang*22.+T*.25+fbm(vec2(ang*4.,T*.1))*3.),3.)*exp(-pow(ang*2.2,2.));
 sky+=GOLD*rays*.22*op*smoothstep(.15,.8,uv.y)+GOLD*.35*op*exp(-length(lp)*2.5);
 float cl=clouds(p,T,op);sky=mix(sky,vec3(.06,.10,.09)*(.6+.5*fbm(p*5.+T*.05))+GOLD*.08*op,cl*.85);
 float band=smoothstep(.18,.24,uv.y)*(1.-smoothstep(.37,.43,uv.y));sky*=1.-.3*band;
 vec3 c=plain(uv,p,hz,sky);
 c+=door(p,vec2(0.,hz-.002),.03,.09,0.,.6+.6*op);
 c+=vec3(.55,.65,.6)*rain(p,T,.80+.17*op,.18)*.22*(1.-op*.8);return c;}
vec3 foam(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.46;
 if(uv.y>hz){float y=uv.y-hz;vec3 c=mix(vec3(.06,.12,.10),vec3(.006,.025,.022),smoothstep(0.,.5,y));
  c+=stars(p,80.)*vec3(1.,.95,.85)*.8;
  float md=length(p-vec2(.12,.86));c+=GOLD*1.1*smoothstep(.04,.036,md)+GOLD*.1*exp(-md*7.);return c;}
 float y=hz-uv.y;float pz=1./(y*7.+.12);vec2 sp=vec2(p.x*pz,pz);
 vec3 c=mix(vec3(.03,.10,.09),vec3(.005,.03,.03),smoothstep(0.,.4,y));
 float dis=smoothstep(1.,9.,ts);  // foam turning into light over the line
 float cr=0.;for(int k=0;k<4;k++){float fk=float(k);
  float ph=fract(sp.y*.35-T*.12+fk*.25);
  float crest=exp(-pow((ph-.5)*18.,2.))*smoothstep(.35,.7,fbm(vec2(sp.x*1.5+fk*3.,sp.y*.6-T*.2)));
  cr+=crest;}
 cr*=smoothstep(0.,.05,y);float bub=smoothstep(.55,.9,fbm(sp*vec2(4.,2.)+T*.3))*cr;
 c+=vec3(.85,.9,.85)*(cr*.45+bub*.4)*(1.-dis*.85);
 c+=GOLD*(cr*.35+bub*.5)*dis;
 c+=GOLD*.25*exp(-abs(p.x-.12)*30.)*smoothstep(.3,0.,y)*(.5+.5*n2(vec2(p.x*80.,y*200.-T*3.)));
 // gold motes rising off the dissolving foam into the sky
 float a=0.;for(int k=0;k<2;k++){float fk=float(k),sc=18.+fk*10.;vec2 q=p*sc+vec2(sin(T*.4+fk)*.4,-T*(.5+fk*.2));
  vec2 g=floor(q),f=fract(q)-.5;float r=h1(g+fk*9.);a+=r>.82?smoothstep(.15,0.,length(f))*(.5+.5*sin(T*3.+r*40.)):0.;}
 return c+GOLD*a*dis*.8;}
vec3 back(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.10;
 float op=smoothstep(1.5,9.,ts);
 vec3 sky=mix(vec3(.08,.15,.12),vec3(.006,.03,.026),smoothstep(.15,.9,uv.y));sky+=stars(p,80.)*.5*smoothstep(.5,.9,uv.y);
 sky+=GOLD*.18*op*exp(-length((p-vec2(0.,hz+.06))*vec2(1.,1.6))*3.);
 float band=smoothstep(.18,.24,uv.y)*(1.-smoothstep(.37,.43,uv.y));sky*=1.-.35*band;
 vec3 c=plain(uv,p,hz,sky);
 if(uv.y<hz){float y=hz-uv.y;float pw=.010+y*1.4;  // path of light toward the door, drawing forward
  float path=smoothstep(pw,pw*.6,abs(p.x))*smoothstep(0.,.5,ts*.25-y*2.4+.4);
  c+=GOLD*path*(.30+.25*sin(y*120.-T*4.)*.5)*(.6+.4*op);}
 c+=door(p,vec2(0.,hz-.002),.04,.115,op,1.3);
 c*=1.-.25*band*step(hz,uv.y);return c;}
vec3 dawn(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.10;
 vec3 sky=mix(vec3(.30,.24,.12),vec3(.05,.13,.11),smoothstep(hz,hz+.25,uv.y));sky=mix(sky,vec3(.008,.03,.026),smoothstep(.45,.95,uv.y));
 sky+=GOLD*.25*exp(-length((p-vec2(0.,hz))*vec2(.6,2.))*4.);
 vec3 c=plain(uv,p,hz,sky);
 c+=door(p,vec2(0.,hz-.002),.04,.115,1.,1.1+.15*sin(ts*1.5));return c;}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return storm(uv,ts);if(s==11)return parting(uv,ts);if(s==12)return foam(uv,ts);if(s==13)return back(uv,ts);return dawn(uv,ts);}
