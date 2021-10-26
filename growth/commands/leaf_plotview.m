function m = leaf_plotview( m, varargin )
%m = leaf_plotview( m, ... )
%   Set the view parameters.
%
%   There are two sets of parameters with which the view can be described:
%   1. The parameters that Matlab itself uses:
%       CameraViewAngle
%       CameraTarget
%       CameraPosition
%       CameraUpVector
%   2. An alternative set that is sometimes more convenient:
%       fov (field of view)
%       azimuth
%       elevation
%       roll
%       pan (two components)
%       targetdistance (the distance that CameraTarget is behind the plane
%           perpendicular to the view direction through the origin of
%           coordinates)
%       camdistance (the distance that CameraTarget is in front of the
%           plane perpendicular to the view direction through the origin
%           of coordinates)
%   Both sets of parameters are maintained in the mesh structure.
%
%   For example, to set an overhead view:
%
%       m = leaf_plotview( m, 'azimuth', 0, 'elevation', 90, 'roll', 0 );
%
%   Topics: Plotting.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    
    matlabCamParams = { 'CameraViewAngle', ...
                        'CameraTarget', ...
                        'CameraPosition', ...
                        'CameraUpVector' };
    ourCamParams = { 'fov', ...
                     'azimuth', ...
                     'elevation', ...
                     'roll', ...
                     'pan', ...
                     'targetdistance', ...
                     'camdistance' };
    
    ok = checkcommandargs( mfilename(), s, 'only', ...
            matlabCamParams{:}, ourCamParams{:}, ...
            'matlabViewParams', 'ourViewParams');
    
    haveMatlabParam = false;
    haveOurParam = false;
    passedMatlabParams = struct();
    passedOurParams = struct();
    
    if isfield( s, 'matlabViewParams' )
        haveMatlabParam = true;
        passedMatlabParams = s.matlabViewParams;
    else
        for i=1:length(matlabCamParams)
            n = matlabCamParams{i};
            if isfield( s, n )
                haveMatlabParam = true;
                passedMatlabParams.(n) = s.(n);
            end
        end
    end
    
    if isfield( s, 'ourViewParams' )
        haveOurParam = true;
        passedOurParams = s.ourViewParams;
    else
        for i=1:length(ourCamParams)
            n = ourCamParams{i};
            if isfield( s, n )
                haveOurParam = true;
                passedOurParams.(n) = s.(n);
            end
        end
    end

    if haveOurParam
        ourParams = getOurViewParams( m );
        ourParams = setFromStruct( ourParams, passedOurParams );
        m = setOurViewParams( m, ourParams );
    end
    
    if haveMatlabParam
        matlabParams = getMatlabViewParams( m );
        matlabParams = setFromStruct( matlabParams, passedMatlabParams );
        m = setMatlabViewParams( m, matlabParams );
    end
    
    if haveMatlabParam || haveOurParam
        saveStaticPart( m );
    end
end
