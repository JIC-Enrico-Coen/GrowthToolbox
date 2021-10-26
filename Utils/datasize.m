function n = datasize( s )
%n = structsize( s )
%   Estimate the number of bytes in anything.

    if iscell(s)
        n = 0;
        for i=1:numel(s)
            n = n + datasize(s{i});
        end
    elseif isstruct(s)
        n = 0;
        fns = fieldnames(s);
        for si=1:numel(s)
            for i=1:length(fns)
                fn = fns{i};
                n = n + datasize(s(si).(fn));
            end
        end
        for i=1:length(fns)
            fn = fns{i};
            n = n + length(fn);
        end
    else
        if issparse(s)
            n = length(find(s));
        else
            n = numel(s);
        end
    	switch class(s)
            case { 'logical', 'char', 'int8', 'uint8' }
                % No change.
            case 'double'
                n = n*8;
            case { 'int32', 'uint32' }
                n = n*4;
            case { 'int16', 'uint16' }
                n = n*2;
            otherwise
                % Don't know what this is.
                n = n*4;
        end
    end
end

function sz = Xdatasize( s )
    if isempty(s)
        sz = 0;
    elseif isnumeric(s) || ischar(s) || islogical(s)
        sz = numel(s);
    elseif iscell(s)
        sz = 0;
        for i=1:numel(s)
            sz = sz + datasize(s{i});
        end
    elseif isstruct(s)
        fns = fieldnames(s);
        for si=1:numel(s)
            sz = 0;
            for i=1:length(fns)
                fn = fns{i};
                sz = sz + datasize(s(si).(fn));
            end
        end
    else
        warning( '%s: Unknown data type %s, size assumed to be 1\.', mfilename(), class(s) );
    end
end
