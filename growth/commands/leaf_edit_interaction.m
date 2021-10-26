function [m,ok] = leaf_edit_interaction( m, varargin )
%m = leaf_edit_interaction( m, ... )
%   Open the interaction function in the Matlab editor.
%   If there is no interaction function, create one.
%
%   Options:
%       'force'     If true, the interaction function will be opened even
%                   if the model m is marked read-only.  If false (the
%                   default) a warning will be given and the function not
%                   opened.
%
%   Extra results:
%       ok is true if the function was opened, false if for any reason it
%       was not.
%
%   Topics: Interaction function.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'force', false );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'force' );
    if ~ok, return; end
    
    ok = false;

    if m.globalProps.readonly && ~s.force
        fprintf( 1, '%s: Project is marked read-only.  Editing refused.\n', mfilename() );
        return;
    end
    modeldir = getModelDir( m );
    if isempty(modeldir)
        modeldir = pwd();
    end
    if isempty( m.globalProps.mgen_interactionName )
        % No interaction function.  Make one.
        m.globalProps.mgen_interactionName = makeIFname( m.globalProps.modelname );
        if isempty( m.globalProps.mgen_interactionName )
            % Error.  m.globalProps.modelname should be nonempty by this
            % point.  What should we do about it?
            fprintf( 1, '%s: Something impossible has occurred.\n    Interaction function cannot be loaded.\n', ...
                mfilename() );
            return;
        end
    end
    fullIFname = fullfile( modeldir, [m.globalProps.mgen_interactionName, '.m'] );
    if ~exist( fullIFname, 'file' )
        fprintf( 1, '%s: no interaction function is defined.\n', mfilename() );
        ok = writeInteractionSkeleton( fullIFname, m );
        if ~ok, return; end
    end
    m = resetInteractionHandle( m, mfilename() );

    try
        edit( fullIFname );
        ok = true;
    catch
        complain( 'Cannot open interaction file %s in editor.', ...
            fullIFname );
    end
end
