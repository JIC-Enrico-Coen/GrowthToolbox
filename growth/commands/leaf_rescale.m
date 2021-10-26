function m = leaf_rescale( m, varargin )
%m = leaf_rescale( m, ... )
%   Rescale a mesh in space and/or time.  All dat in the mesh that depends
%   on the space or time scales will be scaled in such a way that a single
%   simulation step will have an identical effect.  Thus not only is the
%   geometry rescaled, but also the time step, the diffusion constants, the
%   decay rates, and so on.
%
%   Stage times are not rescaled and existing stage files are left
%   unchanged.
%
%   Options:
%       'spaceunitname'     The name of the new unit of distance.
%       'spaceunitvalue'    The number of old units that the new unit is
%                           equal to.
%       'timeunitname'      The name of the new unit of time.
%       'timeunitvalue'     The number of old units that the new unit is
%                           equal to.
%       If either spaceunitname or timeunitname is omitted or empty, no
%       change will be made to that unit.  spaceunitvalue and
%       timeunitvalue default to 1, i.e. no change.
%
%   Example:
%       Convert a leaf scaled in microns to millimetres, and from days to
%       hours:
%           m = leaf_rescale( m, 'spaceunitname', 'mm', ...
%                                'spaceunitvalue', 1000, ...
%                                'timeunitname', 'hour', ...
%                                'timeunitvalue', 1/24 );
%
%   Equivalent GUI operation: the 'Params/Rescale...' menu item.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'spaceunitname', '', 'spaceunitvalue', 1, ...
                          'timeunitname', '', 'timeunitvalue', 1 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'spaceunitname', 'spaceunitvalue', 'timeunitname', 'timeunitvalue' );
    if ~ok, return; end
    
    if isempty( s.spaceunitname )
        s.spaceunitvalue = 1;
    end
    if isempty( s.timeunitname )
        s.timeunitvalue = 1;
    end
    
    m = rescaleSpaceTime( m, s.spaceunitname, s.spaceunitvalue, ...
                             s.timeunitname, s.timeunitvalue );
end

