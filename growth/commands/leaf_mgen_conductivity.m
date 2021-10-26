function m = leaf_mgen_conductivity( m, varargin )
%m = leaf_mgen_conductivity( m, morphogen, conductivity, ... )
%   Set the rate at which a specified morphogen diffuses through the leaf.
%   Arguments:
%   morphogen: The name or index of a morphogen.
%   conductivity: The diffusion constant for the morphogen, in units of
%       length^2/time.
%   Values can be set for multiple morphogens by listing morphogen names
%   and conductivities alternately.  Where more than one morphogen is to be
%   given the same conductivity, an array of morphogen indexes or a cell
%   array of morphogen names can be given.
%
%   Example:
%       m = leaf_mgen_conductivity( m, 'kapar', 0.05, {'foo','bar'}, 0.3, [10 12 13], 0.02 );
%   This will set the diffusion constant for KAPAR to 0.05, those for FOO
%   and BAR to 0.3, and those for morphogens 10, 12, and 13 to 0.02.
%
%   Equivalent GUI operation: setting the value in the "Diffusion"
%   text box in the "Morphogens" panel.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    if isempty(varargin), return; end
    
    args = varargin;
    while ~isempty(args)
        [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char','cell'}, args );
        if ok1
            [ok2, conductivity, args] = getTypedArg( mfilename(), 'double', args );
        end
        if ~(ok1 && ok2), return; end
        haveinf = any(isinf(conductivity(:)));
        if haveinf
            if ~all(isinf(conductivity(:)))
                fprintf( 1, '%s: Some but not all conductivity values were infinite. Assumed infinite everywhere.\n', ...
                    mfilename() );
            end
            conductivity = Inf;
        end
        if all(conductivity==conductivity(1))
            conductivity = conductivity(1);
        end
        if length(conductivity)==getNumberOfVertexes(m)
            conductivity = perVertextoperFE( m, conductivity );
        end
        g = FindMorphogenIndex( m, morphogen, mfilename() );
        for i=1:length(g)
            m.conductivity(g(i)) = conductivityStruct( conductivity );
        end
    end
    saveStaticPart( m );
end



