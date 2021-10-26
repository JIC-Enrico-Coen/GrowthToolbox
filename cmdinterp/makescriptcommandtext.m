function s = makescriptcommandtext( commandname, replaceM, varargin )
    s = [ 'm = leaf_' commandname '(' ];
    if replaceM
        s = [ s ' []' ];
    else
        s = [ s ' m' ];
    end
    if ~isempty( varargin )
        for i=1:length(varargin)
            s = [ s ', ' argToScriptString( varargin{i} ) ];
        end
    end
    s = [ s ' );' char(10) ];
end
