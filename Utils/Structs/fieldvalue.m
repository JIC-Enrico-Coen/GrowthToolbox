function v = fieldvalue( s, f, default )
%v = fieldvalue( s, f )
%   Set v to s.(f) if s has such a field, otherwise to the default if there
%   is one, otherwise to [].

    if isfield( s, f )
        v = s.(f);
    elseif nargin >= 3
        v = default;
    else
        v = [];
    end
end
