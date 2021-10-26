function m = setCellFactorLevels( m, n, v, ci )
    if isnumeric(n)
        i = n;
    else
        i = name2Index( m.secondlayer.valuedict, n );
    end
    if isempty(i)
        fprintf('Missing morphogen %s\n',n);
    else
        i = i(1);
    end
    
    if nargin >= 4
        m.secondlayer.cellvalues(ci,i) = v;
    else
        m.secondlayer.cellvalues(:,i) = v;
    end
end
