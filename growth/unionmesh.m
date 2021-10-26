function m = unionmesh( varargin )
%m = unionmesh( varargin )
%   Set m to be the union of the given meshes.
%   The meshes are assumed to be raw, i.e. only nodes and tricellvxs are
%   defined.  The same will be true of the result.

    m.nodes = zeros(0,3);
    m.tricellvxs = zeros(0,3);
    for i=1:length(varargin)
        if ~isempty( varargin{i} )
            numnodes = size(m.nodes,1);
            m.nodes = [ m.nodes; varargin{i}.nodes ];
            m.tricellvxs = [ m.tricellvxs; (varargin{i}.tricellvxs + numnodes) ];
        end
    end
end
