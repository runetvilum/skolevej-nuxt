#http://www.gnu.org/prep/standards/html_node/Standard-Targets.html#Standard-Targets
TOOL_ROOT?=$(shell pwd)/node_modules/osrm/lib/binding
PROFILES?=$(shell pwd)/osrm/profiles
OSRM_EXTRACT:=$(TOOL_ROOT)/osrm-extract
OSRM_CONTRACT:=$(TOOL_ROOT)/osrm-contract
OSRM_PARTITION:=$(TOOL_ROOT)/osrm-partition
OSRM_CUSTOMIZE:=$(TOOL_ROOT)/osrm-customize
OGR2OSM:=osrm/ogr2osm/

clean:
	rm -rf osrm/bicycle
	rm -rf osrm/car
	rm -rf osrm/foot
	rm -rf osrm/osm

josm: 
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Skolevej_0-3_ny.osm osrm/data/Skolevej_0-3_20210520.geojson
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_old.py -o osrm/osm/Skolevej_0-3_old.osm osrm/data_old/Skolevej_0-3_20210520.geojson


osm: clean
	mkdir -p osrm/osm
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Skolevej_0-3.osm osrm/data/Skolevej_0-3_20210520.geojson --id 200000
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Skolevej_4-6.osm osrm/data/Skolevej_4-6_20210520.geojson --id 200000
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Skolevej_7-10.osm osrm/data/Skolevej_7-10_20210520.geojson --id 200000
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Vejmidte.osm osrm/data/Alle_veje.geojson --id 200000
    
copy: osm
	mkdir -p osrm/bicycle
	mkdir -p osrm/foot
	mkdir -p osrm/car
	cp osrm/osm/Skolevej_0-3.osm osrm/bicycle/.
	cp osrm/osm/Skolevej_0-3.osm osrm/foot/.
	cp osrm/osm/Skolevej_0-3.osm osrm/car/.
	cp osrm/osm/Skolevej_4-6.osm osrm/bicycle/.
	cp osrm/osm/Skolevej_4-6.osm osrm/foot/.
	cp osrm/osm/Skolevej_4-6.osm osrm/car/.
	cp osrm/osm/Skolevej_7-10.osm osrm/bicycle/.
	cp osrm/osm/Skolevej_7-10.osm osrm/foot/.
	cp osrm/osm/Skolevej_7-10.osm osrm/car/.
	cp osrm/osm/Vejmidte.osm osrm/bicycle/.
	cp osrm/osm/Vejmidte.osm osrm/foot/.
	cp osrm/osm/Vejmidte.osm osrm/car/.
    
extract: copy
	@echo "Running osrm-extract..."
	$(OSRM_EXTRACT) osrm/bicycle/Skolevej_0-3.osm -p $(PROFILES)/bicycle.lua
	$(OSRM_EXTRACT) osrm/bicycle/Skolevej_4-6.osm -p $(PROFILES)/bicycle.lua    
	$(OSRM_EXTRACT) osrm/bicycle/Skolevej_7-10.osm -p $(PROFILES)/bicycle.lua
	$(OSRM_EXTRACT) osrm/bicycle/Vejmidte.osm -p $(PROFILES)/bicycle.lua
	$(OSRM_EXTRACT) osrm/car/Skolevej_0-3.osm -p $(PROFILES)/car.lua
	$(OSRM_EXTRACT) osrm/car/Skolevej_4-6.osm -p $(PROFILES)/car.lua    
	$(OSRM_EXTRACT) osrm/car/Skolevej_7-10.osm -p $(PROFILES)/car.lua
	$(OSRM_EXTRACT) osrm/car/Vejmidte.osm -p $(PROFILES)/car.lua
	$(OSRM_EXTRACT) osrm/foot/Skolevej_0-3.osm -p $(PROFILES)/foot.lua
	$(OSRM_EXTRACT) osrm/foot/Skolevej_4-6.osm -p $(PROFILES)/foot.lua    
	$(OSRM_EXTRACT) osrm/foot/Skolevej_7-10.osm -p $(PROFILES)/foot.lua
	$(OSRM_EXTRACT) osrm/foot/Vejmidte.osm -p $(PROFILES)/foot.lua
    
partition: extract
	@echo "Running osrm-partition..."
	$(OSRM_PARTITION) osrm/bicycle/Skolevej_0-3.osrm
	$(OSRM_PARTITION) osrm/bicycle/Skolevej_4-6.osrm
	$(OSRM_PARTITION) osrm/bicycle/Skolevej_7-10.osrm
	$(OSRM_PARTITION) osrm/bicycle/Vejmidte.osrm
	$(OSRM_PARTITION) osrm/car/Skolevej_0-3.osrm
	$(OSRM_PARTITION) osrm/car/Skolevej_4-6.osrm
	$(OSRM_PARTITION) osrm/car/Skolevej_7-10.osrm
	$(OSRM_PARTITION) osrm/car/Vejmidte.osrm
	$(OSRM_PARTITION) osrm/foot/Skolevej_0-3.osrm
	$(OSRM_PARTITION) osrm/foot/Skolevej_4-6.osrm
	$(OSRM_PARTITION) osrm/foot/Skolevej_7-10.osrm
	$(OSRM_PARTITION) osrm/foot/Vejmidte.osrm
	
customize: partition
	@echo "Running osrm-customize..."
	$(OSRM_CUSTOMIZE) osrm/bicycle/Skolevej_0-3.osrm
	$(OSRM_CUSTOMIZE) osrm/bicycle/Skolevej_4-6.osrm
	$(OSRM_CUSTOMIZE) osrm/bicycle/Skolevej_7-10.osrm
	$(OSRM_CUSTOMIZE) osrm/bicycle/Vejmidte.osrm
	$(OSRM_CUSTOMIZE) osrm/car/Skolevej_0-3.osrm
	$(OSRM_CUSTOMIZE) osrm/car/Skolevej_4-6.osrm
	$(OSRM_CUSTOMIZE) osrm/car/Skolevej_7-10.osrm
	$(OSRM_CUSTOMIZE) osrm/car/Vejmidte.osrm
	$(OSRM_CUSTOMIZE) osrm/foot/Skolevej_0-3.osrm
	$(OSRM_CUSTOMIZE) osrm/foot/Skolevej_4-6.osrm
	$(OSRM_CUSTOMIZE) osrm/foot/Skolevej_7-10.osrm
	$(OSRM_CUSTOMIZE) osrm/foot/Vejmidte.osrm
	
contract: extract
	@echo "Running osrm-contract..."
	$(OSRM_CONTRACT) osrm/bicycle/Skolevej_0-3.osrm
	$(OSRM_CONTRACT) osrm/bicycle/Skolevej_4-6.osrm
	$(OSRM_CONTRACT) osrm/bicycle/Skolevej_7-10.osrm
	$(OSRM_CONTRACT) osrm/bicycle/Vejmidte.osrm
	$(OSRM_CONTRACT) osrm/car/Skolevej_0-3.osrm
	$(OSRM_CONTRACT) osrm/car/Skolevej_4-6.osrm
	$(OSRM_CONTRACT) osrm/car/Skolevej_7-10.osrm
	$(OSRM_CONTRACT) osrm/car/Vejmidte.osrm
	$(OSRM_CONTRACT) osrm/foot/Skolevej_0-3.osrm
	$(OSRM_CONTRACT) osrm/foot/Skolevej_4-6.osrm
	$(OSRM_CONTRACT) osrm/foot/Skolevej_7-10.osrm
	$(OSRM_CONTRACT) osrm/foot/Vejmidte.osrm

test: 
#	$(OGR2OSM)ogr2osm.py -f -t translation_0-3.py -o Skolevej_0-3.osm Vejmidte.geojson
	cp Skolevej_0-3.osm bicycle/.
	$(OSRM_EXTRACT) bicycle/Skolevej_0-3.osm -p $(PROFILES)/bicycle.lua
	$(OSRM_CONTRACT) bicycle/Skolevej_0-3.osrm

prepare:
	$(OSRM_PARTITION) bicycle/Skolevej_0-3.osrm
	$(OSRM_CUSTOMIZE) bicycle/Skolevej_0-3.osrm

denmark:
	$(OSRM_EXTRACT) data/denmark-latest.osm.pbf --threads 1 -p $(PROFILES)/car.lua
#	$(OSRM_PARTITION) data/denmark-latest.osrm
#	$(OSRM_CUSTOMIZE) data/denmark-latest.osrm

rune:
	rm -rf osrm/bicycle
	$(OGR2OSM)ogr2osm.py -f -t osrm/translations/translation_vej.py -o osrm/osm/Vejmidte.osm osrm/data/Alle_veje_20210520.geojson
	mkdir -p osrm/bicycle
	cp osrm/osm/Vejmidte.osm osrm/bicycle/.
	$(OSRM_EXTRACT) osrm/bicycle/Vejmidte.osm -p $(PROFILES)/bicycle.lua
