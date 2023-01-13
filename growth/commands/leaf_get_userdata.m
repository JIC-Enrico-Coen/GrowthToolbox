function ud = leaf_get_userdata( m, varargin )
%m = leaf_set_userdata( m, ... )
%   Get fields of the userdata of m. The arguments should be field names.
%   Field names that do not exist in the statuc usedata will be ignored.
%
%   You can store anything you like in the userdata field of the canvas.
%   The growth toolbox will never use it, but your own callbacks, such as
%   the morphogen interaction function, may want to make use of it.
%
%   See also: LEAF_ADD_USERDATA, LEAF_DELETE_USERDATA, LEAF_SET_USERDATA,
%       LEAF_ADD_USERDATASTATIC, LEAF_DELETE_USERDATASTATIC,
%       LEAF_SET_USERDATASTATIC.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data.

    ud = struct();
    if isempty(m), return; end
    
    ud = setFromStruct( [], m.userdata, varargin{:} );
end
