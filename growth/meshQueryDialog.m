function result = meshQueryDialog( m, numbuttons, title, format, varargin )
%result = meshQueryDialog( m, numbuttons, format, varargin )
%   If m is being run interactively, ask the user the question and return
%   the user's response.  Otherwise, don't ask, and return 1 (the OK button).

    if m.globalProps.interactive
        result = queryDialog( numbuttons, format, varargin );
    else
        result = 1;
    end
end
