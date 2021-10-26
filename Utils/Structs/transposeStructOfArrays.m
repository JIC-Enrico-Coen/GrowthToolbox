function ss = transposeStructOfArrays( s, n )
    if n <= 1
        ss = s;
        return;
    end
    
    fns = fieldnames(s);
    
    for i=1:length(fns)
        fn = fns{i};
        if isempty(s.(fn))
            s.(fn) = zeros(size(s.(fn)),class(s.(fn)));
        end
        if numel(s.(fn))==1
            s.(fn) = repmat( s.(fn), n, 1 );
        end
    end
    
    ss = emptystructarray( n, fns{:} );
    cellargs = cell( 2, length(fns) );
    cellargs(1,:) = fns;
    for i=1:n
        for j=1:length(fns)
            fn = fns{j};
            if (n > 1) && strcmp(fn,'status')
                BREAKPOINT
            end
            if isempty( s.(fn) )
                cellargs{2,j} = s.(fn);
            else
                cellargs{2,j} = s.(fn)(i,:);
            end
        end
        ss(i) = struct( cellargs{:} );
    end
end
