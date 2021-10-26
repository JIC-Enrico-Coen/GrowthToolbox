function v = mgenGradient( m, amount, varargin )
%v = mgenGradient( m, direction )
%   Set v to a value per mesh vertex, according to the arguments of
%   leaf-mgen_linear.

    v = [];
    if numel(amount)==1
        amount = [0 amount];
    end
    g = FindMorphogenIndex( m, morphogen, mfilename() );
    if isempty(g), return; end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'direction', [1,0,0], 'add', true, 'nodes', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', 'direction', 'nodes', 'add' );
    if ~ok, return; end
    if length(s.direction)==1
        s.direction = s.direction * pi/180;
    end
    
    if isVolumetricMesh(m)
        nodes = m.nodes;
    else
        nodes = m.FEnodes;
    end
    % Process arguments as in leaf_mgen_linear
    v = nodes(:,1)*s.direction(1) + nodes(:,2)*s.direction(2) + nodes(:,3)*s.direction(3);
    v = v - min(v);
    if any(v ~= 0)
        v = v*((amount(1)-amount(0))/max(v)) + amount(0);
    end
end