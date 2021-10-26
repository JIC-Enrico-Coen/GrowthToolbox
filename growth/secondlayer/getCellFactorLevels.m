function [i,p] = getCellFactorLevels( m, n, ci )
    if ~hasSecondLayer(m)
        i = 0;
        p = [];
        return;
    end
    
    if isnumeric(n)
        i = n;
    else
        i = name2Index( m.secondlayer.valuedict, n );
    end
    if isempty(i) || (i(1)==0)
        fprintf('Missing cellular value %s\n',n);
        p = [];
        return;
    end
    
    if isempty( m.secondlayer.cellvalues )
        p = [];
        return;
    end
    
    i = i(1);

    if nargout >= 2
        if nargin >= 3
            p = m.secondlayer.cellvalues(ci,i);
        else
            p = m.secondlayer.cellvalues(:,i);
        end
    end
end
