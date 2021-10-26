function amountPerCell = VVconvertMconcToCamount( vvlayer, concPerMembrane )
%amountPerCell = VVconvertMconcToCamount( vvlayer, concPerMembrane )
%   Given a concentration defined per membrane vertex, convert it to a
%   total amount per cell.

    numcells = length(vvlayer.cellM);
    amountPerCell = zeros( numcells, 1 );
    
    amountPerMembrane = (concPerMembrane .* vvlayer.vxLengthsM)/2;
    ends = [find(vvlayer.edgeCM(1:(end-1),1) ~= vvlayer.edgeCM(2:end,1)); size(vvlayer.edgeCM,1) ];
    starts = [1; 1+ends(1:(end-1))];
    for i=1:numcells
        vxs = vvlayer.edgeCM( starts(i):ends(i), 2 );
        amountPerCell(i) = sum( amountPerMembrane(vxs) );
    end
end
