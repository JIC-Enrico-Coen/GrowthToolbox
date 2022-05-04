function userparams = cvt_convert_oldstyle_userargs( varargin )
    userparams = struct( 'usertype', varargin{1} );
    varargin(1) = [];
    switch userparams.usertype
        case { 'rectangle', 'testrectangle' }
            userparams.bbox = varargin{1};
        case 'semiellipse'
            userparams.bbox = varargin{1};
            userparams.axis = varargin{2};
        case 'ellipse'
            userparams.bbox = varargin{1};
        case 'polygon'
            userparams.poly = varargin{1};
        case { '', 'unitcircle', 'spheresurf' }
            % No options.
        case 'meshcells'
            userparams.mesh = varargin{1};
            userparams.elements = varargin{2};
        case 'triangles'
            userparams.vxs = varargin{1};
            userparams.trivxs = varargin{2};
            userparams.triareas = varargin{3};
            userparams.whichtris = varargin{4};
        otherwise
            userparams = [];
    end
end

