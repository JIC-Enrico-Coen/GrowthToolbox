function eq = equalAnyType( v1, v2, fns )
%eq = equalAnyType( v1, v2, fns )
%   Determine whether two values of any sort are equal.  The Matlab ==
%   operator cannot be used for structs or cell arrays.  If v1 and v2 are
%   structs, the third argument can be a list of field names.  Only those
%   fields of v1 and v2 will be compared.

    eq = samesize( v1, v2 );
    if ~eq
        % Different size, therefore unequal.
        return;
    end

    if isempty(v1)
        % Both empty, therefore equal (even if of different types).
        return;
    end
    
    isnumlike1 = isnumeric(v1) || ischar(v1);
    isnumlike2 = isnumeric(v2) || ischar(v2);
    eq = isnumlike1 == isnumlike2;
    if ~eq
        % Number-like and non-number-like are not equal.
        return;
    end
    
    if isnumlike1 && isnumlike2
        eq = all(v1(:)==v2(:));
        return;
    end
    
    % At this point we know that neither v1 nor v2 are number-like.
        
    eq = strcmp(class(v1),class(v2));
    if ~eq
        % Nonempty and different non-number-like types, therefore unequal.
        return;
    end

    if isstruct(v1)
        fn1 = fieldnames(v1);
        fn2 = fieldnames(v2);
        if nargin >= 3
            % Compare only the specified fields, ignoring the others.
            fn1 = intersect( fn1, fns );
            fn2 = intersect( fn2, fns );
        end
        
        if length(fn1) ~= length(fn2)
            % Different number of fields, therefore unequal.
            eq = false;
            return;
        end
        
        numfields = length(fn1);

        fn1 = sort(fn1);
        fn2 = sort(fn2);
        eq = all( strcmp( fn1, fn2 ) );
        if ~eq
            % Unequal field names, therefore unequal.
            return;
        end
        
        for i=1:numel(v1)
            for j=1:numfields
                fn = fn1{j};
                if ~equalAnyType( v1(i).(fn), v2(i).(fn) )
                    eq = false;
                    return;
                end
            end
        end
    elseif iscell(v1)
        for i=1:numel(v1)
            if ~equalAnyType( v1{i}, v2{i} )
                eq = false;
                return;
            end
        end
    elseif isa( v1, 'function_handle' )
        eq = strcmp( func2str(v1), func2str(v2) );
    else
        % Catchall in case we missed some case.
        if any(v1 ~= v2)
            eq = false;
            return;
        end
    end
end

function eq = samesize( x, y )
    sz1 = size(x);
    sz2 = size(y);
    eq = (length(sz1)==length(sz2)) && all(sz1 == sz2);
end
