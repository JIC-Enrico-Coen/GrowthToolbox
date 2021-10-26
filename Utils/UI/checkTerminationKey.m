function checkTerminationKey( hObject )
    if nargin==0
        hObject = gcbo();
    end
    if isempty(hObject), return; end
    dlg = getRootHandle(hObject);
    key = get(dlg,'CurrentKey');
    if isequal(key,'escape')
        % User said no by hitting escape
        exitDialog(hObject,false);
    elseif isequal(key,'return')
        % User said yes by hitting return
        exitDialog(hObject,true);
    end
    % Ignore all other keystrokes.
end
