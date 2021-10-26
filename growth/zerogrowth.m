function m = zerogrowth( m, mgenIndexes, whichVertexes )
%mesh = zerogrowth( mesh, mgenIndexes, whichVertexes )
%   Set the specified morphogens (by default, all of the standard
%   morphogens that specify amounts of growth) to zero, and their
%   production rates and clamp settings.  If mgenIndexes is the string
%   'all', then all morphogens are set to zero. whichNodes, if supplied,
%   specifies which vertexes to act on, by default all of them. It can be
%   either a list of vertex indexes or a bitmap of all the vertexes.

    if nargin < 2
        mgenIndexes = growthIndexes( m );
    elseif strcmp(mgenIndexes,'all')
        mgenIndexes = 1:size( m.morphogens, 2 );
    end
    if isempty(mgenIndexes), return; end

    if nargin < 3
        whichVertexes = true(size(m.morphogens,1),1);
    end
    if isempty(whichVertexes), return; end

    m.morphogens(whichVertexes,mgenIndexes) = 0;
    m.morphogenclamp(whichVertexes,mgenIndexes) = 0;
    m.mgen_production(whichVertexes,mgenIndexes) = 0;
    m.mgen_absorption(whichVertexes,mgenIndexes) = 0;

    m.saved = 0;
end
