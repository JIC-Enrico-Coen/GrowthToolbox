function amountPerCell = VVconvertCconcToCamount( m, concPerCell )
%amountPerCell = VVconvertCconcToCamount( m, concPerCell )
%   Given a concentration defined per cell vertex, convert it to a
%   total amount per cell.

    amountPerCell = concPerCell .* m.secondlayer.cellarea;
end
