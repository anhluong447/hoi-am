// One-time oracle/content capture. Imports reference modules read-only.
import {pathToFileURL} from 'node:url';
const [source, mode] = process.argv.slice(2);
const load = p => import(pathToFileURL(`${source}/${p}`).href);
if (mode === 'packs') {
  const {default:vi} = await load('content/locales/vi.js');
  const text = await load('src/shared/text.js');
  text.registerLocale('migration', Object.fromEntries(Object.keys(vi).map(k=>[k,`@@${k}`])));
  text.setLocale('migration');
  const defs = await load('content/gameplay/definitions.js');
  const balance = await load('content/gameplay/balance.js');
  const {LEGACY_SKILLS} = await load('content/gameplay/migrations.js');
  const {phases,places} = await load('content/gameplay/presentation.js');
  const {MAPS} = await load('content/maps/definitions.js');
  const {INTERACTION_SCENES} = await load('content/dialogue/interaction-scenes.js');
  const convert = value => {
    if (Array.isArray(value)) return value.map(convert);
    if (value && typeof value==='object') return Object.fromEntries(Object.entries(value).map(([k,v])=>
      typeof v==='string' && v.startsWith('@@') ? [`${k}_key`,v.slice(2)] : [k,convert(v)]));
    return value;
  };
  const stats = Object.keys(defs.STAT_NAMES);
  const gameplay = {
    schema_version:1, balance,
    stats:stats.map(id=>({id,name_key:defs.STAT_NAMES[id].slice(2)})),
    roster:defs.roster.map(([id,name,female,joinDay,values])=>({id,name_key:name.slice(2),female,joinDay,stats:Object.fromEntries(stats.map((k,i)=>[k,values[i]]))})),
    cases:defs.templates.map(convert),
    quest_steps:defs.QUEST_STEPS.map(([id,name])=>({id,name_key:name.slice(2)})),
    phases:Object.entries(phases).map(([id,name])=>({id,name_key:name.slice(2)})),
    places:places.map(([id,name,description,x,y])=>({id,name_key:name.slice(2),description_key:description.slice(2),x,y})),
    legacy_skills:LEGACY_SKILLS,
    quest_title_key:'src.gameplay.engine.ho_so_khue_value0_cang_tin_va_nguoi_trong_cuoc'
  };
  const maps=convert(MAPS);
  for(const room of Object.values(maps)) {
    // Existing teammate map labels are technical IDs rather than localized names.
    for(const npc of room.npcs) if(npc.person) {
      npc.label_key=gameplay.roster.find(p=>p.id===npc.person).name_key; delete npc.label;
    }
    if(room.signs) room.signs=room.signs.map(([x,y,key])=>({x,y,label_key:key.slice(2)}));
  }
  process.stdout.write(JSON.stringify({gameplay,maps,dialogue:convert(INTERACTION_SCENES)}));
} else if(mode === 'oracles') {
  const {createSession,transition} = await load('src/domain/session.js');
  const traces=[];
  function record(id,initial,commands,scope='chapter02') {
    let state=structuredClone(initial); const steps=[];
    for(const command of commands) {
      const input=state, before=structuredClone(state), start=state.log.length;
      try {
        state=transition(state,command);
        steps.push({command,ok:true,state:structuredClone(state),events:state.log.slice(start)});
      } catch(error) {steps.push({command,ok:false,error_text:error.message,state:structuredClone(state),events:[]});}
      if(JSON.stringify(before)!==JSON.stringify(input)) throw new Error('Transition mutated source input');
    }
    traces.push({id,scope,initial,steps});
  }
  const day=()=>[{type:'school'},{type:'endClub'},{type:'activity',kind:'rest'},{type:'activity',kind:'rest'},{type:'sleep'}];
  record('calendar-weekend',createSession(),Array.from({length:5},day).flat().concat([
    {type:'school'}, {type:'activity',kind:'investigate'}, {type:'finishInvestigation'},
    {type:'activity',kind:'rest'},{type:'activity',kind:'rest'},{type:'sleep'},
    {type:'activity',kind:'rest'},{type:'activity',kind:'rest'},{type:'activity',kind:'rest'},{type:'sleep'}]));
  record('guards',createSession(),[{type:'sleep'},{type:'endClub'},{type:'nonsense'},{type:'school'},{type:'school'},{type:'finishInvestigation'}]);
  const ending=createSession(); ending.day=14; ending.phase='bed';
  record('final-day',ending,[{type:'sleep'},{type:'sleep'}]);
  const mismatch=createSession(); mismatch.phase='club'; mismatch.energy=4;
  record('assignment-reassignment',mismatch,[{type:'open',id:'W1-community'},{type:'assign',id:'W1-community',person:'nhi'},
    {type:'endClub'},{type:'activity',kind:'rest'},{type:'activity',kind:'rest'},{type:'sleep'},
    {type:'sleep'},{type:'approve',id:'W1-community-1-1',option:'reassign',person:'long'},{type:'sleep'}]);
  const publishing=createSession(); publishing.day=5; publishing.phase='bed';
  publishing.articles.push({id:'Q1',title:publishing.quests[0].title,branch:'khue',author:'khue',quality:.8,attraction:8,readyDay:3,score:79872,selected:true,published:false});
  publishing.cases[0].opened=true; publishing.cases[0].status='working'; publishing.cases[0].owner='long'; publishing.cases[0].attempts=1;
  record('publication-once',publishing,[{type:'sleep'},{type:'sleep'},{type:'approve',id:'W1-community-1-5',option:'continue'},{type:'sleep'}]);
  const working=createSession(); working.phase='bed'; working.cases[1].opened=true; working.cases[1].status='working'; working.cases[1].owner='nhi'; working.cases[1].attempts=1;
  record('editorial-next-day',working,[{type:'sleep'},{type:'approve',id:'W1-documents-1-1',option:'continue'},{type:'sleep'},
    ...day().slice(0,-1),{type:'sleep'},{type:'approve',id:'W1-documents-1-2',option:'continue'},{type:'sleep'},...day()]);
  // Coverage captured now for later chapters, deliberately outside the current port.
  record('quest-and-write',createSession(),[{type:'school'},{type:'quest',id:'Q1',step:'interview'},
    {type:'quest',id:'Q1',step:'photo'},{type:'quest',id:'Q1',step:'documents'},{type:'quest',id:'Q1',step:'courage'},
    {type:'write',id:'Q1'}],'chapter07');
  process.stdout.write(JSON.stringify(traces));
} else throw new Error('Expected packs or oracles mode');
