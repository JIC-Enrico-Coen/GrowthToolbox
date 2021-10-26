function ok = tryset( h, varargin )
%ok = tryset( h, varargin )
%   Set attributes of a handle.  Do not crash if anything goes wrong, just
%   return a boolean to indicate success or failure.

    try
        set( h, varargin{:} );
        ok = true;
    catch e %#ok<NASGU>
        ok = false;
    end
end

