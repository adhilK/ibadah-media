const float V=1.; // visual variant: 0 = English, 1 = Malayalam (mirrored, emerald sky, lower shoreline)
// Theme "dawam" ("the most constant, even if small": Sahih al-Bukhari 6465, Sahih Muslim 783).
// order in the reel: 10 hook (a big flare bursts and fades; one tiny lamp keeps burning)
//                    11 "the most constant, even if small": one drop falls into a still pool, again and again, rings spreading
//                    12 "take on what you are able to do": the small lamp burns steady, its reflection on the water
//                    13 'A'ishah kept doing a deed once she began it: NEW motion "accumulation" - every drop adds
//                       a little more gold light to the pool, step by step
//                    14 CTA and end card: pre-dawn; small lamps along the shore light one by one, like days kept
float band(vec2 uv){return smoothstep(.19,.24,uv.y)*(1.-smoothstep(.40,.46,uv.y));} // caption zone
vec2 P(vec2 uv){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);p.x*=mix(1.,-1.,V);return p;}
float HZ(){return mix(.205,.175,V);}            // shoreline / water surface
const float DX=-.165;                            // where the drop falls
float LX(){return .175;}                          // the small lamp
const float PD=1.45;                              // one drop every PD seconds
vec3 sky(vec2 p,float y,float dawn){
 vec3 top=mix(vec3(.004,.020,.020),vec3(.002,.030,.016),V);
 vec3 low=mix(mix(vec3(.065,.135,.115),vec3(.040,.160,.100),V),mix(vec3(.36,.28,.15),vec3(.25,.33,.18),V),dawn);
 vec3 s=mix(low,top,smoothstep(HZ(),HZ()+mix(.55,.75,dawn),y));
 s+=mix(vec3(.010,.030,.026),vec3(.006,.036,.020),V)*exp(-abs(y-.62)*3.); // faint night haze behind the card
 s+=stars(p,85.)*vec3(1.,.95,.85)*.65*(1.-dawn)*smoothstep(HZ()+.05,.8,y);
 s+=GOLD*(.04+.40*dawn)*exp(-abs(y-HZ())*12.)*dawn;
 return s;}
// far hills behind the water
float hill(float x){return HZ()+.018+.030*(fbm(vec2(x*3.,7.))-.35)+.02*sin(x*4.+1.);}
// rock overhang at the top, its tip above the drop point
float rockEdge(float x){return .935+.06*smoothstep(DX+.02,DX+.30,x)+.025*(fbm(vec2(x*9.,2.))-.5)-.035*exp(-pow((x-DX)*14.,2.));}
float TIP(){return rockEdge(DX)-.004;}
vec3 lampAt(vec2 p,vec2 c,float k,float flick){ // a small flame on a stone, with glow
 vec2 q=(p-c)/vec2(1.,1.7);float d=length(q-vec2(0.,.006));
 float flame=smoothstep(.0075,.003,length((p-c-vec2(0.,.010))*vec2(1.,.55)));
 vec3 col=GOLD*k*(1.5*flame+.55*exp(-d*55.)*flick+.20*exp(-d*12.));
 col+=vec3(1.,.93,.75)*k*smoothstep(.0035,0.,length((p-c-vec2(0.,.008))*vec2(1.,.6)))*.8;
 return col;}
vec3 world(vec2 uv,float ts,float lamp,float dawn,float acc,float drops,float rowN){
 vec2 p=P(uv);float y=uv.y;vec3 c;
 float fl=.85+.15*sin(T*9.)*sin(T*5.3+1.);
 if(y>HZ()){
  c=sky(p,y,dawn);
  float hy=hill(p.x);
  if(y<hy){c=mix(vec3(.018,.040,.035),vec3(.012,.045,.028),V)*(1.+dawn*2.)+GOLD*.08*exp(-(hy-y)*160.)*(.4+dawn);}
  // stone the lamp stands on
  float st=length((p-vec2(LX(),HZ()+.002))*vec2(1.,2.6));
  if(st<.018)c=vec3(.03,.05,.04)+GOLD*.12*lamp*exp(-st*60.);
  c+=lampAt(p,vec2(LX(),HZ()+.009),lamp,fl);
  // a row of lamps along the shore (scene 14), lit one by one
  for(int i=0;i<7;i++){float fi=float(i);if(fi>=rowN)break;
   float lx=-.235+fi*.068;if(abs(lx-LX())<.03)continue;
   float on=clamp(rowN-fi,0.,1.);
   c+=lampAt(p,vec2(lx,HZ()+.007),on*.55,fl);}
 }else{
  // water: mirrored sky, darker, gently moving
  float wy=2.*HZ()-y;float w=n2(vec2(p.x*60.,y*220.-T*.6))*.5+n2(vec2(p.x*20.,y*90.+T*.3))*.5;
  c=sky(vec2(p.x,wy),wy,dawn)*.55;c*=.75+.35*w;
  c=mix(c,mix(vec3(.010,.030,.028),vec3(.006,.034,.020),V),smoothstep(HZ(),0.,y)*.6);
  // lamp reflection (a vertical shimmer)
  float rx=exp(-abs(p.x-LX()+.004*sin(y*160.+T*2.))*110.)*exp(-(HZ()-y)*9.);
  c+=GOLD*lamp*rx*(.55+.45*w)*.9;
  for(int i=0;i<7;i++){float fi=float(i);if(fi>=rowN)break;
   float lx=-.235+fi*.068;if(abs(lx-LX())<.03)continue;
   c+=GOLD*clamp(rowN-fi,0.,1.)*.45*exp(-abs(p.x-lx+.003*sin(y*170.+T*2.+fi))*130.)*exp(-(HZ()-y)*12.)*(.5+.5*w);}
  // accumulation: gold light gathered in the pool around where the drops land
  vec2 ip=vec2(DX,HZ()-.045);
  float pd=length((p-ip)*vec2(1.,3.2));
  c+=GOLD*acc*(.55*exp(-pd*14.)+.18*exp(-pd*4.))*(.7+.3*w);
  // ripples from every drop that has landed
  if(drops>0.){
   for(int k=0;k<5;k++){float age=mod(ts-.9,PD)+float(k)*PD;
    if(ts-.9-float(k)*PD<0.)continue;
    float r=.012+age*.055;float e=length((p-ip)*vec2(1.,3.2));
    float ring=exp(-abs(e-r)*260.)*exp(-age*.85);
    c+=GOLD*drops*ring*.9;}
  }
 }
 // rock overhang at the top
 float re=rockEdge(p.x);
 if(y>re){c=vec3(.016,.034,.029)+GOLD*.22*exp(-(y-re)*140.)+GOLD*.015*(fbm(p*40.)-.4);}
 // the drop: forms at the tip, falls, lands; one every PD seconds
 if(drops>0.){
  float ph=mod(ts,PD);vec2 tp=vec2(DX,TIP());
  float grow=smoothstep(0.,.55,ph)*(1.-step(.55,ph));
  float fall=clamp((ph-.55)/.35,0.,1.);
  float dy=mix(tp.y-.006,HZ()-.045,fall*fall);
  float dd=length((p-vec2(DX,ph<.55?tp.y-.004*grow:dy))*vec2(1.,ph<.55?1.:.55));
  float dr=ph<.55?.0065*grow:.0058;
  float trail=(ph>=.55&&ph<.9)?exp(-abs(p.x-DX)*700.)*step(dy,uv.y)*exp(-(uv.y-dy)*25.)*.35:0.;
  c+=drops*GOLD*trail;
  float vis=ph<.9?1.:0.;
  c+=drops*vis*(GOLD*1.3*smoothstep(dr,dr*.4,dd)+vec3(1.,.95,.85)*.5*smoothstep(dr*.5,0.,dd)+GOLD*.25*exp(-dd*90.));
 }
 return c;}
vec3 fin(vec3 c,vec2 uv){return c*(1.-.30*band(uv));}
// 10 the flare that fades vs the lamp that stays
vec3 flare(vec2 uv,float ts){vec2 p=P(uv);vec3 c=world(uv,ts,.9,0.,0.,0.,0.);
 float t=ts-.3;
 if(t>0.){vec2 fc=vec2(0.,mix(.47,.41,V));float d=length(p-fc);
  float life=exp(-t*.9);float rad=.02+t*.05;
  c+=GOLD*life*1.6*exp(-d*d/(.0009+t*.0010)); // core flash
  for(int i=0;i<34;i++){float fi=float(i);float a=fi*.1848*6.2831+h1(vec2(fi,2.))*.4;
   float sp=.7+.6*h1(vec2(fi,7.));vec2 q=fc+vec2(cos(a),sin(a))*rad*sp-vec2(0.,.012*t*t);
   c+=GOLD*life*1.1*smoothstep(.0045,.001,length(p-q))*(1.-band(uv)*.6);}
 }
 return fin(c,uv);}
vec3 drip(vec2 uv,float ts){return fin(world(uv,ts,.9,0.,0.,1.,0.),uv);}
vec3 steady(vec2 uv,float ts){float k=.9+.35*smoothstep(0.,4.,ts);return fin(world(uv,ts+40.,k,0.,.15,.8,0.),uv);}
vec3 gather(vec2 uv,float ts){float n=floor(max(ts-.9,0.)/PD)+1.;float a=.12+.12*min(n,7.);
 a+=.10*exp(-mod(max(ts-.9,0.),PD)*3.)*step(.9,ts);                  // each landing adds a little more
 return fin(world(uv,ts,1.1,0.,a,1.,0.),uv);}
vec3 dawnRow(vec2 uv,float ts){float dawn=.25+.40*smoothstep(0.,9.,ts);float row=ts/.75;
 return fin(world(uv,ts,1.1,dawn,.9,.6,row),uv);}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return flare(uv,ts);if(s==11)return drip(uv,ts);if(s==12)return steady(uv,ts);
 if(s==13)return gather(uv,ts);return dawnRow(uv,ts);}
