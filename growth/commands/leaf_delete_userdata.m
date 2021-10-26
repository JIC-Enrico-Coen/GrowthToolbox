function m = leaf_delete_userdata( m, varargin )
%m = leaf_delete_userdata( m, ... )
%   Delete specified fields from the userdata of m.  The arguments should
%   be strings.  If no strings are given, all the user data is deleted.
%
%   If a named field does not exist, it is ignored.
%
%   See also: LEAF_SET_USERDATA, LEAF_ADD_USERDATA, 
%       LEAF_ADD_USERDATASTATIC, LEAF_DELETE_USERDATASTATIC,
%       LEAF_SET_USERDATASTATIC.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data

    if isempty(m), return; end
    if isempty(varargin)
        m.userdata = struct();
    else
        for i=1:length(varargin)
            if ischar( varargin{i} )
                m.userdata = safermfield( m.userdata, varargin{i} );
            else
                fprintf( 1, '%s: non-string argument %d ignored.\n', mfilename(), i );
            end
        end
    end
end
