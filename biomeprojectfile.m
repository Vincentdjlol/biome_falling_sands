clear all;

ROWS = 120;
COLS = 180;

EMPTY = 0;
SAND = 1;
WALL = 2;

world = zeros(ROWS, COLS);

margin = 10;
left = margin;
right = COLS - margin;
top = margin;
bottom = ROWS - margin;

% muren
world(top:bottom, left) = WALL;
world(top:bottom, right) = WALL;
world(bottom, left:right) = WALL;
world(top, left:right) = WALL;

world(bottom-20:bottom-1, (left+1):(right-1)) = SAND;

sand_colors = [
    1.0, 0.8, 0.2;  % geel
    1.0, 0.0, 0.0;  % rood
    0.0, 0.0, 1.0;  % blauw
    0.0, 1.0, 0.0]; % groen

sand_color_index = 1;

fig = figure("Name", "Falling Sand", "NumberTitle", "off", "MenuBar", "none");
set(fig, "Position", [100, 100, 1000, 700]);

colormap([1 1 1; sand_colors(sand_color_index, :); 0.3 0.3 0.3]);

uicontrol("Style", "pushbutton", "String", "Sluit", "Position", [20 20 60 30], ...
    "Callback", @(src, event) setappdata(fig, "stop_simulation", true));
uicontrol("Style", "pushbutton", "String", "Reset", "Position", [100 20 60 30], ...
    "Callback", @(src, event) setappdata(fig, "do_reset", true));
muurk = uicontrol("Style", "togglebutton", "String", "Muur uit", ...
    "Position", [260 20 90 30], "Value", 0, "Callback", @(src, event) []);
kleurk = uicontrol("Style", "pushbutton", "String", "Verander kleur", ...
    "Position", [360 20 100 30], "Callback", @(src, event) setappdata(fig, "change_color", true));
strooik = uicontrol("Style", "togglebutton", "String", "Strooi zand", ...
    "Position", [480 20 100 30], "Value", 0);

generation = 0;

block_size = 6;
mid_x = round((left + right) / 2);
mid_y = round((top + bottom) / 2);


## Functions ##

function world = GrowPlantAndSeeds(world);
  % plant groeit -- kan nog dat je dit kan verandern
  GROWSPEED1 = 50;
  SEEDSPEED2 = 5000;

  % filteren van planten
  Mask = (world == 3);
  
  %Nums = sum(Mask(:)); % tel de hoeveelheid die groeit
  Vals1 = randi(GROWSPEED, size(world));
  Vals2 = randi(SEEDSPEED, size(world));
  
  Acti1 = (Mask & (Vals == 1));
  Acti2 = (Mask & (Vals == 1));

  % alle posities waar de actie wordt uitgevoerd
  [Row1, Col1] = find(Acti1);
  [Row2, Col2] = find(Acti2);
  
  % groei van planten
  for Index = 1:nnz(Mask);
    % chek of boved de pant niets is anders groeit het niet.
    if sum(world((Row1-1):(Row1+1),Col1-1)) = 0;
      % groei aan lings, rechst of midden op random.
      Kant = randi(1,3)
      world(Kant,Col-1) = 3;
    elseif world(Row2, Col2) = 3;
      world(Row2, Col2) = 2;
    end
    
  end
end

## main script ##

while ishandle(fig) && ~isappdata(fig, "stop_simulation")

    if isappdata(fig, "do_reset") && getappdata(fig, "do_reset")
        world = zeros(ROWS, COLS);
        world(top:bottom, left) = WALL;
        world(top:bottom, right) = WALL;
        world(bottom, left:right) = WALL;
        world(top, left:right) = WALL;
        world(bottom-20:bottom-1, (left+1):(right-1)) = SAND;
        generation = 0;
        rmappdata(fig, "do_reset");
        set(muurk, "Value", 0);
        set(muurk, "String", "Muur uit");
        sand_color_index = 1;
        colormap([1 1 1; sand_colors(sand_color_index, :); 0.3 0.3 0.3]);
    endif

    if get(muurk, "Value") == 1
        x_range = (mid_x - floor(block_size/2)):(mid_x + ceil(block_size/2) - 1);
        y_range = (mid_y - floor(block_size/2)):(mid_y + ceil(block_size/2) - 1);
        world(y_range, x_range) = WALL;
        set(muurk, "String", "Muur aan");
    else
        x_range = (mid_x - floor(block_size/2)):(mid_x + ceil(block_size/2) - 1);
        y_range = (mid_y - floor(block_size/2)):(mid_y + ceil(block_size/2) - 1);
        mask = (world(y_range, x_range) == WALL);
        tmp = world(y_range, x_range);
        tmp(mask) = EMPTY;
        world(y_range, x_range) = tmp;
        set(muurk, "String", "Muur uit");
    endif

    if isappdata(fig, "change_color") && getappdata(fig, "change_color")
        sand_color_index = sand_color_index + 1;
        if sand_color_index > size(sand_colors, 1)
            sand_color_index = 1;
        endif
        colormap([1 1 1; sand_colors(sand_color_index, :); 0.3 0.3 0.3]);
        rmappdata(fig, "change_color");
    endif

    imagesc(world);
    axis off;
    axis image;
    title(["generation ", int2str(generation)]);
    drawnow();

    new_world = world;

    for y = ROWS-1:-1:1
        for x = 2:COLS-1
            if world(y,x) == SAND
                if world(y+1,x) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x) = SAND;
                elseif world(y+1,x-1) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x-1) = SAND;
                elseif world(y+1,x+1) == EMPTY
                    new_world(y,x) = EMPTY;
                    new_world(y+1,x+1) = SAND;
                endif
            endif
        endfor
    endfor

    world = new_world;
    generation = generation + 1;

endwhile

close(fig);
