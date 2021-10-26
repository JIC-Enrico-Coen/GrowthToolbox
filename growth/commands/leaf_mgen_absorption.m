function m = leaf_mgen_absorption( m, varargin )
%m = leaf_mgen_absorption( m, morphogen, absorption )
%   Set the rate at which a specified morphogen is absorbed.
%   Arguments:
%   morphogen: The name or index of a morphogen.
%   absorption: The rate of decay of the morphogen.  A value of 1 means that
%      the morphogen decays by 1% every 0.01 seconds.
%   Values can be set for multiple morphogens by listing morphogen names
%   and absorptions alternately.  Where more than one morphogen is to be
%   given the same absorption, an array of morphogen indexes or a cell
%   array of morphogen names can be given.
%   Examples:
%       m = leaf_mgen_absorption( m, {'abc','def'}, 0.5 );
%
%   Equivalent GUI operation: setting the value in the "Absorption"
%   text box in the "Morphogens" panel.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if isempty(varargin), return; end
    
    
    
    args = varargin;
    while ~isempty(args)
        [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char','cell'}, args );
        if ok1
            [ok2, absorption, args] = getTypedArg( mfilename(), 'double', args );
        end
        if ~(ok1 && ok2), return; end
        absPerVertex = size( m.mgen_absorption, 1 ) > 1;
        needAbsPerVertex = size( absorption, 1 ) > 1;
        if needAbsPerVertex && ~absPerVertex
            m.mgen_absorption = repmat( m.mgen_absorption, getNumberOfVertexes(m), 1 );
        end
        g = FindMorphogenIndex( m, morphogen, mfilename() );
        g = g(g ~= 0);
        if ~isempty(g)
            m.mgen_absorption( :, g ) = absorption;
        end
    end
    saveStaticPart( m );
end
