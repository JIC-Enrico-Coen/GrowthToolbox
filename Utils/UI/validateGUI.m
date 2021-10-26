function ok = validateGUI( h, ancestors )
%ok = validateGUI( h )
%   Make validity checks of the GUI element h.

    if nargin < 2
        ancestors = '';
    end
    ok = true;
    htag = get( h, 'Tag' );
    ancestors = [ ancestors, '/', htag ];
    htype = get( h, 'Type' );
    switch htype
        case 'uicontrol'
            hstyle = get( h, 'Style' );
            switch hstyle
                case 'slider'
                    hmin = get( h, 'Min' );
                    hmax = get( h, 'Max' );
                    hvalue = get( h, 'Value' );
                    if (hvalue < hmin) || (hvalue > hmax)
                        fprintf( 1, '%s slider has invalid value: %f %f %f\n', ...
                            ancestors, hmin, hvalue, hmax );
                        ok = false;
                    end
                case 'checkbox'
                    hvalue = get( h, 'Value' );
                    if (hvalue ~= 0) && (hvalue ~= 1)
                        fprintf( 1, '%s checkbox has invalid value: %f\n', ...
                            ancestors, hvalue );
                        ok = false;
                    end
            end
    end
    hchildren = get( h, 'Children' );
    if ~isempty(hchildren)
        okc = false(1,length(hchildren));
        for i=1:length(hchildren)
            okc(i) = validateGUI( hchildren(i), ancestors );
        end
        ok = ok & all(okc);
    end
end
