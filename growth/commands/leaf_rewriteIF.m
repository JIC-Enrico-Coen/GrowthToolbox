function m = leaf_rewriteIF( m, varargin )
%m = leaf_rewriteIF( m, ... )
%   Rewrite the interaction function of m.
%
%   Normally the interaction function is rewritten the first time that it
%   is called after loading a mesh.  This is to ensure that it is always
%   compatible with the current version of GFtbox.  Sometimes it is
%   necessary to prevent this from happening.  In this case, if it is later
%   desired to force a rewrite, this function can be called.
%
%   leaf_rewriteIF will do nothing if the i.f. has already been rewritten,
%   unless the 'force' option has value true.
%
%   Note that a rewrite always happens when a morphogen is added, deleted,
%   or renamed, or when the standard morphogen type (K/BEND or A/B) is
%   changed.
%
%   Equivalent GUI operation: the Rewrite button on the Interaction
%   function panel.
%
%   Topics: Interaction function.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'force', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'force' );
    if ~ok, return; end
    if s.force || m.rewriteIFneeded
        [m,ok] = rewriteInteractionSkeleton( m, '', '', mfilename() );
    end
end
