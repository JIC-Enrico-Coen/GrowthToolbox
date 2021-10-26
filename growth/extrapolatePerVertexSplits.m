function m = extrapolatePerVertexSplits( m, ends )
%m = extrapolatePerVertexSplits( m, ends )
%   ENDS is a list of pairs of vertex indexes of M.  Each is assumed to
%   define an edge which has just been split, creating a new vertex at its
%   midpoint.  This procedure creates values at the new vertexes of every
%   per-vertex field of M.

    isVol = isVolumetricMesh( m );
    
    if isVol()
        pends = ends;
    else
        pends = [ ends*2-1; ends ];
    end
    
    newmgens = zeros( size(ends,1), size(m.morphogens,2) );
    newmgenprod = zeros( size(ends,1), size(m.morphogens,2) );
    for i=1:size(m.morphogens,2)
        newmgens(:,i) = splitVals( m.morphogens(:,i), ends, m.mgen_interpType{i} );
        newmgenprod(:,i) = splitVals( m.mgen_production(:,i), ends, m.mgen_interpType{i} );
        newmgenabsorp(:,i) = splitVals( m.mgen_absorption(:,i), ends, m.mgen_interpType{i} );
    end
    m.morphogens = [ m.morphogens; newmgens ];
    m.mgen_production = [ m.mgen_production; newmgenprod ];
    m.mgen_absorption = [ m.mgen_absorption; newmgenabsorp ];
    m.morphogenclamp = extendSplit( m.morphogenclamp, ends, 'min' );
    if ~isempty( m.growthanglepervertex )
        m.growthanglepervertex = extendSplit( m.growthanglepervertex, ends, 'ave' );
    end
    if isfield(m, 'growthTensorPerVertex')
        m.growthTensorPerVertex = extendSplit( m.growthTensorPerVertex, pends, 'ave' );
    end
    m.displacements = extendSplit( m.displacements, pends, 'ave' );
end