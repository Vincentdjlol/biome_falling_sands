% reset de workspace
clear all;
close all;

ROWS = 120;
COLS = 180;

% dit zijn de 5 types die elke cel als vorm in de matrix kan aanemen
EMPTY = 0;
SAND = 1;
WALL = 2;
SEED = 3;
PLANT = 4;
DEAD_PLANT = 5;

world = zeros(ROWS, COLS);

% rand van de matrix
margin = 10;
left = margin;
right = COLS - margin;
top = margin;
bottom = ROWS - margin;

% maak van de rand een muur
world(top:bottom, left) = WALL;
world(top:bottom, right) = WALL;
world(bottom, left:right) = WALL;
world(top, left:right) = WALL;
world(bottom-20:bottom-1, (left+1):(right-1)) = SAND;

sand_colors = [1.0, 0.8, 0.2; 1.0, 0.0, 0.0; 0.0, 0.0, 1.0; 0.0, 1.0, 0.0];
seed_color = [0.6, 0.3, 0.0];
plant_colors = [0.0, 0.8, 0.0; 0.0, 0.5, 1.0; 0.5, 0.0, 0.5; 1.0, 0.0, 0.0];
dead_color = [0.4, 0.3, 0.1];

sand_color_index = 1;
plant_color_index = 1;

death_age = zeros(ROWS, COLS); % counter voor wanneer de dode plant moet verdwijnen

fig = figure("Name", "Falling Sand", "NumberTitle", "off", "MenuBar", "none", "Color", [0 0 0.5]);
ax = axes('Parent', fig);
set(ax, 'Color', [0.3 0.5 0.8]);
axis(ax, 'off');
axis(ax, 'image');

cm = [0.2 0.4 0.8; sand_colors(sand_color_index, :); 0.3 0.3 0.3; seed_color; plant_colors(plant_color_index, :); dead_color];
colormap(ax, cm);

% alle knopjes
uicontrol("Style", "pushbutton", "String", "Sluit", "Position", [20 20 60 30], "Callback", @(src, event) close(fig)); % sluit het programma
uicontrol("Style", "pushbutton", "String", "Reset", "Position", [100 20 60 30], "Callback", @(src, event) setappdata(fig, "do_reset", true)); % reset het programma terug naar generatie 0
uicontrol("Style", "pushbutton", "String", "Verander plantkleur", "Position", [180 20 120 30], "Callback", @(src, event) setappdata(fig, "change_plant_color", true)); % verander kleur plant
uicontrol("Style", "pushbutton", "String", "Plaats Seed", "Position", [320 20 100 30], "Callback", @(src, event) setappdata(fig, "place_seed", true)); % klik op het scherm om een zaadje te plaatsen
uicontrol("Style", "togglebutton", "String", "Pauze", "Position", [440 20 60 30], "Value", 0, "Callback", @(src,event) setappdata(fig, "pause_sim", get(src, "Value"))); % pauzeer de simulatie, niks kan groeien vallen of doodgaan
uicontrol("Style", "pushbutton", "String", "Verander zandkleur", "Position", [520 20 120 30], "Callback", @(src, event) setappdata(fig, "change_sand_color", true)); % verander kleur zand
uicontrol("Style", "pushbutton", "String", "Export", "Position", [660 20 70 30], "Callback", @(src, event) setappdata(fig, "save_sim", true)); % sla een generatie op
uicontrol("Style", "pushbutton", "String", "Import", "Position", [750 20 70 30], "Callback", @(src, event) setappdata(fig, "load_sim", true)); % importer een generatie om te runnen

generation = 0;

while ishandle(fig) % Hoofdloop, blijft draaien zolang het figuur bestaat

    if isappdata(fig, "do_reset") && getappdata(fig, "do_reset") % Reset simulatie bij knopdruk
        world = zeros(ROWS, COLS);
        world(top:bottom, left) = WALL;
        world(top:bottom, right) = WALL;
        world(bottom, left:right) = WALL;
        world(top, left:right) = WALL;
        world(bottom-20:bottom-1, (left+1):(right-1)) = SAND;
        generation = 0;
        death_age = zeros(ROWS, COLS);
        rmappdata(fig, "do_reset");
        sand_color_index = 1;
        plant_color_index = 1;
        cm = [0.2 0.4 0.8; sand_colors(sand_color_index, :); 0.3 0.3 0.3; seed_color; plant_colors(plant_color_index, :); dead_color];
        colormap(ax, cm);
    endif

    if isappdata(fig, "change_plant_color") && getappdata(fig, "change_plant_color") % ga door de plantkleur index, en verander het met 1
        plant_color_index = plant_color_index + 1;
        if plant_color_index > size(plant_colors, 1)
            plant_color_index = 1;
        endif
        cm = [0.2 0.4 0.8; sand_colors(sand_color_index, :); 0.3 0.3 0.3; seed_color; plant_colors(plant_color_index, :); dead_color];
        colormap(ax, cm);
        rmappdata(fig, "change_plant_color");
    endif

    if isappdata(fig, "change_sand_color") && getappdata(fig, "change_sand_color") % ga door de zandkleur index, en verander het met 1
        sand_color_index = sand_color_index + 1;
        if sand_color_index > size(sand_colors, 1)
            sand_color_index = 1;
        endif
        cm = [0.2 0.4 0.8; sand_colors(sand_color_index, :); 0.3 0.3 0.3; seed_color; plant_colors(plant_color_index, :); dead_color];
        colormap(ax, cm);
        rmappdata(fig, "change_sand_color");
    endif

    if isappdata(fig, "place_seed") && getappdata(fig, "place_seed")
        [x_mouse, y_mouse] = ginput(1); % krijg de coordinaten van de muisklik
        x_idx = round(x_mouse);
        y_idx = round(y_mouse); % rond dit af naar een punt op de matrix
        if x_idx >= 1 && x_idx <= COLS && y_idx >= 1 && y_idx <= ROWS % ligt die ook in de matrix en niet daarbuiten
            if world(y_idx, x_idx) == EMPTY
                world(y_idx, x_idx) = SEED;
            endif
        endif
        rmappdata(fig, "place_seed"); % Verwijder de flag zodat er maar een zaadje spawnt per klik
    endif

    if isappdata(fig, "pause_sim") && getappdata(fig, "pause_sim")
        pause(0.1); % door dit constant te loopen pauzeert de simulatie constant
        continue;
    endif

    if isappdata(fig, "save_sim") && getappdata(fig, "save_sim")
        [file,path] = uiputfile('simulation.mat', 'Save Simulation');
        if isequal(file,0)
            disp('Opslaan gestopt');
        else
            world_data = world;
            gen = generation;
            save(fullfile(path,file), 'world_data', 'gen', 'plant_color_index', 'sand_color_index'); % sla alle toestanden op die nodig zijn voor het namaken van de simulatie
            disp(['Simulatie opgeslagen in ' fullfile(path,file)]);
        endif
        rmappdata(fig, "save_sim");
    endif

    if isappdata(fig, "load_sim") && getappdata(fig, "load_sim")
        [file,path] = uigetfile('simulation.mat','Load Simulation');
        if isequal(file,0)
            disp('Importeren gestopt');
        else
            loaded = load(fullfile(path,file));
            world = loaded.world_data;
            generation = loaded.gen;
            if isfield(loaded, 'plant_color_index')
                plant_color_index = loaded.plant_color_index;
            else
                plant_color_index = 1;
            endif
            if isfield(loaded, 'sand_color_index')
                sand_color_index = loaded.sand_color_index;
            else
                sand_color_index = 1;
            endif
            cm = [0.2 0.4 0.8; sand_colors(sand_color_index, :); 0.3 0.3 0.3; seed_color; plant_colors(plant_color_index, :); dead_color];
            colormap(ax, cm); % laad alle opgeslagen toestanden in
        endif
        rmappdata(fig, "load_sim");
    endif

    imagesc(ax, world, [0, 6]); % maak het venster aan
    axis(ax, 'off');
    axis(ax, 'image');
    title(ax, ["generation ", int2str(generation)], 'Color', 'k');
    drawnow();

    new_world = world;  % maak een kopie van wereld om veranderingen mee te gevem

    for y = 2:ROWS-1  % loop door alle rijen behalve de randjes
        for x = 2:COLS-1  % en loop door alle kolommen behalve de randjes
            if world(y,x) == DEAD_PLANT  % verhoog de counter voor een dood plantje
                death_age(y,x) = death_age(y,x) + 1;
                if death_age(y,x) > 20
                    new_world(y,x) = EMPTY;  % verwijder dode plant na 20 generaties
                    death_age(y,x) = 0;
                endif
            else
                death_age(y,x) = 0;  % reset als cel niet dood is
            endif
        endfor
    endfor

    for y = ROWS-1:-1:1  % loop van beneden naar boven door wereld
        for x = 2:COLS-1
            val = world(y,x);
            if val == SAND || val == SEED  % beweeg zand of zaad omlaag als mogelijk
                if world(y+1,x) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x) = val;
                elseif world(y+1,x-1) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x-1) = val;
                elseif world(y+1,x+1) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x+1) = val;
                elseif val == SEED && world(y+1,x) == SAND  % zaad wordt plant als het op zand ligt
                    new_world(y,x) = PLANT;
                endif
            elseif val == PLANT
                empty_above = 0;
                options = [];
                if world(y-1,x) == EMPTY
                    empty_above += 1;
                    options = [options; y-1 x];
                endif
                if x > 2 && world(y-1,x-1) == EMPTY
                    empty_above += 1;
                    options = [options; y-1 x-1];
                endif
                if x < COLS-1 && world(y-1,x+1) == EMPTY
                    empty_above += 1;
                    options = [options; y-1 x+1];
                endif
                if empty_above >= 3
                    if rand() < 0.3 % hoe hoger, hoe sneller de plant omhoog groeit
                        idx = randi(size(options,1));
                        pos = options(idx,:);
                        new_world(pos(1),pos(2)) = PLANT;
                    endif
                    if rand() < 0.3 % hoe hoger, hoe sneller en meer takken de plant groeit
                        if x > 2 && (world(y,x-1) == EMPTY || world(y,x-1) == SEED) && world(y-1,x-1) ~= WALL
                            new_world(y,x-1) = PLANT;
                        endif
                        if x < COLS-1 && (world(y,x+1) == EMPTY || world(y,x+1) == SEED) && world(y-1,x+1) ~= WALL
                            new_world(y,x+1) = PLANT;
                        endif
                    endif
                endif
                if rand() < 0.0001  % kans om zaad te laten vallen als plant
                    drop_positions = [];
                    candidates = [1 0; 1 -1; 1 1];
                    for i = 1:size(candidates,1)
                        ny = y + candidates(i,1);
                        nx = x + candidates(i,2);
                        if ny >= 1 && ny <= ROWS && nx >= 1 && nx <= COLS
                            if world(ny,nx) == EMPTY || world(ny,nx) == SEED
                                drop_positions = [drop_positions; ny nx];
                            endif
                        endif
                    endfor
                    if ~isempty(drop_positions)
                        idx = randi(size(drop_positions,1));
                        pos = drop_positions(idx,:);
                        if world(pos(1),pos(2)) ~= DEAD_PLANT
                            new_world(pos(1),pos(2)) = SEED; % drop dat zaad
                            new_world(y,x) = DEAD_PLANT; % en maak de plant dood
                            death_age(y,x) = 0;
                        endif
                    endif
                endif
            endif
        endfor
    endfor

    for y = 2:ROWS-1
        for x = 2:COLS-1
            if world(y,x) == DEAD_PLANT  % als mijn buren dood zijn, ga ook dood
                neighbors = [-1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1];
                for n = 1:size(neighbors,1)
                    ny = y + neighbors(n,1);
                    nx = x + neighbors(n,2);
                    if world(ny,nx) == PLANT
                        if rand() < 0.5
                            new_world(ny,nx) = DEAD_PLANT;
                            death_age(ny,nx) = 0;
                        endif
                    endif
                endfor
            endif
        endfor
    endfor

    world = new_world;  % Update normale wereld met alles wat is veranderd
    generation += 1;  % generatie counter omhoog

endwhile  % Einde!
