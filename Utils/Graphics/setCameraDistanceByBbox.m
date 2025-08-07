function [cameraParams,axbbox] = setCameraDistanceByBbox( ax, varargin )
%setCameraDistanceByBbox( ax, option, value, option, value, ... )
%   Set the distance of the camera from its target so as to ensure that the
%   whole axes object is in view. The options specify how the desired
%   result is specified.
%
%   'distance': The absolute distance of the camera from its target point.
%   The camera is moved along its direction of view to ensure this.
%
%   'relmargin': The distance of the farthest point of the axis bounding
%   box from the camera target is found, and multiplied by 1 + the number
%   specified.
%
%   'absmargin': The distance of the farthest point of the axis bounding
%   box from the camera target is found, to which is added the number
%   specified.
%
%   'at': This specifies whether the target point should be moved. If the
%   option is not given, the target point is not moved. If it is 'origin',
%   the target is moved to the origin. If it is 'centre' or 'center', the
%   target point is moved to the centre of the bounding box.
%
%   'bboxmode': If present, this specifies whether the axis bounding box
%   should include the axis ranges, the data ranges, or both, in the same
%   way as for getAxBoundingBox.
%
%   SEE ALSO: getAxBoundingBox


    cameraParams = [];
    axbbox = [];
    if ~ishghandle(ax)
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'bboxmode', '', 'setaxislimits', false );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'bbox', 'distance', 'relmargin', 'absmargin', 'at', 'bboxmode', 'setaxislimits' );
    if ~ok, return; end
    if isempty(s) || isempty(fieldnames(s))
        return;
    end
    
    cameraParams = getCameraParams( ax );
    
    if isfield( s, 'distance' )
        d = s.distance;
    else
        if isfield( s, 'bbox' )
            axbbox = s.bbox;
        else
            axbbox = getAxBoundingBox( ax, 'data', s.bboxmode );
        end
        bboxcorners = axbbox( [1 2 3;1 2 6;1 5 3;1 5 6;4 2 3;4 2 6;4 5 3;4 5 6] );
        cornerDistances = sqrt( sum( (bboxcorners - cameraParams.CameraTarget).^2, 2 ) );
        d = max( cornerDistances );
        if isfield( s, 'relmargin' )
            d = d * (1 + s.relmargin);
        elseif isfield( s, 'absmargin' )
            d = d + s.absmargin;
        end
    end

    if isfield( s, 'at' )
        newTarget = cameraParams.CameraTarget;
        switch s.at
            case 'origin'
                newTarget = [0 0 0];
            case { 'centre', 'center' }
                newTarget = (axbbox(1,:) + axbbox(2,:))/2;
            otherwise
                % Ignore.
        end
        if any( newTarget ~= cameraParams.CameraTarget )
            vecToCamera = cameraParams.CameraPosition - cameraParams.CameraTarget;
            cameraParams.CameraTarget = newTarget;
            cameraParams.CameraPosition = newTarget + vecToCamera;
            setCameraParams( ax, cameraParams.CameraTarget );
        end
            
    end
    setCameraDistance( ax, d );
end
