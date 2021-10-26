function s = callbackName( hObject, fnName )
    if nargin < 2, fnName = 'Callback'; end
    callbackString = get( hObject, fnName );
    match = regexp( callbackString, '''(?<name>[^'']+)''', 'names' );
    s = match.name;
end
