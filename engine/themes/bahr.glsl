const float V=0.; // visual variant: 0 = English, 1 = Malayalam (mirrored shore, emerald sky, different sea timing)
// Theme "bahr" (Musa at the sea: Qur'an 26:60-65, Tafsir Ibn Kathir).
// order in the reel: 10 hook, 11 pursued at sunrise (26:60-61), 12 "with me is my Lord" (26:62),
//                    13 the sea parts (26:63), 14 the open path at dawn (Ibn Kathir, 26:65, CTA, end card)
// 10 shore: a dark sea ahead at sunrise, a dust haze rising from the land behind (no people shown)
// 11 trapped: the haze thickens and closes in, the sea grows rough, light dims
// 12 certainty: the sea calms; a single gold light rises over the horizon and steadies
// 13 split: a seam of light runs down the sea, which opens into two towering walls of water with a dry gold path
// 14 path: the parted sea at full dawn, the path glowing to the sunrise
// NEW motion: the "sea split" — a seam of light that tears open into a perspective canyon of water walls
float band(vec2 uv){return smoothstep(.19,.24,uv.y)*(1.-smoothstep(.40,.46,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.53,.56,V);}
vec3 skyc(vec2 uv,vec2 p,float dawn,float dim){float hz=HZ();
 vec3 top=mix(vec3(.006,.025,.022),vec3(.004,.03,.028),V);
 vec3 low=mix(mix(vec3(.30,.20,.09),vec3(.10,.24,.17),V),mix(vec3(.62,.46,.22),vec3(.40,.50,.30),V),dawn);
 vec3 s=mix(low,top,smoothstep(hz,hz+mix(.22,.42,dawn),uv.y));
 vec2 sp=p-vec2(mix(0.,.06,V),hz);
 s+=GOLD*(.35+.6*dawn)*exp(-length(sp*vec2(.55,1.8))*mix(5.,2.8,dawn));
 float sun=smoothstep(.045,.041,length(sp))*step(hz,uv.y);
 s+=mix(GOLD,vec3(1.,.95,.8),.4)*sun*(.8+.6*dawn);
 s+=stars(p,80.)*vec3(1.,.95,.85)*.5*(1.-dawn)*smoothstep(hz+.15,.95,uv.y);
 return s*(1.-.45*dim);}
// sea below the horizon: perspective waves rolling toward the viewer
vec3 seac(vec2 uv,vec2 p,float rough,float dawn,float dim){float hz=HZ();float y=max(hz-uv.y,.0);
 float z=1./(y+.012);
 float w=0.;
 w+=sin(p.x*z*2.2+z*.9-T*mix(1.2,1.5,V)*(1.+rough))*.5+.5;
 w=mix(w,fbm(vec2(p.x*z*1.4,z*.6-T*.5*(1.+rough))),.5+.2*rough);
 vec3 deep=mix(vec3(.01,.045,.04),vec3(.005,.05,.045),V),crest=vec3(.05,.16,.13);
 vec3 c=mix(deep,crest,pow(w,2.)*(.5+rough*.8)*smoothstep(0.,.25,y));
 // sun glitter column
 float col=exp(-abs(p.x-mix(0.,.06,V))*mix(14.,7.,dawn)/(y*3.+.15));
 c+=GOLD*col*(.25+.55*dawn)*pow(n2(vec2(p.x*z*6.,z*3.-T*2.)),3.)*2.2;
 c+=GOLD*.12*dawn*exp(-y*12.);
 return c*(1.-.45*dim);}
// dust haze rising from the land behind the viewer (the pursuers, never shown)
float dust(vec2 uv,vec2 p,float amt,float ts){
 vec2 q=vec2(p.x*2.2+T*.05,uv.y*3.-T*.18);
 float d=fbm(q)*fbm(q*1.7+3.);
 float reach=mix(.12,.42,amt);
 float edge=smoothstep(reach,0.,uv.y-(.05+.25*smoothstep(.2,-.3,p.x))*amt);
 return clamp(d*1.8*edge*amt,0.,1.);}
vec3 addDust(vec3 c,vec2 uv,vec2 p,float amt,float ts){float d=dust(uv,p,amt,ts);
 return mix(c,mix(vec3(.18,.12,.06),vec3(.30,.20,.09),d),d*.75*(1.-.35*band(uv)));}
vec3 base(vec2 uv,float rough,float dawn,float dim){vec2 p=P(uv);
 return uv.y>HZ()?skyc(uv,p,dawn,dim):seac(uv,p,rough,dawn,dim);}
vec3 shore(vec2 uv,float ts){vec2 p=P(uv);vec3 c=base(uv,.35,.15,0.);
 c=addDust(c,uv,p,smoothstep(0.,4.,ts)*.55,ts);return c*(1.-.3*band(uv));}
vec3 trapped(vec2 uv,float ts){vec2 p=P(uv);float k=smoothstep(0.,7.,ts);
 vec3 c=base(uv,.6+.5*k,.15,.25*k);
 c=addDust(c,uv,p,.55+.4*k,ts);return c*(1.-.3*band(uv));}
vec3 certainty(vec2 uv,float ts){vec2 p=P(uv);float k=smoothstep(0.,5.,ts);
 vec3 c=base(uv,mix(1.,.15,k),.2+.15*k,mix(.25,0.,k));
 c=addDust(c,uv,p,mix(.95,.25,k),ts);
 // one gold light rising above the horizon and steadying
 vec2 lc=vec2(mix(-.0,.06,V),HZ()+.05+.16*smoothstep(0.,4.,ts));float d=length(p-lc);
 float pulse=.85+.15*sin(T*3.)*(1.-k);
 c+=GOLD*(smoothstep(.012,.006,d)*1.4+.5*exp(-d*22.)+.15*exp(-d*6.))*pulse*smoothstep(0.,1.2,ts);
 float ang=atan(p.y-lc.y,p.x-lc.x);
 c+=GOLD*.08*k*exp(-d*4.)*(.5+.5*sin(ang*12.+T*.3));
 return c*(1.-.3*band(uv));}
// the parted sea: a perspective canyon between two walls of water
vec3 parted(vec2 uv,float open,float dawn,float ts){vec2 p=P(uv);float hz=HZ();
 vec3 c=uv.y>hz?skyc(uv,p,dawn,0.):seac(uv,p,.2,dawn,0.);
 if(open<=0.001)return c;
 float ax=abs(p.x);
 float y0=max(ax/max(open,.001)-.006,0.)/.62; // depth (below horizon) where the wall stands in this column
 float yb=hz-y0;                              // wall base on screen
 float H=(y0+.02)*2.6*open;                 // wall height (perspective)
 float wpix=(.006+.62*max(hz-uv.y,0.))*open;  // path half-width at this row
 if(uv.y<hz&&ax<wpix){ // the dry path
  float y=hz-uv.y;float z=1./(y+.012);
  vec3 g=mix(vec3(.10,.08,.05),vec3(.04,.035,.025),smoothstep(0.,.4,y));
  g*=.8+.2*fbm(vec2(p.x*z*3.,z*1.5));
  g+=GOLD*(.45+.55*dawn)*exp(-ax/wpix*2.2)*(.5+.5*exp(-y*5.));
  g+=GOLD*.9*exp(-ax*mix(400.,40.,y/.55))*(.4+.6*dawn); // a line of light running to the sunrise
  g+=vec3(.5,.7,.65)*.05*pow(n2(vec2(p.x*z*8.,z*4.)),3.); // wet sand glints
  return g*(1.-.3*band(uv));}
 if(uv.y>=yb&&uv.y<yb+H&&y0<.53){ // wall face
  float h=(uv.y-yb)/H;
  vec3 w=mix(vec3(.02,.09,.08),vec3(.03,.16,.14),h);
  w*=.75+.35*fbm(vec2(ax*60./(y0+.05),uv.y*30./(y0+.05)-T*.4));
  w+=GOLD*.35*exp(-(ax-(.006+.62*y0)*open)*120.)*(1.-h*.5); // light from the path on the inner face
  w+=GOLD*.6*smoothstep(.93,1.,h)*(.5+.5*n2(vec2(ax*200.,T*2.)));  // gold rim at the top
  w+=vec3(.6,.8,.75)*.06*pow(n2(vec2(ax*300.,uv.y*20.-T*3.)),4.)*4.;  // falling streaks
  return w*(1.-.3*band(uv));}
 return c*(1.-.3*band(uv));}
vec3 split(vec2 uv,float ts){vec2 p=P(uv);float hz=HZ();
 float seam=smoothstep(.3,1.5,ts)*(1.-smoothstep(2.2,3.2,ts));
 float open=smoothstep(1.8,5.,ts)*.9;
 vec3 c=parted(uv,open,.35,ts);
 if(uv.y<hz){float y=hz-uv.y;float reach=smoothstep(.3,1.6,ts);
  float s=exp(-abs(p.x)*mix(900.,120.,y/.5))*step(y,reach*.55);
  c+=GOLD*s*seam*1.6;}
 // spray where the walls tear apart
 float sp=exp(-abs(abs(p.x)-(.006+.62*max(hz-uv.y,0.))*open)*60.)*step(uv.y,hz+.25);
 c+=vec3(.75,.9,.85)*.35*sp*smoothstep(1.8,2.4,ts)*(1.-smoothstep(3.2,5.,ts))*smoothstep(.55,.9,fbm(p*40.+vec2(0.,-T*3.)));
 return c;}
vec3 path(vec2 uv,float ts){float dawn=.4+.5*smoothstep(0.,8.,ts);return parted(uv,.9,dawn,ts);}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return shore(uv,ts);if(s==11)return trapped(uv,ts);if(s==12)return certainty(uv,ts);if(s==13)return split(uv,ts);return path(uv,ts);}
