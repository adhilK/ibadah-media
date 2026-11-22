// Theme "hilm" (anger: Bukhari 6114 & 6116, Qur'an 3:134 "who restrain anger and pardon the people").
// order in the reel: 10 hook, 11 hadith 6114, 12 hadith 6116, 13 verse 3:134 + Ibn Kathir, 14 dawn lake (CTA/end)
// 10 blaze: a fire flaring on a dark plain, wild embers whirling upward (anger taking over)
// 11 held: the same fire is mastered: flames sink into one small steady flame inside a gold ring, embers slow
// 12 three: "Do not become angry" x3: dark still water, three gold ripples spread one after another, each calming it
// 13 still: a mirror-calm night lake; the last embers drift down and settle as stars reflected in the water
// 14 dawn: gold dawn rising over the still lake (end card)
// NEW motion: embers that slow, fall and turn into stars (anger cooling into calm)
float band(vec2 uv){return smoothstep(.20,.25,uv.y)*(1.-smoothstep(.38,.44,uv.y));} // caption zone
float flame(vec2 p,vec2 c,float h,float w,float wild,float tt){
 vec2 q=p-c;if(q.y<-.01)return 0.;float y=q.y/h;
 float n=fbm(vec2(q.x*9.,q.y*6.-tt*(1.5+wild*2.)))-.5;
 float x=q.x+n*w*(.6+wild*1.4)*y;
 float wid=w*(1.-y)*(.7+.3*sin(tt*7.+y*5.)*wild);
 return smoothstep(wid,wid*.2,abs(x))*smoothstep(1.,.2,y)*smoothstep(-.01,.02,q.y);}
float embers(vec2 p,float tt,float speed,float wild,float dens){float a=0.;
 for(int k=0;k<3;k++){float fk=float(k),sc=14.+fk*9.;
  vec2 q=p*sc+vec2(sin(tt*(.7+wild)+p.y*6.+fk)*wild*1.5,-tt*speed*(1.+fk*.3));
  vec2 g=floor(q),f=fract(q)-.5;float r=h1(g+fk*7.);
  a+=r>dens?smoothstep(.13,0.,length(f))*(.5+.5*sin(tt*5.+r*50.)):0.;}
 return a;}
vec3 ground(vec2 uv,vec2 p,float hz,vec3 sky){if(uv.y>hz)return sky;float y=hz-uv.y;
 return mix(vec3(.035,.075,.06),vec3(.006,.02,.017),smoothstep(0.,.1,y))*(.8+.2*fbm(vec2(p.x*18.,y*50.)));}
vec3 nightsky(vec2 uv,vec2 p){vec3 s=mix(vec3(.05,.10,.085),vec3(.006,.025,.022),smoothstep(.05,.9,uv.y));
 return s+stars(p,80.)*vec3(1.,.95,.85)*.55*smoothstep(.45,.9,uv.y);}
vec3 blaze(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.09;
 vec3 sky=nightsky(uv,p);float fl=.6+.4*n2(vec2(T*6.,0.));
 sky+=vec3(.95,.55,.25)*.16*fl*exp(-length((p-vec2(0.,hz))*vec2(1.,1.5))*3.5);
 vec3 c=ground(uv,p,hz,sky);
 float f=flame(p,vec2(0.,hz-.01),.24,.10,1.,T);float core=flame(p,vec2(0.,hz-.01),.12,.04,1.,T*1.3);
 c+=mix(vec3(.9,.45,.18),GOLD,.4)*f*1.2+vec3(1.,.9,.7)*core*.9;
 c+=mix(vec3(1.,.55,.25),GOLD,.5)*embers(p,T,1.4,1.,.86)*(1.-.6*band(uv))*smoothstep(0.,.6,ts);
 return c*(1.-.3*band(uv));}
vec3 held(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.09;
 float m=smoothstep(.5,6.,ts);            // mastering the anger across the line
 float h=mix(.24,.05,m),w=mix(.10,.018,m),wild=1.-m;
 vec3 sky=nightsky(uv,p);
 sky+=mix(vec3(.95,.55,.25),GOLD,m)*.14*exp(-length((p-vec2(0.,hz))*vec2(1.,1.5))*(3.5+m*3.));
 vec3 c=ground(uv,p,hz,sky);
 vec2 fc=vec2(0.,hz-.01);
 c+=mix(vec3(.9,.45,.18),GOLD,.4+.6*m)*flame(p,fc,h,w,wild,T)*1.2+vec3(1.,.92,.75)*flame(p,fc,h*.55,w*.45,wild,T*1.3)*.9;
 // a gold ring closing around the flame: self-control
 float rr=length((p-vec2(0.,hz+.025))*vec2(1.,1.25));float R0=mix(.20,.075,m);
 c+=GOLD*exp(-abs(rr-R0)*260.)*smoothstep(0.,2.,ts)*.9;
 c+=mix(vec3(1.,.55,.25),GOLD,m)*embers(p,T,mix(1.4,.15,m),wild,.86+.08*m)*(1.-.7*band(uv));
 return c*(1.-.3*band(uv));}
vec3 lake(vec2 uv,vec2 p,float hz,float rip,float ts,float dawnk){
 // sky above the water line
 vec3 sky=mix(vec3(.05,.10,.085),vec3(.006,.025,.022),smoothstep(hz,.95,uv.y));
 sky=mix(sky,mix(vec3(.32,.25,.12),vec3(.06,.13,.11),smoothstep(hz,hz+.22,uv.y)),dawnk);
 sky+=GOLD*.3*dawnk*exp(-length((p-vec2(0.,hz))*vec2(.6,2.2))*4.);
 if(uv.y>hz){vec3 s=sky+stars(p,80.)*vec3(1.,.95,.85)*.8*(1.-dawnk*.8);
  float md=length(p-vec2(-.13,.84));s+=GOLD*1.1*smoothstep(.035,.031,md)*smoothstep(.024,.029,length(p-vec2(-.115,.845)))+GOLD*.08*exp(-md*7.);
  return s;}
 // reflection: mirror the sky, disturbed only by ripples
 float y=hz-uv.y;vec2 rp=vec2(p.x,hz+y);
 float d=rip;vec2 ruv=vec2(uv.x+d*.004*sin(y*180.),hz+y+d*.003*sin(p.x*90.));
 vec2 pr=vec2((ruv.x-.5)*R.x/R.y,ruv.y);
 vec3 r=mix(vec3(.05,.10,.085),vec3(.006,.025,.022),smoothstep(hz,.95,ruv.y));
 r=mix(r,mix(vec3(.32,.25,.12),vec3(.06,.13,.11),smoothstep(hz,hz+.22,ruv.y)),dawnk);
 r+=GOLD*.3*dawnk*exp(-length((pr-vec2(0.,hz))*vec2(.6,2.2))*4.);
 r+=stars(pr,80.)*vec3(1.,.95,.85)*.6*(1.-dawnk*.8);
 float md=length(pr-vec2(-.13,.84));r+=GOLD*.8*smoothstep(.035,.031,md)*smoothstep(.024,.029,length(pr-vec2(-.115,.845)));
 return r*vec3(.55,.68,.65)*(1.-.4*smoothstep(0.,.5,y));}
vec3 three(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.47;
 // three ripples, one per "Do not become angry"
 float rip=0.,ring=0.;
 for(int k=0;k<3;k++){float t0=.6+float(k)*2.6;float a=ts-t0;if(a>0.){
  vec2 q=(p-vec2(0.,.15))*vec2(1.,3.2);float r=length(q);float rad=a*.22;
  float w=exp(-abs(r-rad)*40.)*exp(-a*.35);ring+=w;rip+=w*1.5;}}
 vec3 c=lake(uv,p,hz,rip,ts,0.);
 if(uv.y<hz)c+=GOLD*ring*.55*(1.-.5*band(uv));
 // the agitated embers above the water die down with each ripple
 float calm=smoothstep(0.,8.,ts);
 c+=mix(vec3(1.,.55,.25),GOLD,calm)*embers(p,T,mix(.8,.1,calm),1.-calm,.9+.07*calm)*step(hz,uv.y)*(1.-calm*.8);
 return c;}
vec3 still(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.47;
 vec3 c=lake(uv,p,hz,.15+.1*sin(T*.5),ts,0.);
 // embers drifting DOWN and settling as stars (new motion)
 if(uv.y>hz){float a=0.;for(int k=0;k<2;k++){float fk=float(k),sc=10.+fk*7.;
  vec2 q=p*sc+vec2(sin(T*.3+fk*2.)*.3,T*(.25+fk*.1));vec2 g=floor(q),f=fract(q)-.5;float r=h1(g+fk*5.);
  float life=fract(q.y*.05+r);a+=r>.88?smoothstep(.12,0.,length(f))*(.6+.4*sin(T*2.+r*30.)):0.;}
  c+=mix(vec3(1.,.6,.3),vec3(1.,.95,.85),smoothstep(.5,.9,uv.y))*a*.7;}
 return c;}
vec3 dawnlake(vec2 uv,float ts){float asp=R.x/R.y;vec2 p=vec2((uv.x-.5)*asp,uv.y);float hz=.47;
 float k=smoothstep(0.,6.,ts)*.9+.1;vec3 c=lake(uv,p,hz,.1,ts,k);
 if(uv.y<hz)c+=GOLD*.35*k*exp(-abs(p.x)*25.)*exp(-(hz-uv.y)*5.)*(.6+.4*n2(vec2(p.x*60.,(hz-uv.y)*300.-T*2.)));
 return c;}
vec3 theme(int s,vec2 uv,float ts){if(s==10)return blaze(uv,ts);if(s==11)return held(uv,ts);if(s==12)return three(uv,ts);if(s==13)return still(uv,ts);return dawnlake(uv,ts);}
