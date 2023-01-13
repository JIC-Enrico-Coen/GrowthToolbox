function s = combineStructs( varargin )
    if nargin==0
        s = struct();
    else
        s = varargin{1};
        for i=2:nargin
            s = setFromStruct( s, varargin{i} );
        end
    end
end