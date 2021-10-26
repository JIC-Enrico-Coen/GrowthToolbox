function concPerCell = VVconvertMembraneToCell( m, concPerMembrane )
%concPerCell = VVconvertMembraneToCell( m, concPerMembrane )
%   Given a value defined per membrane, convert it to a value per cell.
%   All of these values represent concentrations, the former at each
%   point along the membrane and the latter throughout the cytoplasm.
%   Therefore the conversion requires calculating the total amount of
%   substance on the membrane by multiplying each membrane value by the
%   length of the corresponding membrane segment, adding this up around the
%   cell, and dividing the sum by the area of the cell.

    amountPerCell = VVconvertMconcToCamount( m.secondlayer.vvlayer, concPerMembrane );
    concPerCell = amountPerCell ./ m.secondlayer.cellarea;
end
