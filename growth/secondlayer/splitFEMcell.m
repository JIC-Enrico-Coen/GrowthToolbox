function secondlayer = splitFEMcell( secondlayer, femCell, newFemCell, splitv1, splitv2 )
%secondlayer = splitFEMcell( secondlayer, femCell, newFemCell, edge )
%   Recalculate the parent cell and barycentric coordinates when the FEM
%   cell with index femCell splits on the specified edge, with the new cell
%   index newFemCell.  The edge is specified by splitv1 and splitv2, which
%   are the FEM vertexes at either end of the split edge, with splitv1
%   belonging to the old FEM cell and splitv2 belonging to the new FEM cell.

    numvxs = length( secondlayer.vxFEMcell );
    for vi=1:numvxs
        if secondlayer.vxFEMcell(vi)==femCell
            if 1
                [secondlayer.vxFEMcell(vi),secondlayer.vxBaryCoords(vi,:)] = ...
                    splitBaryCoords( secondlayer.vxBaryCoords(vi,:), ...
                        femCell, newFemCell, splitv1, splitv2 );
            else
                % Determine which half it's in.
                test = secondlayer.vxBaryCoords( vi, [splitv1, splitv2] );
                if test(1) > test(2)
                    % It's in the old cell.
                    secondlayer.vxBaryCoords( vi, [splitv1, splitv2] ) = ...
                        [ test(1)-test(2), 2*test(2) ];
                else
                    % It's in the new cell.
                    secondlayer.vxFEMcell(vi) = newFemCell;
                    secondlayer.vxBaryCoords( vi, [splitv1, splitv2] ) = ...
                        [ 2*test(1), test(2)-test(1) ];
                end
            end
        end
    end
    
    [ok,secondlayer] = checkclonesvalid( secondlayer );
    if ~ok
        fprintf( 1, 'Invalid second layer in splitFEMcell.\n' );
        error( 'splitFEMcell' );
    end
end
