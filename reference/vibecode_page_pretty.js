(self.webpackChunk_N_E=self.webpackChunk_N_E||[]).push([[7339],{9898:(e,t,s)=>{"use strict";
s.d(t,{$F:()=>a,od:()=>r,wO:()=>i});
let r="https://apps.apple.com/us/app/vibecode-ai-app-builder/id6742912146",a="https://play.google.com/store/apps/details?id=com.vibecodeapp.app",i="https://sandbox.dev?utm_source=vibecodeappwebsite&utm_medium=website&utm_campaign=vibecodeappwebsite"},
12522:(e,t,s)=>{"use strict";
s.d(t,{DE:()=>o,F$:()=>l,ie:()=>a,qn:()=>i});
let r={PROMPT:"vibecode_pending_prompt",IMAGE_URL:"vibecode_pending_image",MODE:"vibecode_pending_mode",MODEL:"vibecode_pending_model",TIMESTAMP:"vibecode_prompt_timestamp",PROJECT_TYPE:"vibecode_pending_project_type",REMIX_SHARE_ID:"vibecode_remix_share_id",REMIX_PROJECT_ID:"vibecode_remix_project_id",HAS_CLOUD:"vibecode_pending_has_cloud"};
function a(e){try{sessionStorage.setItem(r.PROMPT,e.prompt),e.imageUrl&&sessionStorage.setItem(r.IMAGE_URL,e.imageUrl),e.mode&&sessionStorage.setItem(r.MODE,e.mode),e.model&&sessionStorage.setItem(r.MODEL,e.model),e.projectType&&sessionStorage.setItem(r.PROJECT_TYPE,e.projectType),e.remixShareId&&sessionStorage.setItem(r.REMIX_SHARE_ID,e.remixShareId),e.remixProjectId&&sessionStorage.setItem(r.REMIX_PROJECT_ID,e.remixProjectId),void 0!==e.hasCloud&&sessionStorage.setItem(r.HAS_CLOUD,e.hasCloud.toString()),sessionStorage.setItem(r.TIMESTAMP,Date.now().toString()),document.cookie="vibecode_has_prompt=true;
 path=/;
 max-age=3600"}catch(e){console.error("Failed to save prompt to storage:",e)}}function i(){try{let e=sessionStorage.getItem(r.PROMPT),t=sessionStorage.getItem(r.TIMESTAMP);
if(!e||!t)return null;
if(Date.now()-parseInt(t,10)>36e5)return o(),null;
let s=sessionStorage.getItem(r.HAS_CLOUD);
return{prompt:e,imageUrl:sessionStorage.getItem(r.IMAGE_URL),mode:sessionStorage.getItem(r.MODE)||void 0,model:sessionStorage.getItem(r.MODEL)||void 0,projectType:sessionStorage.getItem(r.PROJECT_TYPE)||void 0,remixShareId:sessionStorage.getItem(r.REMIX_SHARE_ID)||void 0,remixProjectId:sessionStorage.getItem(r.REMIX_PROJECT_ID)||void 0,hasCloud:"true"===s||"false"!==s&&void 0,timestamp:parseInt(t,10)}}catch(e){return console.error("Failed to retrieve stored prompt:",e),null}}function o(){try{Object.values(r).forEach(e=>{sessionStorage.removeItem(e)}),document.cookie="vibecode_has_prompt=;
 path=/;
 max-age=0"}catch(e){console.error("Failed to clear stored prompt:",e)}}function l(e){try{sessionStorage.setItem(r.PROMPT,"Remixing project..."),sessionStorage.setItem(r.PROJECT_TYPE,"remix"),sessionStorage.setItem(r.REMIX_SHARE_ID,e),sessionStorage.setItem(r.TIMESTAMP,Date.now().toString()),document.cookie="vibecode_has_prompt=true;
 path=/;
 max-age=3600"}catch(e){console.error("Failed to save remix intent:",e)}}},
13547:(e,t,s)=>{"use strict";
s.d(t,{cn:()=>i});
var r=s(52596),a=s(39688);
function i(){for(var e=arguments.length,t=Array(e),s=0;
s<e;
s++)t[s]=arguments[s];
return(0,a.QP)((0,r.$)(t))}},
27016:(e,t,s)=>{"use strict";
s.d(t,{PromisifiedAuthProvider:()=>n,d:()=>c});
var r=s(265),a=s(38572),i=s(35583),o=s(12115);
let l=o.createContext(null);
function n(e){let{authPromise:t,children:s}=e;
return o.createElement(l.Provider,{value:t},
s)}function c(){let e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},
t=(0,i.useRouter)(),s=o.useContext(l),n=s;
return(s&&"then"in s&&(n=o.use(s)),"undefined"!=typeof window)?(0,r.As)({...n,...e}):t?(0,r.As)(e):(0,a.hP)({...n,...e})}},
36894:(e,t,s)=>{"use strict";
s.d(t,{default:()=>v});
var r=s(95155),a=s(12115),i=s(9898);
function o(e){let{shareId:t,projectData:s,isLoading:o,error:l}=e,[n,c]=(0,a.useState)(30),[d,m]=(0,a.useState)(!1);
if((0,a.useEffect)(()=>{if(!s||d||l)return;
let e=setInterval(()=>{c(s=>{if(s<=1&&!d){m(!0),clearInterval(e);
let s="https://appclip.apple.com/id?p=com.vibecodeapp.app.Clip&shareId=".concat(t);
return window.location.href=s,0}return s-1})},
1e3);
return()=>clearInterval(e)},
[t,d,s,l]),o)return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)("div",{className:"workspace-glow-background"}),(0,r.jsx)("div",{className:"min-h-screen relative z-10",style:{backgroundColor:"rgba(14, 14, 14, 0.15)"},
children:(0,r.jsx)("div",{className:"flex justify-center items-center min-h-screen p-4",children:(0,r.jsx)("div",{className:"max-w-md w-full",children:(0,r.jsxs)("div",{className:"rounded-2xl p-8 text-center",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(20px)"},
children:[(0,r.jsx)("div",{className:"animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500 mx-auto mb-4"}),(0,r.jsx)("p",{className:"text-white/70",children:"Loading project..."})]})})})})]});
if(l||!s)return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)("div",{className:"workspace-glow-background"}),(0,r.jsx)("div",{className:"min-h-screen relative z-10",style:{backgroundColor:"rgba(14, 14, 14, 0.15)"},
children:(0,r.jsx)("div",{className:"flex justify-center items-center min-h-screen p-4",children:(0,r.jsx)("div",{className:"max-w-md w-full",children:(0,r.jsxs)("div",{className:"rounded-2xl p-8 text-center space-y-4",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(20px)"},
children:[(0,r.jsx)("div",{className:"text-red-500 text-4xl mb-2",children:"⚠️"}),(0,r.jsx)("h1",{className:"text-lg font-semibold text-gray-400",children:l||"This project may not be published or the link may be invalid."}),(0,r.jsx)("a",{href:"/",className:"inline-block bg-orange-500 hover:bg-orange-600 text-white font-medium py-2 px-4 rounded-lg transition-colors",children:"Go to Vibecode"})]})})})})]});
let{data:x}=s;
return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)("div",{className:"workspace-glow-background"}),(0,r.jsx)("div",{className:"min-h-screen relative z-10 flex justify-center items-center",style:{backgroundColor:"rgba(14, 14, 14, 0.15)"},
children:(0,r.jsx)("div",{className:"flex flex-col items-center p-4",children:(0,r.jsxs)("div",{className:"max-w-md w-full flex flex-col items-center",children:[(0,r.jsxs)("div",{className:"rounded-2xl p-8 text-center space-y-6",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(40px)"},
children:[(0,r.jsxs)("div",{className:"flex flex-col items-center space-y-4",children:[x.iconUrl&&(0,r.jsx)("img",{src:x.iconUrl,alt:x.name,className:"w-16 h-16 rounded-xl object-cover"}),(0,r.jsxs)("div",{children:[(0,r.jsx)("h1",{className:"text-2xl font-semibold text-white/90",children:x.name}),x.description&&(0,r.jsx)("p",{className:"text-sm text-white/70 mt-2",children:x.description})]})]}),(0,r.jsx)("div",{className:"space-y-4",children:(0,r.jsx)("button",{onClick:()=>{if(!s)return;
let e="https://appclip.apple.com/id?p=com.vibecodeapp.app.Clip&shareId=".concat(t);
window.location.href=e},
className:"w-full bg-[#17B086] hover:bg-orange-600 text-white font-medium py-3 px-4 rounded-2xl transition-colors",children:"Open app"})}),(0,r.jsxs)("div",{className:"pt-4 border-t border-white/10",children:[(0,r.jsxs)("p",{className:"text-sm text-white/70",children:["Auto-opening App Clip in"," ",(0,r.jsx)("span",{className:"font-semibold text-white/90",children:n})," ","seconds..."]}),(0,r.jsxs)("p",{className:"text-xs text-white/50 mt-2",children:["Download Vibecode:"," ",(0,r.jsx)("a",{href:i.od,target:"_blank",rel:"noopener noreferrer",className:"text-white/90 hover:text-white/100 underline",children:"App Store"})]})]})]}),(0,r.jsx)("div",{className:"flex justify-center items-center mt-4 ml-2",children:(0,r.jsx)("span",{className:"text-sm font-medium italic",style:{color:"rgba(255, 255, 255, 0.5)"},
children:"If you opened this link from X, Instagram, or TikTok, please open it in Safari for it to work properly."})})]})})})]})}var l=s(38990),n=s(56671),c=s(95787);
let d=(0,s(19946).A)("recycle",[["path",{d:"M7 19H4.815a1.83 1.83 0 0 1-1.57-.881 1.785 1.785 0 0 1-.004-1.784L7.196 9.5",key:"x6z5xu"}],["path",{d:"M11 19h8.203a1.83 1.83 0 0 0 1.556-.89 1.784 1.784 0 0 0 0-1.775l-1.226-2.12",key:"1x4zh5"}],["path",{d:"m14 16-3 3 3 3",key:"f6jyew"}],["path",{d:"M8.293 13.596 7.196 9.5 3.1 10.598",key:"wf1obh"}],["path",{d:"m9.344 5.811 1.093-1.892A1.83 1.83 0 0 1 11.985 3a1.784 1.784 0 0 1 1.546.888l3.943 6.843",key:"9tzpgr"}],["path",{d:"m13.378 9.633 4.096 1.098 1.097-4.096",key:"1oe83g"}]]);
var m=s(92138),x=s(265),h=s(12522);
function p(e){let{children:t}=e;
return(0,r.jsx)("div",{className:"p-4 rounded-[20px] inline-flex justify-start items-center gap-2.5",style:{backgroundColor:"rgba(255, 255, 255, 0.05)"},
children:t})}function u(e){let{projectData:t,shareId:s}=e;
return(0,r.jsxs)("div",{className:"p-5 rounded-xl flex flex-col justify-start items-start gap-2.5 overflow-hidden",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(20px)",width:"500px"},
children:[(0,r.jsx)("div",{className:"inline-flex flex-col justify-start items-start pb-0",children:(0,r.jsx)("span",{className:"text-sm font-semibold",style:{color:"rgba(255, 255, 255, 0.9)"},
children:"View app"})}),(0,r.jsx)("div",{className:"self-stretch border-b",style:{borderColor:"rgba(255, 255, 255, 0.1)"}}),(0,r.jsx)("div",{className:"self-stretch justify-center text-white/50 text-sm font-normal leading-tight pb-4",children:"Scan this project's QR code to open the app on your phone."}),(0,r.jsx)("div",{className:"self-stretch inline-flex flex-col justify-start items-center",children:(0,r.jsx)(p,{children:(0,r.jsx)(l.r,{value:"https://vibecodeapp.com/s/".concat(s),size:192,className:"w-48 h-48 rounded outline outline-3 outline-white",darkColor:"#000000"})})})]})}function g(e){let{shareId:t,projectData:s,isLoading:i,error:o}=e,[l,p]=(0,a.useState)(!1),{isSignedIn:u,isLoaded:g}=(0,x.Jd)(),f=async()=>{if(s){if(g&&!u){(0,h.F$)(t),window.location.href="/sign-up";
return}p(!0);
try{let e=await c.kj.projects.remix(t);
n.toast.success((0,r.jsxs)("div",{children:[(0,r.jsx)("div",{children:"Project remixed successfully!"}),(0,r.jsxs)("div",{className:"text-xs text-gray-600 mt-1",children:["New project: ",e.remixedProject.name]})]})),setTimeout(()=>{window.location.href="/workspace/".concat(e.remixedProject.id)},
1e3)}catch(e){console.error("Failed to remix project:",e),n.toast.error("Failed to remix project. Please try again.")}finally{p(!1)}}};
return(0,r.jsxs)("div",{className:"p-5 rounded-xl flex flex-col justify-start items-start gap-2.5 overflow-hidden",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(20px)",width:"500px"},
children:[(0,r.jsx)("div",{className:"inline-flex flex-col justify-start items-start pb-0",children:(0,r.jsx)("span",{className:"text-sm font-semibold",style:{color:"rgba(255, 255, 255, 0.9)"},
children:"Remix Project"})}),(0,r.jsx)("div",{className:"self-stretch border-b",style:{borderColor:"rgba(255, 255, 255, 0.1)"}}),(0,r.jsx)("div",{className:"self-stretch justify-center text-white/50 text-sm font-normal leading-tight pb-2",children:"Use this project as a template and make it your own."}),(0,r.jsxs)("button",{onClick:f,disabled:l,className:"w-full p-1 text-white/90 font-medium rounded-lg transition-colors flex justify-between items-center ".concat(l?"bg-white/5 cursor-not-allowed opacity-50":"bg-white/5 hover:bg-white/10"),children:[(0,r.jsxs)("div",{className:"flex justify-start items-center gap-0.5",children:[(0,r.jsx)("div",{className:"w-8 h-8 flex justify-center items-center",children:(0,r.jsx)(d,{className:"w-4 h-4 ".concat(l?"animate-spin":""),style:{color:"rgba(255, 255, 255, 0.5)"}})}),(0,r.jsxs)("div",{className:"inline-flex justify-start items-center gap-1",children:[(0,r.jsx)("span",{className:"text-sm font-medium",children:l?"Remixing...":"Remix"}),(0,r.jsx)("span",{className:"text-sm text-white/50",children:null==s?void 0:s.data.name})]})]}),(0,r.jsx)("div",{className:"w-8 h-8 rounded-lg flex justify-center items-center gap-3",children:(0,r.jsx)(m.A,{className:"w-5 h-5",style:{color:"rgba(255, 255, 255, 0.5)"}})})]})]})}function f(e){let{screenshot:t}=e;
return(null==t?void 0:t.url)?(0,r.jsx)("div",{className:"rounded-xl overflow-hidden bg-black/20",children:(0,r.jsx)("img",{src:t.url,alt:"Project preview",className:"w-full h-auto object-contain"})}):null}function j(e){let{projectData:t}=e;
return(0,r.jsx)("div",{className:"p-5 pb-0 rounded-xl flex flex-col justify-start items-start gap-2.5 overflow-hidden",style:{backgroundColor:"rgba(255, 255, 255, 0.00)",backdropFilter:"blur(20px)",width:"500px"},
children:(0,r.jsxs)("div",{className:"flex justify-center items-center gap-4",children:[t.data.iconUrl&&(0,r.jsx)("img",{src:t.data.iconUrl,alt:t.data.name,className:"w-16 h-16 rounded-xl object-cover"}),(0,r.jsx)("div",{className:"flex flex-col items-start gap-0",children:(0,r.jsx)("span",{className:"text-lg font-semibold text-white/90",children:t.data.name})})]})})}function b(e){let{shareId:t,projectData:s,isLoading:i,error:o}=e,[l,n]=(0,a.useState)(null),[c,d]=(0,a.useState)(!0);
(0,a.useEffect)(()=>{t&&(async()=>{try{let e=await fetch("/api/public/screenshot/".concat(t));
if(e.ok){let t=await e.json();
n(t)}}catch(e){console.error("Failed to load screenshot:",e)}finally{d(!1)}})()},
[t]);
let m=!c&&(null==l?void 0:l.url);
return(0,r.jsxs)(r.Fragment,{children:[(0,r.jsx)("div",{className:"workspace-glow-background"}),(0,r.jsx)("div",{className:"min-h-screen relative z-10",style:{backgroundColor:"rgba(14, 14, 14, 0.15)"},
children:(0,r.jsx)("div",{className:"flex justify-center items-center min-h-screen",children:i?(0,r.jsxs)("div",{className:"text-center",children:[(0,r.jsx)("div",{className:"animate-spin h-8 w-8 border-2 border-primary border-t-transparent rounded-full mx-auto mb-4"}),(0,r.jsx)("p",{className:"text-gray-400",children:"Loading project..."})]}):o||!s?(0,r.jsxs)("div",{className:"text-center space-y-4",children:[(0,r.jsx)("div",{className:"text-red-500 text-4xl mb-2",children:"⚠️"}),(0,r.jsx)("h1",{className:"text-lg font-semibold text-gray-400",children:o||"This project may not be published or the link may be invalid."})]}):(0,r.jsxs)("div",{className:"flex max-w-4xl w-full ".concat(m?"":"justify-center"),children:[(0,r.jsxs)("div",{className:"".concat(m?"flex-1":"max-w-lg"," flex flex-col gap-3 justify-center"),children:[(0,r.jsx)(j,{projectData:s}),s.data.allowRemix&&(0,r.jsx)(g,{projectData:s,shareId:t,isLoading:i,error:o}),(0,r.jsx)(u,{projectData:s,shareId:t})]}),m&&(0,r.jsx)("div",{className:"flex-1 flex items-center justify-center max-w-xs overflow-hidden",style:{backgroundColor:"rgba(255, 255, 255, 0.05)",backdropFilter:"blur(20px)",borderRadius:"40px"},
children:(0,r.jsx)(f,{screenshot:l})})]})})})]})}function v(e){let{shareId:t,isMobile:s,initialProjectData:a,initialError:i}=e;
return s?(0,r.jsx)(o,{shareId:t,projectData:a,isLoading:!1,error:i}):(0,r.jsx)(b,{shareId:t,projectData:a,isLoading:!1,error:i})}},
38990:(e,t,s)=>{"use strict";
s.d(t,{r:()=>c});
var r=s(95155),a=s(12115),i=s(13547),o=s(16862);
async function l(e){let t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},
s={width:256,margin:2,color:{dark:"#000000",light:"#FFFFFF"},
errorCorrectionLevel:"M"},
r={...s,...t,color:{...s.color,...t.color}};
try{return await o.toDataURL(e,{width:r.width,margin:r.margin,color:r.color,errorCorrectionLevel:r.errorCorrectionLevel})}catch(e){throw console.error("Error generating QR code:",e),Error("Failed to generate QR code")}}var n=s(51154);
function c(e){let{value:t,size:s=256,errorCorrectionLevel:o="M",darkColor:c="#000000",lightColor:d="#FFFFFF",className:m,onError:x,...h}=e,[p,u]=a.useState(null),[g,f]=a.useState(!0),[j,b]=a.useState(null);
return(a.useEffect(()=>{let e=!1;
return(async()=>{try{f(!0),b(null);
let r=await l(t,{width:s,errorCorrectionLevel:o,color:{dark:c,light:d}});
e||(u(r),f(!1))}catch(t){if(!e){let e=t instanceof Error?t:Error("Failed to generate QR code");
b(e),f(!1),null==x||x(e)}}})(),()=>{e=!0}},
[t,s,o,c,d,x]),g)?(0,r.jsx)("div",{className:(0,i.cn)("flex items-center justify-center",m),style:{width:s,height:s},
...h,children:(0,r.jsx)(n.A,{className:"h-8 w-8 animate-spin text-muted-foreground"})}):j?(0,r.jsx)("div",{className:(0,i.cn)("flex items-center justify-center border-2 border-dashed border-destructive/50 rounded-lg bg-destructive/10",m),style:{width:s,height:s},
...h,children:(0,r.jsx)("p",{className:"text-sm text-destructive text-center px-4",children:"Failed to generate QR code"})}):(0,r.jsx)("div",{className:(0,i.cn)("inline-block",m),...h,children:p&&(0,r.jsx)("img",{src:p,alt:"QR code for ".concat(t),width:s,height:s,className:"block"})})}},
51154:(e,t,s)=>{"use strict";
s.d(t,{A:()=>r});
let r=(0,s(19946).A)("loader-circle",[["path",{d:"M21 12a9 9 0 1 1-6.219-8.56",key:"13zald"}]])},
64067:(e,t,s)=>{Promise.resolve().then(s.bind(s,36894))},
92138:(e,t,s)=>{"use strict";
s.d(t,{A:()=>r});
let r=(0,s(19946).A)("arrow-right",[["path",{d:"M5 12h14",key:"1ays0h"}],["path",{d:"m12 5 7 7-7 7",key:"xquz4c"}]])}},
e=>{e.O(0,[265,7598,142,6862,5787,8441,5964,7358],()=>e(e.s=64067)),_N_E=e.O()}]);
