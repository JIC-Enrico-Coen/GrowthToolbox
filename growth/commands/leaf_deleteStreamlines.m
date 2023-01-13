function m = leaf_deleteStreamlines( m, varargin )
%m = leaf_deleteStreamlines( m, ... )
%   Delete streamlines.
%
%   Options:
%
%   streamlines: a list of indexes of streamlines to delete, or a boolean
%       map of them.  If not supplied, all streamlines are deleted.
%
%   alldata: a boolean (default false). If true, all statistics collected
%       about the streamlines will be zeroed, and new streamlines will be
%       numbered from 1. The tubule parameters and default structure of a
%       track will be unchanged.
%
%   See also: leaf_createStreamlines, leaf_growStreamlines.
%
%   Topics: Streamlines.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'streamlines', 'alldata' );
    if ~ok, return; end
    if ~isfield( s, 'alldata' )
        s.alldata = false;
    end


    if isfield( s, 'streamlines' )
        m.tubules.tracks( s.streamlines ) = [];
        m.tubules.statistics.deleted = m.tubules.statistics.deleted + length( s.streamlines );
    else
        m.tubules.statistics.deleted = m.tubules.statistics.deleted + length( m.tubules.tracks );
        m.tubules.tracks = [];
    end
    
    if s.alldata
        m.tubules = initTubules();
    end
end
