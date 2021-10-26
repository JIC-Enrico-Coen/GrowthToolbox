function [m,ok] = leaf_dointeraction( m, varargin )
%[m,ok] = leaf_dointeraction( m, enable )
%   Execute the interaction function once, without doing any simulation
%   steps.  This will happen even if the do_interaction property of the mesh
%   is set to false, 
%   If there is no interaction function, this has no effect, and OK will be
%   returned as TRUE.
%   If there is an interaction function and it throws an exception, OK will
%   be returned as FALSE.
%
%   Arguments:
%       enable: 1 if the interaction function should be enabled for all
%       subsequent simulation steps, 0 if its state of enablement should be
%       left unchanged (the default).  If the i.f. throws an error then it
%       will be disabled for subsequent steps regardless of the setting of
%       this argument.
%
%   Topics: Interaction function.

    ok = false;
    if isempty(m), return; end
    [ok,enable,args] = getTypedArg( mfilename(), 'numeric', varargin, 0 );
    if ~ok
        return;
    end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', length(args) );
    end
    
    if enable
        m.globalProps.allowInteraction = true;
    end
    [m,ok] = attemptInteractionFunction( m );
end
