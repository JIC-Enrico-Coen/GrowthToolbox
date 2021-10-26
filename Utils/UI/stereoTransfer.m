function [CameraPosition, CameraTarget, CameraUpVector] = stereoTransfer( varargin )
%[CameraPosition, CameraTarget, CameraUpVector] = stereoTransfer( varargin )
%   Set the viewpoint of one axes to that of another, rotated about the
%   camera up vector.
%
%   stereoTransfer(AX) will transfer the view of the axes AX to the axes
%       contained in AX's guidata element stereodata.otheraxes, rotated by
%       stereodata.vergence (an angle in radians).
%   stereoTransfer() is equivalent to stereoTransfer(gca).
%   stereoTransfer( AX1, AX2, VERGENCE ) will transfer the view from AX1 to
%       AX2, offset by the angle VERGENCE.
%   stereoTransfer( AX, POSITION, TARGET, UP, VERGENCE ) will set the view
%       of the axes AX to the result of offsetting the view by a rotation
%       about UP by VERGENCE, from the view specified by the given camera
%       POSITION, TARGET, and UP vectors.
%
%   In all cases, vergence must be an angle in radians.  If the view is
%   being transferred from the left eye to the right eye, vergence should
%   be positive.  If the distance between someone's eye is E and they are
%   a distance D from the screen, vergence should be E/D radians.
%
%   The resulting view is returned in the output arguments.

    narginchk(0,5);
    theaxes = [];
    switch nargin
        case { 0, 1 }
            if nargin==0
                theaxes = gca;
            else
                theaxes = varargin{1};
            end
            CameraPosition = get( theaxes,'CameraPosition' );
            CameraTarget = get( theaxes,'CameraTarget' );
            CameraUpVector = get( theaxes,'CameraUpVector' );
            gd = guidata( theaxes );
            if isempty(gd), return; end
            if ~isfield( gd, 'stereodata' ), return; end
            sd = gd.stereodata;
            otheraxes = sd.otheraxes;
            vergence = sd.vergence;
        case 3
            theaxes = varargin{1};
            CameraPosition = get( theaxes,'CameraPosition' );
            CameraTarget = get( theaxes,'CameraTarget' );
            CameraUpVector = get( theaxes,'CameraUpVector' );
            otheraxes = varargin{2};
            vergence = varargin{3};
        case 5
            otheraxes = varargin{1};
            CameraPosition = varargin{2};
            CameraTarget = varargin{3};
            CameraUpVector = varargin{4};
            vergence = varargin{5};
        otherwise
            error( 'stereoTransfer: wrong number of arguments, 3 or 5 expected.' );
    end
    CameraUpVector = makeperp( CameraTarget-CameraPosition, CameraUpVector );
    CameraUpVector = CameraUpVector/norm(CameraUpVector);

    % Rotate Position about Up by vergence
    CameraPosition = rotVec( CameraPosition, CameraTarget, CameraUpVector, vergence );
    set( otheraxes, ...
        'CameraPosition', CameraPosition, ...
        'CameraTarget', CameraTarget, ...
        'CameraUpVector', CameraUpVector, ...
        'CameraPositionMode', 'manual', ...
        'CameraTargetMode', 'manual', ...
        'CameraUpVectorMode', 'manual', ...
        'CameraViewAngleMode', 'manual', ...
        'DataAspectRatio', [1 1 1], ...
        'DataAspectRatioMode', 'manual', ...
        'PlotBoxAspectRatio',[1 1 1], ...
        'PlotBoxAspectRatioMode', 'manual' );
    if theaxes
        set( theaxes, 'CameraUpVector', CameraUpVector );
        set( otheraxes, 'CameraViewAngle', get( theaxes,'CameraViewAngle' ) );
    end
end
