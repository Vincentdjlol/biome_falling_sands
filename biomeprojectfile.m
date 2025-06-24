clc;
clear all;

%-- Fazes --
%   0 = "lucht"
%   1 = "grond"
%   2 = "zaad"
%   3 = "plant"
%   4 = "dood plant"

% -- Variabele --

COLS = 30;
ROWS = 100;

% -- Functions --

function Matrix = CreateStartingWorld(Cols,Rows);
  GRONDLAYER = 3;
  % maak een wereld waar de de laagst 3 lagen grond zijn
  Matrix = zeros(Cols,Rows);
  Matrix((end-GRONDLAYER+1):end,1:end) = 1;
end

function Matrix = GrowPlant(Matrix);
  GROWSPEED = 50;
  
  % filteren van planten
  Mask = (Matrix == 3);
  %Nums = sum(Mask(:)); % tel de hoeveelheid die groeit
  Vals = randi(GROWSPEED, size(Matrix));
  Acti = (Mask & (Vals == 1));

  % Toon posities waar de actie wordt uitgevoerd
  [Row, Col] = find(Acti);

  % groei van planten
  for Index = 1:length(Row)
    % chek of boved de pant niets is anders groeit het niet.
    if sum(Matrix((Row-1):(Row+1),Col-1)) = 0; 
      % groei aan lings, rechst of midden op random.
      Kant = randi(1,3)
      Matrix(Kant,Col-1) = 3;
    end
  
  end
end 

function Matrix = FallingSeed(Matrix);
  % zorg ervoor dat de zand valt
  
  
end




