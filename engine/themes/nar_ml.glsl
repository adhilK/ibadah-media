const float V=1.; // visual variant: 0 = English, 1 = Malayalam (mirrored, emerald night, lower horizon)
// Theme "nar" (Ibrahim and the fire: Qur'an 21:68-70, 37:97).
// No people anywhere: only the plain, the fire, its sparks, and what Allah made of it.
// order in the reel: 10 hook: a great fire built on a dark plain, sparks streaming up, smoke over the stars
//                    11 "burn him": the fire climbs higher, sparks faster, the smoke thickens
//                    12 21:69 "O fire, be coolness and safety": NEW motion "the cooling" - over ~5 s the flames
//                       turn from burning orange to a cool pale emerald, fall low and calm, the rising sparks
//                       slow, stop and drift DOWN like cool dew, the smoke clears and the stars return
//                    13 "and safety": a soft gold ring of safety settles around the cooled fire and holds
//                    14 21:70 + CTA + end card: dawn; the fire is gone, green shoots rise from the ash
float band(vec2 uv){return smoothstep(.17,.22,uv.y)*(1.-smoothstep(.42,.48,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.150,.125,V);}   // horizon / ground line
const float FX=.045;                    // fire centre (mirrored in ML)
vec3 skyc(vec2 p,float y,float heat,float cool,float dawn){
 vec3 top=mix(vec3(.004,.018,.016),vec3(.002,.026,.014),V);
 vec3 low=mix(vec3(.030,.070,.060),vec3(.020,.085,.050),V);
 low=mix(low,vec3(.34,.27,.15)*mix(1.,.85,V)+vec3(0.,.04*V,.02*V),dawn);
 vec3 s=mix(low,top,smoothstep(HZ(),HZ()+mix(.55,.80,dawn),y));
 // hot glow reflected on the smoke over the fire
 float gx=exp(-pow((p.x-FX)*3.2,2.));
 s+=vec3(.55,.22,.05)*heat*(1.-cool)*gx*exp(-(y-HZ())*4.5)*.55;
 // cool emerald afterglow
 s+=mix(vec3(.05,.28,.20),vec3(.04,.32,.16),V)*cool*(1.-dawn)*gx*exp(-(y-HZ())*6.)*.35;
 // smoke: dark drifting fbm, only while it burns
 float sm=fbm(vec2(p.x*3.+.2*T,y*2.6-T*.18));
 float smoke=heat*(1.-cool)*smoothstep(.35,.75,sm)*smoothstep(HZ()+.05,.45,y)*gx*1.2;
 s=mix(s,vec3(.012,.012,.010),clamp(smoke,0.,.75));
 float starOn=(1.-dawn)*clamp(1.-heat*(1.-cool)*.85,0.,1.);
 s+=stars(p,85.)*vec3(1.,.95,.85)*.7*starOn*smoothstep(HZ()+.05,.8,y);
 s+=GOLD*(.05+.45*dawn)*exp(-abs(y-HZ())*12.)*dawn;
 return s;}
// flame field: H = flame height, cool = 0 hot .. 1 cool
vec3 flame(vec2 p,float H,float heat,float cool,float t){
 float x=p.x-FX,y=p.y-HZ();
 if(y<-.012||heat<=0.)return vec3(0.);
 float spd=mix(2.6,.7,cool);
 float yh=clamp(y/H,0.,1.5);
 float n=fbm(vec2(x*11.,y*7.-t*spd));
 float m=fbm(vec2(x*23.+5.,y*15.-t*spd*1.6));
 float xd=x+(n-.5)*.075*yh*mix(1.,.6,cool);           // tongues sway more the higher they go
 float w=mix(.115,.13,cool)*pow(max(1.-yh*.8,0.),.8)+.004;
 float base=1.-abs(xd)/w;
 float tongues=.55+.45*sin(xd*95.+n*7.-t*spd*.8);        // separate licks of flame
 float f=base-yh*(.55+.9*(m-.4))*mix(1.,.6,cool);
 f*=mix(tongues,1.,smoothstep(.0,.35,1.-yh)*.6+cool*.15);
 f=clamp(f,0.,1.)*smoothstep(-.012,.01,y)*(1.-smoothstep(.80,1.05,yh));
 float core=smoothstep(.35,.9,f)*smoothstep(.9,.2,yh);
 vec3 hot=mix(vec3(.45,.09,.01),vec3(.98,.48,.08),smoothstep(0.,.35,f));
 hot=mix(hot,vec3(1.,.80,.38),core);hot=mix(hot,vec3(1.,.93,.72),core*core*.6);
 vec3 cl=mix(mix(vec3(.03,.26,.20),vec3(.02,.30,.13),V),vec3(.50,.92,.74),smoothstep(0.,.5,f));
 cl=mix(cl,vec3(.88,1.,.94),core*.7);
 return mix(hot,cl,cool)*smoothstep(0.,.25,f)*heat*mix(1.6,1.05,cool);}
// sparks rising (hot) or cool motes drifting down
vec3 sparks(vec2 p,float heat,float cool,float t,float rate){
 vec3 c=vec3(0.);if(heat<=0.)return c;
 for(int i=0;i<42;i++){float fi=float(i);float h=h1(vec2(fi,3.1)),g=h1(vec2(fi,8.7));
  float x0=FX+(h-.5)*.16;
  float up=mod(t*(.07+.08*g)*rate+h*7.,1.);         // 0..1 life of a rising spark
  float yUp=HZ()+.04+up*.62;
  float dn=mod(-t*(.018+.02*g)+h*5.,1.);            // slow downward drift
  float yDn=HZ()+.02+dn*.66;
  float y=mix(yUp,yDn,cool);
  float x=x0+.03*sin(t*(1.+g)+fi)*(1.+up*2.*(1.-cool))+mix(0.,.10*(h-.5),cool);
  float d=length(p-vec2(x,y));
  float life=mix((1.-up)*smoothstep(0.,.06,up),.6*smoothstep(0.,.08,dn)*smoothstep(1.,.85,dn),cool);
  vec3 col=mix(mix(vec3(1.,.55,.18),GOLD,g),mix(vec3(.70,1.,.88),vec3(1.,.95,.85),g),cool);
  float sz=mix(.0032,.0042,cool);
  c+=col*life*heat*(1.4*smoothstep(sz,sz*.3,d)+.25*exp(-d*180.));}
 return c;}
vec3 ground(vec2 p,float y,float heat,float cool,float dawn,float ash,float grow){
 float d=HZ()-y;
 vec3 g=mix(vec3(.020,.032,.026),vec3(.012,.040,.024),V)*(1.+dawn*2.2)+.012*(fbm(p*vec2(30.,90.))-.5);
 float lx=exp(-pow((p.x-FX)*4.,2.))*exp(-d*9.);
 g+=vec3(.60,.25,.06)*heat*(1.-cool)*lx*.7;
 g+=mix(vec3(.10,.45,.32),vec3(.08,.48,.25),V)*heat*cool*lx*.45;
 // ash bed where the fire was
 float ab=length((p-vec2(FX,HZ()-.012))*vec2(1.,5.));
 g=mix(g,vec3(.05,.05,.045)+GOLD*.05*dawn,ash*smoothstep(.11,.06,ab));
 // green shoots from the ash (scene 14)
 if(grow>0.){
  for(int i=0;i<40;i++){float fi=float(i);float h=h1(vec2(fi,4.4));
   float bx=FX+(h-.5)*.24;float bh=(.018+.050*h1(vec2(fi,1.9)))*clamp(grow*1.4-h*.5,0.,1.);
   float top=HZ()-.016+bh;float lean=.25*(h1(vec2(fi,6.))-.5);
   float yy=y-(HZ()-.016);
   if(yy>0.&&y<top){float bxx=bx+lean*yy+.002*sin(T*1.5+fi);
    float wdt=.0030*(1.-yy/max(bh,.001))+.0004;
    float on=smoothstep(wdt,wdt*.3,abs(p.x-bxx));
    g=mix(g,mix(vec3(.14,.48,.20),vec3(.42,.78,.32),yy/max(bh,.001))+GOLD*.25*dawn,on);}
  }
 }
 return g;}
vec3 world(vec2 uv,float t,float H,float heat,float cool,float rate,float dawn,float ash,float grow,float ring){
 vec2 p=P(uv);float y=uv.y;vec3 c;
 if(y>HZ())c=skyc(p,y,heat,cool,dawn);else c=ground(p,y,heat,cool,dawn,ash,grow);
 // far low hills
 float hl=HZ()+.012+.018*(fbm(vec2(p.x*3.,5.))-.3);
 if(y>HZ()&&y<hl)c=mix(vec3(.014,.030,.025),vec3(.010,.036,.020),V)*(1.+2.*dawn)+vec3(.35,.14,.03)*heat*(1.-cool)*.25*exp(-pow((p.x-FX)*3.,2.));
 c+=flame(p,H,heat,cool,t);
 // fire glow halo
 float gd=length((p-vec2(FX,HZ()+H*.35))*vec2(1.,1.3));
 c+=mix(vec3(.85,.38,.08),mix(vec3(.25,.75,.55),vec3(.20,.78,.42),V),cool)*heat*exp(-gd*mix(7.,9.,cool))*mix(.42,.25,cool);
 c+=sparks(p,heat,cool,t,rate);
 // ring of safety around the cooled fire
 if(ring>0.){float rr=length((p-vec2(FX,HZ()+.06))*vec2(1.,1.15));float R0=.165;
  float rg=exp(-abs(rr-R0)*mix(220.,160.,.5+.5*sin(T*1.3)));
  float ang=atan(p.y-HZ()-.06,p.x-FX);
  float sh=.65+.35*sin(ang*3.-T*1.6);
  c+=GOLD*ring*rg*sh*.9+GOLD*ring*.05*exp(-rr*6.);}
 return c;}
vec3 fin(vec3 c,vec2 uv){return c*(1.-.38*band(uv));}
// 10 the fire they built
vec3 built(vec2 uv,float ts){float H=.20+.03*smoothstep(0.,3.,ts);return fin(world(uv,T,H,1.,0.,1.,0.,0.,0.,0.),uv);}
// 11 "burn him": it climbs and roars
vec3 roar(vec2 uv,float ts){float k=smoothstep(0.,3.5,ts);return fin(world(uv,T,.23+.06*k,1.+.15*k,0.,1.+.8*k,0.,0.,0.,0.),uv);}
// 12 "O fire, be coolness and safety": the cooling
vec3 cooling(vec2 uv,float ts){float k=smoothstep(.6,5.6,ts);
 float H=mix(.29,.12,k);float heat=mix(1.12,.85,k);
 return fin(world(uv,T,H,heat,k,mix(1.6,.6,k),0.,0.,0.,.35*smoothstep(4.,7.,ts)),uv);}
// 13 "and safety": the ring settles and holds
vec3 safe(vec2 uv,float ts){float r=.35+.65*smoothstep(0.,2.5,ts);return fin(world(uv,T,.12,.85,1.,.6,0.,0.,0.,r),uv);}
// 14 dawn: the fire is gone, green rises from the ash
vec3 dawnAsh(vec2 uv,float ts){float dawn=.30+.55*smoothstep(0.,9.,ts);float out_=1.-smoothstep(0.,2.5,ts);
 return fin(world(uv,T,.10*out_+.001,.85*out_,1.,.6,dawn,1.-out_*.6,smoothstep(.8,9.,ts),.5*out_),uv);}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return built(uv,ts);if(s==11)return roar(uv,ts);if(s==12)return cooling(uv,ts);
 if(s==13)return safe(uv,ts);return dawnAsh(uv,ts);}
