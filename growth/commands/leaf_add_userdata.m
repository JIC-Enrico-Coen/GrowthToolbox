function m = leaf_add_userdata( m, varargin )
%m = leaf_add_userdata( m, ... )
%   Add fields to the userdata of m.  The arguments should be alternately a
%   field name and a field value.  Existing fields of those names in
%   m.userdata will be left unchanged.
%
%   See also: leaf_set_userdata, leaf_delete_userdata, 
%       LEAF_ADD_USERDATASTATIC, LEAF_DELETE_USERDATASTATIC,
%       LEAF_SET_USERDATASTATIC.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    
    m.userdata = defaultFromStruct( m.userdata, s );
end
