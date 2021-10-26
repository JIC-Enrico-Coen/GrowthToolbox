function m = cutCellsMulti( m, cs )
%m = cutCellsMulti( m, cs )
%   cs is a cell array of arrays of cell indexes.  cutCells will be called
%   for each member array of cs.

    if iscell(cs)
        for i=1:length(cs)
            m = cutCells( m, cs{i} );
        end
    else
        m = cutCells( m, cs );
    end
end

