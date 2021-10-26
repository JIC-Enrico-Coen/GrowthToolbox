function m = leaf_mgen_production( m, varargin )
%m = leaf_mgen_production( m, morphogen, production, ... )
%   Set the rate at which a specified morphogen is produced.
%
%   Arguments:
%
%   morphogen: The name or index of a morphogen.
%   production: The rate of production of the morphogen.  This is the
%       absolute amount that is created in a single time unit. It can be a
%       single value or a value per vertex of the mesh.
%
%   Values can be set for multiple morphogens by listing morphogen names
%   and productions alternately.  Where more than one morphogen is to be
%   given the same production, an array of morphogen indexes or a cell
%   array of morphogen names can be given.
%
%   Example:
%       m = leaf_mgen_production( m, {'abc','def'}, 0.5 );
%
%   Equivalent GUI operation: none.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if isempty(varargin), return; end
    
    args = varargin;
    while ~isempty(args)
        [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char','cell'}, args );
        if ok1
            [ok2, production, args] = getTypedArg( mfilename(), 'double', args );
        end
        if ~(ok1 && ok2), return; end
        g = FindMorphogenIndex( m, morphogen, mfilename() );
        g = g(g ~= 0);
        if ~isempty(g)
            if (numel(production) > 1) && (size(production,1)==1)
                production = repmat( production, getNumberOfVertexes(m), 1 );
            end
            m.mgen_production( :, g ) = production;
        end
    end
    saveStaticPart( m );
end
