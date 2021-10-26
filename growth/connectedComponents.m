function [cc,cellcpt] = connectedComponents( m )
%cc = connectedComponents( m )
%   Find the connected components of m.  The result is a cell array of
%   arrays of cell indexes, one for each component, and an array listing
%   for each FE its component.
%   Connected components are defined as being connected across at least an
%   edge.  Thus parts connected only at corners will be regarded as separate
%   components, even though they may have one or more vertexes in common.
%
%   If it is desired to eliminate corner contacts, call SPLITCORNERTOUCH
%   first.

    numcells = size(m.tricellvxs,1);
    cellcpt = zeros(1,numcells);
    nc = sortrows( ...
            [ reshape(m.tricellvxs,[],1), ...
              reshape( (1:numcells)' * ones(1,size(m.tricellvxs,2)), [], 1 ) ...
            ] );
    numcpts = 0;
    cc = {};
    for ci=1:numcells
        if cellcpt(ci)==0
            numcpts = numcpts+1;
            cellsincpt = [];
            cellstoexamine = ci;
            while ~isempty(cellstoexamine)
                cellsincpt = [ cellsincpt, cellstoexamine ];
                cellcpt(cellstoexamine) = numcpts;
                ces = m.celledges(cellstoexamine,:);
                ccs = reshape(m.edgecells(ces,:),1,[]);
                cellstoexamine = unique(ccs(ccs > 0));
                cellstoexamine = cellstoexamine( cellcpt(cellstoexamine)==0 );
            end
            cc{numcpts} = cellsincpt;
        end
    end
end

