function v = newversioninfo( meshversion, mgenversion, matlabversion )
%v = newversioninfo( version )
%   Create version info.

    v = struct( 'meshversion', meshversion, ...
                'mgenversion', mgenversion, ...
                'matlabversion', matlabversion );
end
