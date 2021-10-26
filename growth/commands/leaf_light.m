function m = leaf_light( m, varargin )
%m = leaf_light( m, on )
%   Turn the scene light on or off.
%
%   Arguments:
%       on: boolean, true if the light is to be on.
%
%   Topics: Plotting.

    if isempty(m), return; end
    if isempty(varargin)
        fprintf( 1, '%s: Missing argument, boolean expected.\n', mfilename() );
        return;
    end
    if length(varargin) > 1
        fprintf( 1, '%s: One argument expected, %d extra arguments ignored.\n', ...
            mfilename(), length(varargin)-1 );
    end
    
    turnLightOn = varargin{1}==true;
    m.plotdefaults.light = turnLightOn;
    for i=1:length(m.pictures)
        h = guidata( m.pictures(i) );
        lightAxes( h.picture, turnLightOn );
    end
end
