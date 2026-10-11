# Selected room composition intentions

All rooms keep existing location IDs, target command IDs and progression. Furniture
is authored in content; runtime has no switch on location name. The newsroom scene
is the shared coastal room assembler, originating in the pilot. Each pack separately
owns art placement, camera, collision, light and motion.

| Location | Composition | Material/light | Interaction |
| --- | --- | --- | --- |
| Club | Four writing groups, archive/notice board, printer, harbor windows | Honey wood, window sunlight, cool ambient | Existing six targets and Van dialogue |
| Library | Rear bookcase banks, two reading desks, quiet sofa nook | Cooler oak/ambient, restrained fill | Notes desk and calendar |
| Cafe | Two round tables, sofa, service counter and pendant | Terracotta, warm hanging fill | Table notes and calendar |
| Home | Bed, sofa, laptop desk and coastal painting | Warm oak, evening tint and desk light | Desk notes and calendar |
| Shop | Broad counter, three jar shelves and striped awning | Muted terracotta, diffuse daylight | Counter notes and calendar |
| Job | Food-street facades, striped stalls, service counter, table and waiting bench | Cobble, warm daylight | Counter notes and calendar |
| School | Independent courtyard, school facade, trees, bench, notice stand | Cobble, outdoor sunlight, larger camera/overscan | Notice stand and facade clock |
| Waterfront | Stone quay, railing, pier, boat, palms and three distant layers | Teal sea motion, warmer outdoor sun | Bench notes and streetlamp clock |

School/waterfront use their own wider collision bounds, camera distance, follow
maximum and background overscan. They are composed from outdoor silhouettes rather
than stretching the interior wall kit. Fixed outdoor cutouts can opt into silhouette
shadows; indoor furniture/actors retain separate proxies.

No new NPC, story, quest or balancing is introduced. Non-club prototypes previously
reused newsroom desk/clock labels; catalog notes/calendar labels now describe the
same existing quest/calendar workspace commands without adding canon.

Generated source masters and old prototype JSON remain intact. Native High/Low,
approach/anchor/portal/save checks and user review determine acceptance separately.
Agent review is a delivery checkpoint; final user art acceptance remains pending.
