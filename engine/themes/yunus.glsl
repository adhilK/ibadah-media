// Theme "yunus" (Qur'an 21:87-88): the three darknesses and the rescue.
// 10 descent: night sky -> sea surface -> sinking into the deep   11 abyss: a lone light calling out in the dark
// 12 rays: light breaking down from the surface, bubbles rising     13 dawn: sunrise over a calm sea
// The fish itself is never shown (no animals); the darkness is shown through night, sea and depth.
float snow(vec2 p,float tt,float dir){float a=0.;
 for(int k=0;k<3;k++){float fk=float(k),sc=16.+fk*12.;
  vec2 q=p*sc+vec2(sin(tt*.2+fk)*.4,-dir*tt*(.22+fk*.1)*sc*.08);
  vec2 g=floor(q),f=fract(q)-.5;float r=h1(g+fk*7.);vec2 o=vec2(h1(g+1.3),h1(g+2.7))-.5;
  a+=r>.86?smoothstep(.13,0.,length(f-o*.6))*(.4+.6*h1(g+5.))/(1.+fk*.6):0.;}
 return a;}
vec3 water(float depth){return mix(vec3(.004,.016,.018),vec3(.05,.20,.17),exp(-depth*2.4));}
vec3 descent(vec2 uv,float ts){
 float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 float d=1.8*smoothstep(1.5,11.5,ts);float y=uv.y-.30-d;
 float wave=.006*sin(p.x*30.+T*1.2)+.004*sin(p.x*53.-T*1.7);
 if(y>wave){vec3 c=mix(vec3(.06,.13,.12),vec3(.008,.025,.03),smoothstep(0.,.6,y));
  c+=stars(vec2(p.x,y),80.)*vec3(1.,.95,.85)+stars(vec2(p.x,y)*1.6+2.,120.)*.5;
  float md=length(vec2(p.x,y)-vec2(-.2,.52));c+=GOLD*1.2*smoothstep(.05,.046,md)+GOLD*.12*exp(-md*8.);
  c+=GOLD*.18*exp(-(y-wave)*40.);return c;}
 float depth=-y;vec3 c=water(depth);
 float gl=smoothstep(.10,0.,abs(p.x+.2+.025*sin(depth*60.+T)))*exp(-depth*12.)*(.5+.5*sin(depth*160.-T*3.));
 c+=GOLD*gl*.6+GOLD*.3*exp(-abs(y-wave)*120.);
 float ca=fbm(vec2(p.x*6.,depth*6.)+T*.15);c+=GOLD*.12*pow(ca,3.)*exp(-depth*3.);
 c+=vec3(.7,.8,.7)*snow(vec2(p.x,y),T,-1.)*.35*exp(-depth*.5);
 return c;}
vec3 abyss(vec2 uv,float ts){
 float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y-.5);
 vec3 c=vec3(.003,.012,.013)+vec3(.01,.03,.03)*fbm(p*2.+T*.03);
 float g=smoothstep(0.,4.,ts),r=length((p-vec2(0.,-.30))*vec2(1.,.8));
 c+=GOLD*(.9*exp(-r*10.)+.22*exp(-r*3.))*g*(.85+.15*sin(ts*2.2));
 for(int k=0;k<3;k++){float ph=fract(ts*.22+float(k)/3.);c+=GOLD*.2*g*(1.-ph)*exp(-abs(r-ph*.95)*55.);}
 c+=vec3(.6,.75,.7)*snow(p,T,1.)*.25;return c;}
vec3 rays(vec2 uv,float ts){
 float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);
 vec3 c=mix(vec3(.004,.02,.02),vec3(.04,.17,.14),pow(uv.y,1.5));
 float op=smoothstep(0.,3.,ts);vec2 v=p-vec2(0.,1.25);float an=atan(v.x,-v.y);
 float b=pow(.5+.5*sin(an*22.+T*.25+sin(an*7.-T*.4)*1.5),3.)*.6+pow(.5+.5*sin(an*9.-T*.18),4.)*.5;
 c+=GOLD*b*exp(-length(v)*1.1)*op*.95;
 c+=GOLD*fbm(vec2(p.x*8.,T*.4))*smoothstep(.85,1.,uv.y)*op;
 c+=vec3(1.,.95,.8)*snow(p,T*1.8,1.)*.5*op;return c;}
vec3 dawn(vec2 uv,float ts){
 float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.56;
 float sd=length(p-vec2(0.,hz-.03+.07*smoothstep(0.,14.,ts)));
 if(uv.y>hz){float y=uv.y-hz;
  vec3 c=mix(vec3(.50,.36,.16),vec3(.03,.13,.11),smoothstep(0.,.32,y));c=mix(c,vec3(.01,.05,.05),smoothstep(.32,.6,y));
  c+=GOLD*(1.6*smoothstep(.075,.07,sd)+.5*exp(-sd*6.));
  c+=stars(p,80.)*smoothstep(.4,.6,y)*(1.-smoothstep(0.,10.,ts))*.6;
  c+=GOLD*.12*smoothstep(.55,.8,fbm(vec2(p.x*3.+T*.02,y*14.)))*(1.-smoothstep(0.,.3,y));
  return c;}
 float y=hz-uv.y;vec3 c=mix(vec3(.10,.16,.12),vec3(.01,.04,.04),smoothstep(0.,.3,y));
 float w=fbm(vec2(p.x*(10./(y+.05)),y*80.-T*.8)),path=exp(-pow(p.x/(.04+y*.5),2.));
 c+=GOLD*path*pow(w,2.)*1.4*(1.-smoothstep(0.,.45,y)*.5)+GOLD*.15*exp(-y*25.);return c;}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return descent(uv,ts);if(s==11)return abyss(uv,ts);if(s==12)return rays(uv,ts);return dawn(uv,ts);}
