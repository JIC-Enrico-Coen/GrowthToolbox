function m = leaf_set_userdata( m, varargin )
%m = leaf_set_userdata( m, ... )
%   Set fields of the userdata of m.  The arguments should be alternately a
%   field name and a field value.
%
%   You can store anything you like in the userdata field of the canvas.
%   The growth toolbox will never use it, but your own callbacks, such as
%   the morphogen interaction function, may want to make use of it.
%
%   See also: LEAF_ADD_USERDATA, LEAF_DELETE_USERDATA, 
%       LEAF_ADD_USERDATASTATIC, LEAF_DELETE_USERDATASTATIC,
%       LEAF_SET_USERDATASTATIC.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    
    m.userdata = setFromStruct( m.userdata, s );
end
