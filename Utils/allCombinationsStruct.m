function s1 = allCombinationsStruct( varargin )
    if nargin==0
        s1 = emptystructarray();
        return;
    end
    
    if isstruct(varargin{1})
        s = varargin{1};
    else
        s = struct( varargin{:} );
    end
    f = fieldnames(s);
    sc = cell(length(f),1);
    for i=1:length(f)
        sc{i} = s.(f{i});
    end
    c = allCombinationsCell( sc{:} );
    s1 = emptystructarray( size(c,2), f );
    for i=1:size(c,2)
        for j=1:length(f)
            s1(i).(f{j}) = c(j,i);
        end
    end
end

