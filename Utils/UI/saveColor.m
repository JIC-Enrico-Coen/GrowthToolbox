function saveColor( h )
%saveColor( h )
%   Store the color attributes of h in its UserData,
%   so that if we have occasion to temporarily change the colors, we can later
%   restore the original values.

    c = tryget( h, { 'BackgroundColor', 'ForegroundColor', 'Color' } );
    % c is a struct containing those of the requested fields that exist in
    % h.
    set( h, 'UserData', c );
end
