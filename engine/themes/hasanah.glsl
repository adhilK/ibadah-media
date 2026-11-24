const float V=0.; // visual variant: 0 = English, 1 = Malayalam (mirrored, emerald sky, lower hills, different mote timing)
// Theme "hasanah" (the Prophet's most frequent dua: Qur'an 2:201, Sahih al-Bukhari 6389, Tafsir Ibn Kathir).
// order in the reel: 10 hook, 11 hadith (his most frequent dua), 12 Qur'an 2:201 (two goods),
//                    13 good of this world, 14 good of the Hereafter, 15 protection from the Fire, 16 both goods joined (CTA, end card)
// 10 many duas: a night sky above dark hills; countless faint motes of light rise from the land
// 11 one dua: the motes fade back and ONE light brightens and climbs, leaving a gold trail
// 12 two goods: NEW motion "two lights, one thread": a warm light settles on the earth, a second light opens high in the sky,
//    and a thread of gold draws up between them while the verse is read
// 13 this world: the valley at first light: a river catching the dawn, fields, a few warm lit windows on the hillside
// 14 the Hereafter: the sky deepens and a tall arch of light opens above the hills with slow rays and drifting gold
// 15 the Fire kept away: a low ember glow at the edge of the land is pressed down and dimmed by a rising dome of gold light
// 16 joined: dawn over the valley, the earth light and the sky arch both lit and linked by the thread
float band(vec2 uv){return smoothstep(.19,.24,uv.y)*(1.-smoothstep(.40,.46,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.50,.46,V);}
float ridge(float x,float k,float base,float amp){return base+amp*(fbm(vec2(x*k+7.*base,base*13.))-.5)*2.;}
vec3 sky(vec2 uv,vec2 p,float dawn){
 vec3 top=mix(vec3(.005,.022,.02),vec3(.003,.03,.024),V);
 vec3 low=mix(mix(vec3(.09,.15,.10),vec3(.06,.17,.11),V),mix(vec3(.45,.33,.16),vec3(.32,.40,.22),V),dawn);
 vec3 s=mix(low,top,smoothstep(HZ(),HZ()+mix(.25,.55,dawn),uv.y));
 s+=GOLD*(.10+.35*dawn)*exp(-length((p-vec2(mix(.12,.1,V),HZ()))*vec2(.6,2.))*3.);
 s+=stars(p,90.)*vec3(1.,.95,.85)*.55*(1.-dawn)*smoothstep(HZ()+.1,.9,uv.y);
 return s;}
// layered hills; returns colour if uv is on land, else sky
vec3 land(vec2 uv,vec2 p,vec3 s,float dawn,float windows){
 vec3 c=s;
 for(int i=0;i<3;i++){float fi=float(i);
  float h=ridge(p.x,1.2+fi*.9,HZ()-fi*.07,.05-fi*.008);
  if(uv.y<h){
   vec3 g=mix(vec3(.05,.14,.10),vec3(.02,.07,.05),fi/2.);
   g+=GOLD*exp(-(h-uv.y)*70./(1.+fi))*(.35+.45*dawn); // rim light on each ridge
   g*=.85+.15*fbm(p*vec2(9.,30.)+fi);
   if(i==1){ // warm windows of homes on the middle hill
    vec2 q=vec2(p.x*22.,(h-uv.y)*60.);vec2 id=floor(q);vec2 f=fract(q)-.5;
    float on=step(.80,h1(id+3.))*step(1.,id.y)*step(id.y,3.);
    float w=smoothstep(.22,.12,max(abs(f.x),abs(f.y)*1.3))*on;
    g+=vec3(1.,.78,.42)*w*windows*(.7+.3*sin(T*1.3+id.x));
    g+=GOLD*.15*exp(-length(f)*3.)*on*windows;}
   c=g;}
 }
 return c;}
// a river winding toward the viewer, catching the light
vec3 river(vec2 uv,vec2 p,vec3 c,float dawn){float h=HZ()-.15;
 if(uv.y<h){float y=h-uv.y;float cx=.10*sin(y*9.+1.)*(1.+y*2.)+mix(.0,.05,V);
  float w=.012+y*.28;float d=abs(p.x-cx);
  if(d<w){vec3 r=mix(vec3(.05,.16,.13),vec3(.10,.26,.20),1.-d/w);
   r+=GOLD*(.25+.6*dawn)*pow(n2(vec2(p.x*40./(y+.05),y*30.-T*1.2)),3.)*1.6;
   c=mix(c,r,smoothstep(w,w*.8,d));}}
 return c;}
// rising motes (the many duas)
vec3 motes(vec2 p,float amt,float ts){vec3 c=vec3(0.);float asp=R.x/R.y;
 for(int i=0;i<36;i++){float fi=float(i);
  float sp=.025+.03*h1(vec2(fi,2.));
  vec2 m=vec2((h1(vec2(fi,1.))-.5)*asp*1.05,fract(h1(vec2(fi,3.))+(T+V*7.)*sp)*1.1-.05);
  m.x+=.015*sin(T*.7+fi);
  float d=length(p-m);
  c+=GOLD*(smoothstep(.009,.003,d)*1.2+.30*exp(-d*45.))*amt*(.4+.6*h1(vec2(fi,4.)))*smoothstep(1.,.75,m.y);}
 return c;}
vec3 glow(vec2 p,vec2 c,float r,float k){float d=length(p-c);return GOLD*k*(smoothstep(r,r*.5,d)*1.3+.45*exp(-d*18./ (r*40.))+.12*exp(-d*5.));}
// arch of light in the sky (the Hereafter): never a figure, only light
vec3 archLight(vec2 p,vec2 c,float open,float ts){vec2 q=(p-c)/.12;
 float top=.6+.45*sqrt(max(1.-q.x*q.x/.30,0.));
 float body=max(abs(q.x)-.55,0.)+max(q.y-top,0.)+max(-q.y-.9,0.);
 float din=min(min(.55-abs(q.x),top-q.y),q.y+.9);
 float sd=din>0.?-din:body;
 float inside=step(sd,0.);
 float edge=exp(-abs(sd)*22.);
 vec3 c2=GOLD*open*(edge*1.1+inside*(.05+.20*smoothstep(1.,-.9,q.y)*smoothstep(.55,.0,abs(q.x))+.10*fbm(q*3.+vec2(0.,-T*.3))));
 float ang=atan(q.y,q.x);float r=length(q);
 c2+=GOLD*open*.18*exp(-r*.8)*(.5+.5*sin(ang*14.+T*.25))*smoothstep(.6,1.4,r);
 return c2;}
vec3 base(vec2 uv,float dawn,float win){vec2 p=P(uv);vec3 c=sky(uv,p,dawn);c=land(uv,p,c,dawn,win);return river(uv,p,c,dawn);}
float onSky(vec2 uv){vec2 p=P(uv);return step(ridge(p.x,1.2,HZ(),.05),uv.y);}
vec3 many(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.0,.2);c+=motes(p,smoothstep(0.,2.,ts),ts);return c*(1.-.3*band(uv));}
vec3 one(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.05,.2);
 c+=motes(p,1.-smoothstep(0.,2.5,ts)*.8,ts);
 float y=HZ()-.02+.5*smoothstep(.5,6.,ts);vec2 lc=vec2(mix(-.04,.05,V)+.03*sin(ts*.8),y);
 c+=glow(p,lc,.016,1.2);
 float tr=exp(-abs(p.x-lc.x)*120.)*step(uv.y,y)*step(HZ()-.02,uv.y)*smoothstep(HZ()-.02,y,uv.y);
 c+=GOLD*.5*tr*smoothstep(.5,1.5,ts);
 return c*(1.-.3*band(uv));}
vec3 two(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.12,.45);
 vec2 e=vec2(mix(-.12,.12,V),HZ()-.05),h=vec2(mix(.12,-.1,V),.90);
 c+=glow(p,e,.014,smoothstep(0.,1.5,ts));
 c+=glow(p,h,.018,smoothstep(1.,3.,ts));
 // thread drawn upward from the earth light to the sky light
 float k=smoothstep(2.,6.,ts);vec2 ab=h-e;float t=clamp(dot(p-e,ab)/dot(ab,ab),0.,1.);
 vec2 q=e+ab*t;q.x+=.03*sin(t*6.28+T)*(1.-k*.5);
 float d=length(p-q);float drawn=step(t,k);
 c+=GOLD*drawn*(exp(-d*260.)*.9+exp(-d*40.)*.15)*(1.-.6*band(uv));
 c+=GOLD*exp(-length(p-(e+ab*k))*90.)*.8*k*(1.-step(.999,k)); // the travelling spark
 return c*(1.-.3*band(uv));}
vec3 world(vec2 uv,float ts){float dawn=.25+.45*smoothstep(0.,6.,ts);vec3 c=base(uv,dawn,1.);
 vec2 p=P(uv);c+=motes(p,.25,ts)*step(HZ(),uv.y);return c*(1.-.3*band(uv));}
vec3 hereafter(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.08,.5);
 c=mix(c,c*.7,onSky(uv));
 float open=smoothstep(0.,3.5,ts);
 c+=archLight(p,vec2(mix(.0,.02,V),.655),open,ts)*onSky(uv);
 c+=motes(p,.5*open,ts)*onSky(uv);
 return c*(1.-.3*band(uv));}
vec3 shield(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.1,.6);
 float k=smoothstep(.3,5.,ts);
 // ember glow along the bottom edge, pressed down and dimmed
 float fl=fbm(vec2(p.x*4.,uv.y*6.-T*1.6));
 float emb=exp(-uv.y*mix(4.,25.,k))*(.6+.8*fl)*(1.-.8*k);
 c+=vec3(.75,.30,.07)*emb*1.6;
 float hor=exp(-max(uv.y-HZ()+.03,0.)*mix(7.,40.,k))*step(HZ()-.06,uv.y)*(.6+.7*fl)*(1.-.85*k);
 c+=vec3(.70,.28,.06)*hor*onSky(uv);
 // the rising dome of gold light over the land
 float r=mix(.05,.75,k);float d=length((p-vec2(0.,HZ()-.35))*vec2(.75,1.));
 c+=GOLD*(exp(-abs(d-r)*55.)*.55+exp(-abs(d-r)*10.)*.08)*smoothstep(0.,.6,ts)*(1.-.5*band(uv));
 c+=GOLD*.06*step(d,r)*(.5+.5*sin(d*60.-T*2.));
 return c*(1.-.3*band(uv));}
vec3 joined(vec2 uv,float ts){vec2 p=P(uv);float dawn=.45+.35*smoothstep(0.,6.,ts);vec3 c=base(uv,dawn,.9);
 vec2 e=vec2(mix(-.12,.12,V),HZ()-.05),h=vec2(mix(.0,.02,V),.655);
 c+=glow(p,e,.013,.9);
 c+=archLight(p,h,.8,ts)*onSky(uv);
 vec2 ab=h-e;float t=clamp(dot(p-e,ab)/dot(ab,ab),0.,1.);float d=length(p-(e+ab*t));
 c+=GOLD*(exp(-d*260.)*.7)*(1.-.7*band(uv))*smoothstep(.0,.15,t)*smoothstep(1.,.75,t);
 return c*(1.-.3*band(uv));}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return many(uv,ts);if(s==11)return one(uv,ts);if(s==12)return two(uv,ts);
 if(s==13)return world(uv,ts);if(s==14)return hereafter(uv,ts);if(s==15)return shield(uv,ts);return joined(uv,ts);}
