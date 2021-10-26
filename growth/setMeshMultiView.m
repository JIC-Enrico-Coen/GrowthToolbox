function setMeshMultiView( m, varargin ) % az, el, roll, camdistance )
%     noaz = isempty(az);
%     noel = isempty(el);
%     if nargin < 4
%         roll = [];
%     end
%     noroll = isempty(roll);
%     if nargin < 5
%         camdistance = [];
%     end
%     nocamdistance = isempty(camdistance);
%     if noaz && noel && noroll && nocamdistance, return; end
%     setMultiView( m.pictures, az, el, roll, camdistance );
    setMultiView( m.pictures, varargin{:} );
end
