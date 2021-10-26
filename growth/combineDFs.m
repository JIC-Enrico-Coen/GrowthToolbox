function dfs = combineDFs( x, y, z )
%dfs = combineDFs( x, y, z )

    dfs = unique( [ x*3-2, y*3-1, z*3 ] );
end
