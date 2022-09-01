function m = leaf_setmorphogen( m, varargin )
%m = leaf_setmorphogen( m, mgens, values, mgens, values, ... )
%
%   Set the given morphogens to the given values.
%
%   Morphogens can be given as an array of morphogen indexes or a cell
%   array of morphogen names.
%
%   Values can be a single value, a single value per vertex (as a column
%   vector), a single value per morphogens (as a row vector) or as a value
%   per vertex per morphogen.
%
%   Names of non-existent morphogens are ignored.
%
%   Topics: Morphogens.

    for i=2:2:length(varargin)
        mgens = varargin{i-1};
        values = varargin{i};
        mgenindexes = FindMorphogenIndex2( m, mgens );
        if size(values,1)==1
            values = repmat( values, getNumberOfVertexes(m), 1 );
        end
        if (size(values,2)==1) && (length(mgenindexes) > 1)
            values = repmat( values, 1, length(mgenindexes) );
        end
        m.morphogens(:,mgenindexes) = values;
    end
end

