# Gentry-fication v0.1
A project looking at the relationship between aristocratic names and the street names of the United Kingdom.

![A shot of central London with all the roads whose names have links to aristocrats highlighted in yellow](https://github.com/siskiyoucedar/Gentry-fication/assets/124599703/68675357-9695-48a2-a18b-83461c13707b)

"_ew, that img looks gross!_"

**I know. The viz for this project is still WIP**

## Input Data

To use this code you will need:

- The open access Ordnance Survey geometry for all the roads in the country, available [here](https://www.ordnancesurvey.co.uk/products/os-mastermap-highways-network-roads#get): **oproad_gb.gpkg**
- The five files included in *words_input*: **aristocracy.csv, county_towns.csv, monarchs.csv, nouns.csv, place_names.csv**
    - The lists of names included in my various .csv files are currently sourced from Wikipedia, and I'm not sorry about this. My mum has suggested I cross-check with Whitaker's Almanack, which, amazingly, I'm going to do.
- Whitaker's Almanack. It is hefty, so not in the repo. Enjoy searching for it!!!!

## Current to-do

Trying to run commands on 400,000 datapoints is proving a dead bother, so I'm not going to do it. Instead:

- Filter to Greater London (work by borough) before joining names-data
- Produce stats on % aristocratic names in each LB
- Build out hypotheses: one would expect higher % across inner London with particular hotspots in Westminster, Kensington for obvious reasons
- Continue reading. Victorian studies is litty as hell!
- Almanack cross-checks for peerages etc.
