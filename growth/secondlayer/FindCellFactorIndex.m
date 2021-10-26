function cfIndex = FindCellFactorIndex( m, cellfactor, messageprefix, complain )
%mgenIndex = FindCellFactorIndex( mesh, cellfactor, messageprefix, complain )
%   Find the index of any cell factor.  cellfactor can be an array of cell
%   factor indexes, a cell factor name, or a cell array of cell factor names or
%   indexes.  The list of indexes returned will exclude all invalid names
%   or indexes.  The messageprefix argument is optional and if empty or
%   absent defaults to the name of this procedure.  It will be prefixed to
%   every warning message about non-existent morphogens.  The complain
%   argument is optional (default false) and specifies whether a warning
%   message should be written to the console if any of the requested
%   factors do not exist.

    if isempty( m )
        cfIndex = [];
        return;
    end
    if (nargin < 3) || isempty(messageprefix)
        messageprefix = mfilename();
    end
    if nargin < 4
        complain = false;
    end
    numfactors = size( m.secondlayer.cellvalues, 2 );
    if isnumeric( cellfactor )
        cellfactor = abs(cellfactor);
        okindexmap = (1 <= cellfactor) & (cellfactor <= numfactors) & (cellfactor==int32(cellfactor));
        badindexes = cellfactor(~okindexmap);
        if complain && ~isempty(badindexes)
            if length(badindexes)==1
                fprintf( 1, '%s: No such cell factor index as %g.\n', messageprefix, badindexes );
            else
                fprintf( 1, '%s: No such cell factor indexes as', messageprefix );
                fprintf( 1, ' %d', badindexes );
                fprintf( 1, '.\n' );
            end
        end
        cfIndex = cellfactor(okindexmap);
    elseif ischar(cellfactor)
        cellfactor = lower(cellfactor);
        if isfield( m.secondlayer.valuedict.name2IndexMap, cellfactor )
            cfIndex = m.secondlayer.valuedict.name2IndexMap.(cellfactor);
        else
            if complain
                fprintf( 1, '%s: No such cell factor as "%s".\n', messageprefix, cellfactor );
            end
            cfIndex = [];
        end
    elseif iscell(cellfactor)
        cfIndex = zeros(1,numel(cellfactor));
        for i=1:numel(cellfactor)
            mi = FindCellFactorIndex( m, cellfactor{i}, messageprefix, complain );
            if ~isempty(mi)
                cfIndex(i) = mi;
            end
        end
        cfIndex(cfIndex==0) = [];
    end
end
