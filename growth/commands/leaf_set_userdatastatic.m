function m = leaf_set_userdatastatic( m, varargin )
%m = leaf_set_userdatastatic( m, ... )
%   Set fields of the static userdata of m.  The arguments should be alternately a
%   field name and a field value.
%
%   The static userdata is contained in the field m.userdatastatic.  It is
%   saved in the static file of a project whenever
%   it is updated through one of these procedures, and loaded from there
%   whenever a stage file is loaded.  Thus the static userdata has a fixed
%   value throughout a project, while the non-static userdata has a
%   different value independently at each time step.
%
%   You can store anything you like in the static userdata field of the canvas.
%   The growth toolbox will never use it, but your own callbacks, such as
%   the morphogen interaction function, may want to make use of it.
%
%   See also: LEAF_ADD_USERDATASTATIC, LEAF_DELETE_USERDATASTATIC,
%       LEAF_ADD_USERDATA, LEAF_DELETE_USERDATA, leaf_set_userdata.
%
%   Equivalent GUI operation: none.
%
%   Topics: User data.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    
    m.userdatastatic = setFromStruct( m.userdatastatic, s );
    saveStaticPart( m );
end
