const float V=1.; // visual variant: 0 = English, 1 = Malayalam (mirrored, emerald sky, higher horizon)
// Theme "qarib" ("I am near": Qur'an 2:186 between the fasting verses, Qur'an 40:60, Tafsir Ibn Kathir on 40:60).
// order in the reel: 10 hook (the fasting verses: a thin crescent over a vast night desert, one tiny light far away),
//                    11 Qur'an 2:186, 12 Qur'an 40:60, 13 Ibn Kathir + Sufyan ath-Thawri, 14 CTA and end card
// 11 NEW motion "the closing distance": while "indeed I am near" is read the dune layers slide past (a dolly
//    forward with parallax) and the far light grows until it glows warm right in front of the viewer
// 12 call and response: a thin gold thread rises from the near dune into the sky (the call), then a pulse of light
//    comes back down along it and blooms on the ground (the response)
// 13 many asking: small gold lights rise slowly from all across the dunes
// 14 first light: pre-dawn glow over the dunes, the crescent fading, the near light still there
float band(vec2 uv){return smoothstep(.19,.24,uv.y)*(1.-smoothstep(.40,.46,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.50,.55,V);}
vec2 MOON(){return vec2(mix(.11,.09,V),mix(.83,.86,V));}
vec3 sky(vec2 p,float y,float dawn){
 vec3 top=mix(vec3(.004,.018,.022),vec3(.002,.028,.018),V);
 vec3 low=mix(mix(vec3(.045,.095,.085),vec3(.03,.12,.08),V),mix(vec3(.40,.31,.16),vec3(.28,.37,.20),V),dawn);
 vec3 s=mix(low,top,smoothstep(HZ(),HZ()+mix(.32,.62,dawn),y));
 s+=stars(p,90.)*vec3(1.,.95,.85)*.7*(1.-dawn)*smoothstep(HZ()+.03,.8,y);
 // thin crescent: a disc minus an offset disc, with a soft halo
 float d1=length(p-MOON()),d2=length(p-MOON()-vec2(.017,.009));
 float cres=smoothstep(.034,.030,d1)*smoothstep(.027,.032,d2);
 s+=GOLD*(cres*1.25+.10*exp(-d1*12.))*(1.-.65*dawn);
 s+=GOLD*(.05+.42*dawn)*exp(-abs(y-HZ())*11.)*dawn;
 return s;}
// dune ridge for layer i (0 far .. 3 near); z = how far the viewer has moved forward
float ridge(float i,float x,float z){
 float depth=mix(.015,.30,pow(i/3.,1.3));
 float g=.15+i*i*.35;               // nearer layers move more (parallax)
 float sx=x/(1.+z*g*.8)+i*3.1;       // and spread out as we approach
 return HZ()-depth*(1.+z*g*.55)+(.03+.045*i)*(fbm(vec2(sx*(2.2-i*.35),i*1.7))-.5)*2.;}
vec3 glowL(vec2 p,vec2 c,float r,float k){float d=length((p-c)*vec2(1.,1.15));
 return GOLD*k*(smoothstep(r,r*.35,d)*1.3+.45*exp(-d/(r*5.)))+vec3(1.,.9,.7)*k*smoothstep(r*.45,0.,d)*.6;}
// light: 0..1 position from far (horizon) to near, li = intensity
vec2 LPOS(float near){return vec2(mix(-.05,-.03,near),HZ()+mix(-.012,-.032,near));}
float LRAD(float near){return mix(.004,.040,near*near);}
vec3 world(vec2 uv,float z,float near,float li,float dawn){vec2 p=P(uv);
 vec3 c=sky(p,uv.y,dawn);
 vec2 lp=LPOS(near);float lr=LRAD(near);
 for(int j=0;j<4;j++){float i=float(j);
  float r=ridge(i,p.x,z);
  if(uv.y<r){
   vec3 col=mix(vec3(.075,.13,.11),vec3(.022,.05,.04),i/3.);
   col*=.55+.45*exp(-(r-uv.y)*9.);                               // moonlit slope near the crest, shadow below
   col=mix(col,mix(vec3(.16,.12,.07),vec3(.09,.15,.09),V),dawn*(.5-.12*i));
   col+=GOLD*(.20+.35*dawn)*exp(-(r-uv.y)*(110.+i*40.))*(1.-.2*i); // moon/dawn rim on the crest
   col+=GOLD*.020*(fbm(vec2(p.x*30.,uv.y*60.)+i)-.4);              // sand texture
   // warm light falling on the sand near the light (grows as it comes near)
   col+=GOLD*li*near*.55*exp(-length((p-lp)*vec2(.8,1.6))*mix(30.,7.,near));
   c=col;}
  // the light sits behind layer 1 while far, in front of the near dunes when near
  if(j==int(mix(1.,3.,near)+.001)-1)c+=glowL(p,lp,lr,li);
 }
 return c;}
vec3 fin(vec3 c,vec2 uv){return c*(1.-.32*band(uv));}
// 10 vast night: far light faintly pulsing
vec3 vast(vec2 uv,float ts){return fin(world(uv,0.,0.,.55+.15*sin(T*1.7),0.),uv);}
// 11 the closing distance
vec3 nearer(vec2 uv,float ts){float k=smoothstep(.6,7.5,ts);k=k*k*(3.-2.*k);
 return fin(world(uv,k,k,.7+.5*k,0.),uv);}
// 12 call and response
vec3 answer(vec2 uv,float ts){vec2 p=P(uv);vec3 c=world(uv,1.,1.,1.1,0.);
 float tx=mix(.235,.235,V);        // at the edge, clear of the verse card
 float y0=ridge(3.,tx,1.)-.01;                        // foot of the thread on the near dune
 float grow=smoothstep(.3,3.,ts);float ytop=y0+grow*(1.02-y0);
 float wob=.003*sin(uv.y*38.-T*2.);
 float line=exp(-abs(p.x-tx-wob)*520.)*step(y0,uv.y)*step(uv.y,ytop);
 float tip=exp(-length(p-vec2(tx+wob,ytop))*90.)*(1.-step(.999,grow));
 vec3 add=GOLD*(line*.75+tip*1.3);
 // the response: a pulse travels back down from the top, then blooms where the thread began
 float tr=ts-3.4;
 if(tr>0.){float yp=1.02-tr*.42;
  add+=GOLD*1.6*exp(-abs(uv.y-yp)*45.)*line*step(y0-.01,yp);
  float tland=(1.02-y0)/.42;float bloom=smoothstep(tland-.1,tland+.8,tr);
  add+=GOLD*bloom*(.55*exp(-length((p-vec2(tx,y0))*vec2(.7,1.4))*16.)+.25*exp(-length(p-vec2(tx,y0))*5.));
  c+=vec3(.02,.03,.02)*bloom;}
 c+=add*(1.-.55*band(uv));
 return fin(c,uv);}
// rising lights
vec3 motes(vec2 p,float ts,float amt,float sp){vec3 c=vec3(0.);
 for(int i=0;i<26;i++){float fi=float(i);
  float x=(h1(vec2(fi,1.3))-.5)*.56;
  float y0=ridge(2.+step(.5,h1(vec2(fi,4.))),x,1.);
  float s=(.018+.03*h1(vec2(fi,2.)))*sp;
  float y=y0+mod(ts*s+h1(vec2(fi,3.))*.6,1.1);
  vec2 q=vec2(x+.012*sin(ts*.8+fi),y);
  float fade=smoothstep(y0,y0+.05,y)*(1.-smoothstep(.75,1.05,y));
  c+=GOLD*amt*fade*(smoothstep(.0045,.0015,length(p-q))*1.1+.18*exp(-length(p-q)*120.));}
 return c;}
vec3 many(vec2 uv,float ts){vec2 p=P(uv);vec3 c=world(uv,1.,1.,1.,.04);
 c+=motes(p,ts+4.,smoothstep(0.,2.5,ts),1.)*(1.-.6*band(uv));return fin(c,uv);}
vec3 first(vec2 uv,float ts){vec2 p=P(uv);float dawn=.30+.42*smoothstep(0.,8.,ts);
 vec3 c=world(uv,1.,1.,1.-.3*dawn,dawn);c+=motes(p,ts+30.,.45,.6)*(1.-band(uv));return fin(c,uv);}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return vast(uv,ts);if(s==11)return nearer(uv,ts);if(s==12)return answer(uv,ts);
 if(s==13)return many(uv,ts);return first(uv,ts);}
