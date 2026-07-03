function s = structFromArrays( varargin )
%s = structFromArrays( FIELDNAME, VALUES, FIELDNAME, VALUES, ... )
%   Each of VALUES must be an array of the same number of elements.
%   The result is a struct array of that many structs, each of which maps
%   each FIELDNAME to the corresponding element of the corresponding
%   VALUES.
%
%   The numerical types of the VALUES are preserved.

    
    fns = varargin(1:2:end);
    fvals = varargin(2:2:end);
    if length(fns) ~= length(fvals)
        timedFprintf( 'Invalid arguments to structarray. Field and value input arguments must come in pairs. %d field names, %d values\n', ...
            length(fns), length(fvals) );
        s = [];
        return;
    end
    
    if isempty(fns)
        s = struct();
        return;
    end
    
    numfields = length(fns);
    numvals = size( fvals{1}, 1 );
    for fi=2:length(fns)
        if size( fvals{fi}, 1 ) ~= numvals
            timedFprintf( 'Each field value must have the same number of elements. Field ''%s'' has %d, field ''%s'' has %d.\n', ...
                fns{1}, numvals, fns{fi}, size( fvals{fi}, 1 ) );
            s = [];
            return;
        end
    end

    s = emptystructarray( [numvals 1], fns );
    for fi=1:numfields
        for vi=1:numvals
            s(vi).(fns{fi}) = fvals{fi}(vi,:);
        end
    end
end
    