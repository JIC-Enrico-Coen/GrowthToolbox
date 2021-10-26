function cs = conductivityStruct( condArray )
    global gPerMgenDefaults
    if nargin < 1
        condArray = [];
    end
    if size(condArray,1) < size(condArray,1)
        condArray = condArray';
    end
    if isempty( condArray )
        cs = gPerMgenDefaults.conductivity;
    elseif numel(condArray)==1
        cs = struct( 'Dpar', condArray, 'Dper', [] );
    elseif numel(condArray)==2
        cs = struct( 'Dpar', condArray(1), 'Dper', condArray(2) );
    elseif size(condArray,2)==1
        cs = struct( 'Dpar', condArray(:,1), 'Dper', [] );
    else
        cs = struct( 'Dpar', condArray(:,1), 'Dper', condArray(:,2) );
    end
end

