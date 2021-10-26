function m = leaf_setthicknessparams( m, varargin )
%m = leaf_setthicknessparams( m, value )
%   Set the thickness of the leaf, as a function of its current area.
%   thickness = K*area^(P/2).
%   K may have any positive value.  P must be between 0 and 1.
%   When P is 1, K is dimensionless; when P is 0, K is the actual thickness
%   in length units.
%
%   Options:
%       'scale'     K.  Default is 0.5.
%       'power'     P.  Default is 0.
%
%   Topics: Mesh editing, Simulation.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'scale', 'power' );
    if ~ok, return; end
    if isfield( s, 'scale' ) && (s.scale <= 0)
        fprintf( 1, '%s: Invalid argument %.3f: positive value required.\n', ...
            mfilename(), s.scale );
        return;
    end
    if isfield( s, 'power' )
        if s.power < 0
            fprintf( 1, '%s: Invalid argument %.3f: non-negative value required.\n', ...
                mfilename(), s.power );
            return;
        end
        if s.power > 1
            fprintf( 1, '%s: Invalid argument %.3f: maximum allowed value is 1.\n', ...
                mfilename(), s.power );
            return;
        end
    end

    if isfield( s, 'power' )
        m.globalProps.thicknessArea = s.power;
    end
    if isfield( s, 'scale' )
        m.globalProps.thicknessRelative = s.scale;
    end
    m = restorethickness( m );
end
