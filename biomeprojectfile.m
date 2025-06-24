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

  Matrix = zeros(Cols,Rows);
  Matrix((end-GRONDLAYER+1):end,1:end) = 1;
end

function Matrix = FallingSeed(Matrix);
  % zorg ervoor dat de zand valt
  
end

