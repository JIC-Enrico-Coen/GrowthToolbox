function s = optionsFromGui( varargin )
    s = [];
    h = getGFtboxHandles;
    if isempty(h)
        return;
    end
    
    for i=1:2:length(varargin)
        fieldname = varargin{i};
        handlename = varargin{i+1};
        if ~isfield( h, handlename ) || ~ishandle( h.(handlename) )
            continue;
        end
        s.(fieldname) = getGuiItemValue( h.(handlename) );
    end
end