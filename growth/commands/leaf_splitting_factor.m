function [m,ok] = leaf_splitting_factor( m, varargin )
%[m,ok] = leaf_splitting_factor( m, factorname )
%   Specify the name of a morphogen to use to control edge-splitting,
%   edge-flipping, and retriangulation.  Edges will only be modified by
%   these transformations if the value of the morphogen is at least 0.5 at
%   both ends.  Specify the empty string as the name to turn this off.
%
%   Topics: Morphogens, Simulation.

    ok = true;
    if isempty(m), return; end
    if isempty(varargin)
        ok = false;
        fprintf( 1, '%s: No factor name provided.\n', ...
            mfilename );
        return;
    end
    if length(varargin) > 1
        fprintf( 1, '%s: %d extra arguments ignored.\n', ...
            mfilename, length(varargin)-1 );
    end
    
    mgenname = varargin{1};
    if isempty(mgenname)
        m.globalProps.splitmorphogen = '';
    elseif ischar( mgenname )
        mgenname = upper(mgenname);
        if isfield( m.mgenNameToIndex, mgenname )
            m.globalProps.splitmorphogen = mgenname;
        else
            fprintf( 1, '%s: No such morphogen as ''%s''.\n', ...
                mfilename, mgenname );
            ok = false;
        end
    else
        fprintf( 1, '%s: String argument required, %s given.\n', ...
            mfilename, class(mgenname) );
        ok = false;
    end
end
