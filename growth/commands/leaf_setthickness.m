function [m,ok] = leaf_setthickness( m, varargin )
%[m,ok] = leaf_setthickness( m, ... )
%   Set the thickness of the leaf everywhere.
%   This only affects the current mesh and does not modify any of the
%   static mesh properties.
%
%   Options:
%
%   thickness: a number, interpreted as a proportion of the current
%       thickness.
%
%   offset:   Indicates how much thickness should be applied to the two
%       sides of the mesh. Zero means symmetric, 1 means that the A side
%       moved by the whole amount and the B side does not move, -1 means
%       the opposite, and intermediate values give intermediate results.
%
%   If thickness is being handled non-physically, the effect of this
%   command will be overridden on the next simulation step.  In that case
%   you should call leaf_setthicknessparams instead.
%
%   see also: leaf_setthicknessparams.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    
    % Legacy form: one argument, a number.
    [ok, thickness, args] = getTypedArg( mfilename(), 'numeric', varargin );
    if ok
        s = struct( 'thickness', thickness, 'offset', 0 );
    else
        % More recent form: option/argument pairs.
        [s,ok] = safemakestruct( mfilename(), varargin );
        if ~ok, return; end
        setGlobals();
        s = defaultfields( s, 'thickness', 0, 'offset', 0 );
        ok = checkcommandargs( mfilename(), s, 'exact', ...
            'thickness', 'offset' );
        if ~ok, return; end
    end
    if s.thickness <= 0
        fprintf( 1, '%s: thickness must be positive, value %f given.\n', ...
            mfilename(), s.thickness );
        ok = false;
        return;
    end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end
    
    m = setAbsoluteThickness( m, s.thickness, s.offset );
end
