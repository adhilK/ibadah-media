const float V=0.; // visual variant: 0 = English, 1 = Malayalam (mirrored, emerald sky, higher horizon, different cloud timing)
// Theme "sakinah" (hearts find rest in the remembrance of Allah: Qur'an 13:28, Tafsir Ibn Kathir, Sahih al-Bukhari 6407).
// order in the reel: 10 hook (restless heart), 11 Qur'an 13:28, 12 Ibn Kathir (comfort, tranquil, Protector),
//                    13 hadith (living vs dead), 14 remember Him (CTA) and end card
// 10 restless: a night lake under racing clouds; wind churns the water and breaks the moon's reflection into scattered shards
// 11 the verse: NEW motion "the settling mirror": the wind dies while the verse is read, the chop calms over ~6 s
//    and the broken reflection draws back together into one clear moon path; stars appear in the still water
// 12 comfort: the still lake; single drops of light fall and send slow gold rings outward that fade into stillness
// 13 living and dead: the near shore is dry, grey, cracked ground; a wave of gold light sweeps across it and green life
//    glows up behind it (the living heart vs the dead one)
// 14 rest: first light over the perfectly still lake, the dawn mirrored in the water, the green shore lit
float band(vec2 uv){return smoothstep(.19,.24,uv.y)*(1.-smoothstep(.40,.46,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.50,.55,V);}
vec2 MOON(){return vec2(mix(.13,.11,V),mix(.80,.82,V));}
// sky with clouds; wind = cloud speed/coverage, dawn = 0..1
vec3 sky(vec2 p,float y,float wind,float dawn){
 vec3 top=mix(vec3(.004,.02,.022),vec3(.002,.03,.02),V);
 vec3 low=mix(mix(vec3(.05,.11,.10),vec3(.04,.14,.09),V),mix(vec3(.42,.32,.17),vec3(.30,.38,.22),V),dawn);
 vec3 s=mix(low,top,smoothstep(HZ(),HZ()+mix(.30,.60,dawn),y));
 s+=stars(p,85.)*vec3(1.,.95,.85)*.6*(1.-dawn)*smoothstep(HZ()+.05,.85,y);
 // moon: a soft gold disc with halo
 float dm=length(p-MOON());
 s+=GOLD*(smoothstep(.040,.034,dm)*1.1+.25*exp(-dm*14.))*(1.-.7*dawn);
 s+=GOLD*(.10+.45*dawn)*exp(-length((p-vec2(mix(-.08,.06,V),HZ()))*vec2(.5,2.2))*3.)*dawn;
 // clouds
 float cl=fbm(vec2(p.x*2.2-T*(.03+.25*wind)-V*5.,y*5.+T*.02*wind));
 float cov=smoothstep(.55-.15*wind,.85,cl)*smoothstep(HZ()+.02,HZ()+.15,y);
 vec3 cc=mix(vec3(.03,.07,.065),vec3(.12,.12,.09)+GOLD*.08,dawn)+GOLD*.10*exp(-dm*5.);
 s=mix(s,cc,cov*(.55+.35*wind)*(1.-.7*dawn));
 return s;}
// lake: reflect the sky with ripple distortion; chop 0 = mirror, 1 = rough
vec3 lake(vec2 uv,vec2 p,float chop,float wind,float dawn){
 float d=HZ()-uv.y; // depth below horizon
 float persp=1./(d+.02);
 float w1=n2(vec2(p.x*9.*persp*.08+T*.4*wind,d*90.*persp*.02-T*1.3*chop));
 float w2=n2(vec2(p.x*23.*persp*.08-T*.7,d*160.*persp*.02+T*.9));
 float ripple=(w1-.5)*.7+(w2-.5)*.3;
 vec2 rp=vec2(p.x+ripple*chop*.10,HZ()+d+ripple*chop*.06);
 vec3 c=sky(rp,rp.y,wind,dawn)*.80;
 c=mix(c,c*vec3(.6,.85,.8),.25);
 // moon path: shards when rough, one clean column when still
 float mx=abs(p.x-MOON().x-ripple*chop*.06);
 float col=exp(-mx*mix(60.,10.,chop));
 float shards=pow(max(n2(vec2(p.x*60.,d*140.*persp*.05-T*2.)),0.),6.)*14.*chop;
 c+=GOLD*(1.-.6*dawn)*col*(mix(.55,.20,chop)+shards*exp(-mx*7.))*smoothstep(0.,.02,d);
 // shoreline glint at the horizon
 c+=GOLD*.15*exp(-d*120.);
 return c*(1.-.35*band(uv));}
// the near shore (bottom strip): dry vs living; life 0..1 along x via sweep
float shoreH(vec2 p){return .165+.035*(fbm(vec2(p.x*3.,1.7))-.5)*2.;}
vec3 shore(vec2 uv,vec2 p,vec3 c,float sweep,float dawn,float ts){
 float h=shoreH(p);
 if(uv.y<h){
  float x=(p.x*mix(1.,-1.,V))/(R.x/R.y)+.5; // 0..1 across screen, left to right on screen
  float alive=smoothstep(x-.06,x,sweep);
  // dry cracked earth
  vec2 q=p*vec2(14.,26.);vec2 id=floor(q+fbm(q*.5)*.8);vec2 f=fract(q+fbm(q*.5)*.8);
  float crack=1.-smoothstep(.0,.07,min(min(f.x,1.-f.x),min(f.y,1.-f.y)));
  vec3 dry=vec3(.21,.17,.12)*(.75+.25*h1(id))*(1.-.6*crack);
  // living ground: deep green with tiny gold-tipped shoots swaying
  vec3 live=vec3(.05,.22,.12)*(.8+.4*fbm(p*20.));
  float gx=fract(p.x*90.);float gh=h1(vec2(floor(p.x*90.),2.))*.03;
  float blade=smoothstep(.12,.0,abs(gx-.5+.25*sin(T*1.4+p.x*40.)*(h-uv.y)*20.))*step(h-uv.y,gh+.004);
  live+=vec3(.10,.38,.18)*blade+GOLD*.35*blade*step(h-uv.y,.006);
  vec3 g=mix(dry,live,alive);
  g+=GOLD*exp(-(h-uv.y)*80.)*(.25+.5*dawn); // rim light
  float edge=exp(-abs(x-sweep)*60.)*step(.001,sweep)*step(sweep,.999);
  g+=GOLD*.9*edge; // the travelling front of light
  c=g;}
 return c;}
vec3 rings(vec2 p,float ts,float amt){vec3 c=vec3(0.);
 for(int i=0;i<4;i++){float fi=float(i);
  float t0=fi*1.6+.4;float age=ts-t0;if(age<0.)continue;age=mod(age,6.4);
  vec2 cen=vec2((h1(vec2(fi,9.))-.5)*.35,HZ()-.07-.12*h1(vec2(fi,7.)));
  float persp=(HZ()-cen.y)*7.;
  vec2 q=(p-cen)*vec2(1.,1./max(persp*.35,.12));
  float r=age*.07;float d=length(q);
  c+=GOLD*amt*exp(-abs(d-r)*90.)*exp(-age*.55)*.9;
  // the falling drop of light just before it lands
  float fall=clamp(age/0.5,0.,1.);
  c+=GOLD*amt*smoothstep(.010,.003,length(p-vec2(cen.x,cen.y+.25*(1.-fall))))*(1.-step(.999,fall));}
 return c;}
vec3 scene(vec2 uv,float chop,float wind,float dawn,float sweep,float ts){vec2 p=P(uv);vec3 c;
 if(uv.y>HZ())c=sky(p,uv.y,wind,dawn);else c=lake(uv,p,chop,wind,dawn);
 return shore(uv,p,c,sweep,dawn,ts);}
vec3 restless(vec2 uv,float ts){return scene(uv,1.,1.,0.,0.,ts)*(1.-.3*band(uv));}
vec3 settle(vec2 uv,float ts){float k=smoothstep(.5,6.5,ts);return scene(uv,1.-k,1.-k*.9,0.,0.,ts)*(1.-.3*band(uv));}
vec3 comfort(vec2 uv,float ts){vec2 p=P(uv);vec3 c=scene(uv,.04,.1,.05,0.,ts);
 c+=rings(p,ts,1.)*step(uv.y,HZ())*step(shoreH(p),uv.y)*(1.-.5*band(uv));return c*(1.-.3*band(uv));}
vec3 living(vec2 uv,float ts){float s=smoothstep(.5,6.,ts);return scene(uv,.06,.12,.12,s,ts)*(1.-.3*band(uv));}
vec3 rest(vec2 uv,float ts){float dawn=.35+.4*smoothstep(0.,7.,ts);vec2 p=P(uv);
 vec3 c=scene(uv,.02,.05,dawn,1.,ts);c+=rings(p,ts+2.,.35)*step(uv.y,HZ())*step(shoreH(p),uv.y)*(1.-band(uv));return c*(1.-.3*band(uv));}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return restless(uv,ts);if(s==11)return settle(uv,ts);if(s==12)return comfort(uv,ts);
 if(s==13)return living(uv,ts);return rest(uv,ts);}
