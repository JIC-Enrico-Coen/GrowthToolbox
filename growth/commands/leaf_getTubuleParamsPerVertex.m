function tubuleParamsPerVertex = leaf_getTubuleParamsPerVertex( m, varargin )
%tubuleParamsPerVertex = leaf_getTubuleParamPerVertex( m, paramname1, paramname2, ... )
%
%   For each of the specified microtubule parameters, find their current
%   value at every vertex. The result is an N*K array, where the mesh has N
%   vertexes and K parameter names were given.
%
%   The set of all microtubule parameter names can be found in the global
%   variable gMTProperties.
%
%   If an invalid name is given, the corresponding column of
%   tubuleParamsPerVertex will be zero.

    tubuleParamsPerVertex = zeros( getNumberOfVertexes(m), length(varargin) );
    for i=1:length(varargin)
        fn = varargin{i};
        if isfield( m.tubules.tubuleparams, fn )
            v = m.tubules.tubuleparams.(fn);
            if isnumeric(v)
                tubuleParamsPerVertex(:,i) = v;
            elseif ischar( v )
                mi = FindMorphogenIndex( m, v );
                if ~isempty(mi)
                    tubuleParamsPerVertex(:,i) = m.morphogens(:,mi);
                end
            end
        end
    end
end
