function m = leaf_add_userdatastatic( m, varargin )
%m = leaf_add_userdatastatic( m, ... )
%   Add fields to the static userdata of m.  The arguments should be alternately a
%   field name and a field value.  Existing fields of those names in
%   m.userdatastatic will be left unchanged.
%
%   The static userdata is contained in the field m.userdatastatic.  It is
%   saved in the static file of a project whenever
%   it is updated through one of these procedures, and loaded from there
%   whenever a stage file is loaded.  Thus the static userdata has a fixed
%   value throughout a project, while the non-static userdata has a
%   different value independently at each time step.
%
%   See also: leaf_set_userdatastatic, leaf_delete_userdatastatic,
%       leaf_set_userdata, leaf_delete_userdata, leaf_add_userdata.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    
    m.userdatastatic = defaultFromStruct( m.userdatastatic, s );
    saveStaticPart( m );
end
