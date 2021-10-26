function m = leaf_delete_userdatastatic( m, varargin )
%m = leaf_delete_userdatastatic( m, ... )
%   Delete specified fields from the userdata of m.  The arguments should
%   be strings.  If no strings are given, all the user data is deleted.
%
%   If a named field does not exist, it is ignored.
%
%   The static userdata is contained in the field m.userdatastatic.  It is
%   saved in the static file of a project whenever
%   it is updated through one of these procedures, and loaded from there
%   whenever a stage file is loaded.  Thus the static userdata has a fixed
%   value throughout a project, while the non-static userdata has a
%   different value independently at each time step.
%
%   See also: leaf_set_userdatastatic, leaf_add_userdatastatic,
%       LEAF_SET_USERDATA, LEAF_ADD_USERDATA, leaf_delete_userdata.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data

    if isempty(m), return; end
    if isempty(varargin)
        m.userdatastatic = struct();
    else
        for i=1:length(varargin)
            if ischar( varargin{i} )
                m.userdatastatic = safermfield( m.userdatastatic, varargin{i} );
            else
                fprintf( 1, '%s: non-string argument %d ignored.\n', mfilename(), i );
            end
        end
    end
    saveStaticPart( m );
end
