function v = getUIFlag( h )
%v = getUIFlag( h )
%   Return the value of a checkbox, radio button, or toggle button as a
%   boolean.

    v = logical( get( h, 'Value' ) );
end