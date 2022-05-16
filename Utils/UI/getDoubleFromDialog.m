function [x,ok] = getDoubleFromDialog( varargin )
%[x,ok] = getDoubleFromDialog( varargin )
%   
    s = get( varargin{1}, 'String' );
    ud = get( varargin{1}, 'UserData' );
    
    if isfield( ud, 'datainfo' )
        name = ud.datainfo;
    else
        name = '';
    end
    
    [x,ok] = getDoubleFromString( name, s, varargin{2:nargin} );
end
