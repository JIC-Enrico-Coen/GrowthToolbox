function m = disallowNegativeGrowth( m )
%m = disallowNegativeGrowth( m )
%   If m.globalProps.allowNegativeGrowth is false, force all growth-related
%   morphogens to be non-negative.

    if ~m.globalProps.allowNegativeGrowth
        growthMgens = growthIndexes( m );
        if ~isempty(growthMgens)
            m.morphogens(:,growthMgens) = ...
                max( m.morphogens(:,growthMgens), 0 );
        end
    end
end
