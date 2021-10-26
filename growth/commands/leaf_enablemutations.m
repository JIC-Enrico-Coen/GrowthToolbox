function m = leaf_enablemutations( m, varargin )
%m = leaf_enablemutations( m, enable )
%   Enable or disable mutations.
%
%   Arguments:
%   enable:  True to enable all mutations, false to disable them.
%
%   Examples:
%       m = leaf_enablemutations( m, 0 );
%           % Disable all mutations, i.e. revert to wild-type.
%
%   Topics: Morphogens, Mutation.

    if isempty(m), return; end
    [ok, enable, args] = getTypedArg( mfilename(), {'numeric','logical'}, varargin );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: Ignoring %d extra arguments.\n', length(args) );
    end
    
    m.allMutantEnabled = enable;
    saveStaticPart( m );
end
