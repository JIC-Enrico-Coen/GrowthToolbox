function m = leaf_mgen_dilution( m, varargin )
%m = leaf_mgen_dilution( m, morphogen, enable )
%   Set the rate at which a specified morphogen is absorbed.
%   Arguments:
%   1: The name or index of a morphogen.
%   2: A boolean specifying whether to enable dilution by growth
%   Examples:
%       m = leaf_mgen_dilution( m, 'growth', 1 );
%
%   Equivalent GUI operation: setting the "Dilution" checkbox in the
%   "Morphogens" panel.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [ok1, morphogen, args] = getTypedArg( mfilename(), {'numeric','char','cell'}, varargin );
    if ok1
        [ok2, dilution, args] = getTypedArg( mfilename(), {'numeric','logical'}, args );
    end
    if ~(ok1 && ok2), return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end

    g = FindMorphogenIndex( m, morphogen, mfilename() );
    for i=1:length(g)
        m.mgen_dilution( g(i) ) = dilution ~= 0;
    end
    saveStaticPart( m );
end
