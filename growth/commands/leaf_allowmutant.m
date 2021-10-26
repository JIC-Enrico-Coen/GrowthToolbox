function m = leaf_allowmutant( m, varargin )
%m = leaf_allowmutant( m, enable )
%   Enable or disable the whole mutation feature.  When enabled, all mutant
%   levels of morphogens will be active.  When disabled, the tissue will
%   grow as the wild type.
%
%   Arguments:
%       enable: 1 or true to allow mutation, 0 or false to disable mutation.
%
%   Topics: Morphogens, Mutation.

    if isempty(m), return; end
    [ok, amount, args] = getTypedArg( mfilename(), 'logical', varargin );
    if ~ok, return; end
    
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', ...
            mfilename(), length(args) );
    end
    
    m.allMutantEnabled = amount ~= 0;
    saveStaticPart( m );
end
