function values = discretiseValues( allowedValues, values )
%values = discretiseValues( allowedValues, values )
%   Replace every element of values by the closest member of allowedValues.
%   Both allowedValues and values may validly include Inf or -Inf.
%   values and allowedValues may have any shape.  allowedValues does not
%   need to be sorted.

    if isempty(allowedValues)
        return;
    end
    allowedValues = reshape( sort(allowedValues), 1, [] );
    midvalues = [ -Inf, (allowedValues(1:(end-1)) + allowedValues(2:end))/2 ];
    ixs = sum( repmat( values(:), 1, length(midvalues) ) >= repmat( midvalues(:)', numel(values), 1 ), 2 );
    
    values = reshape( allowedValues( ixs ), size( values ) );
end
