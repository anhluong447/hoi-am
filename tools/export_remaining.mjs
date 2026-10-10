// Read-only source oracle. Writes JSON only to stdout; capture in target workspace.
import {pathToFileURL} from 'node:url';
const source = process.argv[2];
const load = p => import(pathToFileURL(`${source}/${p}`).href);
const {createSession,transition:act} = await load('src/domain/session.js');
const gameplay=[];
for(const [mode,days] of [['solo',14],['team',14],['mixed',14],['mixed',84]]) {
 let s=createSession({days});const commands=[];
 const run=c=>{commands.push(c);s=act(s,c);};
 while(!s.ended) {
  if(s.phase==='morning')run({type:'school'});
  if(s.phase==='club') {
   if(mode!=='solo')for(const [key,who] of [['community','long'],['documents','nhi']]) {
    const c=s.cases.find(c=>c.key===key&&c.week===Math.ceil(s.day/7)&&c.status==='available');
    if(c&&s.energy>=2&&!s.cases.some(x=>x.owner===who&&['working','blocked'].includes(x.status))) {
     run({type:'open',id:c.id});run({type:'assign',id:c.id,person:who});
    }
   }
   if(mode!=='team') {
    const q=s.quests.find(q=>!q.written);
    if(q) {
     for(const step of ['interview','photo','documents','courage'])if(!q.steps.includes(step)&&s.energy>=1)run({type:'quest',id:q.id,step});
     if(q.steps.length===4&&s.energy>=1)run({type:'write',id:q.id});
    }
   }
   run({type:'endClub'});
  }
  while(['personal','evening','weekend1','weekend2'].includes(s.phase))run({type:'activity',kind:'rest'});
  run({type:'sleep'});
  if(s.messages.some(m=>!m.resolved)) {
   for(const m of s.messages.filter(m=>!m.resolved))run({type:'approve',id:m.id,option:m.kind==='mismatch'?'cancel':'continue'});
   run({type:'sleep'});
  }
 }
 gameplay.push({id:days===84?'mixed-84-days':mode,commands,state:s});
}
const personalInitial=createSession();let personal=createSession();const personalSteps=[];
function step(c){const before=personal;try{personal=act(personal,c);personalSteps.push({command:c,ok:true,state:personal,events:personal.log.slice(before.log.length)});}catch(e){personalSteps.push({command:c,ok:false,error_text:e.message,state:personal,events:[]});}}
for(let day=1;day<=8;day++) {
 if(personal.phase==='morning')step({type:'school'});
 if(personal.phase==='club') {
  step({type:'boost'});step({type:'boost'});
  if(day===1)step({type:'tool',person:'van',stat:'documents'});
  step({type:'endClub'});
 }
 while(['personal','evening','weekend1','weekend2'].includes(personal.phase)) {
  if(personal.phase==='evening')step({type:'activity',kind:'job'});
  else if(day<=3)step({type:'activity',kind:'hangout',person:'van'});
  else if(day===4)step({type:'date',person:'van'});
  else if(day<=6)step({type:'activity',kind:'hangout',person:'nhi'});
  else if(day===7&&personal.phase==='weekend1')step({type:'date',person:'nhi'});
  else if(day===7)step({type:'gift',person:'long'});
  else step({type:'activity',kind:'train',stat:'photo'});
 }
 step({type:'sleep'});
}
step({type:'upgrade',person:'nhi',stat:'documents'});
const {POLICIES,simulate} = await load('src/app/Simulation.js');
const formula=POLICIES.map(p=>({id:p.id,state:simulate(p)}));
const {default:vi} = await load('content/locales/vi.js');
const text=await load('src/shared/text.js');text.registerLocale('capture',Object.fromEntries(Object.keys(vi).map(k=>[k,`@@${k}`])));text.setLocale('capture');
const balance=await load('content/sandbox/balance.js');
// Fixtures are already cached, so convert source labels with explicit stable IDs.
const {STAFF,createSubjects}=await load('content/sandbox/fixtures.js');
const names=['content.sandbox.fixtures.khue','content.sandbox.fixtures.van','content.gameplay.definitions.long','content.gameplay.definitions.nhi','content.sandbox.fixtures.cong_tac_vien_anh','content.sandbox.fixtures.cong_tac_vien_hien_truong'];
const staff=STAFF.map((p,i)=>{const {name,role,...rest}=p;return {...rest,name_key:names[i]};});
const subjects=createSubjects().map(p=>{const {name,...rest}=p;return {...rest,name_key:'content.sandbox.fixtures.de_tai_thu_value0_tuan_value1',name_parameters:{value0:Number(p.id.slice(-2)),value1:Number(p.id.slice(1,3))}};});
const policies=POLICIES.map(p=>{const {name,...rest}=p;return {...rest,name_key:Object.keys(vi).find(k=>vi[k]===name)};});
process.stdout.write(JSON.stringify({gameplay,personal:{id:'personal-all',initial:personalInitial,steps:personalSteps},formula,pack:{schema_version:1,config:balance.DEFAULT_CONFIG,staff,subjects,policies}}));
