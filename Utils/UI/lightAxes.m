function lightAxes( theaxes, turnLightOn )
%lightAxes( theaxes, turnLightOn )
%   Turn lighting for the given axes object on or off.
%   To turn the light off, every child object of type 'light' is deleted.
%   To turn it on, if there is already a child object of type 'light',
%   nothing is done.  Otherwise a light is created with default properties.

    lights = findobj( theaxes, 'Type', 'light' );
    if turnLightOn
        if isempty( lights )
            setCamlight( theaxes, [], [], turnLightOn );
        end
    else
        delete( lights );
    end
end
